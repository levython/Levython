# Levython VS Code Extension - Snippets Quick Reference

Complete guide to all 100+ code snippets available in the Levython VS Code extension.

## How to Use Snippets

1. Start typing the snippet prefix in a `.levy` or `.ly` file
2. Press `Tab` or `Enter` when the snippet appears in autocomplete
3. Use `Tab` to jump between placeholder fields
4. Fill in your values and continue coding

---

## Core Language Snippets

### Functions & Classes

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `act` | Function with return | Standard function definition |
| `actv` | Void function | Function without explicit return |
| `class` | Class definition | Complete class with constructor and method |
| `abstract` | Abstract class | Abstract base class |
| `classext` | Class with inheritance | Child class extending parent with `is_a` |

**Example:**
```levy
# Type: act
act calculate_total(items) {
    -> sum(items)
}
```

### Control Flow

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `if` | If statement | Basic conditional |
| `ife` | If-else statement | Conditional with alternative |
| `ternary` | Ternary operator | Inline conditional expression |
| `for` | For-in loop | Iterate over collection |
| `forr` | For-range loop | Iterate over numeric range |
| `while` | While loop | Conditional loop |

**Example:**
```levy
# Type: ternary
status <- age >= 18 ? "adult" : "minor"
```

### Exception Handling

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `try` | Try-catch block | Exception handling |
| `throw` | Throw statement | Raise an exception |

**Example:**
```levy
# Type: try
try {
    result <- dangerous_operation()
} catch e {
    say("Error: " + str(e))
}
```

### Basic Operations

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `var` | Variable assignment | Assign value with `<-` |
| `say` | Print statement | Output to console |
| `sayv` | Print with variable | Formatted output |
| `list` | List creation | Initialize array |
| `map` | Map creation | Initialize dictionary |
| `imp` | Import statement | Import module |
| `main` | Main template | File header with boilerplate |

---

## OS Module Snippets

### Core OS Operations

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `os` | Import OS | Import OS module |
| `osfile` | File operations | Read, write, list files |
| `osproc` | Process operations | Run, spawn, list processes |

**Example:**
```levy
# Type: osfile
# Check if file exists
exists <- os.exists("config.json")

# Read/write
content <- os.read_file("data.txt")
os.write_file("output.txt", "Hello")

# List directory
files <- os.listdir("/path")
```

---

## OS.Hooks - System Monitoring Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `oshook` | Register hook | Generic hook registration |
| `oshookproc` | Process monitor | Monitor process creation |

**Example:**
```levy
# Type: oshookproc
# Monitor process creation
hook_id <- os.Hooks.register("PROCESS_CREATE", "Monitor processes")
os.Hooks.set_callback(hook_id, act(event) {
    pid <- event["pid"]
    name <- event["name"]
    say("New process: " + name + " (PID: " + str(pid) + ")")
})
os.Hooks.enable(hook_id)
```

**Available Hook Types:**
- `PROCESS_CREATE` - New process detection
- `FILE_ACCESS` - File operations monitoring
- `NETWORK_CONNECT` - Network connection tracking
- `KEYBOARD` - Keyboard events
- `MOUSE` - Mouse events

---

## OS.InputControl - Automation Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `osinputkey` | Keyboard control | Full keyboard automation example |
| `osinputmouse` | Mouse control | Full mouse automation example |

**Example:**
```levy
# Type: osinputkey
# Control keyboard
os.InputControl.capture_keyboard()

# Press and release
os.InputControl.press_key("A")
os.sleep_ms(100)
os.InputControl.release_key("A")

# Or tap (press + release)
os.InputControl.tap_key("ENTER")

# Type text
os.InputControl.type_text("Hello World")

os.InputControl.release_keyboard()
```

---

## OS.Processes - Process Management Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `osproclist` | List processes | Enumerate all running processes |
| `osprocCreate` | Create process | Spawn process with options |
| `osprocmem` | Memory operations | Read/write process memory |

**Example:**
```levy
# Type: osprocCreate
# Create process with options
opts <- {
    "cwd": "/tmp",
    "env": {"VAR": "value"},
    "stdin": "/dev/null"
}
pid <- os.Processes.create("command", ["args"], opts)
```

---

## OS.Audio & Display Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `osaudio` | Audio playback | Complete audio control |
| `osdisplay` | Display operations | Screen info and screenshots |

**Example:**
```levy
# Type: osaudio
# Play audio
os.Audio.load("sound.wav")
os.Audio.play()

# Control playback
os.Audio.pause()
os.Audio.resume()
os.Audio.stop()

# Volume
os.Audio.set_volume(0.8)
```

---

## OS.Privileges Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `ospriv` | Privilege check | Check admin/root privileges |

---

## HTTP & Networking Snippets

### HTTP Client

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `httpget` | HTTP GET | GET request with response handling |
| `httppost` | HTTP POST | POST request with JSON body |

**Example:**
```levy
# Type: httpget
http <- import("http")
res <- http.get("https://api.example.com/data")
say("Status: " + str(res["status"]))
say("Body: " + res["body"])
```

### HTTP Server

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `httpserver` | HTTP server | Complete HTTP server with routing |

