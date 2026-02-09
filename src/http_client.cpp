/**
 * ===========================================================================
 * LEVYTHON HTTP CLIENT IMPLEMENTATION
 * ===========================================================================
 */

#include "http_client.hpp"
#include <cstring>
#include <sstream>
#include <chrono>
#include <iomanip>
#include <array>
#include <cstdlib>

#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#endif

namespace {

std::string get_openssl_error_string() {
  unsigned long err = ERR_get_error();
  if (err == 0) {
    return "";
  }
  char err_buf[256];
  ERR_error_string_n(err, err_buf, sizeof(err_buf));
  return std::string(err_buf);
}

#ifdef __APPLE__
bool load_macos_system_roots(SSL_CTX *ctx) {
  if (!ctx) {
    return false;
  }

  CFArrayRef anchors = nullptr;
  OSStatus status = SecTrustCopyAnchorCertificates(&anchors);
  if (status != errSecSuccess || anchors == nullptr) {
    return false;
  }

  X509_STORE *store = SSL_CTX_get_cert_store(ctx);
  if (!store) {
    CFRelease(anchors);
    return false;
  }

  bool loaded_any = false;
  CFIndex count = CFArrayGetCount(anchors);
  for (CFIndex i = 0; i < count; ++i) {
    auto cert = (SecCertificateRef)CFArrayGetValueAtIndex(anchors, i);
    if (!cert) {
      continue;
    }

    CFDataRef cert_data = SecCertificateCopyData(cert);
    if (!cert_data) {
      continue;
    }

    const unsigned char *ptr = CFDataGetBytePtr(cert_data);
    long len = CFDataGetLength(cert_data);
    X509 *x509 = d2i_X509(nullptr, &ptr, len);
    if (x509) {
      // Add certificate; ignore duplicates.
      if (X509_STORE_add_cert(store, x509) == 1) {
        loaded_any = true;
      } else {
        unsigned long err = ERR_peek_last_error();
        if (ERR_GET_LIB(err) == ERR_LIB_X509 &&
            ERR_GET_REASON(err) == X509_R_CERT_ALREADY_IN_HASH_TABLE) {
          loaded_any = true;
        }
        ERR_clear_error();
      }
      X509_free(x509);
    }

    CFRelease(cert_data);
  }

  CFRelease(anchors);
  return loaded_any;
}
#endif

} // namespace

