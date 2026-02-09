/**
 * ===========================================================================
 * LEVYTHON HTTP CLIENT MODULE
 * ===========================================================================
 *
 * Production-grade HTTP/HTTPS client for Levython programming language
 *
 * Features:
 * - Full HTTP/1.1 support (GET, POST, PUT, PATCH, DELETE, HEAD)
 * - HTTPS with TLS verification (OpenSSL)
 * - Async + Sync APIs
 * - JSON integration
 * - Cross-platform (Linux, macOS, Windows)
 * - Memory-safe, no leaks
 * - Secure by default
 *
 * Copyright (c) 2024 Levython Authors
 * Licensed under the MIT License
 */

#ifndef LEVYTHON_HTTP_CLIENT_HPP
#define LEVYTHON_HTTP_CLIENT_HPP

#include <algorithm>
#include <cstring>
#include <functional>
#include <map>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <chrono>

// Platform-specific socket includes
#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "crypt32.lib")
typedef int socklen_t;
#else
#include <arpa/inet.h>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

// OpenSSL includes
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/ssl.h>
#include <openssl/x509v3.h>

namespace levython {
namespace http {

// ============================================================================
// CONFIGURATION CONSTANTS
// ============================================================================

constexpr int DEFAULT_TIMEOUT_MS = 30000;        // 30 seconds
constexpr int DEFAULT_CONNECT_TIMEOUT_MS = 10000; // 10 seconds
constexpr int MAX_REDIRECTS = 10;
constexpr size_t MAX_HEADER_SIZE = 8192;         // 8KB headers max
constexpr size_t MAX_RESPONSE_SIZE = 104857600;  // 100MB max response
constexpr size_t READ_BUFFER_SIZE = 16384;       // 16KB read buffer

// ============================================================================
// ERROR TYPES
// ============================================================================

enum class HttpErrorType {
  NONE,
  NETWORK,      // DNS, connection refused, timeout
  TLS,          // Certificate validation, SSL errors
  HTTP,         // 4xx, 5xx status codes
  PROTOCOL,     // Malformed response
  TIMEOUT,      // Operation timeout
  TOO_LARGE,    // Response exceeds size limit
  REDIRECT_LOOP // Too many redirects
};

struct HttpError {
  HttpErrorType type;
  std::string message;
  int code; // System errno or HTTP status

  HttpError() : type(HttpErrorType::NONE), code(0) {}
  HttpError(HttpErrorType t, const std::string &msg, int c = 0)
      : type(t), message(msg), code(c) {}

  bool has_error() const { return type != HttpErrorType::NONE; }
  std::string to_string() const;
};

// ============================================================================
// HTTP RESPONSE
// ============================================================================

class HttpResponse {
public:
  int status;
  std::map<std::string, std::string> headers;
  std::vector<uint8_t> body;
  std::string url;
  double elapsed_ms;
  HttpError error;

  HttpResponse() : status(0), elapsed_ms(0.0) {}

  bool ok() const { return status >= 200 && status < 300 && !error.has_error(); }

  std::string text() const {
    return std::string(body.begin(), body.end());
  }

  std::string header(const std::string &name) const {
    auto it = headers.find(name);
    return it != headers.end() ? it->second : "";
  }

  // JSON parsing stub - will be integrated with Levython's JSON parser
  std::string json_text() const { return text(); }
};

// ============================================================================
// HTTP REQUEST
// ============================================================================

enum class HttpMethod { GET, POST, PUT, PATCH, DEL, HEAD };

class HttpRequest {
public:
  HttpMethod method;
  std::string url;
  std::map<std::string, std::string> headers;
  std::vector<uint8_t> body;
  int timeout_ms;
  bool follow_redirects;
  bool verify_ssl;

  HttpRequest()
      : method(HttpMethod::GET), timeout_ms(DEFAULT_TIMEOUT_MS),
        follow_redirects(true), verify_ssl(true) {}

  void set_header(const std::string &name, const std::string &value) {
    headers[name] = value;
  }

  void set_body(const std::string &data) {
    body.assign(data.begin(), data.end());
  }

  void set_json_body(const std::string &json) {
    set_body(json);
    set_header("Content-Type", "application/json");
  }
};

// ============================================================================
// URL PARSER
// ============================================================================

struct ParsedURL {
  std::string scheme;   // http or https
  std::string host;
  int port;
  std::string path;
  std::string query;