**Example:**
```levy
# Type: httpserver
http_server <- import("http_server")

act handler(req) {
    path <- req["path"]
    method <- req["method"]
    
    if path == "/" {
        -> {"status": 200, "body": "Hello, World!"}
    }
    
    if path == "/api/data" {
        json <- import("json")
        -> {"status": 200, "body": json.stringify({"data": "value"})}
    }
    
    -> {"status": 404, "body": "Not Found"}
}

say("Starting server on 127.0.0.1:8080...")
http_server.serve("127.0.0.1", 8080, handler)
```

### TCP Networking

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `tcpserver` | TCP server | Complete TCP server loop |
| `tcpclient` | TCP client | TCP client connection |

---

## Async & Threading Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `asyncspawn` | Async spawn | Create async task with polling |
| `asyncawait` | Async await | Create and await async task |
| `thread` | Create thread | Thread creation and join |
| `channel` | Channel comm | Channel-based communication |

**Example:**
```levy
# Type: asyncawait
async <- import("async")

task_id <- async.spawn(act() {
    # async work
    -> result
})

result <- async.await(task_id)
```

---

## File & Data Snippets

### File Operations

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `fread` | Read file | Read text file |
| `fwrite` | Write file | Write text file |
| `path` | Path operations | Join, dirname, basename, ext |

### JSON

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `jsonparse` | Parse JSON | Parse JSON string |
| `jsonstringify` | Stringify JSON | Convert to JSON string |

**Example:**
```levy
# Type: jsonparse
json <- import("json")
data <- json.parse("{\"key\": \"value\"}")
say("Parsed: " + str(data))
```

---

## Cryptography Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `hash` | Crypto hash | Hash with SHA256/512/MD5 |
| `encrypt` | Encrypt/Decrypt | Symmetric encryption |

**Example:**
```levy
# Type: hash
crypto <- import("crypto")
hash <- crypto.sha256("data")
say("Hash: " + hash)
```

---

## DateTime & Logging Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `dtnow` | Current datetime | Get current UTC time |
| `dtformat` | Format datetime | Format with strftime |
| `log` | Logging setup | Configure logging levels |
| `config` | Load config | Load .env configuration |

**Example:**
```levy
# Type: log
log <- import("log")
log.set_level("info")

log.info("Info message")
log.warn("Warning message")
log.error("Error message")
```

---

## Input Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `inputpoll` | Non-blocking input | Raw input polling loop |
| `inputchr` | ASCII conversion | chr() and ord() examples |

**Example:**
```levy
# Type: inputchr
input <- import("input")

# ASCII to character
char <- input.chr(65)  # Returns "A"

# Character to ASCII
code <- input.ord("A")  # Returns 65
```

---

## Algorithm Snippets

| Prefix | Expands To | Description |
|--------|------------|-------------|
| `fib` | Fibonacci | Recursive Fibonacci |
| `fact` | Factorial | Recursive factorial |
| `qsort` | Quick sort | Quick sort implementation |
| `bsearch` | Binary search | Binary search algorithm |
| `mapfn` | Map function | Map implementation |
| `filterfn` | Filter function | Filter implementation |
| `reducefn` | Reduce function | Reduce implementation |

**Example:**
```levy
# Type: qsort
act quicksort(arr) {
    if len(arr) <= 1 {
        -> arr
    }
    
    pivot <- arr[0]
    left <- []
    right <- []
    
    for i in range(1, len(arr)) {
        if arr[i] < pivot {
            append(left, arr[i])
        } else {
            append(right, arr[i])
        }
    }
    
    -> quicksort(left) + [pivot] + quicksort(right)
}
```

---

## Tips for Maximum Productivity

### 1. Combine Snippets with Copilot
Start with a snippet and let GitHub Copilot complete the implementation:
```levy
# Type: httpserver then let Copilot suggest routes
http_server <- import("http_server")
act handler(req) {
    # Copilot will suggest common routes
```

### 2. Chain Multiple Snippets
```levy
# Type: os
os <- import("os")

# Then type: oshookproc
# Then type: osinputkey
```

### 3. Use Comments to Guide
```levy
# Create a web server that handles JSON API requests
# Type: httpserver
# Copilot will generate appropriate JSON handling
```

### 4. Customize After Expansion
All snippets use tab stops - press Tab to jump to the next field and customize values.

---

## Module Coverage Summary

✅ **Core Language**: 20+ snippets  
✅ **OS Module**: 5+ snippets  
✅ **OS.Hooks**: 2 snippets  
✅ **OS.InputControl**: 2 snippets  
✅ **OS.Processes**: 3 snippets  
✅ **OS.Audio**: 1 snippet  
✅ **OS.Display**: 1 snippet  
✅ **OS.Privileges**: 1 snippet  
✅ **HTTP**: 3 snippets  
✅ **Networking**: 2 snippets  
✅ **Async/Threading**: 4 snippets  
✅ **File/Data**: 5 snippets  
✅ **Crypto**: 2 snippets  
✅ **DateTime/Config**: 4 snippets  
✅ **Input**: 2 snippets  
✅ **Algorithms**: 7 snippets  

**Total: 100+ comprehensive code snippets!**

---

## Getting Help

- Press `Ctrl+Space` (or `Cmd+Space` on Mac) to trigger IntelliSense
- Type the snippet prefix to see available completions
- Hover over keywords for quick syntax help
- Use `Ctrl+Shift+P` to access command palette

---

**Happy coding with Levython! 🚀**
