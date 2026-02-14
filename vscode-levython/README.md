# Levython Language Extension for VS Code

Complete language support for **Levython 1.0.3** - the high-performance, JIT-compiled programming language with powerful OS automation capabilities and system-level control.

**🤖 GitHub Copilot Ready** - This extension is specifically optimized for AI-powered code generation, providing comprehensive language context for flawless Levython development with Copilot.

## ✨ Features

- **🎨 Advanced Syntax Highlighting** - Complete support for all Levython keywords, operators, modules, and constructs
- **🐉 Official Dragon Logo Icon** - Authentic Levython dragon for .levy and .ly files
- **�📝 150+ Code Snippets** - Comprehensive snippets for every module, feature, and use case
- **🧠 IntelliSense Support** - Smart completions for modules, functions, classes, and keywords
- **🔧 Auto-formatting** - Bracket matching, auto-indentation, auto-closing pairs, and smart formatting
- **🤖 GitHub Copilot Optimized** - Detailed syntax definitions and context for perfect AI code generation
- **📦 Complete Language Coverage** - All core modules and 8 advanced OS submodules
- **🎯 Snippet-First Development** - Fast development with intuitive snippet prefixes

## 🆕 What's New in 1.0.3

### Language Features
- ✅ **Ternary operator** (`condition ? true_value : false_value`)
- ✅ **Enhanced exception handling** (try-catch-finally)
- ✅ **Abstract classes** and inheritance with `is_a`
- ✅ **ASCII/character conversion** (`input.chr()`, `input.ord()`)
- ✅ **Compound assignment operators** (`+=`, `-=`, `*=`, `/=`, `%=`, `^=`)
- ✅ **Super keyword** for parent class access

### Advanced OS Modules (New System-Level APIs)
- ✅ **OS.Hooks** - System event hooking and monitoring
- ✅ **OS.InputControl** - Keyboard, mouse, and touch automation
- ✅ **OS.Processes** - Advanced process control and memory operations
- ✅ **OS.Audio** - Audio device management, playback, and recording
- ✅ **OS.Display** - Screen capture, pixel manipulation, and overlays
- ✅ **OS.Privileges** - Permission management and elevation
- ✅ **OS.Events** - Filesystem, network, and power event monitoring
- ✅ **OS.Persistence** - Autostart, services, and scheduled tasks

### Extension Improvements
- ✅ 150+ comprehensive code snippets
- ✅ Complete syntax highlighting for all modules and methods
- ✅ Enhanced IntelliSense for system APIs
- ✅ Optimized for GitHub Copilot integration
- ✅ Improved auto-indentation and formatting

## 📦 Installation

### From VS Code Marketplace
1. Open VS Code
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac)
3. Search for "Levython"
4. Click Install

### From VSIX File
1. Download the `.vsix` file from releases
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

## 🚀 Quick Start

1. Create a new file with `.levy` or `.ly` extension
2. Start typing and enjoy syntax highlighting
3. Use snippets (see below) for rapid development
4. Let GitHub Copilot help you write Levython code!

### Example with Snippets

Type `main` and press Tab:
```levy
#!/usr/bin/env levython

# Script description

act main() {
	# main code
}

main()
```

Type `oshook` for system monitoring:
```levy
import os

hook_id <- OS.Hooks.register("PROCESS_CREATE", "Monitor processes")
OS.Hooks.set_callback(hook_id, act(event) {
	say("Event: " + str(event))
	# handle event
})
OS.Hooks.enable(hook_id)
```

## 🎨 Levython Icon Theme

The extension includes the **official Levython dragon logo** as the file icon for all your `.levy` and `.ly` files!

### Auto-Activation

The dragon icon automatically appears for all Levython files as soon as you install the extension. Works perfectly with any icon theme!

### Features

- **🐉 Official Dragon Logo** - The authentic Levython dragon in fiery red/orange
- **📄 File Recognition** - Instant visual identification of `.levy` and `.ly` files
- **🎭 Universal Compatibility** - Works with Material Icons, VSCode Icons, or any theme
- **⚡ Zero Config** - Automatically activates on installation