namespace levython {
namespace http {

// ============================================================================
// WINDOWS WINSOCK INITIALIZATION
// ============================================================================

#ifdef _WIN32
class WinSockInitializer {
public:
  WinSockInitializer() {
    WSADATA wsa_data;
    if (WSAStartup(MAKEWORD(2, 2), &wsa_data) != 0) {
      throw std::runtime_error("Failed to initialize WinSock");
    }
  }
  ~WinSockInitializer() { WSACleanup(); }
};

static WinSockInitializer winsock_init;
#endif

// ============================================================================
// ERROR IMPLEMENTATION
// ============================================================================

std::string HttpError::to_string() const {
  std::ostringstream oss;
  switch (type) {
  case HttpErrorType::NONE:
    return "No error";
  case HttpErrorType::NETWORK:
    oss << "Network error: " << message;
    break;
  case HttpErrorType::TLS:
    oss << "TLS error: " << message;
    break;
  case HttpErrorType::HTTP:
    oss << "HTTP error " << code << ": " << message;
    break;
  case HttpErrorType::PROTOCOL:
    oss << "Protocol error: " << message;
    break;
  case HttpErrorType::TIMEOUT:
    oss << "Timeout: " << message;
    break;
  case HttpErrorType::TOO_LARGE:
    oss << "Response too large: " << message;
    break;
  case HttpErrorType::REDIRECT_LOOP:
    oss << "Redirect loop: " << message;
    break;
  }
  if (code != 0 && type != HttpErrorType::HTTP) {
    oss << " (code: " << code << ")";
  }
  return oss.str();
}

// ============================================================================
// URL PARSER IMPLEMENTATION
// ============================================================================

HttpError ParsedURL::parse(const std::string &url, ParsedURL &result) {
  // Parse URL: scheme://host:port/path?query

  size_t pos = 0;

  // Extract scheme
  size_t scheme_end = url.find("://", pos);
  if (scheme_end == std::string::npos) {
    return HttpError(HttpErrorType::PROTOCOL, "Invalid URL: missing scheme");
  }

  result.scheme = url.substr(0, scheme_end);
  std::transform(result.scheme.begin(), result.scheme.end(),
                 result.scheme.begin(), ::tolower);

  if (result.scheme != "http" && result.scheme != "https") {
    return HttpError(HttpErrorType::PROTOCOL,
                     "Unsupported scheme: " + result.scheme);
  }

  result.is_https = (result.scheme == "https");
  result.port = result.is_https ? 443 : 80;

  pos = scheme_end + 3; // Skip "://"

  // Extract host and port
  size_t path_start = url.find('/', pos);
  size_t query_start = url.find('?', pos);
  size_t host_end = std::min(path_start, query_start);
  if (host_end == std::string::npos) {
    host_end = url.length();
  }

  std::string host_part = url.substr(pos, host_end - pos);

  // Check for port
  size_t port_sep = host_part.find(':');
  if (port_sep != std::string::npos) {
    result.host = host_part.substr(0, port_sep);
    std::string port_str = host_part.substr(port_sep + 1);
    try {
      result.port = std::stoi(port_str);
      if (result.port <= 0 || result.port > 65535) {
        return HttpError(HttpErrorType::PROTOCOL, "Invalid port number");
      }
    } catch (...) {
      return HttpError(HttpErrorType::PROTOCOL, "Invalid port number");
    }
  } else {
    result.host = host_part;
  }

  if (result.host.empty()) {
    return HttpError(HttpErrorType::PROTOCOL, "Empty hostname");
  }

  // Extract path and query
  if (path_start != std::string::npos) {
    if (query_start != std::string::npos && query_start > path_start) {
      result.path = url.substr(path_start, query_start - path_start);
      result.query = url.substr(query_start + 1);
    } else {
      result.path = url.substr(path_start);
    }
  } else {
    result.path = "/";
    if (query_start != std::string::npos) {
      result.query = url.substr(query_start + 1);
    }
  }

  return HttpError(); // Success
}

// ============================================================================
// SOCKET IMPLEMENTATION
// ============================================================================

HttpSocket::HttpSocket() : connected_(false) {
#ifdef _WIN32
  sock_ = INVALID_SOCKET;
#else
  sock_ = -1;
#endif
}

HttpSocket::~HttpSocket() { close(); }

HttpError HttpSocket::connect(const std::string &host, int port, int timeout_ms) {
  // Resolve hostname
  struct addrinfo hints, *result = nullptr, *rp = nullptr;
  std::memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;     // IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP
  hints.ai_protocol = IPPROTO_TCP;

  std::string port_str = std::to_string(port);
  int status = getaddrinfo(host.c_str(), port_str.c_str(), &hints, &result);
  if (status != 0) {
#ifdef _WIN32
    return HttpError(HttpErrorType::NETWORK,
                     "DNS resolution failed: " + std::string(gai_strerror(status)));
#else
    return HttpError(HttpErrorType::NETWORK,
                     "DNS resolution failed: " + std::string(gai_strerror(status)));
#endif
  }

  // Try each address until connection succeeds
  HttpError last_error;
  for (rp = result; rp != nullptr; rp = rp->ai_next) {
    sock_ = ::socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
#ifdef _WIN32
    if (sock_ == INVALID_SOCKET)
      continue;
#else
    if (sock_ < 0)
      continue;
#endif

    // Set non-blocking for timeout support
    HttpError err = set_nonblocking();
    if (err.has_error()) {
      close();
      continue;
    }

    // Attempt connection
    int conn_result = ::connect(sock_, rp->ai_addr, rp->ai_addrlen);

#ifdef _WIN32
    if (conn_result == SOCKET_ERROR) {
      int error = WSAGetLastError();
      if (error != WSAEWOULDBLOCK) {
        last_error = HttpError(HttpErrorType::NETWORK,
                               "Connection failed", error);
        close();
        continue;
      }
#else
    if (conn_result < 0) {
      if (errno != EINPROGRESS) {
        last_error = HttpError(HttpErrorType::NETWORK,
                               "Connection failed: " + std::string(strerror(errno)),
                               errno);
        close();
        continue;
      }
#endif
      // Wait for connection with timeout
      err = wait_for_io(false, timeout_ms); // false = wait for write (connect)
      if (err.has_error()) {
        last_error = err;
        close();
        continue;
      }

      // Check if connection succeeded
#ifdef _WIN32
      int sock_err = 0;
      socklen_t len = sizeof(sock_err);
      if (getsockopt(sock_, SOL_SOCKET, SO_ERROR, (char *)&sock_err, &len) < 0) {
        last_error = HttpError(HttpErrorType::NETWORK, "getsockopt failed");
        close();
        continue;
      }
      if (sock_err != 0) {
        last_error = HttpError(HttpErrorType::NETWORK, "Connection failed", sock_err);
        close();
        continue;
      }
#else
      int sock_err = 0;
      socklen_t len = sizeof(sock_err);
      if (getsockopt(sock_, SOL_SOCKET, SO_ERROR, &sock_err, &len) < 0) {
        last_error = HttpError(HttpErrorType::NETWORK,
                               "getsockopt failed: " + std::string(strerror(errno)));
        close();
        continue;
      }
      if (sock_err != 0) {
        last_error = HttpError(HttpErrorType::NETWORK,
                               "Connection failed: " + std::string(strerror(sock_err)),
                               sock_err);
        close();
        continue;
      }
#endif
    }

    // Connection successful
    connected_ = true;
    break;
  }

  freeaddrinfo(result);

  if (!connected_) {
    return last_error.has_error() ? last_error
                                   : HttpError(HttpErrorType::NETWORK,
                                               "Could not connect to host");
  }

  return HttpError(); // Success
}

HttpError HttpSocket::send(const void *data, size_t len) {
  if (!connected_) {
    return HttpError(HttpErrorType::NETWORK, "Socket not connected");
  }

  size_t total_sent = 0;
  const char *ptr = static_cast<const char *>(data);

  while (total_sent < len) {
#ifdef _WIN32
    int sent = ::send(sock_, ptr + total_sent, (int)(len - total_sent), 0);
    if (sent == SOCKET_ERROR) {
      int error = WSAGetLastError();
      if (error == WSAEWOULDBLOCK) {
        // Wait for socket to be writable
        HttpError err = wait_for_io(false, DEFAULT_TIMEOUT_MS);
        if (err.has_error())
          return err;
        continue;
      }
      return HttpError(HttpErrorType::NETWORK, "Send failed", error);
    }
#else
    ssize_t sent = ::send(sock_, ptr + total_sent, len - total_sent, 0);
    if (sent < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        // Wait for socket to be writable
        HttpError err = wait_for_io(false, DEFAULT_TIMEOUT_MS);
        if (err.has_error())
          return err;
        continue;
      }
      return HttpError(HttpErrorType::NETWORK,
                       "Send failed: " + std::string(strerror(errno)), errno);
    }
#endif
    total_sent += sent;
  }

  return HttpError(); // Success
}

HttpError HttpSocket::recv(void *buffer, size_t len, size_t &bytes_read,
                           int timeout_ms) {
  if (!connected_) {
    return HttpError(HttpErrorType::NETWORK, "Socket not connected");
  }

  bytes_read = 0;

  // Wait for data with timeout
  HttpError err = wait_for_io(true, timeout_ms);
  if (err.has_error())
    return err;

#ifdef _WIN32
  int received = ::recv(sock_, static_cast<char *>(buffer), (int)len, 0);
  if (received == SOCKET_ERROR) {
    int error = WSAGetLastError();
    if (error == WSAEWOULDBLOCK) {
      return HttpError(HttpErrorType::TIMEOUT, "Receive timeout");
    }
    return HttpError(HttpErrorType::NETWORK, "Receive failed", error);
  }
#else
  ssize_t received = ::recv(sock_, buffer, len, 0);
  if (received < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return HttpError(HttpErrorType::TIMEOUT, "Receive timeout");
    }
    return HttpError(HttpErrorType::NETWORK,
                     "Receive failed: " + std::string(strerror(errno)), errno);
  }
#endif

