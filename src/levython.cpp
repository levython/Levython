#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <memory>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <algorithm>
#include <future>
#include <chrono>
#include <filesystem>
#include <cmath>
#include <utility>

namespace fs = std::filesystem;

// Forward declarations
class ASTNode;
class Environment;
class Value;

// Object Types
enum class ObjectType {
    INTEGER, FLOAT, STRING, BOOLEAN, NONE, LIST, MAP, FUNCTION, CLASS, INSTANCE, FILE
};

// Environment Definition
class Environment {
public:
    std::map<std::string, Value> variables;
    std::shared_ptr<Environment> parent;

    

    Environment() : parent(nullptr) {}
    explicit Environment(std::shared_ptr<Environment> p) : parent(std::move(p)) {}

    Environment(const Environment& other) : parent(other.parent), variables(other.variables) {}
    Environment& operator=(const Environment& other) {
        if (this != &other) {
            parent = other.parent;
            variables = other.variables;
        }
        return *this;
    }

    void define(const std::string& name, Value value);
    Value get(const std::string& name);
    void assign(const std::string& name, Value value);
};

// ASTNode Definition
enum class TokenType {
    IDENTIFIER, NUMBER, STRING, TRUE, FALSE, NONE,
    SAY, ASK, ACT, CLASS, IS_A, INIT, TRY, CATCH,
    IF, ELSE, WHILE, FOR, IN, REPEAT, IMPORT, RETURN_TOKEN,
    PLUS, MINUS, MULTIPLY, DIVIDE, MOD, POWER,
    EQ, NE, LT, GT, LE, GE,
    AND, OR, NOT,
    ASSIGN, LPAREN, RPAREN, LBRACKET, RBRACKET, LBRACE, RBRACE,
    COLON, DOT, COMMA, SEMICOLON,
    COMMENT, EOF_TOKEN, UNKNOWN
};

struct Token {
    TokenType type;
    std::string lexeme;
    size_t line;
};

enum class NodeType {
    PROGRAM, ASSIGN, BINARY, UNARY, LITERAL, VARIABLE,
    SAY, ASK, FUNCTION, CALL, CLASS, INSTANCE, METHOD, GET_ATTR,
    IF, WHILE, FOR, REPEAT, TRY, BLOCK, RETURN, IMPORT,
    INDEX, MAP
};

class ASTNode {
public:
    NodeType type;
    std::vector<std::unique_ptr<ASTNode>> children;
    Token token;
    std::string value;
    std::vector<std::string> params;
    std::string class_name;

    ASTNode(NodeType t, Token tok) : type(t), token(std::move(tok)) {}
    ASTNode(const ASTNode& other) : type(other.type), token(other.token), value(other.value), params(other.params), class_name(other.class_name) {
        children.reserve(other.children.size());
        for (const auto& child : other.children) {
            children.push_back(child ? std::make_unique<ASTNode>(*child) : nullptr);
        }
    }

    ASTNode& operator=(const ASTNode& other) {
        if (this != &other) {
            type = other.type;
            token = other.token;
            value = other.value;
            params = other.params;
            class_name = other.class_name;
            children.clear();
            children.reserve(other.children.size());
            for (const auto& child : other.children) {
                children.push_back(child ? std::make_unique<ASTNode>(*child) : nullptr);
            }
        }
        return *this;
    }

    ~ASTNode() = default;

    void addChild(std::unique_ptr<ASTNode> child) {
        children.push_back(std::move(child));
    }
};

// Value Definition
class Value {
public:
    ObjectType type;
    struct Data {
        long integer = 0;
        double floating = 0.0;
        std::string string;
        bool boolean = false;
        std::vector<Value> list;
        std::map<std::string, Value> map;
        struct Function {
            std::vector<std::string> params;
            std::unique_ptr<ASTNode> body;
            std::shared_ptr<Environment> env;
            bool is_builtin = false;
            std::string builtin_name;

            Function() = default;
            Function(std::vector<std::string> p, std::unique_ptr<ASTNode> b, std::shared_ptr<Environment> e)
                : params(std::move(p)), body(std::move(b)), env(std::move(e)), is_builtin(false) {}
            Function(std::string name, std::vector<std::string> p = {})
                : params(std::move(p)), body(nullptr), env(nullptr), is_builtin(true), builtin_name(std::move(name)) {}
            Function(const Function& other) : params(other.params), body(other.body ? std::make_unique<ASTNode>(*other.body) : nullptr),
                env(other.env), is_builtin(other.is_builtin), builtin_name(other.builtin_name) {}
            Function& operator=(const Function& other) {
                if (this != &other) {
                    params = other.params;
                    body = other.body ? std::make_unique<ASTNode>(*other.body) : nullptr;
                    env = other.env;
                    is_builtin = other.is_builtin;
                    builtin_name = other.builtin_name;
                }
                return *this;
            }
            Function(Function&&) = default;
            Function& operator=(Function&&) = default;
            ~Function() = default;
        } function;
        struct ClassObj {
            std::string name;
            std::map<std::string, Value> methods;
            std::shared_ptr<Value> parent;
        } class_obj;
        struct Instance {
            std::string class_name;
            std::map<std::string, Value> attributes;
            std::shared_ptr<Value> class_ref;
        } instance;
        std::shared_ptr<std::fstream> file;

        Data() = default;
        ~Data() = default;
        Data(const Data& other) = default;
        Data& operator=(const Data& other) = default;
        Data(Data&& other) = default;
        Data& operator=(Data&& other) = default;
    } data;

    Value() : type(ObjectType::NONE) {}
    Value(long i) : type(ObjectType::INTEGER) { data.integer = i; }
    Value(double d) : type(ObjectType::FLOAT) { data.floating = d; }
    Value(std::string s) : type(ObjectType::STRING) { data.string = std::move(s); }
    Value(const char* s) : type(ObjectType::STRING) { data.string = s; }
    Value(bool b) : type(ObjectType::BOOLEAN) { data.boolean = b; }
    explicit Value(ObjectType t) : type(t) {
        if (t == ObjectType::LIST) {}
        else if (t == ObjectType::MAP) {}
        else if (t == ObjectType::FILE) { data.file = nullptr; }
    }

    Value(const Value& other) = default;
    Value(Value&& other) noexcept = default;
    Value& operator=(const Value& other) = default;
    Value& operator=(Value&& other) noexcept = default;
    ~Value() = default;

    std::string to_string() const {
        switch (type) {
            case ObjectType::INTEGER: return std::to_string(data.integer);
            case ObjectType::FLOAT: return std::to_string(data.floating);
            case ObjectType::STRING: return data.string;
            case ObjectType::BOOLEAN: return data.boolean ? "yes" : "no";
            case ObjectType::NONE: return "none";
            case ObjectType::LIST: {
                std::string s = "[";
                for (size_t i = 0; i < data.list.size(); ++i) {
                    s += data.list[i].to_string();
                    if (i < data.list.size() - 1) s += ", ";
                }
                return s + "]";
            }
            case ObjectType::MAP: {
                std::string s = "{";
                size_t i = 0;
                for (const auto& pair : data.map) {
                    s += "\"" + pair.first + "\": " + pair.second.to_string();
                    if (i++ < data.map.size() - 1) s += ", ";
                }
                return s + "}";
            }
            case ObjectType::FUNCTION: return "<function" + (data.function.is_builtin ? " " + data.function.builtin_name : "") + ">";
            case ObjectType::CLASS: return "<class " + data.class_obj.name + ">";
            case ObjectType::INSTANCE: return "<instance of " + data.instance.class_name + ">";
            case ObjectType::FILE: return data.file && data.file->is_open() ? "<file open>" : "<file closed>";
            default: return "<unknown>";
        }
    }

    bool is_truthy() const {
        switch (type) {
            case ObjectType::BOOLEAN: return data.boolean;
            case ObjectType::INTEGER: return data.integer != 0;
            case ObjectType::FLOAT: return data.floating != 0.0;
            case ObjectType::STRING: return !data.string.empty();
            case ObjectType::LIST: return !data.list.empty();
            case ObjectType::MAP: return !data.map.empty();
            case ObjectType::NONE: return false;
            case ObjectType::FUNCTION: return true;
            case ObjectType::CLASS: return true;
            case ObjectType::INSTANCE: return true;
            case ObjectType::FILE: return data.file != nullptr;
            default: return false;
        }
    }
};

// Environment Methods
void Environment::define(const std::string& name, Value value) {
    variables[name] = std::move(value);
}

Value Environment::get(const std::string& name) {
    auto it = variables.find(name);
    if (it != variables.end()) return it->second;
    if (parent) return parent->get(name);
    throw std::runtime_error("Undefined variable: " + name);
}

