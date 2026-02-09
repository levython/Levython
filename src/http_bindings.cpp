/**
 * ===========================================================================
 * LEVYTHON HTTP MODULE BINDINGS IMPLEMENTATION
 * ===========================================================================
 */

// NOTE: This file should be included in levython.cpp after the Value class definition

namespace levython {
namespace http_bindings {

// ============================================================================
// MODULE STATE
// ============================================================================

std::unique_ptr<HttpModuleState> HttpModuleState::instance_;

HttpModuleState &HttpModuleState::get_instance() {
  if (!instance_) {
    instance_ = std::make_unique<HttpModuleState>();
  }
  return *instance_;
}

// ============================================================================
// CONVERSION UTILITIES
// ============================================================================

std::string value_to_string(const Value &val) {
  if (val.type == ObjectType::STRING) {
    return val.data.string;
  }
  return val.to_string();
}

int value_to_int(const Value &val) {
  if (val.type == ObjectType::INTEGER) {
    return static_cast<int>(val.data.integer);
  }
  if (val.type == ObjectType::FLOAT) {
    return static_cast<int>(val.data.floating);
  }
  throw std::runtime_error("Expected integer value");
}

double value_to_double(const Value &val) {
  if (val.type == ObjectType::FLOAT) {
    return val.data.floating;
  }
  if (val.type == ObjectType::INTEGER) {
    return static_cast<double>(val.data.integer);
  }
  throw std::runtime_error("Expected numeric value");
}

bool value_to_bool(const Value &val) {
  return val.is_truthy();
}

std::map<std::string, std::string> value_to_headers(const Value &val) {
  std::map<std::string, std::string> headers;

  if (val.type == ObjectType::MAP) {
    for (const auto &pair : val.data.map) {
      headers[pair.first] = value_to_string(pair.second);
    }
  }

  return headers;
}

Value string_to_value(const std::string &str) {
  return Value(str);
}

Value int_to_value(int i) {
  return Value(static_cast<long>(i));
}

Value double_to_value(double d) {
  return Value(d);
}

Value bool_to_value(bool b) {
  return Value(b);
}

Value map_to_value(const std::map<std::string, std::string> &map) {
  Value result(ObjectType::MAP);
  for (const auto &pair : map) {
    result.data.map[pair.first] = Value(pair.second);
  }
  return result;
}

Value bytes_to_value(const std::vector<uint8_t> &bytes) {
  std::string str(bytes.begin(), bytes.end());
  return Value(str);
}

Value response_to_value(const http::HttpResponse &resp) {
  Value response(ObjectType::MAP);

  // Basic fields
  response.data.map["status"] = int_to_value(resp.status);
  response.data.map["ok"] = bool_to_value(resp.ok());
  response.data.map["url"] = string_to_value(resp.url);
  response.data.map["elapsed_ms"] = double_to_value(resp.elapsed_ms);

  // Headers as map
  response.data.map["headers"] = map_to_value(resp.headers);

  // Body as bytes (vector)
  Value body_list(ObjectType::LIST);
  for (uint8_t byte : resp.body) {
    body_list.data.list.push_back(int_to_value(byte));
  }
  response.data.map["body"] = body_list;

  // Text representation
  response.data.map["text"] = string_to_value(resp.text());

  // Error information
  if (resp.error.has_error()) {
    Value error_map(ObjectType::MAP);
    error_map.data.map["type"] = int_to_value(static_cast<int>(resp.error.type));
    error_map.data.map["message"] = string_to_value(resp.error.message);
    error_map.data.map["code"] = int_to_value(resp.error.code);
    response.data.map["error"] = error_map;
  } else {
    response.data.map["error"] = Value(); // None
  }

  // Helper function to get header
  Value get_header_func(ObjectType::FUNCTION);
  get_header_func.data.function = Value::Data::Function("http_response_header");
  response.data.map["header"] = get_header_func;

  // Helper function for JSON parsing (returns text for now, user can parse)
  response.data.map["json_text"] = string_to_value(resp.json_text());

  return response;
}

// ============================================================================
// HTTP REQUEST FUNCTIONS
// ============================================================================

Value builtin_http_get(const std::vector<Value> &args) {
  if (args.empty()) {
    throw std::runtime_error("http.get() requires at least 1 argument (url)");
  }

  std::string url = value_to_string(args[0]);
  std::map<std::string, std::string> headers;

  if (args.size() > 1 && args[1].type == ObjectType::MAP) {
    headers = value_to_headers(args[1]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().get(url, headers);

  return response_to_value(resp);
}

Value builtin_http_post(const std::vector<Value> &args) {
  if (args.size() < 2) {
    throw std::runtime_error("http.post() requires at least 2 arguments (url, body)");
  }

  std::string url = value_to_string(args[0]);
  std::string body = value_to_string(args[1]);
  std::map<std::string, std::string> headers;

  if (args.size() > 2 && args[2].type == ObjectType::MAP) {
    headers = value_to_headers(args[2]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().post(url, body, headers);

  return response_to_value(resp);
}

Value builtin_http_put(const std::vector<Value> &args) {
  if (args.size() < 2) {
    throw std::runtime_error("http.put() requires at least 2 arguments (url, body)");
  }

  std::string url = value_to_string(args[0]);
  std::string body = value_to_string(args[1]);
  std::map<std::string, std::string> headers;

  if (args.size() > 2 && args[2].type == ObjectType::MAP) {
    headers = value_to_headers(args[2]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().put(url, body, headers);

  return response_to_value(resp);
}

Value builtin_http_patch(const std::vector<Value> &args) {
  if (args.size() < 2) {
    throw std::runtime_error("http.patch() requires at least 2 arguments (url, body)");
  }

  std::string url = value_to_string(args[0]);
  std::string body = value_to_string(args[1]);
  std::map<std::string, std::string> headers;

  if (args.size() > 2 && args[2].type == ObjectType::MAP) {
    headers = value_to_headers(args[2]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().patch(url, body, headers);

  return response_to_value(resp);
}

Value builtin_http_delete(const std::vector<Value> &args) {
  if (args.empty()) {
    throw std::runtime_error("http.delete() requires at least 1 argument (url)");
  }

  std::string url = value_to_string(args[0]);
  std::map<std::string, std::string> headers;

  if (args.size() > 1 && args[1].type == ObjectType::MAP) {
    headers = value_to_headers(args[1]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().del(url, headers);

  return response_to_value(resp);
}

Value builtin_http_head(const std::vector<Value> &args) {
  if (args.empty()) {
    throw std::runtime_error("http.head() requires at least 1 argument (url)");
  }

  std::string url = value_to_string(args[0]);
  std::map<std::string, std::string> headers;

  if (args.size() > 1 && args[1].type == ObjectType::MAP) {
    headers = value_to_headers(args[1]);
  }

  http::HttpResponse resp =
      HttpModuleState::get_instance().client().head(url, headers);

  return response_to_value(resp);
}

Value builtin_http_request(const std::vector<Value> &args) {
  if (args.size() < 2) {
    throw std::runtime_error(
        "http.request() requires at least 2 arguments (method, url)");
  }

  std::string method_str = value_to_string(args[0]);
  std::string url = value_to_string(args[1]);

  // Parse method
  http::HttpMethod method = http::HttpMethod::GET;
  std::transform(method_str.begin(), method_str.end(), method_str.begin(), ::toupper);

  if (method_str == "GET")
    method = http::HttpMethod::GET;
  else if (method_str == "POST")
    method = http::HttpMethod::POST;
  else if (method_str == "PUT")
    method = http::HttpMethod::PUT;
  else if (method_str == "PATCH")
    method = http::HttpMethod::PATCH;
  else if (method_str == "DELETE")
    method = http::HttpMethod::DEL;
  else if (method_str == "HEAD")
    method = http::HttpMethod::HEAD;
  else
    throw std::runtime_error("Invalid HTTP method: " + method_str);

  // Build request
  http::HttpRequest req;
  req.method = method;
  req.url = url;

  if (args.size() > 2) {
    req.set_body(value_to_string(args[2]));
  }

  if (args.size() > 3 && args[3].type == ObjectType::MAP) {
    req.headers = value_to_headers(args[3]);
  }

  if (args.size() > 4) {
    req.timeout_ms = value_to_int(args[4]);
  }

  if (args.size() > 5) {
    req.verify_ssl = value_to_bool(args[5]);
  }

  // Execute request
  http::HttpResponse resp =
      HttpModuleState::get_instance().client().request(req);

  return response_to_value(resp);
}

Value builtin_http_set_timeout(const std::vector<Value> &args) {
  if (args.empty()) {
    throw std::runtime_error("http.set_timeout() requires 1 argument (milliseconds)");
  }

  int timeout_ms = value_to_int(args[0]);
  HttpModuleState::get_instance().client().set_default_timeout(timeout_ms);

  return Value(); // None
}

Value builtin_http_set_verify_ssl(const std::vector<Value> &args) {
  if (args.empty()) {
    throw std::runtime_error("http.set_verify_ssl() requires 1 argument (enabled)");
  }

  bool verify = value_to_bool(args[0]);
  HttpModuleState::get_instance().client().set_verify_ssl(verify);

  return Value(); // None
}

// ============================================================================
// MODULE CREATION
// ============================================================================

Value create_http_module() {
  Value http_module(ObjectType::MAP);

  // Register HTTP methods as builtin functions
  Value get_func(ObjectType::FUNCTION);
  get_func.data.function = Value::Data::Function("http_get");
  http_module.data.map["get"] = get_func;

  Value post_func(ObjectType::FUNCTION);
  post_func.data.function = Value::Data::Function("http_post");
  http_module.data.map["post"] = post_func;

  Value put_func(ObjectType::FUNCTION);
  put_func.data.function = Value::Data::Function("http_put");
  http_module.data.map["put"] = put_func;

  Value patch_func(ObjectType::FUNCTION);
  patch_func.data.function = Value::Data::Function("http_patch");
  http_module.data.map["patch"] = patch_func;

  Value delete_func(ObjectType::FUNCTION);
  delete_func.data.function = Value::Data::Function("http_delete");
  http_module.data.map["delete"] = delete_func;

  Value head_func(ObjectType::FUNCTION);
  head_func.data.function = Value::Data::Function("http_head");
  http_module.data.map["head"] = head_func;

  Value request_func(ObjectType::FUNCTION);
  request_func.data.function = Value::Data::Function("http_request");
  http_module.data.map["request"] = request_func;

  Value set_timeout_func(ObjectType::FUNCTION);
  set_timeout_func.data.function = Value::Data::Function("http_set_timeout");
  http_module.data.map["set_timeout"] = set_timeout_func;

  Value set_verify_ssl_func(ObjectType::FUNCTION);
  set_verify_ssl_func.data.function = Value::Data::Function("http_set_verify_ssl");
  http_module.data.map["set_verify_ssl"] = set_verify_ssl_func;

  return http_module;
}

} // namespace http_bindings
} // namespace levython