  bytes_read = static_cast<size_t>(received);
  return HttpError(); // Success
}

void HttpSocket::close() {
  if (connected_) {
#ifdef _WIN32
    closesocket(sock_);
    sock_ = INVALID_SOCKET;
#else
    ::close(sock_);
    sock_ = -1;
#endif
    connected_ = false;
  }
}

HttpError HttpSocket::set_nonblocking() {
#ifdef _WIN32
  u_long mode = 1; // Non-blocking
  if (ioctlsocket(sock_, FIONBIO, &mode) != 0) {
    return HttpError(HttpErrorType::NETWORK, "Failed to set non-blocking mode");
  }
#else
  int flags = fcntl(sock_, F_GETFL, 0);
  if (flags < 0) {
    return HttpError(HttpErrorType::NETWORK,
                     "fcntl F_GETFL failed: " + std::string(strerror(errno)));
  }
  if (fcntl(sock_, F_SETFL, flags | O_NONBLOCK) < 0) {
    return HttpError(HttpErrorType::NETWORK,
                     "fcntl F_SETFL failed: " + std::string(strerror(errno)));
  }
#endif
  return HttpError(); // Success
}

HttpError HttpSocket::wait_for_io(bool for_read, int timeout_ms) {
  fd_set fds;
  FD_ZERO(&fds);
  FD_SET(sock_, &fds);

  struct timeval tv;
  tv.tv_sec = timeout_ms / 1000;
  tv.tv_usec = (timeout_ms % 1000) * 1000;

  int result;
  if (for_read) {
    result = select((int)sock_ + 1, &fds, nullptr, nullptr, &tv);
  } else {
    result = select((int)sock_ + 1, nullptr, &fds, nullptr, &tv);
  }

  if (result < 0) {
#ifdef _WIN32
    return HttpError(HttpErrorType::NETWORK, "select failed", WSAGetLastError());
#else
    return HttpError(HttpErrorType::NETWORK,
                     "select failed: " + std::string(strerror(errno)), errno);
#endif
  }

  if (result == 0) {
    return HttpError(HttpErrorType::TIMEOUT,
                     for_read ? "Read timeout" : "Write timeout");
  }

  return HttpError(); // Success
}

// ============================================================================
// TLS/SSL IMPLEMENTATION
// ============================================================================

bool HttpTLS::ssl_initialized_ = false;

void HttpTLS::init_openssl() {
  if (!ssl_initialized_) {
    SSL_load_error_strings();
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    ssl_initialized_ = true;
  }
}

void HttpTLS::cleanup_openssl() {
  if (ssl_initialized_) {
    EVP_cleanup();
    ERR_free_strings();
  }
}

HttpTLS::HttpTLS() : ctx_(nullptr), ssl_(nullptr), socket_(nullptr), connected_(false) {
  init_openssl();
}

HttpTLS::~HttpTLS() { close(); }

HttpError HttpTLS::connect(HttpSocket *socket, const std::string &hostname,
                           bool verify_cert) {
  if (!socket || !socket->is_connected()) {
    return HttpError(HttpErrorType::NETWORK, "Invalid socket");
  }

  socket_ = socket;

  // Create SSL context
  const SSL_METHOD *method = TLS_client_method();
  ctx_ = SSL_CTX_new(method);
  if (!ctx_) {
    return HttpError(HttpErrorType::TLS, "Failed to create SSL context");
  }

  // Set options for security
  long ssl_opts = SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3;
#ifdef SSL_OP_IGNORE_UNEXPECTED_EOF
  // OpenSSL 3 compatibility: tolerate peers that omit close_notify.
  ssl_opts |= SSL_OP_IGNORE_UNEXPECTED_EOF;
#endif
  SSL_CTX_set_options(ctx_, ssl_opts);
  SSL_CTX_set_mode(ctx_, SSL_MODE_AUTO_RETRY);

  if (verify_cert) {
    SSL_CTX_set_verify(ctx_, SSL_VERIFY_PEER, nullptr);
    bool ca_loaded = SSL_CTX_set_default_verify_paths(ctx_) == 1;

    // Fallback CA bundle locations (helps with non-standard OpenSSL installs)
    if (!ca_loaded) {
      const char *env_cert_file = std::getenv("SSL_CERT_FILE");
      const char *env_cert_dir = std::getenv("SSL_CERT_DIR");
      if (env_cert_file || env_cert_dir) {
        if (SSL_CTX_load_verify_locations(ctx_, env_cert_file, env_cert_dir) == 1) {
          ca_loaded = true;
        }
      }
    }

    if (!ca_loaded) {
      static const std::array<const char *, 6> kCaBundlePaths = {
          "/etc/ssl/cert.pem",                            // macOS common
          "/private/etc/ssl/cert.pem",                    // macOS alt
          "/etc/ssl/certs/ca-certificates.crt",           // Debian/Ubuntu
          "/etc/pki/tls/certs/ca-bundle.crt",             // RHEL/CentOS
          "/etc/ssl/ca-bundle.pem",                       // SUSE/OpenSUSE
          "/usr/local/etc/openssl@3/cert.pem"};           // Homebrew OpenSSL
      for (const char *path : kCaBundlePaths) {
        if (SSL_CTX_load_verify_locations(ctx_, path, nullptr) == 1) {
          ca_loaded = true;
          break;
        }
      }
    }

#ifdef __APPLE__
    // On macOS, also load roots from Keychain to match system trust behavior.
    if (load_macos_system_roots(ctx_)) {
      ca_loaded = true;
    }
#endif

    if (!ca_loaded) {
      return HttpError(HttpErrorType::TLS,
                       "Could not load system CA certificates for TLS verification");
    }
  } else {
    SSL_CTX_set_verify(ctx_, SSL_VERIFY_NONE, nullptr);
  }

  // Create SSL object
  ssl_ = SSL_new(ctx_);
  if (!ssl_) {
    return HttpError(HttpErrorType::TLS, "Failed to create SSL object");
  }

  // Set hostname for SNI
  SSL_set_tlsext_host_name(ssl_, hostname.c_str());

  // Enable hostname verification at TLS layer when cert verification is enabled.
  if (verify_cert) {
#if OPENSSL_VERSION_NUMBER >= 0x10100000L
    if (SSL_set1_host(ssl_, hostname.c_str()) != 1) {
      return HttpError(HttpErrorType::TLS, "Failed to set TLS hostname verification");
    }
#else
    X509_VERIFY_PARAM *param = SSL_get0_param(ssl_);
    X509_VERIFY_PARAM_set_hostflags(param, 0);
    if (X509_VERIFY_PARAM_set1_host(param, hostname.c_str(), 0) != 1) {
      return HttpError(HttpErrorType::TLS, "Failed to set TLS hostname verification");
    }
#endif
  }

  // Attach socket
  SSL_set_fd(ssl_, (int)socket_->native_handle());

  // Perform handshake (non-blocking sockets may return WANT_READ/WANT_WRITE)
  auto deadline =
      std::chrono::steady_clock::now() + std::chrono::milliseconds(DEFAULT_CONNECT_TIMEOUT_MS);
  while (true) {
    int ret = SSL_connect(ssl_);
    if (ret == 1) {
      break;
    }

    int ssl_error = SSL_get_error(ssl_, ret);
    if (ssl_error == SSL_ERROR_WANT_READ || ssl_error == SSL_ERROR_WANT_WRITE) {
      auto now = std::chrono::steady_clock::now();
      if (now >= deadline) {
        return HttpError(HttpErrorType::TIMEOUT, "TLS handshake timeout");
      }
      int remaining_ms = static_cast<int>(
          std::chrono::duration_cast<std::chrono::milliseconds>(deadline - now).count());
      if (remaining_ms < 1)
        remaining_ms = 1;
      HttpError io_wait_err = socket_->wait_for_io(ssl_error == SSL_ERROR_WANT_READ, remaining_ms);
      if (io_wait_err.has_error()) {
        return io_wait_err;
      }
      continue;
    }

    std::string openssl_msg = get_openssl_error_string();
    if (openssl_msg.empty()) {
      openssl_msg = "TLS handshake failed (SSL error " + std::to_string(ssl_error) + ")";
    }
    return HttpError(HttpErrorType::TLS, openssl_msg, ssl_error);
  }

  // Verify certificate if requested
  if (verify_cert) {
    HttpError err = verify_certificate(hostname);
    if (err.has_error())
      return err;
  }

  connected_ = true;
  return HttpError(); // Success
}

HttpError HttpTLS::send(const void *data, size_t len) {
  if (!connected_ || !ssl_) {
    return HttpError(HttpErrorType::TLS, "SSL not connected");
  }

  size_t total_sent = 0;
  const char *ptr = static_cast<const char *>(data);
  auto deadline =
      std::chrono::steady_clock::now() + std::chrono::milliseconds(DEFAULT_TIMEOUT_MS);

  while (total_sent < len) {
    int sent = SSL_write(ssl_, ptr + total_sent, (int)(len - total_sent));
    if (sent <= 0) {
      int ssl_error = SSL_get_error(ssl_, sent);
      if (ssl_error == SSL_ERROR_WANT_WRITE || ssl_error == SSL_ERROR_WANT_READ) {
        auto now = std::chrono::steady_clock::now();
        if (now >= deadline) {
          return HttpError(HttpErrorType::TIMEOUT, "SSL write timeout");
        }
        int remaining_ms = static_cast<int>(
            std::chrono::duration_cast<std::chrono::milliseconds>(deadline - now).count());
        if (remaining_ms < 1)
          remaining_ms = 1;
        HttpError wait_err = socket_->wait_for_io(ssl_error == SSL_ERROR_WANT_READ, remaining_ms);
        if (wait_err.has_error()) {
          return wait_err;
        }
        continue;
      }
      std::string openssl_msg = get_openssl_error_string();
      if (openssl_msg.empty()) {
        openssl_msg = "SSL write failed (SSL error " + std::to_string(ssl_error) + ")";
      }
      return HttpError(HttpErrorType::TLS, openssl_msg, ssl_error);
    }
    total_sent += sent;
  }

  return HttpError(); // Success
}

HttpError HttpTLS::recv(void *buffer, size_t len, size_t &bytes_read,
                        int timeout_ms) {
  if (!connected_ || !ssl_) {
    return HttpError(HttpErrorType::TLS, "SSL not connected");
  }

  bytes_read = 0;

  auto deadline =
      std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);