void Environment::assign(const std::string& name, Value value) {
    auto it = variables.find(name);
    if (it != variables.end()) {
        it->second = std::move(value);
        return;
    }
    if (parent) {
        try {
            parent->get(name);
            parent->assign(name, std::move(value));
            return;
        } catch (const std::runtime_error&) {}
    }
    define(name, std::move(value));
}

// Lexer
class Lexer {
    std::string source;
    size_t pos;
    size_t line;
    std::map<std::string, TokenType> keywords;

public:
    Lexer(const std::string& src) : source(src), pos(0), line(1) {
        keywords["say"] = TokenType::SAY;
        keywords["act"] = TokenType::ACT;
        keywords["class"] = TokenType::CLASS;
        keywords["init"] = TokenType::INIT;
        keywords["try"] = TokenType::TRY;
        keywords["catch"] = TokenType::CATCH;
        keywords["if"] = TokenType::IF;
        keywords["else"] = TokenType::ELSE;
        keywords["while"] = TokenType::WHILE;
        keywords["for"] = TokenType::FOR;
        keywords["in"] = TokenType::IN;
        keywords["repeat"] = TokenType::REPEAT;
        keywords["import"] = TokenType::IMPORT;
        keywords["return"] = TokenType::RETURN_TOKEN;
        keywords["yes"] = TokenType::TRUE;
        keywords["no"] = TokenType::FALSE;
        keywords["none"] = TokenType::NONE;
        keywords["and"] = TokenType::AND;
        keywords["or"] = TokenType::OR;
        keywords["not"] = TokenType::NOT;
    }

    std::vector<Token> tokenize() {
        std::vector<Token> tokens;
        while (pos < source.size()) {
            char c = source[pos];
            if (isspace(c)) {
                if (c == '\n') ++line;
                ++pos;
                continue;
            }
            if (c == '#') {
                while (pos < source.size() && source[pos] != '\n') ++pos;
                continue;
            }
            if (isalpha(c) || c == '_') {
                tokens.push_back(scan_identifier());
                continue;
            }
            if (isdigit(c) || c == '.') {
                tokens.push_back(scan_number());
                continue;
            }
            if (c == '"') {
                tokens.push_back(scan_string());
                continue;
            }
            if (pos + 1 < source.size()) {
                std::string op2 = source.substr(pos, 2);
                if (op2 == "==") { tokens.push_back({TokenType::EQ, "==", line}); pos += 2; continue; }
                if (op2 == "!=") { tokens.push_back({TokenType::NE, "!=", line}); pos += 2; continue; }
                if (op2 == "<=") { tokens.push_back({TokenType::LE, "<=", line}); pos += 2; continue; }
                if (op2 == ">=") { tokens.push_back({TokenType::GE, ">=", line}); pos += 2; continue; }
                if (op2 == "<-") { tokens.push_back({TokenType::ASSIGN, "<-", line}); pos += 2; continue; }
                if (op2 == "->") { tokens.push_back({TokenType::RETURN_TOKEN, "->", line}); pos += 2; continue; }
            }
            switch (c) {
                case '+': tokens.push_back({TokenType::PLUS, "+", line}); ++pos; break;
                case '-': tokens.push_back({TokenType::MINUS, "-", line}); ++pos; break;
                case '*': tokens.push_back({TokenType::MULTIPLY, "*", line}); ++pos; break;
                case '/': tokens.push_back({TokenType::DIVIDE, "/", line}); ++pos; break;
                case '%': tokens.push_back({TokenType::MOD, "%", line}); ++pos; break;
                case '^': tokens.push_back({TokenType::POWER, "^", line}); ++pos; break;
                case '<': tokens.push_back({TokenType::LT, "<", line}); ++pos; break;
                case '>': tokens.push_back({TokenType::GT, ">", line}); ++pos; break;
                case '&': tokens.push_back({TokenType::AND, "&", line}); ++pos; break;
                case '|': tokens.push_back({TokenType::OR, "|", line}); ++pos; break;
                case '!': tokens.push_back({TokenType::NOT, "!", line}); ++pos; break;
                case '(': tokens.push_back({TokenType::LPAREN, "(", line}); ++pos; break;
                case ')': tokens.push_back({TokenType::RPAREN, ")", line}); ++pos; break;
                case '[': tokens.push_back({TokenType::LBRACKET, "[", line}); ++pos; break;
                case ']': tokens.push_back({TokenType::RBRACKET, "]", line}); ++pos; break;
                case '{': tokens.push_back({TokenType::LBRACE, "{", line}); ++pos; break;
                case '}': tokens.push_back({TokenType::RBRACE, "}", line}); ++pos; break;
                case ':': tokens.push_back({TokenType::COLON, ":", line}); ++pos; break;
                case '.': tokens.push_back({TokenType::DOT, ".", line}); ++pos; break;
                case ',': tokens.push_back({TokenType::COMMA, ",", line}); ++pos; break;
                case ';': tokens.push_back({TokenType::SEMICOLON, ";", line}); ++pos; break;
                default:
                    tokens.push_back({TokenType::UNKNOWN, std::string(1, c), line});
                    ++pos;
            }
        }
        tokens.push_back({TokenType::EOF_TOKEN, "", line});
        return tokens;
    }

private:
    Token scan_identifier() {
        std::string lexeme;
        while (pos < source.size() && (isalnum(source[pos]) || source[pos] == '_')) {
            lexeme += source[pos++];
        }
        if (lexeme == "is" && pos < source.size()) {
            size_t next_pos = pos;
            while (next_pos < source.size() && isspace(source[next_pos]) && source[next_pos] != '\n') next_pos++;
            if (next_pos + 1 < source.size() && source[next_pos] == 'a' &&
                (next_pos + 1 == source.size() || !isalnum(source[next_pos + 1]))) {
                pos = next_pos + 1;
                return {TokenType::IS_A, "is a", line};
            }
        }
        auto it = keywords.find(lexeme);
        if (it != keywords.end()) return {it->second, lexeme, line};
        return {TokenType::IDENTIFIER, lexeme, line};
    }

    Token scan_number() {
    // If it's a standalone ".", treat it as DOT
    if (source[pos] == '.' && (pos + 1 >= source.size() || !isdigit(source[pos + 1]))) {
        ++pos;
        return {TokenType::DOT, ".", line};
    }

    std::string lexeme;
    bool has_decimal = false;
    bool has_digits = false;

    while (pos < source.size() && (isdigit(source[pos]) || source[pos] == '.')) {
        if (source[pos] == '.') {
            if (has_decimal) break;
            has_decimal = true;
        } else {
            has_digits = true;
        }
        lexeme += source[pos++];
    }

    // Fallback if number lexeme somehow failed
    if (lexeme.empty()) {
        return {TokenType::DOT, ".", line};
    }

    return {TokenType::NUMBER, lexeme, line};
}


    Token scan_string() {
        std::string lexeme;
        size_t start_line = line;
        ++pos;
        while (pos < source.size() && source[pos] != '"') {
            if (source[pos] == '\\') {
                ++pos;
                if (pos >= source.size()) break;
                switch (source[pos]) {
                    case 'n': lexeme += '\n'; break;
                    case 't': lexeme += '\t'; break;
                    case '"': lexeme += '"'; break;
                    case '\\': lexeme += '\\'; break;
                    default: lexeme += source[pos];
                }
            } else {
                if (source[pos] == '\n') ++line;
                lexeme += source[pos];
            }
            ++pos;
        }
        if (pos < source.size()) ++pos;
        return {TokenType::STRING, lexeme, start_line};
    }
};

// Parser
class Parser {
    std::vector<Token> tokens;
    size_t pos;

    Token current() const { return pos < tokens.size() ? tokens[pos] : Token{TokenType::EOF_TOKEN, "", tokens.empty() ? 0 : tokens.back().line}; }
    Token previous() const { return pos > 0 ? tokens[pos - 1] : Token{TokenType::UNKNOWN, "", 0}; }
    Token advance() { if (!is_at_end()) pos++; return previous(); }
    Token peek() const { return pos + 1 < tokens.size() ? tokens[pos + 1] : Token{TokenType::EOF_TOKEN, "", tokens.back().line}; }
    bool is_at_end() const { return current().type == TokenType::EOF_TOKEN; }
    bool check(TokenType type) const { return !is_at_end() && current().type == type; }
    bool match(const std::vector<TokenType>& types) {
        for (TokenType type : types) {
            if (check(type)) {
                advance();
                return true;
            }
        }
        return false;
    }

    void error(const Token& token, const std::string& message) const {
        std::stringstream ss;
        ss << "[Line " << token.line << "] Error";
        if (token.type == TokenType::EOF_TOKEN) ss << " at end";
        else ss << " at '" << token.lexeme << "'";
        ss << ": " << message;
        throw std::runtime_error(ss.str());
    }

    Token consume(TokenType type, const std::string& message) {
        if (check(type)) return advance();
        error(current(), message);
        return Token{TokenType::UNKNOWN, "", current().line};
    }