Your Levython scripts will display the iconic dragon logo in the file explorer!

## 📚 Complete Snippets Reference

### Core Language (40+ snippets)

| Prefix | Description | Example Output |
|--------|-------------|----------------|
| `var` | Variable assignment | `name <- "value"` |
| `say` | Print message | `say("Hello")` |
| `sayv` | Print with variable | `say("Count: " + str(n))` |
| `ask` | Get user input | `answer <- ask("Question?")` |
| `act` | Create function | `act name(args) { -> result }` |
| `actv` | Create void function | `act name(args) { ... }` |
| `lambda` | Lambda function | `act(x) { x * 2 }` |
| `if` | If statement | `if condition { }` |
| `ife` | If-else | `if cond { } else { }` |
| `ifeif` | If-elif-else chain | Full conditional chain |
| `ternary` | Ternary operator | `result <- x > 0 ? "yes" : "no"` |
| `for` | For loop | `for item in list { }` |
| `forr` | For with range | `for i in range(0, 10) { }` |
| `while` | While loop | `while condition { }` |
| `class` | Create class | Complete class structure |
| `abstract` | Abstract class | Class with abstract methods |
| `classext` | Class with inheritance | `class Child is a Parent { }` |
| `try` | Try-catch block | Exception handling |
| `throw` | Throw exception | `throw "error"` |
| `imp` | Import module | `import module` |
| `list` | Create list | `list <- [1, 2, 3]` |
| `map` | Create map | `map <- {"key": "value"}` |
| `main` | Main template | Complete file template |

### HTTP & Networking (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `httpget` | HTTP GET request | API calls |
| `httppost` | HTTP POST request | Submit data |
| `httpserver` | HTTP server setup | Web service |
| `tcpserver` | TCP server | Network service |
| `tcpclient` | TCP client | TCP connection |

### File & OS Operations (15+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `fread` | Read file | File input |
| `fwrite` | Write file | File output |
| `os` | Import OS module | System operations |
| `osfile` | OS file operations | File management |
| `osproc` | Run OS process | Execute commands |
| `osruncap` | Run and capture output | Get command output |

### OS.Hooks - System Monitoring (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `oshook` | Register hook | Monitor system events |
| `oshookproc` | Hook process creation | Track new processes |
| `oshookfile` | Hook file access | Monitor file operations |
| `oshookkey` | Hook keyboard | Track keyboard input |
| `oshookmouse` | Hook mouse | Monitor mouse events |

**Real-World Use Cases:**
- Security monitoring and threat detection
- Application behavior analysis
- System auditing and compliance
- Performance profiling and debugging

### OS.InputControl - Input Automation (15+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `osinputkey` | Keyboard control | Automate typing |
| `osinputtype` | Type text | Simulate user typing |
| `osinputpress` | Press key | Single key press |
| `osinputtap` | Tap key | Quick key tap |
| `osinputmouse` | Mouse control | Automate mouse |
| `osinputclick` | Click mouse | Simulate clicks |
| `osinputscroll` | Scroll mouse | Automate scrolling |
| `osinputremap` | Remap key | Change key mapping |
| `osinputblock` | Block key | Disable key |
| `inputchr` | ASCII conversion | Convert ASCII/characters |

**Real-World Use Cases:**
- Test automation and UI testing
- Accessibility tools
- Gaming macros and bots
- Remote control applications
- Workflow automation

### OS.Processes - Process Management (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `osproclist` | List processes | Monitor running processes |
| `osproccreate` | Create process | Launch with options |
| `osproccontrol` | Control process | Suspend/resume/terminate |
| `osprocmem` | Memory operations | Read/write process memory |
| `osprocprio` | Set priority | Control process priority |
| `osprocinfo` | Get process info | Detailed process data |

**Real-World Use Cases:**
- Process monitoring and management
- Debugging and analysis
- Game modding and reverse engineering
- System administration
- Performance optimization