  while (true) {
    auto now = std::chrono::steady_clock::now();
    if (now >= deadline) {
      return HttpError(HttpErrorType::TIMEOUT, "SSL read timeout");
    }
    int remaining_ms = static_cast<int>(
        std::chrono::duration_cast<std::chrono::milliseconds>(deadline - now).count());
    if (remaining_ms < 1)
      remaining_ms = 1;

    // Wait for socket readiness before SSL_read on non-blocking socket.
    HttpError wait_err = socket_->wait_for_io(true, remaining_ms);
    if (wait_err.has_error()) {
      return wait_err;
    }

    int received = SSL_read(ssl_, buffer, (int)len);
    if (received > 0) {
      bytes_read = static_cast<size_t>(received);
      return HttpError(); // Success
    }

    int ssl_error = SSL_get_error(ssl_, received);
    if (ssl_error == SSL_ERROR_WANT_READ || ssl_error == SSL_ERROR_WANT_WRITE) {
      HttpError io_wait = socket_->wait_for_io(ssl_error == SSL_ERROR_WANT_READ, remaining_ms);
      if (io_wait.has_error()) {
        return io_wait;
      }
      continue;
    }
    if (ssl_error == SSL_ERROR_ZERO_RETURN) {
      // Connection closed cleanly
      bytes_read = 0;
      return HttpError(); // Success (0 bytes = EOF)
    }

    std::string openssl_msg = get_openssl_error_string();
    if (openssl_msg.empty()) {
      openssl_msg = "SSL read failed (SSL error " + std::to_string(ssl_error) + ")";
    }
    return HttpError(HttpErrorType::TLS, openssl_msg, ssl_error);
  }
}