    std::unique_ptr<ASTNode> parse_statement() {
        if (match({TokenType::SAY})) return parse_say_statement();
        if (match({TokenType::IF})) return parse_if_statement();
        if (match({TokenType::WHILE})) return parse_while_statement();
        if (match({TokenType::FOR})) return parse_for_statement();
        if (match({TokenType::REPEAT})) return parse_repeat_statement();
        if (match({TokenType::RETURN_TOKEN})) return parse_return_statement();
        if (match({TokenType::ACT})) return parse_function_definition("act");
        if (match({TokenType::CLASS})) return parse_class_definition();
        if (match({TokenType::IMPORT})) return parse_import_statement();
        if (match({TokenType::TRY})) return parse_try_statement();
        if (match({TokenType::LBRACE})) return parse_block();
        return parse_expression_statement();
    }

    std::unique_ptr<ASTNode> parse_block() {
        auto block_node = std::make_unique<ASTNode>(NodeType::BLOCK, previous());
        while (!check(TokenType::RBRACE) && !is_at_end()) {
            block_node->addChild(parse_declaration_or_statement());
        }
        consume(TokenType::RBRACE, "Expect '}' after block.");
        return block_node;
    }

    std::unique_ptr<ASTNode> parse_declaration_or_statement() {
        if (match({TokenType::ACT})) return parse_function_definition("act");
        if (match({TokenType::CLASS})) return parse_class_definition();
        return parse_statement();
    }

    std::unique_ptr<ASTNode> parse_say_statement() {
        Token keyword = previous();
        consume(TokenType::LPAREN, "Expect '(' after 'say'.");
        auto value = parse_expression();
        consume(TokenType::RPAREN, "Expect ')' after value.");
        match({TokenType::SEMICOLON});
        auto node = std::make_unique<ASTNode>(NodeType::SAY, keyword);
        node->addChild(std::move(value));
        return node;
    }

    std::unique_ptr<ASTNode> parse_if_statement() {
        Token keyword = previous();
        auto condition = parse_expression();
        auto then_branch = parse_statement_or_block();
        std::unique_ptr<ASTNode> else_branch = nullptr;
        if (match({TokenType::ELSE})) {
            else_branch = parse_statement_or_block();
        }
        auto node = std::make_unique<ASTNode>(NodeType::IF, keyword);
        node->addChild(std::move(condition));
        node->addChild(std::move(then_branch));
        if (else_branch) node->addChild(std::move(else_branch));
        return node;
    }

    std::unique_ptr<ASTNode> parse_while_statement() {
        Token keyword = previous();
        auto condition = parse_expression();
        auto body = parse_statement_or_block();
        auto node = std::make_unique<ASTNode>(NodeType::WHILE, keyword);
        node->addChild(std::move(condition));
        node->addChild(std::move(body));
        return node;
    }

    std::unique_ptr<ASTNode> parse_for_statement() {
        Token keyword = previous();
        Token loop_var_token = consume(TokenType::IDENTIFIER, "Expect loop variable name.");
        consume(TokenType::IN, "Expect 'in' after loop variable.");
        auto iterable = parse_expression();
        auto body = parse_statement_or_block();
        auto node = std::make_unique<ASTNode>(NodeType::FOR, keyword);
        node->value = loop_var_token.lexeme;
        node->addChild(std::move(iterable));
        node->addChild(std::move(body));
        return node;
    }

    std::unique_ptr<ASTNode> parse_repeat_statement() {
        Token keyword = previous();
        auto count_expr = parse_expression();
        auto body = parse_statement_or_block();
        auto node = std::make_unique<ASTNode>(NodeType::REPEAT, keyword);
        node->addChild(std::move(count_expr));
        node->addChild(std::move(body));
        return node;
    }

    std::unique_ptr<ASTNode> parse_return_statement() {
        Token keyword = previous();
        std::unique_ptr<ASTNode> value = nullptr;
        if (!check(TokenType::SEMICOLON) && !check(TokenType::RBRACE)) {
            value = parse_expression();
        }
        match({TokenType::SEMICOLON});
        auto node = std::make_unique<ASTNode>(NodeType::RETURN, keyword);
        if (value) node->addChild(std::move(value));
        return node;
    }

    std::unique_ptr<ASTNode> parse_function_definition(const std::string& kind) {
        Token keyword = previous();
        Token name = consume(TokenType::IDENTIFIER, "Expect function name.");
        auto node = std::make_unique<ASTNode>(NodeType::FUNCTION, name);
        node->value = name.lexeme;
        consume(TokenType::LPAREN, "Expect '(' after function name.");
        if (!check(TokenType::RPAREN)) {
            do {
                node->params.push_back(consume(TokenType::IDENTIFIER, "Expect parameter name.").lexeme);
            } while (match({TokenType::COMMA}));
        }
        consume(TokenType::RPAREN, "Expect ')' after parameters.");
        consume(TokenType::LBRACE, "Expect '{' before function body.");
        node->addChild(parse_block());
        return node;
    }

    std::unique_ptr<ASTNode> parse_class_definition() {
        Token keyword = previous();
        Token name = consume(TokenType::IDENTIFIER, "Expect class name.");
        auto node = std::make_unique<ASTNode>(NodeType::CLASS, name);
        node->class_name = name.lexeme;

        if (match({TokenType::IS_A})) {
            Token parent_name = consume(TokenType::IDENTIFIER, "Expect parent class name after 'is a'.");
            node->addChild(std::make_unique<ASTNode>(NodeType::VARIABLE, parent_name));
            node->children[0]->value = parent_name.lexeme;
        }

        consume(TokenType::LBRACE, "Expect '{' before class body.");

        while (!check(TokenType::RBRACE) && !is_at_end()) {
            if (match({TokenType::ACT})) {
                auto method = parse_function_definition("act");
                node->addChild(std::move(method));
            } else if (match({TokenType::INIT})) {
                Token initToken = previous();
                auto initNode = std::make_unique<ASTNode>(NodeType::FUNCTION, Token{TokenType::IDENTIFIER, "init", initToken.line});
                initNode->value = "init";

                consume(TokenType::LPAREN, "Expect '(' after init.");
                if (!check(TokenType::RPAREN)) {
                    do {
                        initNode->params.push_back(consume(TokenType::IDENTIFIER, "Expect parameter name.").lexeme);
                    } while (match({TokenType::COMMA}));
                }
                consume(TokenType::RPAREN, "Expect ')' after parameters.");
                consume(TokenType::LBRACE, "Expect '{' before init body.");
                initNode->addChild(parse_block());
                node->addChild(std::move(initNode));
            } else {
                error(current(), "Expect method definition or '}' in class body.");
            }
        }

        consume(TokenType::RBRACE, "Expect '}' after class body.");
        return node;
    }

    std::unique_ptr<ASTNode> parse_import_statement() {
        Token keyword = previous();
        Token module_name = consume(TokenType::IDENTIFIER, "Expect module name after 'import'.");
        match({TokenType::SEMICOLON});
        auto node = std::make_unique<ASTNode>(NodeType::IMPORT, keyword);
        node->value = module_name.lexeme;
        return node;
    }

    std::unique_ptr<ASTNode> parse_try_statement() {
        Token keyword = previous();
        auto try_block = parse_statement_or_block();
        consume(TokenType::CATCH, "Expect 'catch' after try block.");
        auto catch_block = parse_statement_or_block();
        auto node = std::make_unique<ASTNode>(NodeType::TRY, keyword);
        node->addChild(std::move(try_block));
        node->addChild(std::move(catch_block));
        return node;
    }

    std::unique_ptr<ASTNode> parse_statement_or_block() {
        if (match({TokenType::LBRACE})) return parse_block();
        return parse_statement();
    }

    std::unique_ptr<ASTNode> parse_expression_statement() {
        auto expr = parse_expression();
        match({TokenType::SEMICOLON});
        return expr;
    }

    std::unique_ptr<ASTNode> parse_expression() {
        return parse_assignment();
    }

