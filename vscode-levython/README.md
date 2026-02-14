# Levython Language Extension for VS Code

Complete language support for Levython 1.0.3 - the high-performance, JIT-compiled programming language with powerful OS automation capabilities.

## ✨ Features

- **🎨 Advanced Syntax Highlighting** - Complete support for all Levython keywords, operators, and constructs
- **📝 100+ Code Snippets** - Comprehensive snippets for every module and feature
- **🧠 IntelliSense Support** - Smart completions for modules, functions, and keywords
- **🔧 Auto-formatting** - Bracket matching, auto-indentation, and smart formatting
- **🚀 GitHub Copilot Ready** - Optimized for AI-powered code generation
- **📦 Full Language Coverage** - All modules: OS, HTTP, Async, Crypto, Threading, and more

## 🆕 What's New in 1.0.3

- ✅ Ternary operator support (`? :`)
- ✅ Try-catch exception handling
- ✅ Abstract classes and inheritance (`is_a`)
- ✅ 8 new OS submodules (Hooks, InputControl, Processes, Audio, Display, Privileges, Events, Persistence)
- ✅ ASCII/character conversion (`chr`, `ord`)
- ✅ Comprehensive snippets for all features

## 📦 Installation

### From VSIX

1. Download the `.vsix` file
2. Open VS Code
3. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
4. Type "Install from VSIX"
5. Select the downloaded file

### Manual Installation

Copy the `vscode-levython` folder to:
- **Windows**: `%USERPROFILE%\.vscode\extensions\`
- **macOS**: `~/.vscode/extensions/`
- **Linux**: `~/.vscode/extensions/`

Restart VS Code after installation.

## 📚 Snippets Reference

### Core Language

| Prefix | Description |
|--------|-------------|
| `act` | Create a function |
| `actv` | Create a void function |
| `class` | Create a class |
| `abstract` | Create an abstract class |
| `classext` | Create a class with inheritance |
| `try` | Try-catch block |
| `throw` | Throw an exception |
| `if` | If statement |
| `ife` | If-else statement |
| `ternary` | Ternary operator |
| `for` | For loop |
| `forr` | For loop with range |
| `while` | While loop |
| `var` | Variable assignment |
| `say` | Print output |
| `sayv` | Print with variable |
| `list` | Create a list |
| `map` | Create a map |
| `imp` | Import module |
| `main` | Main file template |

### OS Module

| Prefix | Description |
|--------|-------------|
| `os` | Import OS module |
| `osfile` | OS file operations |
| `osproc` | OS process operations |

### OS.Hooks (System Event Monitoring)

| Prefix | Description |
|--------|-------------|
| `oshook` | Register OS hook |
| `oshookproc` | Monitor process creation |

### OS.InputControl (Keyboard/Mouse Automation)

| Prefix | Description |
|--------|-------------|
| `osinputkey` | Keyboard control |
| `osinputmouse` | Mouse control |

### OS.Processes (Process Management)

| Prefix | Description |
|--------|-------------|
| `osproclist` | List all processes |
| `osprocCreate` | Create process with options |
| `osprocmem` | Process memory operations |

### OS.Audio & Display

| Prefix | Description |
|--------|-------------|
| `osaudio` | Audio playback |
| `osdisplay` | Display operations |

### OS.Privileges

| Prefix | Description |
|--------|-------------|
| `ospriv` | Check admin privileges |

### HTTP & Networking

| Prefix | Description |
|--------|-------------|
| `httpget` | HTTP GET request |
| `httppost` | HTTP POST request |
| `httpserver` | HTTP server |
| `tcpserver` | TCP server |
| `tcpclient` | TCP client |

### Async & Threading

| Prefix | Description |
|--------|-------------|
| `asyncspawn` | Async task spawning |
| `asyncawait` | Async await pattern |
| `thread` | Create thread |
| `channel` | Channel communication |

### File & Path Operations

| Prefix | Description |
|--------|-------------|
| `fread` | Read file |
| `fwrite` | Write file |
| `path` | Path operations |

### JSON & Data

| Prefix | Description |
|--------|-------------|
| `jsonparse` | Parse JSON |
| `jsonstringify` | Stringify JSON |

### Cryptography

| Prefix | Description |
|--------|-------------|
| `hash` | Crypto hash (SHA256/512/MD5) |
| `encrypt` | Encrypt/Decrypt |

### DateTime & Logging

| Prefix | Description |
|--------|-------------|
| `dtnow` | Current datetime |
| `dtformat` | Format datetime |
| `log` | Logging |
| `config` | Load configuration |

### Input

| Prefix | Description |
|--------|-------------|
| `inputpoll` | Non-blocking input |
| `inputchr` | ASCII/char conversion |

### Algorithms

| Prefix | Description |
|--------|-------------|
| `fib` | Fibonacci function |
| `fact` | Factorial function |
| `qsort` | Quick sort |
| `bsearch` | Binary search |
| `mapfn` | Map function |
| `filterfn` | Filter function |
| `reducefn` | Reduce function |

## 🎯 Language Syntax

```levy
# Variables and Types
name <- "Levython"
count <- 42
pi <- 3.14159
active <- true
nothing <- none