void HttpTLS::close() {
  if (ssl_) {
    SSL_shutdown(ssl_);
    SSL_free(ssl_);
    ssl_ = nullptr;
  }
  if (ctx_) {
    SSL_CTX_free(ctx_);
    ctx_ = nullptr;
  }
  connected_ = false;
  socket_ = nullptr;
}

HttpError HttpTLS::verify_certificate(const std::string &hostname) {
  X509 *cert = SSL_get_peer_certificate(ssl_);
  if (!cert) {
    return HttpError(HttpErrorType::TLS, "No certificate presented by server");
  }

  // Verify certificate chain
  long verify_result = SSL_get_verify_result(ssl_);
  if (verify_result != X509_V_OK) {
    X509_free(cert);
    return HttpError(HttpErrorType::TLS,
                     std::string("Certificate verification failed: ") +
                         X509_verify_cert_error_string(verify_result));
  }

  X509_free(cert);
  return HttpError(); // Success
}

// ============================================================================
// HTTP PROTOCOL IMPLEMENTATION
// ============================================================================

std::string HttpProtocol::build_request(const HttpRequest &req,
                                         const ParsedURL &url) {
  std::ostringstream oss;

  // Request line
  oss << method_to_string(req.method) << " " << url.path;
  if (!url.query.empty()) {
    oss << "?" << url.query;
  }
  oss << " HTTP/1.1\r\n";

  // Required headers
  oss << "Host: " << url.host;
  if ((url.is_https && url.port != 443) || (!url.is_https && url.port != 80)) {
    oss << ":" << url.port;
  }
  oss << "\r\n";

  // Default headers
  bool has_user_agent = false;
  bool has_accept = false;
  bool has_connection = false;
  bool has_content_length = false;

  for (const auto &header : req.headers) {
    std::string lower_name = util::to_lower(header.first);
    if (lower_name == "user-agent")
      has_user_agent = true;
    if (lower_name == "accept")
      has_accept = true;
    if (lower_name == "connection")
      has_connection = true;
    if (lower_name == "content-length")
      has_content_length = true;

    oss << header.first << ": " << header.second << "\r\n";
  }

  if (!has_user_agent) {
    oss << "User-Agent: Levython-HTTP/1.0\r\n";
  }
  if (!has_accept) {
    oss << "Accept: */*\r\n";
  }
  if (!has_connection) {
    oss << "Connection: close\r\n";
  }

  // Content-Length for POST/PUT/PATCH
  if (!req.body.empty() && !has_content_length) {
    oss << "Content-Length: " << req.body.size() << "\r\n";
  }

  // End of headers
  oss << "\r\n";

  return oss.str();
}