### OS.Display - Screen & Graphics (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `osdisplay` | List displays | Get display info |
| `osdispcap` | Capture screen | Screenshot |
| `osdispregion` | Capture region | Partial screenshot |
| `osdisppixel` | Get pixel color | Read screen pixel |
| `osdispcursor` | Hide/show cursor | Cursor control |

**Real-World Use Cases:**
- Screen recording and streaming
- Computer vision and image processing
- Game overlays and HUDs
- Accessibility tools
- Automated testing

### OS.Audio - Audio Control (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `osaudio` | List devices | Audio device management |
| `osaudiovol` | Volume control | Get/set volume |
| `osaudioplay` | Play sound | Sound playback |
| `osaudiotone` | Play tone | Generate tone |
| `osaudiorec` | Record audio | Audio recording |
| `osaudiostream` | Audio streaming | Stream audio data |

**Real-World Use Cases:**
- Audio playback and recording applications
- Voice assistants
- Audio processing tools
- System sound control
- Music and media applications

### OS.Privileges - Permission Management (8+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `ospriv` | Check privileges | Verify elevation |
| `osprivelevate` | Request elevation | Get admin access |
| `osprivadmin` | Run as admin | Execute with privileges |
| `osprivlevel` | Get privilege level | Check current level |

**Real-World Use Cases:**
- Administrative task automation
- Security tools
- System maintenance scripts
- Privilege management
- Installation and configuration

### OS.Events - Event Monitoring (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `oseventfile` | Watch files | Monitor file changes |
| `oseventnet` | Watch network | Network monitoring |
| `oseventpwr` | Watch power | Power events |
| `oseventpoll` | Poll events | Check for events |
| `oseventloop` | Event loop | Process events |

**Real-World Use Cases:**
- File change monitoring
- Network activity logging
- Power management
- System event automation
- Hot-reload development tools

### OS.Persistence - System Persistence (8+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `ospersistauto` | Add autostart | App autostart |
| `ospersistsvc` | Install service | Windows/Linux service |
| `ospersistctl` | Control service | Start/stop service |
| `ospersistsched` | Scheduled task | Task scheduling |

**Real-World Use Cases:**
- Application deployment and installation
- System maintenance automation
- Background service creation
- Scheduled task management
- Startup configuration

### Async & Threading (8+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `async` | Async task | Asynchronous operations |
| `asyncsleep` | Async sleep | Non-blocking delay |
| `thread` | Spawn thread | Concurrent execution |
| `channel` | Create channel | Thread communication |

### JSON & Data (5+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `jsonparse` | Parse JSON | Deserialize JSON |
| `jsonstr` | Stringify JSON | Serialize to JSON |

### Cryptography (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `sha256` | SHA256 hash | Secure hashing |
| `cryptorand` | Random bytes | Generate randomness |
| `hmac` | HMAC-SHA256 | Message authentication |
| `b64enc` | Base64 encode | Encode data |
| `b64dec` | Base64 decode | Decode data |

### DateTime & Logging (8+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `dtnow` | Get current time | Timestamp |
| `dtfmt` | Format datetime | Format date/time |
| `log` | Logging setup | Configure logging |
| `loglevel` | Log at levels | Debug/info/warn/error |
| `config` | Load config | Configuration management |

### Advanced Operations (15+ snippets)

| Prefix | Description | Category |
|--------|-------------|----------|
| `mem` | Memory operations | Low-level |
| `bitwise` | Bitwise operations | Low-level |
| `tensor` | Create tensor | ML/AI |
| `tensorop` | Tensor operations | ML/AI |
| `simd` | SIMD operations | Performance |
| `random` | Random numbers | Utilities |
| `assert` | Assertion | Testing |
| `time` | Time measurement | Performance |
| `sleep` | Sleep seconds | Utilities |
| `sleepms` | Sleep milliseconds | Utilities |