# Functions
act add(a, b) {
    -> a + b
}

# Classes with Inheritance
class Animal {
    act init(name) {
        self.name <- name
    }
    
    act speak() {
        say(self.name + " makes a sound")
    }
}

class Dog is_a Animal {
    act init(name, breed) {
        self.name <- name
        self.breed <- breed
    }
    
    act speak() {
        say(self.name + " barks!")
    }
}

# Exception Handling
try {
    result <- risky_operation()
} catch e {
    say("Error: " + str(e))
}

# Ternary Operator
status <- count > 10 ? "large" : "small"

# Conditionals
if count > 2 {
    say("big")
} else {
    say("small")
}

# Loops
for i in range(1, 4) {
    say(str(i))
}

items <- ["a", "b", "c"]
for x in items {
    say(x)
}

# OS Automation
os <- import("os")

# Hook system events
hook_id <- os.Hooks.register("PROCESS_CREATE", "Monitor")
os.Hooks.set_callback(hook_id, act(event) {
    say("New process: " + event["name"])
})
os.Hooks.enable(hook_id)

# Control input devices
os.InputControl.capture_keyboard()
os.InputControl.type_text("Hello, World!")
os.InputControl.release_keyboard()

# Manage processes
procs <- os.Processes.list()
for proc in procs {
    say(proc["name"])
}

# Async operations
async <- import("async")
task <- async.spawn(act() {
    async.sleep(1000)
    -> "Done!"
})
result <- async.await(task)

# HTTP server
http_server <- import("http_server")
act handler(req) {
    if req["path"] == "/" {
        -> {"status": 200, "body": "Hello!"}
    }
    -> {"status": 404, "body": "Not Found"}
}
http_server.serve("127.0.0.1", 8080, handler)
```

## 🔌 Available Modules

- **os** - System operations, file I/O, processes
- **os.Hooks** - System event hooking and monitoring
- **os.InputControl** - Keyboard, mouse, touch automation
- **os.Processes** - Advanced process management
- **os.Audio** - Audio playback and recording
- **os.Display** - Display management and screenshots
- **os.Privileges** - Privilege elevation and checks
- **os.Events** - Event system
- **os.Persistence** - Data persistence
- **http** - HTTP client
- **http_server** - HTTP server
- **fs** - File system operations
- **path** - Path manipulation
- **process** - Process control
- **json** - JSON parsing/stringifying
- **url** - URL parsing and encoding
- **net** - TCP/UDP networking
- **thread** - Threading
- **channel** - Channel communication
- **async** - Async/await operations
- **crypto** - Cryptography (hashing, encryption)
- **datetime** - Date and time operations
- **log** - Logging
- **config** - Configuration management
- **input** - Input handling

## 🤖 GitHub Copilot Integration

This extension is optimized for GitHub Copilot. The comprehensive syntax highlighting and snippets help Copilot understand Levython code patterns and generate accurate code suggestions.

**Tips for best results:**
- Use descriptive comments to guide Copilot
- Start with snippets and let Copilot complete the logic
- Reference module names explicitly (e.g., `os.Hooks`, `http.get`)
- Use type hints in comments for complex data structures

## 📖 File Extensions

- `.levy` - Levython source file
- `.ly` - Levython source file (short form)

## 🔗 Links

- [Levython GitHub Repository](https://github.com/levython/Levython)
- [Documentation](https://github.com/levython/Levython#readme)
- [Examples](https://github.com/levython/Levython/tree/main/examples)

## 📝 License

MIT License

## 🙏 Contributing

Contributions are welcome! Please submit issues or pull requests on GitHub.

---

**Enjoy coding with Levython! 🚀**