HttpError HttpProtocol::parse_response(const std::string &raw,
                                        HttpResponse &resp) {
  // Find end of headers
  size_t header_end = raw.find("\r\n\r\n");
  if (header_end == std::string::npos) {
    return HttpError(HttpErrorType::PROTOCOL, "Malformed response: no header/body separator");
  }

  std::string header_block = raw.substr(0, header_end);
  std::string body = raw.substr(header_end + 4);

  // Parse status line
  size_t first_newline = header_block.find("\r\n");
  if (first_newline == std::string::npos) {
    return HttpError(HttpErrorType::PROTOCOL, "Malformed status line");
  }

  std::string status_line = header_block.substr(0, first_newline);
  HttpError err = parse_status_line(status_line, resp.status);
  if (err.has_error())
    return err;

  // Parse headers
  std::string headers_only = header_block.substr(first_newline + 2);
  err = parse_headers(headers_only, resp.headers);
  if (err.has_error())
    return err;

  // Store body
  resp.body.assign(body.begin(), body.end());

  return HttpError(); // Success
}

std::string HttpProtocol::method_to_string(HttpMethod method) {
  switch (method) {
  case HttpMethod::GET:
    return "GET";
  case HttpMethod::POST:
    return "POST";
  case HttpMethod::PUT:
    return "PUT";
  case HttpMethod::PATCH:
    return "PATCH";
  case HttpMethod::DEL:
    return "DELETE";
  case HttpMethod::HEAD:
    return "HEAD";
  default:
    return "GET";
  }
}