  bool is_https;

  ParsedURL() : port(80), is_https(false) {}

  static HttpError parse(const std::string &url, ParsedURL &result);
};

// ============================================================================
// SOCKET ABSTRACTION
// ============================================================================

class HttpSocket {
private:
#ifdef _WIN32
  SOCKET sock_;
#else
  int sock_;
#endif
  bool connected_;

public:
  HttpSocket();
  ~HttpSocket();

  // Disable copy
  HttpSocket(const HttpSocket &) = delete;
  HttpSocket &operator=(const HttpSocket &) = delete;

  HttpError connect(const std::string &host, int port, int timeout_ms);
  HttpError send(const void *data, size_t len);
  HttpError recv(void *buffer, size_t len, size_t &bytes_read, int timeout_ms);
  void close();
  bool is_connected() const { return connected_; }
  HttpError wait_for_io(bool for_read, int timeout_ms);

#ifdef _WIN32
  SOCKET native_handle() const { return sock_; }
#else
  int native_handle() const { return sock_; }
#endif

private:
  HttpError set_nonblocking();
};

// ============================================================================
// TLS/SSL WRAPPER
// ============================================================================

class HttpTLS {
private:
  SSL_CTX *ctx_;
  SSL *ssl_;
  HttpSocket *socket_;
  bool connected_;

  static bool ssl_initialized_;
  static void init_openssl();
  static void cleanup_openssl();

public:
  HttpTLS();
  ~HttpTLS();

  // Disable copy
  HttpTLS(const HttpTLS &) = delete;
  HttpTLS &operator=(const HttpTLS &) = delete;

  HttpError connect(HttpSocket *socket, const std::string &hostname,
                    bool verify_cert);
  HttpError send(const void *data, size_t len);
  HttpError recv(void *buffer, size_t len, size_t &bytes_read, int timeout_ms);
  void close();

private:
  HttpError verify_certificate(const std::string &hostname);
};

// ============================================================================
// HTTP PROTOCOL HANDLER
// ============================================================================

class HttpProtocol {
public:
  static std::string build_request(const HttpRequest &req, const ParsedURL &url);
  static HttpError parse_response(const std::string &raw, HttpResponse &resp);
  static std::string method_to_string(HttpMethod method);

private:
  static HttpError parse_status_line(const std::string &line, int &status);
  static HttpError parse_headers(const std::string &header_block,
                                  std::map<std::string, std::string> &headers);
  static std::string normalize_header_name(const std::string &name);
};

// ============================================================================
// HTTP CLIENT
// ============================================================================

class HttpClient {
private:
  int default_timeout_ms_;
  bool verify_ssl_;

public:
  HttpClient();
  ~HttpClient();

  // Synchronous API
  HttpResponse request(const HttpRequest &req);
  HttpResponse get(const std::string &url,
                   const std::map<std::string, std::string> &headers = {});
  HttpResponse post(const std::string &url, const std::string &body,
                    const std::map<std::string, std::string> &headers = {});
  HttpResponse put(const std::string &url, const std::string &body,
                   const std::map<std::string, std::string> &headers = {});
  HttpResponse patch(const std::string &url, const std::string &body,
                     const std::map<std::string, std::string> &headers = {});
  HttpResponse del(const std::string &url,
                   const std::map<std::string, std::string> &headers = {});
  HttpResponse head(const std::string &url,
                    const std::map<std::string, std::string> &headers = {});

  void set_default_timeout(int ms) { default_timeout_ms_ = ms; }
  void set_verify_ssl(bool verify) { verify_ssl_ = verify; }

private:
  HttpResponse execute(const HttpRequest &req, int redirect_count = 0);
  HttpError send_request(HttpSocket *sock, HttpTLS *tls,
                         const HttpRequest &req, const ParsedURL &url);
  HttpError receive_response(HttpSocket *sock, HttpTLS *tls,
                             HttpResponse &resp, int timeout_ms);
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

namespace util {
std::string to_lower(const std::string &str);
std::string trim(const std::string &str);
std::vector<std::string> split(const std::string &str, char delim);
bool starts_with(const std::string &str, const std::string &prefix);
bool ends_with(const std::string &str, const std::string &suffix);
std::string url_encode(const std::string &str);
} // namespace util

} // namespace http
} // namespace levython

#endif // LEVYTHON_HTTP_CLIENT_HPP