    std::unique_ptr<ASTNode> parse_assignment() {
        auto expr = parse_logical_or();
        if (match({TokenType::ASSIGN})) {
            Token equals = previous();
            auto value = parse_assignment();
            if (expr->type == NodeType::VARIABLE || expr->type == NodeType::GET_ATTR || expr->type == NodeType::INDEX) {
                auto assign_node = std::make_unique<ASTNode>(NodeType::ASSIGN, equals);
                assign_node->value = expr->type == NodeType::VARIABLE ? expr->value : "";
                assign_node->addChild(std::move(expr));
                assign_node->addChild(std::move(value));
                return assign_node;
            }
            error(equals, "Invalid assignment target.");
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_logical_or() {
        auto expr = parse_logical_and();
        while (match({TokenType::OR})) {
            Token op = previous();
            auto right = parse_logical_and();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_logical_and() {
        auto expr = parse_equality();
        while (match({TokenType::AND})) {
            Token op = previous();
            auto right = parse_equality();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_equality() {
        auto expr = parse_comparison();
        while (match({TokenType::EQ, TokenType::NE})) {
            Token op = previous();
            auto right = parse_comparison();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_comparison() {
        auto expr = parse_term();
        while (match({TokenType::GT, TokenType::GE, TokenType::LT, TokenType::LE})) {
            Token op = previous();
            auto right = parse_term();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_term() {
        auto expr = parse_factor();
        while (match({TokenType::PLUS, TokenType::MINUS})) {
            Token op = previous();
            auto right = parse_factor();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_factor() {
        auto expr = parse_power();
        while (match({TokenType::MULTIPLY, TokenType::DIVIDE, TokenType::MOD})) {
            Token op = previous();
            auto right = parse_power();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_power() {
        auto expr = parse_unary();
        while (match({TokenType::POWER})) {
            Token op = previous();
            auto right = parse_unary();
            auto node = std::make_unique<ASTNode>(NodeType::BINARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(expr));
            node->addChild(std::move(right));
            expr = std::move(node);
        }
        return expr;
    }

    std::unique_ptr<ASTNode> parse_unary() {
        if (match({TokenType::NOT, TokenType::MINUS})) {
            Token op = previous();
            auto right = parse_unary();
            auto node = std::make_unique<ASTNode>(NodeType::UNARY, op);
            node->value = op.lexeme;
            node->addChild(std::move(right));
            return node;
        }
        return parse_call();
    }

    std::unique_ptr<ASTNode> parse_call() {
    auto expr = parse_primary();

    while (true) {
        if (match({TokenType::DOT})) {
            // Support method names like "init" (which is a keyword)
            Token name = current();
            if (name.type != TokenType::IDENTIFIER && name.type != TokenType::INIT) {
                error(current(), "Expect property or method name after '.'.");
            }
            advance();
            auto get_node = std::make_unique<ASTNode>(NodeType::GET_ATTR, name);
            get_node->value = name.lexeme;
            get_node->addChild(std::move(expr));
            expr = std::move(get_node);
        }

        else if (match({TokenType::LPAREN})) {
            Token paren = previous();
            auto call_node = std::make_unique<ASTNode>(NodeType::CALL, paren);
            call_node->addChild(std::move(expr));
            if (!check(TokenType::RPAREN)) {
                do {
                    call_node->addChild(parse_expression());
                } while (match({TokenType::COMMA}));
            }
            consume(TokenType::RPAREN, "Expect ')' after arguments.");
            expr = std::move(call_node);
        }
        else if (match({TokenType::LBRACKET})) {
            Token bracket = previous();
            auto index = parse_expression();
            consume(TokenType::RBRACKET, "Expect ']' after index.");
            auto index_node = std::make_unique<ASTNode>(NodeType::INDEX, bracket);
            index_node->addChild(std::move(expr));
            index_node->addChild(std::move(index));
            expr = std::move(index_node);
        }
        else {
            break;
        }
    }

    return expr;
}


    std::unique_ptr<ASTNode> parse_map() {
        Token token = previous();
        auto node = std::make_unique<ASTNode>(NodeType::MAP, token);
        if (!check(TokenType::RBRACE)) {
            do {
                auto key = parse_expression();
                if (key->type != NodeType::LITERAL || key->token.type != TokenType::STRING) {
                    error(key->token, "Map keys must be string literals.");
                }
                consume(TokenType::COLON, "Expect ':' after map key.");
                auto value = parse_expression();
                node->addChild(std::move(key));
                node->addChild(std::move(value));
            } while (match({TokenType::COMMA}));
        }
        consume(TokenType::RBRACE, "Expect '}' after map elements.");
        return node;
    }

    std::unique_ptr<ASTNode> parse_primary() {
        if (match({TokenType::FALSE})) return std::make_unique<ASTNode>(NodeType::LITERAL, previous());
        if (match({TokenType::TRUE})) return std::make_unique<ASTNode>(NodeType::LITERAL, previous());
        if (match({TokenType::NONE})) return std::make_unique<ASTNode>(NodeType::LITERAL, previous());
        if (match({TokenType::NUMBER})) {
            auto node = std::make_unique<ASTNode>(NodeType::LITERAL, previous());
            node->value = node->token.lexeme;
            return node;
        }
        if (match({TokenType::STRING})) {
            auto node = std::make_unique<ASTNode>(NodeType::LITERAL, previous());
            node->value = node->token.lexeme;
            return node;
        }
        if (match({TokenType::IDENTIFIER})) {
            auto node = std::make_unique<ASTNode>(NodeType::VARIABLE, previous());
            node->value = node->token.lexeme;
            return node;
        }
        if (match({TokenType::LPAREN})) {
            auto expr = parse_expression();
            consume(TokenType::RPAREN, "Expect ')' after expression.");
            return expr;
        }
        if (match({TokenType::LBRACKET})) {
            auto node = std::make_unique<ASTNode>(NodeType::LITERAL, previous());
            node->value = "list";
            if (!check(TokenType::RBRACKET)) {
                do {
                    if (check(TokenType::RBRACKET)) break;
                    node->addChild(parse_expression());
                } while (match({TokenType::COMMA}));
            }
            consume(TokenType::RBRACKET, "Expect ']' after list elements.");
            return node;
        }
        if (match({TokenType::LBRACE})) {
            return parse_map();
        }
        error(current(), "Expect expression.");
        return nullptr;
    }

public:
    explicit Parser(std::vector<Token> t) : tokens(std::move(t)), pos(0) {}
    std::unique_ptr<ASTNode> parse() {
        auto program = std::make_unique<ASTNode>(NodeType::PROGRAM, Token{TokenType::UNKNOWN, "program", 0});
        while (!is_at_end()) {
            try {
                program->addChild(parse_declaration_or_statement());
            } catch (const std::runtime_error& e) {
                std::cerr << e.what() << std::endl;
                while (!is_at_end()) {
                    if (previous().type == TokenType::SEMICOLON) break;
                    switch (current().type) {
                        case TokenType::CLASS:
                        case TokenType::ACT:
                        case TokenType::FOR:
                        case TokenType::IF:
                        case TokenType::WHILE:
                        case TokenType::REPEAT:
                        case TokenType::SAY:
                        case TokenType::RETURN_TOKEN:
                        case TokenType::IMPORT:
                        case TokenType::TRY:
                            goto next_statement;
                        default:
                            advance();
                            break;
                    }
                }
                next_statement:;
            }
        }
        return program;
    }
};

// Supporting struct for handling return statements
struct ReturnValue {
    Value value;
    explicit ReturnValue(Value v) : value(std::move(v)) {}
};

// Interpreter
class Interpreter {
    std::shared_ptr<Environment> global;
    std::shared_ptr<Environment> current_env;
    std::map<std::string, std::string> modules_source;
    std::map<std::string, Value> modules_cache;

    Value call_method(Value& instance, Value& method, const std::vector<Value>& args, std::shared_ptr<Environment> env);

    Value builtin_say(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("say() expects 1 argument.");
        std::cout << args[0].to_string() << std::endl;
        std::cout.flush();
        return Value();
    }

    Value builtin_ask(const std::vector<Value>& args) {
        if (args.size() > 1) throw std::runtime_error("ask() expects 0 or 1 argument.");
        if (args.size() == 1) {
            if (args[0].type != ObjectType::STRING) throw std::runtime_error("ask() prompt must be a string.");
            std::cout << args[0].data.string;
        }
        std::string input;
        std::getline(std::cin, input);
        return Value(input);
    }

    Value builtin_open(const std::vector<Value>& args) {
        if (args.size() != 2) throw std::runtime_error("open() expects 2 arguments (filename, mode).");
        if (args[0].type != ObjectType::STRING || args[1].type != ObjectType::STRING) {
            throw std::runtime_error("open() arguments must be strings.");
        }
    
        const std::string& filename = args[0].data.string;
        const std::string& mode = args[1].data.string;
    
        auto file = std::make_shared<std::fstream>();
        std::ios_base::openmode flags = std::ios_base::in;
    
        if (mode == "w") flags = std::ios_base::out | std::ios_base::trunc;
        else if (mode == "a") flags = std::ios_base::app | std::ios_base::out;
        else if (mode == "rb") flags = std::ios_base::in | std::ios_base::binary;
        else if (mode == "wb") flags = std::ios_base::out | std::ios_base::trunc | std::ios_base::binary;
        else if (mode != "r") throw std::runtime_error("Invalid file mode: " + mode);
    
        file->open(filename, flags);
        if (!file->is_open()) throw std::runtime_error("Failed to open file: " + filename);
    
        Value file_obj(ObjectType::MAP);
        file_obj.data.map["__handle__"] = Value(ObjectType::FILE);
        file_obj.data.map["__handle__"].data.file = file;
        
        // Add file operations as methods
        Value read_func(ObjectType::FUNCTION);
        read_func.data.function = Value::Data::Function("file.read", {});
        file_obj.data.map["read"] = read_func;
        
        Value write_func(ObjectType::FUNCTION);
        write_func.data.function = Value::Data::Function("file.write", {"content"});
        file_obj.data.map["write"] = write_func;
        
        Value close_func(ObjectType::FUNCTION);
        close_func.data.function = Value::Data::Function("file.close", {});
        file_obj.data.map["close"] = close_func;
    
        return file_obj;
    }
    
    Value builtin_file_read(const std::vector<Value>& args, Value& this_obj) {
        if (!this_obj.data.map.count("__handle__")) throw std::runtime_error("Invalid file object");
        auto& file = this_obj.data.map["__handle__"].data.file;
        if (!file || !file->is_open()) throw std::runtime_error("File is not open");
        
        file->seekg(0, std::ios::end);
        size_t size = file->tellg();
        file->seekg(0);
        std::string content(size, ' ');
        file->read(&content[0], size);
        return Value(content);
    }
    
    Value builtin_file_write(const std::vector<Value>& args, Value& this_obj) {
        if (!this_obj.data.map.count("__handle__")) throw std::runtime_error("Invalid file object");
        if (args.size() != 1) throw std::runtime_error("write() expects 1 argument");
        if (args[0].type != ObjectType::STRING) throw std::runtime_error("write() argument must be a string");
        
        auto& file = this_obj.data.map["__handle__"].data.file;
        if (!file || !file->is_open()) throw std::runtime_error("File is not open");
        
        *file << args[0].data.string;
        file->flush();
        return Value();
    }
    
    Value builtin_file_close(const std::vector<Value>& args, Value& this_obj) {
        if (!this_obj.data.map.count("__handle__")) throw std::runtime_error("Invalid file object");
        auto& file = this_obj.data.map["__handle__"].data.file;
        if (!file || !file->is_open()) throw std::runtime_error("File is not open");
        
        file->close();
        return Value();
    }
    
    Value builtin_len(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("len() expects 1 argument.");
        const Value& obj = args[0];
        if (obj.type == ObjectType::STRING) return Value(static_cast<long>(obj.data.string.length()));
        if (obj.type == ObjectType::LIST) return Value(static_cast<long>(obj.data.list.size()));
        if (obj.type == ObjectType::MAP) return Value(static_cast<long>(obj.data.map.size()));
        throw std::runtime_error("len() not supported for type " + obj.to_string());
    }

    Value builtin_range(const std::vector<Value>& args) {
        long start = 0, stop = 0, step = 1;
        if (args.size() == 1) {
            if (args[0].type != ObjectType::INTEGER) throw std::runtime_error("range() requires integer arguments.");
            stop = args[0].data.integer;
        } else if (args.size() == 2) {
            if (args[0].type != ObjectType::INTEGER || args[1].type != ObjectType::INTEGER) throw std::runtime_error("range() requires integer arguments.");
            start = args[0].data.integer;
            stop = args[1].data.integer;
        } else if (args.size() == 3) {
            if (args[0].type != ObjectType::INTEGER || args[1].type != ObjectType::INTEGER || args[2].type != ObjectType::INTEGER) throw std::runtime_error("range() requires integer arguments.");
            start = args[0].data.integer;
            stop = args[1].data.integer;
            step = args[2].data.integer;
            if (step == 0) throw std::runtime_error("range() step cannot be zero.");
        } else {
            throw std::runtime_error("range() expects 1, 2, or 3 arguments.");
        }
        Value list_val(ObjectType::LIST);
        if (step > 0) {
            for (long i = start; i < stop; i += step) list_val.data.list.push_back(Value(i));
        } else {
            for (long i = start; i > stop; i += step) list_val.data.list.push_back(Value(i));
        }
        return list_val;
    }

    Value builtin_type(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("type() expects 1 argument.");
        switch (args[0].type) {
            case ObjectType::INTEGER: return Value("integer");
            case ObjectType::FLOAT: return Value("float");
            case ObjectType::STRING: return Value("string");
            case ObjectType::BOOLEAN: return Value("boolean");
            case ObjectType::NONE: return Value("none");
            case ObjectType::LIST: return Value("list");
            case ObjectType::MAP: return Value("map");
            case ObjectType::FUNCTION: return Value("function");
            case ObjectType::CLASS: return Value("class");
            case ObjectType::INSTANCE: return Value("instance");
            case ObjectType::FILE: return Value("file");
            default: return Value("unknown");
        }
    }

    Value builtin_int(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("int() expects 1 argument.");
        const Value& arg = args[0];
        try {
            if (arg.type == ObjectType::INTEGER) return arg;
            if (arg.type == ObjectType::FLOAT) return Value(static_cast<long>(arg.data.floating));
            if (arg.type == ObjectType::STRING) return Value(std::stol(arg.data.string));
            if (arg.type == ObjectType::BOOLEAN) return Value(arg.data.boolean ? 1L : 0L);
        } catch (const std::exception&) {
            throw std::runtime_error("Cannot convert '" + arg.to_string() + "' to integer.");
        }
        throw std::runtime_error("Cannot convert type " + builtin_type({arg}).data.string + " to integer.");
    }

    Value builtin_float(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("float() expects 1 argument.");
        const Value& arg = args[0];
        try {
            if (arg.type == ObjectType::FLOAT) return arg;
            if (arg.type == ObjectType::INTEGER) return Value(static_cast<double>(arg.data.integer));
            if (arg.type == ObjectType::STRING) return Value(std::stod(arg.data.string));
            if (arg.type == ObjectType::BOOLEAN) return Value(arg.data.boolean ? 1.0 : 0.0);
        } catch (const std::exception&) {
            throw std::runtime_error("Cannot convert '" + arg.to_string() + "' to float.");
        }
        throw std::runtime_error("Cannot convert type " + builtin_type({arg}).data.string + " to float.");
    }

    Value builtin_str(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("str() expects 1 argument.");
        return Value(args[0].to_string());
    }

    Value builtin_append(const std::vector<Value>& args) {
        if (args.size() != 2) throw std::runtime_error("append() expects 2 arguments.");
        if (args[0].type != ObjectType::LIST) throw std::runtime_error("First argument to append() must be a list.");

        Value result = args[0];  // Make a copy to modify
        result.data.list.push_back(args[1]);
        return result;
    }

    Value builtin_math_sin(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("math.sin() expects 1 argument.");
        if (args[0].type != ObjectType::FLOAT && args[0].type != ObjectType::INTEGER) {
            throw std::runtime_error("math.sin() argument must be a number.");
        }
        double x = args[0].type == ObjectType::FLOAT ? args[0].data.floating : static_cast<double>(args[0].data.integer);
        return Value(std::sin(x));
    }

    Value builtin_math_cos(const std::vector<Value>& args) {
        if (args.size() != 1) throw std::runtime_error("math.cos() expects 1 argument.");
        if (args[0].type != ObjectType::FLOAT && args[0].type != ObjectType::INTEGER) {
            throw std::runtime_error("math.cos() argument must be a number.");
        }
        double x = args[0].type == ObjectType::FLOAT ? args[0].data.floating : static_cast<double>(args[0].data.integer);
        return Value(std::cos(x));
    }

    void define_builtin(const std::string& name, const std::vector<std::string>& params = {}) {
        Value func_val(ObjectType::FUNCTION);
        func_val.data.function = Value::Data::Function(name, params);
        global->define(name, func_val);
    }

    Value find_method(const std::shared_ptr<Value>& class_val, const std::string& method_name) {
        if (!class_val || class_val->type != ObjectType::CLASS) {
            return Value();
        }

        // First check the current class
        auto method_it = class_val->data.class_obj.methods.find(method_name);
        if (method_it != class_val->data.class_obj.methods.end()) {
            return method_it->second;
        }

        // Then check parent class if it exists
        if (class_val->data.class_obj.parent) {
            return find_method(class_val->data.class_obj.parent, method_name);
        }

        return Value();
    }

public:
    Interpreter() {
        std::ios::sync_with_stdio(false);
        std::cin.tie(nullptr);
        std::cout.tie(nullptr);

        global = std::make_shared<Environment>();
        current_env = global;
        
        define_builtin("say", {"value"});
        define_builtin("ask", {"prompt"});
        define_builtin("open", {"filename", "mode"});
        define_builtin("len", {"obj"});
        define_builtin("range", {"stop"});
        define_builtin("type", {"value"});
        define_builtin("int", {"value"});
        define_builtin("float", {"value"});
        define_builtin("str", {"value"});
        define_builtin("append", {"list", "value"});

        // Initialize math module
        Value math_module(ObjectType::MAP);
        math_module.data.map["pi"] = Value(3.141592653589793);
        math_module.data.map["e"] = Value(2.718281828459045);
        
        // Define math.sin
        Value sin_func(ObjectType::FUNCTION);
        sin_func.data.function = Value::Data::Function("math.sin", {"x"});
        sin_func.data.function.is_builtin = true;
        sin_func.data.function.builtin_name = "math.sin";
        math_module.data.map["sin"] = sin_func;
        
        // Define math.cos
        Value cos_func(ObjectType::FUNCTION);
        cos_func.data.function = Value::Data::Function("math.cos", {"x"});
        cos_func.data.function.is_builtin = true;
        cos_func.data.function.builtin_name = "math.cos";
        math_module.data.map["cos"] = cos_func;
        
        // Register math module
        global->define("math", math_module);
    }

    void interpret(ASTNode* node) {
        try {
            evaluate(node, global, false);
        } catch (const std::exception& e) {
            std::cerr << "Runtime Error: " << e.what() << std::endl;
        }
    }

    void run_file(const std::string& filename) {
        fs::path path(filename);
        if (!fs::exists(path)) {
            std::cerr << "Error: File does not exist: " << filename << std::endl;
            return;
        }
        
        // Check if file has .levy extension
        if (path.extension() != ".levy") {
            std::cerr << "Error: File must be a Levy script with .levy extension" << std::endl;
            return;
        }
        
        std::ifstream file(path);
        if (!file.is_open()) {
            std::cerr << "Error: Could not open file: " << filename << std::endl;
            return;
        }
        std::stringstream buffer;
        buffer << file.rdbuf();
        std::string source = buffer.str();
        file.close();
        execute(source, filename);
    }

    void run_repl() {
        std::string line;
        std::cout << "Levython REPL (Alpha v0.1.0) (type 'exit' to quit)\n";
        while (true) {
            std::cout << "> ";
            if (!std::getline(std::cin, line)) break;
            if (line == "exit") break;
            if (line.empty()) continue;
            execute(line, "<stdin>");
        }
    }

private:
void execute(const std::string& source, const std::string& context_name) {
    Lexer lexer(source);
    auto tokens = lexer.tokenize();
    Parser parser(tokens);
    try {
        auto ast = parser.parse();
        Value result = evaluate(ast.get(), current_env, false);
        if (context_name == "<stdin>" && result.type != ObjectType::NONE) {
            std::cout << result.to_string() << std::endl;
        }
    } catch (const std::runtime_error& e) {
        std::cerr << "Error in " << context_name << ": " << e.what() << std::endl;
    }
}

Value evaluate(ASTNode* node, std::shared_ptr<Environment> env, bool is_method) {
    if (!node) return Value();
    try {
        switch (node->type) {
            case NodeType::PROGRAM: {
                Value last_val;
                for (const auto& child : node->children) {
                    last_val = evaluate(child.get(), env, is_method);
                }
                return last_val;
            }
            case NodeType::BLOCK: {
                auto block_env = std::make_shared<Environment>(env);
                Value last_val;
                for (const auto& child : node->children) {
                    last_val = evaluate(child.get(), block_env, is_method);
                }
                return last_val;
            }
            
            case NodeType::ASSIGN: {
                ASTNode* target = node->children[0].get();
                Value value = evaluate(node->children[1].get(), env, is_method);
                if (target->type == NodeType::VARIABLE) {
                    env->assign(target->value, value);
                } else if (target->type == NodeType::GET_ATTR) {
                    ASTNode* objNode = target->children[0].get();
                    const std::string& attr_name = target->value;
                    if (objNode->type == NodeType::VARIABLE) {
                        const std::string& objName = objNode->value;
                        Value object = env->get(objName);
                        if (object.type == ObjectType::INSTANCE) {
                            object.data.instance.attributes[attr_name] = value;
                            env->assign(objName, object);
                        } else if (object.type == ObjectType::MAP) {
                            object.data.map[attr_name] = value;
                            env->assign(objName, object);
                        } else {
                            throw std::runtime_error("Cannot set attribute '" + attr_name + "' on type " + object.to_string());
                        }
                    } else {
                        throw std::runtime_error("Only 'self.attr' assignment is supported currently.");
                    }
                } else if (target->type == NodeType::INDEX) {
                    Value target_val = evaluate(target->children[0].get(), env, is_method);
                    Value index_val = evaluate(target->children[1].get(), env, is_method);
                    if (target_val.type == ObjectType::MAP && index_val.type == ObjectType::STRING) {
                        target_val.data.map[index_val.data.string] = value;
                        if (target->children[0]->type == NodeType::VARIABLE) {
                            env->assign(target->children[0]->value, target_val);
                        } else {
                            throw std::runtime_error("Map index assignment only supported for variables.");
                        }
                    } else if (target_val.type == ObjectType::LIST && index_val.type == ObjectType::INTEGER) {
                        long index = index_val.data.integer;
                        if (index < 0 || index >= static_cast<long>(target_val.data.list.size())) {
                            throw std::runtime_error("List index out of range.");
                        }
                        target_val.data.list[index] = value;
                        if (target->children[0]->type == NodeType::VARIABLE) {
                            env->assign(target->children[0]->value, target_val);
                        } else {
                            throw std::runtime_error("List index assignment only supported for variables.");
                        }
                    } else {
                        throw std::runtime_error("Invalid index type for assignment.");
                    }
                } else {
                    throw std::runtime_error("Invalid assignment target.");
                }
                return value;
            }

            case NodeType::BINARY: {
                Value left = evaluate(node->children[0].get(), env, is_method);
                Value right = evaluate(node->children[1].get(), env, is_method);
                const std::string& op = node->value;

                if (op == "+" && (left.type == ObjectType::STRING || right.type == ObjectType::STRING)) {
                    std::string left_str = left.to_string();
                    std::string right_str = right.to_string();
                    return Value(left_str + right_str);
                }

                if (left.type == ObjectType::INTEGER && right.type == ObjectType::INTEGER) {
                    long l = left.data.integer;
                    long r = right.data.integer;
                    if (op == "+") return Value(l + r);
                    if (op == "-") return Value(l - r);
                    if (op == "*") return Value(l * r);
                    if (op == "/") {
                        if (r == 0) throw std::runtime_error("Division by zero.");
                        return Value(static_cast<double>(l) / r);
                    }
                    if (op == "%") {
                        if (r == 0) throw std::runtime_error("Modulo by zero.");
                        return Value(l % r);
                    }
                    if (op == "^") return Value(static_cast<double>(std::pow(l, r)));
                    if (op == "==") return Value(l == r);
                    if (op == "!=") return Value(l != r);
                    if (op == "<") return Value(l < r);
                    if (op == ">") return Value(l > r);
                    if (op == "<=") return Value(l <= r);
                    if (op == ">=") return Value(l >= r);
                    if (op == "&") return Value(l && r);
                    if (op == "|") return Value(l || r);
                } else if ((left.type == ObjectType::FLOAT || left.type == ObjectType::INTEGER) &&
                           (right.type == ObjectType::FLOAT || right.type == ObjectType::INTEGER)) {
                    double l = left.type == ObjectType::FLOAT ? left.data.floating : static_cast<double>(left.data.integer);
                    double r = right.type == ObjectType::FLOAT ? right.data.floating : static_cast<double>(right.data.integer);
                    if (op == "+") return Value(l + r);
                    if (op == "-") return Value(l - r);
                    if (op == "*") return Value(l * r);
                    if (op == "/") {
                        if (r == 0.0) throw std::runtime_error("Division by zero.");
                        return Value(l / r);
                    }
                    if (op == "^") return Value(std::pow(l, r));
                    if (op == "==") return Value(l == r);
                    if (op == "!=") return Value(l != r);
                    if (op == "<") return Value(l < r);
                    if (op == ">") return Value(l > r);
                    if (op == "<=") return Value(l <= r);
                    if (op == ">=") return Value(l >= r);
                } else if (left.type == ObjectType::STRING && right.type == ObjectType::STRING) {
                    if (op == "==") return Value(left.data.string == right.data.string);
                    if (op == "!=") return Value(left.data.string != right.data.string);
                    if (op == "<") return Value(left.data.string < right.data.string);
                    if (op == ">") return Value(left.data.string > right.data.string);
                    if (op == "<=") return Value(left.data.string <= right.data.string);
                    if (op == ">=") return Value(left.data.string >= right.data.string);
                } else if (left.type == ObjectType::BOOLEAN && right.type == ObjectType::BOOLEAN) {
                    bool l = left.data.boolean;
                    bool r = right.data.boolean;
                    if (op == "&") return Value(l && r);
                    if (op == "|") return Value(l || r);
                    if (op == "==") return Value(l == r);
                    if (op == "!=") return Value(l != r);
                }
                if (op == "&") return left.is_truthy() ? right : left;
                if (op == "|") return left.is_truthy() ? left : right;
                if (op == "==") return Value(left.type == ObjectType::NONE && right.type == ObjectType::NONE);
                if (op == "!=") return Value(!(left.type == ObjectType::NONE && right.type == ObjectType::NONE));
                throw std::runtime_error("Unsupported operand types for '" + op + "': " + left.to_string() + ", " + right.to_string());
            }
            case NodeType::UNARY: {
                Value right = evaluate(node->children[0].get(), env, is_method);
                const std::string& op = node->value;
                if (op == "-") {
                    if (right.type == ObjectType::INTEGER) return Value(-right.data.integer);
                    if (right.type == ObjectType::FLOAT) return Value(-right.data.floating);
                    throw std::runtime_error("Operand for unary '-' must be number.");
                }
                if (op == "!") return Value(!right.is_truthy());
                throw std::runtime_error("Unsupported unary operator '" + op + "'");
            }
            case NodeType::LITERAL: {
                if (node->token.type == TokenType::NUMBER) {
                    try {
                        if (node->value.find('.') != std::string::npos) return Value(std::stod(node->value));
                        return Value(std::stol(node->value));
                    } catch (const std::exception&) {
                        throw std::runtime_error("Invalid numeric literal: " + node->value);
                    }
                }
                if (node->token.type == TokenType::STRING) return Value(node->value);
                if (node->token.type == TokenType::TRUE) return Value(true);
                if (node->token.type == TokenType::FALSE) return Value(false);
                if (node->token.type == TokenType::NONE) return Value(ObjectType::NONE);
                if (node->value == "list") {
                    Value list_val(ObjectType::LIST);
                    list_val.data.list.reserve(node->children.size());
                    for (const auto& elem_node : node->children) {
                        list_val.data.list.push_back(evaluate(elem_node.get(), env, is_method));
                    }
                    return list_val;
                }
                throw std::runtime_error("Unknown literal type at line " + std::to_string(node->token.line));
            }
            case NodeType::VARIABLE: {
                return env->get(node->value);
            }
            case NodeType::SAY: {
                Value value_to_say = evaluate(node->children[0].get(), env, is_method);
                std::cout << value_to_say.to_string() << std::endl;
                std::cout.flush();
                return Value();
            }
            case NodeType::FUNCTION: {
                Value func_val(ObjectType::FUNCTION);
                std::unique_ptr<ASTNode> body_node = std::make_unique<ASTNode>(*node->children[0]);
                func_val.data.function = Value::Data::Function(node->params, std::move(body_node), env);
                env->define(node->value, func_val);
                return Value();
            }
            case NodeType::CLASS: {
                Value class_val(ObjectType::CLASS);
                class_val.data.class_obj.name = node->class_name;
                
                // Handle inheritance
                if (node->children[0] && node->children[0]->type == NodeType::VARIABLE) {
                    Value parent_val = evaluate(node->children[0].get(), env, is_method);
                    if (parent_val.type != ObjectType::CLASS) {
                        throw std::runtime_error("Parent must be a class.");
                    }
                    class_val.data.class_obj.parent = std::make_shared<Value>(parent_val);
                }

                // Process methods
                size_t start_idx = (node->children[0] && node->children[0]->type == NodeType::VARIABLE) ? 1 : 0;
                for (size_t i = start_idx; i < node->children.size(); ++i) {
                    ASTNode* method_node = node->children[i].get();
                    if (method_node->type == NodeType::FUNCTION) {
                        Value method_func(ObjectType::FUNCTION);
                        method_func.data.function = Value::Data::Function(
                            method_node->params,
                            std::make_unique<ASTNode>(*method_node->children[0]),
                            env
                        );
                        class_val.data.class_obj.methods[method_node->value] = method_func;
                    }
                }

                // Define the class in the environment
                env->define(node->class_name, class_val);
                return Value();
            }
            case NodeType::CALL: {
                ASTNode* calleeNode = node->children[0].get();
                Value callee = evaluate(calleeNode, env, is_method);
                std::vector<Value> args;
                for (size_t i = 1; i < node->children.size(); ++i) {
                    args.push_back(evaluate(node->children[i].get(), env, is_method));
                }

                if (calleeNode->type == NodeType::GET_ATTR) {
                    auto* getN = static_cast<ASTNode*>(calleeNode);
                    Value object = evaluate(getN->children[0].get(), env, is_method);
                    const std::string& method_name = getN->value;

                    if (object.type == ObjectType::INSTANCE) {
                        Value method = find_method(object.data.instance.class_ref, method_name);
                        if (method.type != ObjectType::FUNCTION) {
                            throw std::runtime_error("Method '" + method_name + "' not found in class '" + object.data.instance.class_name + "'");
                        }
                        return call_method(object, method, args, env);
                    }
                    if (object.type == ObjectType::MAP) {
                        auto it = object.data.map.find(method_name);
                        if (it == object.data.map.end()) {
                            throw std::runtime_error("Method '" + method_name + "' not found in object");
                        }
                        Value method = it->second;
                        if (method.type != ObjectType::FUNCTION) {
                            throw std::runtime_error("'" + method_name + "' is not a method");
                        }

                        // Super call patch: redirect to self if accessing through `super`
                        if (getN->children[0]->type == NodeType::VARIABLE &&
                            getN->children[0]->value == "super") {
                            Value self = env->get("self");
                            return call_method(self, method, args, env);
                        }

                        return call_method(object, method, args, env);
                    }


                }

                if (callee.type == ObjectType::CLASS) {
                    Value instVal(ObjectType::INSTANCE);
                    instVal.data.instance.class_name = callee.data.class_obj.name;
                    instVal.data.instance.class_ref = std::make_shared<Value>(callee);
                    
                    // Handle parent class initialization first if it exists
                    if (callee.data.class_obj.parent) {
                        auto parent = callee.data.class_obj.parent;
                        if (parent->type == ObjectType::CLASS) {
                            // Create a temporary parent instance
                            Value parent_inst(ObjectType::INSTANCE);
                            parent_inst.data.instance.class_name = parent->data.class_obj.name;
                            parent_inst.data.instance.class_ref = parent;
                            
                            // Call parent's init if it exists
                            Value parent_init = find_method(parent, "init");
                            if (parent_init.type == ObjectType::FUNCTION) {
                                // Get the parent's init parameter count
                                size_t parent_param_count = parent_init.data.function.params.size();
                                // Create a vector with only the first parent_param_count arguments
                                std::vector<Value> parent_args;
                                for (size_t i = 0; i < parent_param_count && i < args.size(); ++i) {
                                    parent_args.push_back(args[i]);
                                }
                                call_method(parent_inst, parent_init, parent_args, env);
                            }
                            
                            // Copy parent's attributes to child instance
                            instVal.data.instance.attributes = parent_inst.data.instance.attributes;
                        }
                    }
                    
                    // Then call the current class's init if it exists
                    Value initM = find_method(instVal.data.instance.class_ref, "init");
                    if (initM.type == ObjectType::FUNCTION) {
                        call_method(instVal, initM, args, env);
                    }
                    
                    return instVal;
                }

                if (callee.type == ObjectType::FUNCTION) {
                    if (callee.data.function.is_builtin) {
                        return call_method(callee, callee, args, env);
                    }

                    auto& f = callee.data.function;
                    if (args.size() != f.params.size()) {
                        throw std::runtime_error(
                            "Expected " + std::to_string(f.params.size()) +
                            " args, got " + std::to_string(args.size()));
                    }
                    auto callEnv = std::make_shared<Environment>(f.env);
                    for (size_t i = 0; i < args.size(); ++i) {
                        callEnv->define(f.params[i], args[i]);
                    }
                    try {
                        return evaluate(f.body.get(), callEnv, is_method);
                    } catch (const ReturnValue& rv) {
                        return rv.value;
                    }
                }
                throw std::runtime_error("Cannot call type: " + callee.to_string());
            }
            case NodeType::INDEX: {
                Value target = evaluate(node->children[0].get(), env, is_method);
                Value index = evaluate(node->children[1].get(), env, is_method);
                if (target.type == ObjectType::LIST && index.type == ObjectType::INTEGER) {
                    long i = index.data.integer;
                    if (i < 0 || i >= static_cast<long>(target.data.list.size())) {
                        throw std::runtime_error("Index out of range.");
                    }
                    return target.data.list[i];
                } else if (target.type == ObjectType::MAP && index.type == ObjectType::STRING) {
                    auto it = target.data.map.find(index.data.string);
                    if (it == target.data.map.end()) {
                        throw std::runtime_error("Key not found: " + index.data.string);
                    }
                    return it->second;
                }
                throw std::runtime_error("Invalid index operation.");
            }
            case NodeType::MAP: {
                Value map_val(ObjectType::MAP);
                for (size_t i = 0; i < node->children.size(); i += 2) {
                    Value key = evaluate(node->children[i].get(), env, is_method);
                    if (key.type != ObjectType::STRING) throw std::runtime_error("Map keys must be strings.");
                    Value value = evaluate(node->children[i + 1].get(), env, is_method);
                    map_val.data.map[key.data.string] = value;
                }
                return map_val;
            }
            
            case NodeType::GET_ATTR: {
                ASTNode* objNode = node->children[0].get();
                const std::string& attr_name = node->value;

                if (objNode->type == NodeType::VARIABLE) {
                    const std::string& objName = objNode->value;
                    Value object = env->get(objName);

                    if (object.type == ObjectType::INSTANCE) {
                        // First check instance attributes
                        auto it = object.data.instance.attributes.find(attr_name);
                        if (it != object.data.instance.attributes.end()) {
                            return it->second;
                        }

                        // Then check methods in current class
                        if (object.data.instance.class_ref) {
                            Value method = find_method(object.data.instance.class_ref, attr_name);
                            if (method.type == ObjectType::FUNCTION) {
                                return method;
                            }
                        }

                        // If not found, check parent class attributes
                        if (object.data.instance.class_ref && 
                            object.data.instance.class_ref->data.class_obj.parent) {
                            auto parent = object.data.instance.class_ref->data.class_obj.parent;
                            // Create a temporary instance of the parent class to access its attributes
                            Value parent_inst(ObjectType::INSTANCE);
                            parent_inst.data.instance.class_name = parent->data.class_obj.name;
                            parent_inst.data.instance.class_ref = parent;
                            parent_inst.data.instance.attributes = object.data.instance.attributes;
                            
                            try {
                                return evaluate(node, env, is_method);
                            } catch (const std::runtime_error&) {
                                // If attribute not found in parent, continue to error
                            }
                        }

                        throw std::runtime_error("Instance of '" + object.data.instance.class_name + "' has no attribute or method '" + attr_name + "'");
                    }

                    if (object.type == ObjectType::MAP) {
                        auto it = object.data.map.find(attr_name);
                        if (it != object.data.map.end()) {
                            return it->second;
                        }
                        throw std::runtime_error("Map has no key '" + attr_name + "'");
                    }

                    throw std::runtime_error("Cannot get attribute '" + attr_name + "' from type " + object.to_string());
                } else {
                    throw std::runtime_error("Only 'self.attr' access is supported currently.");
                }
            }


            case NodeType::IF: {
                Value condition = evaluate(node->children[0].get(), env, is_method);
                if (condition.is_truthy()) return evaluate(node->children[1].get(), env, is_method);
                else if (node->children.size() > 2) return evaluate(node->children[2].get(), env, is_method);
                return Value();
            }
            case NodeType::WHILE: {
                Value last_val;
                while (evaluate(node->children[0].get(), env, is_method).is_truthy()) {
                    last_val = evaluate(node->children[1].get(), env, is_method);
                }
                return last_val;
            }
            case NodeType::FOR: {
                Value iterable = evaluate(node->children[0].get(), env, is_method);
                const std::string& loop_var_name = node->value;
                if (iterable.type != ObjectType::LIST && iterable.type != ObjectType::STRING) {
                    throw std::runtime_error("For loop requires an iterable (list or string).");
                }
                auto loop_env = std::make_shared<Environment>(env);
                Value last_val;
                if (iterable.type == ObjectType::LIST) {
                    for (const auto& item : iterable.data.list) {
                        loop_env->define(loop_var_name, item);
                        last_val = evaluate(node->children[1].get(), loop_env, is_method);
                    }
                } else {
                    for (char c : iterable.data.string) {
                        loop_env->define(loop_var_name, Value(std::string(1, c)));
                        last_val = evaluate(node->children[1].get(), loop_env, is_method);
                    }
                }
                return last_val;
            }
            case NodeType::REPEAT: {
                Value count_val = evaluate(node->children[0].get(), env, is_method);
                if (count_val.type != ObjectType::INTEGER) throw std::runtime_error("Repeat requires an integer count.");
                long count = count_val.data.integer;
                Value last_val;
                for (long i = 0; i < count; ++i) {
                    last_val = evaluate(node->children[1].get(), env, is_method);
                }
                return last_val;
            }
            case NodeType::TRY: {
                try {
                    return evaluate(node->children[0].get(), env, is_method);
                } catch (const std::exception&) {
                    return evaluate(node->children[1].get(), env, is_method);
                }
            }
            case NodeType::IMPORT: {
                const std::string& module_name = node->value;
                auto cache_it = modules_cache.find(module_name);
                if (cache_it != modules_cache.end()) {
                    env->define(module_name, cache_it->second);
                    return cache_it->second;
                }
                std::string source;
                auto source_it = modules_source.find(module_name);
                if (source_it != modules_source.end()) {
                    source = source_it->second;
                } else {
                    fs::path module_path = module_name + ".levy";
                    if (!fs::exists(module_path)) throw std::runtime_error("Module not found: " + module_name);
                    std::ifstream file(module_path);
                    if (!file.is_open()) throw std::runtime_error("Could not open module: " + module_name);
                    std::stringstream buffer;
                    buffer << file.rdbuf();
                    source = buffer.str();
                    file.close();
                    modules_source[module_name] = source;
                }
                Lexer lexer(source);
                auto tokens = lexer.tokenize();
                Parser parser(tokens);
                auto ast = parser.parse();
                auto module_env = std::make_shared<Environment>(global);
                evaluate(ast.get(), module_env, is_method);
                Value module_obj(ObjectType::MAP);
                for (const auto& pair : module_env->variables) {
                    module_obj.data.map[pair.first] = pair.second;
                }
                modules_cache[module_name] = module_obj;
                env->define(module_name, module_obj);
                return module_obj;
            }
            case NodeType::RETURN: {
                Value ret_val = node->children.empty() ? Value() : evaluate(node->children[0].get(), env, is_method);
                throw ReturnValue(ret_val);
            }
            default:
                throw std::runtime_error("Unknown AST node type: " + std::to_string((int)node->type));
        }
    } catch (const ReturnValue& ret) {
        throw ret;
    }
    return Value();
}
};

Value Interpreter::call_method(Value& instance,
    Value& method,
    const std::vector<Value>& args,
    std::shared_ptr<Environment> env)
{
    if (method.data.function.is_builtin) {
        const auto& name = method.data.function.builtin_name;
        if (name == "file.read") return builtin_file_read(args, instance);
        if (name == "file.write") return builtin_file_write(args, instance);
        if (name == "file.close") return builtin_file_close(args, instance);
        if (name == "math.sin") return builtin_math_sin(args);
        if (name == "math.cos") return builtin_math_cos(args);
        if (name == "say") return builtin_say(args);
        if (name == "ask") return builtin_ask(args);
        if (name == "len") return builtin_len(args);
        if (name == "range") return builtin_range(args);
        if (name == "type") return builtin_type(args);
        if (name == "int") return builtin_int(args);
        if (name == "float") return builtin_float(args);
        if (name == "str") return builtin_str(args);
        if (name == "open") return builtin_open(args);
        if (name == "append") return builtin_append(args);
        throw std::runtime_error("Unknown built-in function: " + name);
    }

    const auto& f = method.data.function;
    if (args.size() != f.params.size()) {
        throw std::runtime_error("Expected " + std::to_string(f.params.size()) +
                                 " args, got " + std::to_string(args.size()));
    }

    auto callEnv = std::make_shared<Environment>(f.env);

    // Bind all args
    for (size_t i = 0; i < args.size(); ++i) {
        callEnv->define(f.params[i], args[i]);
    }

    // Automatically define 'self' if this is a method call
    if (instance.type == ObjectType::INSTANCE) {
        callEnv->define("self", instance);

        // Add super support
        if (instance.data.instance.class_ref && 
            instance.data.instance.class_ref->data.class_obj.parent) {
            auto parent = instance.data.instance.class_ref->data.class_obj.parent;
            Value super_map(ObjectType::MAP);
            for (const auto& [name, method] : parent->data.class_obj.methods) {
                super_map.data.map[name] = method;
            }
            callEnv->define("super", super_map);
        }
    }

    Value result;
    try {
        result = evaluate(f.body.get(), callEnv, true);
    } catch (const ReturnValue& rv) {
        result = rv.value;
    }

    // Copy attributes back to the original instance
    if (instance.type == ObjectType::INSTANCE) {
        Value self_val = callEnv->get("self");
        if (self_val.type == ObjectType::INSTANCE) {
            instance.data.instance.attributes = self_val.data.instance.attributes;
        }
    }

    return result;
}


// Main function to run the interpreter
int main(int argc, char* argv[]) {
    Interpreter interpreter;

    if (argc == 2) {
        interpreter.run_file(argv[1]);
        return 0;              // <— exit here, never fall through
    }

    if (argc == 1) {
        interpreter.run_repl();
        return 0;
    }

    std::cerr << "Usage: " << argv[0] << " [script.ly]\n";
    return 1;
}