HttpError HttpProtocol::parse_status_line(const std::string &line, int &status) {
  // Parse: HTTP/1.1 200 OK
  std::istringstream iss(line);
  std::string http_version;
  iss >> http_version >> status;

  if (iss.fail() || status < 100 || status > 599) {
    return HttpError(HttpErrorType::PROTOCOL, "Invalid status line");
  }

  return HttpError(); // Success
}

HttpError HttpProtocol::parse_headers(const std::string &header_block,
                                       std::map<std::string, std::string> &headers) {
  std::istringstream iss(header_block);
  std::string line;

  while (std::getline(iss, line)) {
    if (line.empty() || line == "\r")
      break;

    // Remove \r if present
    if (!line.empty() && line.back() == '\r') {
      line.pop_back();
    }

    size_t colon = line.find(':');
    if (colon == std::string::npos) {
      continue; // Skip malformed headers
    }

    std::string name = util::trim(line.substr(0, colon));
    std::string value = util::trim(line.substr(colon + 1));

    // Normalize header name to lowercase
    std::string normalized_name = normalize_header_name(name);
    headers[normalized_name] = value;
  }

  return HttpError(); // Success
}

std::string HttpProtocol::normalize_header_name(const std::string &name) {
  return util::to_lower(name);
}

// ============================================================================
// HTTP CLIENT IMPLEMENTATION
// ============================================================================

HttpClient::HttpClient()
    : default_timeout_ms_(DEFAULT_TIMEOUT_MS), verify_ssl_(true) {}

HttpClient::~HttpClient() {}

HttpResponse HttpClient::request(const HttpRequest &req) {
  return execute(req, 0);
}

HttpResponse HttpClient::get(const std::string &url,
                              const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::GET;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  return request(req);
}

HttpResponse HttpClient::post(const std::string &url, const std::string &body,
                               const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::POST;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  req.set_body(body);
  return request(req);
}

HttpResponse HttpClient::put(const std::string &url, const std::string &body,
                              const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::PUT;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  req.set_body(body);
  return request(req);
}

HttpResponse HttpClient::patch(const std::string &url, const std::string &body,
                                const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::PATCH;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  req.set_body(body);
  return request(req);
}

HttpResponse HttpClient::del(const std::string &url,
                              const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::DEL;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  return request(req);
}

HttpResponse HttpClient::head(const std::string &url,
                               const std::map<std::string, std::string> &headers) {
  HttpRequest req;
  req.method = HttpMethod::HEAD;
  req.url = url;
  req.headers = headers;
  req.timeout_ms = default_timeout_ms_;
  req.verify_ssl = verify_ssl_;
  return request(req);
}

HttpResponse HttpClient::execute(const HttpRequest &req, int redirect_count) {
  HttpResponse resp;
  resp.url = req.url;

  auto start_time = std::chrono::high_resolution_clock::now();

  // Check redirect limit
  if (redirect_count > MAX_REDIRECTS) {
    resp.error = HttpError(HttpErrorType::REDIRECT_LOOP, "Too many redirects");
    return resp;
  }

  // Parse URL
  ParsedURL url;
  resp.error = ParsedURL::parse(req.url, url);
  if (resp.error.has_error())
    return resp;

  // Create socket
  HttpSocket socket;
  HttpTLS tls;

  // Connect
  int timeout = req.timeout_ms > 0 ? req.timeout_ms : default_timeout_ms_;
  resp.error = socket.connect(url.host, url.port, DEFAULT_CONNECT_TIMEOUT_MS);
  if (resp.error.has_error())
    return resp;

  // TLS handshake if HTTPS
  if (url.is_https) {
    resp.error = tls.connect(&socket, url.host, req.verify_ssl && verify_ssl_);
    if (resp.error.has_error())
      return resp;
  }

  // Send request
  resp.error = send_request(&socket, url.is_https ? &tls : nullptr, req, url);
  if (resp.error.has_error())
    return resp;

  // Receive response
  resp.error = receive_response(&socket, url.is_https ? &tls : nullptr, resp, timeout);
  if (resp.error.has_error())
    return resp;

  auto end_time = std::chrono::high_resolution_clock::now();
  resp.elapsed_ms = std::chrono::duration<double, std::milli>(end_time - start_time).count();

  // Handle redirects
  if (req.follow_redirects && resp.status >= 300 && resp.status < 400) {
    std::string location = resp.header("location");
    if (!location.empty()) {
      HttpRequest redirect_req = req;
      redirect_req.url = location;

      // Handle relative URLs
      if (!util::starts_with(location, "http://") &&
          !util::starts_with(location, "https://")) {
        redirect_req.url = url.scheme + "://" + url.host;
        if ((url.is_https && url.port != 443) || (!url.is_https && url.port != 80)) {
          redirect_req.url += ":" + std::to_string(url.port);
        }
        if (!util::starts_with(location, "/")) {
          redirect_req.url += "/";
        }
        redirect_req.url += location;
      }

      // Change POST to GET on 301/302 (HTTP standard behavior)
      if ((resp.status == 301 || resp.status == 302) && req.method == HttpMethod::POST) {
        redirect_req.method = HttpMethod::GET;
        redirect_req.body.clear();
      }

      return execute(redirect_req, redirect_count + 1);
    }
  }

  return resp;
}

