/**
 * ===========================================================================
 * LEVYTHON HTTP MODULE BINDINGS
 * ===========================================================================
 *
 * This file contains the bindings that expose the HTTP client to Levython.
 * The http module provides a clean API similar to Python's requests library.
 *
 * Usage in Levython:
 *   res <- http.get("https://api.github.com/users/levython")
 *   say res.status
 *   say res.text
 *
 *   data <- http.post("https://httpbin.org/post", '{"key": "value"}', {"Content-Type": "application/json"})
 *   say data.json()
 */

#ifndef LEVYTHON_HTTP_BINDINGS_HPP
#define LEVYTHON_HTTP_BINDINGS_HPP

#include "http_client.hpp"
#include <map>
#include <memory>
#include <string>
#include <vector>

namespace levython {

// Forward declarations (from levython.cpp)
class Value;
enum class ObjectType;

namespace http_bindings {

// ============================================================================
// HTTP MODULE STATE
// ============================================================================

class HttpModuleState {
private:
  http::HttpClient client_;
  static std::unique_ptr<HttpModuleState> instance_;

public:
  static HttpModuleState &get_instance();

  http::HttpClient &client() { return client_; }
};

// ============================================================================
// CONVERSION UTILITIES
// ============================================================================

// Convert Levython Value to C++ types
std::string value_to_string(const Value &val);
int value_to_int(const Value &val);
double value_to_double(const Value &val);
bool value_to_bool(const Value &val);
std::map<std::string, std::string> value_to_headers(const Value &val);

// Convert C++ types to Levython Value
Value string_to_value(const std::string &str);
Value int_to_value(int i);
Value double_to_value(double d);
Value bool_to_value(bool b);
Value map_to_value(const std::map<std::string, std::string> &map);
Value bytes_to_value(const std::vector<uint8_t> &bytes);

// Convert HttpResponse to Levython MAP Value
Value response_to_value(const http::HttpResponse &resp);

// ============================================================================
// LEVYTHON BUILTIN FUNCTIONS
// ============================================================================

// These functions will be registered as Levython built-ins

/**
 * http.get(url, headers={})
 * Perform HTTP GET request
 *
 * Args:
 *   url: String - The URL to fetch
 *   headers: Map - Optional request headers
 *
 * Returns:
 *   Map - Response object with status, headers, body, text, json() method
 */
Value builtin_http_get(const std::vector<Value> &args);

/**
 * http.post(url, body, headers={})
 * Perform HTTP POST request
 *
 * Args:
 *   url: String - The URL to post to
 *   body: String - Request body data
 *   headers: Map - Optional request headers
 *
 * Returns:
 *   Map - Response object
 */
Value builtin_http_post(const std::vector<Value> &args);

/**
 * http.put(url, body, headers={})
 * Perform HTTP PUT request
 */
Value builtin_http_put(const std::vector<Value> &args);

/**
 * http.patch(url, body, headers={})
 * Perform HTTP PATCH request
 */
Value builtin_http_patch(const std::vector<Value> &args);

/**
 * http.delete(url, headers={})
 * Perform HTTP DELETE request
 */
Value builtin_http_delete(const std::vector<Value> &args);

/**
 * http.head(url, headers={})
 * Perform HTTP HEAD request
 */
Value builtin_http_head(const std::vector<Value> &args);

/**
 * http.request(method, url, body="", headers={}, timeout=30000, verify_ssl=true)
 * Perform custom HTTP request
 */
Value builtin_http_request(const std::vector<Value> &args);

/**
 * http.set_timeout(milliseconds)
 * Set global default timeout
 */
Value builtin_http_set_timeout(const std::vector<Value> &args);

/**
 * http.set_verify_ssl(enabled)
 * Set global SSL verification (default: true)
 */
Value builtin_http_set_verify_ssl(const std::vector<Value> &args);

// ============================================================================
// MODULE REGISTRATION
// ============================================================================

/**
 * Create and return the http module as a Levython Value (MAP type)
 * This function should be called during Levython runtime initialization
 */
Value create_http_module();

} // namespace http_bindings
} // namespace levython

#endif // LEVYTHON_HTTP_BINDINGS_HPP