### Collection Operations (15+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `filter` | Filter list | Data filtering |
| `mapfn` | Map function | Data transformation |
| `reduce` | Reduce list | Aggregation |
| `enumerate` | Enumerate with index | Indexed iteration |
| `zip` | Zip lists | Parallel iteration |
| `sorted` | Sort list | Sorting |
| `reversed` | Reverse list | Reverse order |
| `minmax` | Find min/max | Range finding |
| `sum` | Sum elements | Aggregation |
| `str` | String operations | Text processing |
| `listop` | List operations | List manipulation |
| `mapop` | Map operations | Dictionary operations |

### Math & Type Operations (10+ snippets)

| Prefix | Description | Use Case |
|--------|-------------|----------|
| `math` | Math functions | Mathematical operations |
| `trig` | Trigonometry | Trigonometric functions |
| `type` | Type checking | Runtime type checking |
| `convert` | Type conversion | Type casting |

## 🤖 GitHub Copilot Integration

This extension is **specifically optimized** for GitHub Copilot. The comprehensive syntax definitions and snippets provide Copilot with complete context about:

- ✅ All Levython keywords and operators
- ✅ Module structure and naming conventions
- ✅ Function signatures and patterns
- ✅ Common idioms and best practices
- ✅ System API usage patterns
- ✅ Error handling patterns
- ✅ Async/await patterns

### Tips for Best Copilot Experience

1. **Start with comments**: Describe what you want in a comment, Copilot will generate the code
   ```levy
   # Create a TCP server that listens on port 8080 and echoes messages
   ```

2. **Use snippet prefixes**: Type snippet prefixes to guide Copilot
   ```levy
   # Type 'tcpserver' and press Tab
   ```

3. **Import modules first**: Import needed modules at the top for better suggestions
   ```levy
   import os
   import http
   # Now Copilot knows these modules are available
   ```

4. **Descriptive names**: Use clear variable and function names
   ```levy
   act process_user_data(user_id) {
       # Copilot understands the context from the name
   }
   ```

5. **Function signatures**: Write function signatures first, let Copilot fill the body
   ```levy
   act validate_email(email) {
       # Copilot will suggest email validation logic
   }
   ```

### Example Workflows with Copilot

**Example 1: Web Server**
```levy
# Create an HTTP server that serves a REST API for user management
import http_server
import json

# Copilot will suggest the complete implementation
```

**Example 2: File Processing**
```levy
# Process all .txt files in a directory and count words
import os
import fs

# Copilot will suggest the file processing logic
```

**Example 3: System Automation**
```levy
# Monitor system processes and alert when CPU usage exceeds 80%
import os

# Copilot will suggest process monitoring code
```

## 📖 Language Reference

### Core Syntax

**Variables:**
```levy
name <- "value"
count <- 42
active <- true
data <- none
```

**Functions:**
```levy
act greet(name) {
	-> "Hello, " + name
}

# Void function
act log_message(msg) {
	say("[LOG] " + msg)
}
```

**Classes and Inheritance:**
```levy
class Person {
	init(name, age) {
		self.name <- name
		self.age <- age
	}
	
	greet() {
		say("Hi, I'm " + self.name)
	}
}

class Employee is a Person {
	init(name, age, company) {
		super.init(name, age)
		self.company <- company
	}
	
	greet() {
		super.greet()
		say("I work at " + self.company)
	}
}
```

**Conditionals:**
```levy
# If statement
if x > 0 {
	say("positive")
} elif x < 0 {
	say("negative")
} else {
	say("zero")
}

# Ternary operator
status <- active ? "ON" : "OFF"
message <- error ? "Failed: " + error : "Success"
```

**Loops:**
```levy
# For loop
for i in range(0, 10) {
	say(str(i))
}

# For-in loop
for item in items {
	say(str(item))
}

# While loop
while condition {
	# code
}
```

**Exception Handling:**
```levy
try {
	risky_operation()
} catch {
	say("Error occurred")
}
```

### Standard Modules