HttpError HttpClient::send_request(HttpSocket *sock, HttpTLS *tls,
                                    const HttpRequest &req, const ParsedURL &url) {
  std::string request_str = HttpProtocol::build_request(req, url);

  // Send headers
  HttpError err;
  if (tls) {
    err = tls->send(request_str.data(), request_str.size());
  } else {
    err = sock->send(request_str.data(), request_str.size());
  }
  if (err.has_error())
    return err;

  // Send body if present
  if (!req.body.empty()) {
    if (tls) {
      err = tls->send(req.body.data(), req.body.size());
    } else {
      err = sock->send(req.body.data(), req.body.size());
    }
    if (err.has_error())
      return err;
  }

  return HttpError(); // Success
}

HttpError HttpClient::receive_response(HttpSocket *sock, HttpTLS *tls,
                                        HttpResponse &resp, int timeout_ms) {
  std::string raw_response;
  char buffer[READ_BUFFER_SIZE];
  size_t total_read = 0;

  // Read until connection closes or we have full response
  while (true) {
    size_t bytes_read = 0;
    HttpError err;

    if (tls) {
      err = tls->recv(buffer, sizeof(buffer), bytes_read, timeout_ms);
    } else {
      err = sock->recv(buffer, sizeof(buffer), bytes_read, timeout_ms);
    }

    if (err.has_error()) {
      // Timeout or error
      if (err.type == HttpErrorType::TIMEOUT && total_read > 0) {
        // We have partial data, try to parse it
        break;
      }
      return err;
    }

    if (bytes_read == 0) {
      // Connection closed
      break;
    }

    raw_response.append(buffer, bytes_read);
    total_read += bytes_read;

    // Check size limit
    if (total_read > MAX_RESPONSE_SIZE) {
      return HttpError(HttpErrorType::TOO_LARGE, "Response exceeds size limit");
    }

    // Check if we have complete headers
    size_t header_end = raw_response.find("\r\n\r\n");
    if (header_end != std::string::npos) {
      // Parse headers to check Content-Length
      HttpResponse temp_resp;
      HttpError parse_err = HttpProtocol::parse_response(raw_response, temp_resp);

      std::string content_length_str = temp_resp.header("content-length");
      if (!content_length_str.empty()) {
        try {
          size_t content_length = std::stoull(content_length_str);
          size_t expected_total = header_end + 4 + content_length;

          if (raw_response.size() >= expected_total) {
            // We have the full response
            break;
          }
        } catch (...) {
          // Invalid Content-Length, continue reading until connection closes
        }
      } else {
        // No Content-Length, check for chunked encoding or read until close
        std::string transfer_encoding = temp_resp.header("transfer-encoding");
        if (util::to_lower(transfer_encoding).find("chunked") != std::string::npos) {
          // TODO: Implement chunked decoding
          // For now, read until connection closes
          continue;
        }
      }
    }
  }

  // Parse response
  return HttpProtocol::parse_response(raw_response, resp);
}

// ============================================================================
// UTILITY FUNCTIONS IMPLEMENTATION
// ============================================================================

namespace util {

std::string to_lower(const std::string &str) {
  std::string result = str;
  std::transform(result.begin(), result.end(), result.begin(), ::tolower);
  return result;
}

std::string trim(const std::string &str) {
  size_t start = 0;
  size_t end = str.length();

  while (start < end && std::isspace(static_cast<unsigned char>(str[start]))) {
    ++start;
  }

  while (end > start && std::isspace(static_cast<unsigned char>(str[end - 1]))) {
    --end;
  }

  return str.substr(start, end - start);
}

std::vector<std::string> split(const std::string &str, char delim) {
  std::vector<std::string> result;
  std::istringstream iss(str);
  std::string token;

  while (std::getline(iss, token, delim)) {
    result.push_back(token);
  }

  return result;
}

bool starts_with(const std::string &str, const std::string &prefix) {
  return str.size() >= prefix.size() &&
         str.compare(0, prefix.size(), prefix) == 0;
}

bool ends_with(const std::string &str, const std::string &suffix) {
  return str.size() >= suffix.size() &&
         str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

std::string url_encode(const std::string &str) {
  std::ostringstream oss;
  oss << std::hex << std::uppercase;

  for (unsigned char c : str) {
    if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
      oss << c;
    } else {
      oss << '%' << std::setw(2) << std::setfill('0') << static_cast<int>(c);
    }
  }

  return oss.str();
}

} // namespace util

} // namespace http
} // namespace levython