- **os** - Operating system interfaces
- **http** - HTTP client
- **http_server** - HTTP server
- **fs** - Filesystem operations
- **path** - Path manipulation
- **process** - Process control
- **json** - JSON parsing
- **net** - Networking (TCP/UDP)
- **thread** - Threading
- **channel** - Channel communication
- **async** - Async/await
- **crypto** - Cryptography
- **datetime** - Date and time
- **log** - Logging
- **config** - Configuration
- **input** - Input handling

### System Modules (Advanced)

- **OS.Hooks** - System event hooking
- **OS.InputControl** - Input automation
- **OS.Processes** - Process management
- **OS.Audio** - Audio control
- **OS.Display** - Display operations
- **OS.Privileges** - Permission management
- **OS.Events** - Event monitoring
- **OS.Persistence** - System persistence

## 🎯 Real-World Use Cases

### Automation & Scripting
- System administration tasks
- File processing and organization
- Batch operations
- Scheduled tasks
- DevOps automation

### Web Development
- HTTP servers and REST APIs
- Web scraping
- API clients
- Microservices
- WebSocket servers

### System Utilities
- Process monitoring
- File watchers
- System diagnostics
- Performance tools
- Resource management

### Security & Research
- System monitoring
- Event logging
- Access control
- Security auditing
- Vulnerability scanning

### Desktop Automation
- UI testing
- Keyboard/mouse automation
- Screen capture
- Workflow automation
- RPA (Robotic Process Automation)

### Audio/Video
- Audio processing
- Screen recording
- Media control
- Streaming applications
- Real-time audio/video

## 🔧 Configuration

The extension automatically configures optimal settings for Levython:

- **Tab size**: 4 spaces
- **Insert spaces**: false (uses tabs)
- **Auto-indentation**: full
- **Semantic highlighting**: enabled
- **Snippet suggestions**: top priority
- **Quick suggestions**: enabled
- **Accept suggestion on Enter**: on

You can customize these in VS Code settings under `[levython]`.

## 📝 File Associations

The extension automatically recognizes:
- `.levy` files - Levython source code
- `.ly` files - Levython source code (short form)

## 🐛 Troubleshooting

### Syntax highlighting not working
- Ensure the file has a `.levy` or `.ly` extension
- Reload VS Code window (`Cmd+Shift+P` → "Reload Window")
- Check that the language mode shows "Levython" in the bottom right

### Snippets not appearing
- Check that snippets are enabled in settings
- Ensure "Snippet Suggestions" are set to "top" or "inline"
- Try typing the full snippet prefix
- Make sure you're pressing Tab after the prefix

### Copilot not suggesting Levython code
- Make sure the file is recognized as Levython (check bottom right of VS Code)
- Add descriptive comments about what you want to do
- Import required modules at the top of the file
- Use proper Levython syntax for function and class definitions

### IntelliSense not working
- Reload the window
- Check that the extension is enabled
- Verify the file is detected as Levython

## 🤝 Contributing

Found a bug or want to add features? Contributions are welcome!

- **Report issues**: [GitHub Issues](https://github.com/levython/Levython/issues)
- **Submit PRs**: [GitHub Pull Requests](https://github.com/levython/Levython/pulls)
- **Discussion**: [GitHub Discussions](https://github.com/levython/Levython/discussions)

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

## 🔗 Links

- **Website**: https://levython.github.io
- **Documentation**: https://levython.github.io/documentation/
- **GitHub**: https://github.com/levython/Levython
- **Issues**: https://github.com/levython/Levython/issues
- **Examples**: https://github.com/levython/Levython/tree/main/examples

## 🌟 Show Your Support

If you find this extension helpful:
- ⭐ Star the [Levython repository](https://github.com/levython/Levython)
- 📝 Write a review on the VS Code Marketplace
- 🐦 Share with your friends and colleagues
- 💡 Contribute snippets or improvements

---

**Levython 1.0.3** - *Be better than yesterday*

Made with ❤️ by developers, for developers who value performance and productivity.

