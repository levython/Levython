# OS.ProcessManager Quick Reference

## Quick Start

```levy
// Import is automatic - OS module is built-in

// List all processes
processes <- os.ProcessManager.list()

// Get info about current process
info <- os.ProcessManager.get_info(os.getpid())

// Create a new process
pid <- os.ProcessManager.create("python", ["script.py"], {})

// Wait for process to finish
exit_code <- os.ProcessManager.wait(pid, 5000)

// Terminate a process
os.ProcessManager.terminate(pid, yes)
```

---

## Function Reference

### Process Discovery

| Function | Purpose | Returns |
|----------|---------|---------|
| `list()` | Get all running processes | LIST of process maps |
| `get_info(pid)` | Get detailed process info | MAP with process details |

### Process Lifecycle

| Function | Purpose | Returns |
|----------|---------|---------|
| `create(path, args, env)` | Start new process | PID (INTEGER) |
| `terminate(pid, force)` | Stop a process | Success (BOOLEAN) |
| `wait(pid, timeout_ms)` | Wait for completion | Exit code or NONE |
| `suspend(pid)` | Pause process execution | Success (BOOLEAN) |
| `resume(pid)` | Resume paused process | Success (BOOLEAN) |

### Memory Operations (Requires Admin/Root)

| Function | Purpose | Returns |
|----------|---------|---------|
| `read_memory(pid, addr, size)` | Read process memory | Bytes (STRING) |
| `write_memory(pid, addr, data)` | Write process memory | Success (BOOLEAN) |

### Code Injection (Requires Admin/Root)

| Function | Purpose | Returns |
|----------|---------|---------|
| `inject_library(pid, library_path)` | Inject DLL/SO into process | Success (BOOLEAN) |

### Thread Management

| Function | Purpose | Returns |
|----------|---------|---------|
| `list_threads(pid)` | Get all threads in process | LIST of thread maps |

### Priority Management

| Function | Purpose | Returns |
|----------|---------|---------|
| `get_priority(pid)` | Get process priority | Priority (INTEGER) |
| `set_priority(pid, priority)` | Set process priority | Success (BOOLEAN) |

---

## Common Patterns

### Find Process by Name
```levy
act find_process(name) {
    processes <- os.ProcessManager.list()
    for proc in processes {
        if proc["name"].lower().contains(name.lower()) {
            -> proc["pid"]
        }
    }
    -> none
}

// Usage
chrome_pid <- find_process("chrome")
```

### Monitor Process Resource Usage
```levy
act monitor_process(pid, duration_seconds) {
    start_time <- time.now()
    samples <- []
    
    while (time.now() - start_time) < duration_seconds {
        info <- os.ProcessManager.get_info(pid)
        samples.push({
            "time": time.now(),
            "memory": info["memory_usage"],
            "threads": info.get("threads", 0)
        })
        os.sleep(1)
    }
    
    -> samples
}
```

### Safe Process Termination
```levy
act terminate_safely(pid, timeout_ms) {
    // Try graceful termination first
    os.ProcessManager.terminate(pid, no)
    
    // Wait for process to exit
    exit_code <- os.ProcessManager.wait(pid, timeout_ms)
    
    if exit_code == none {
        // Force kill if still running
        say("Process didn't exit gracefully, forcing...")
        os.ProcessManager.terminate(pid, yes)
        os.ProcessManager.wait(pid, 1000)
    }
}
```

### Create Process with Error Handling
```levy
act run_process_safely(cmd, args) {
    try {
        pid <- os.ProcessManager.create(cmd, args, {})
        say("Process started: PID " + pid)
        
        exit_code <- os.ProcessManager.wait(pid)
        
        if exit_code == 0 {
            say("Process completed successfully")
        } else {
            say("Process failed with code: " + exit_code)
        }
        
        -> exit_code
        
    } catch(e) {
        say("Error running process: " + e)
        -> -1
    }
}
```

### Get Process Tree
```levy
act get_children(parent_pid) {
    processes <- os.ProcessManager.list()
    children <- []
    
    for proc in processes {
        if proc.get("ppid") == parent_pid {
            children.push(proc)
        }
    }
    
    -> children
}

// Usage
my_children <- get_children(os.getpid())
say("This process has " + len(my_children) + " children")
```

---

## Process Info Fields

### From list()
```levy
{
    "pid": 1234,              // Process ID
    "ppid": 5678,             // Parent Process ID
    "name": "python.exe",     // Process name
    "threads": 12,            // Thread count
    "priority": 8,            // Priority level
    "status": "R"             // Status (Linux)
}
```

### From get_info()
```levy
{
    // All fields from list() plus:
    "path": "/usr/bin/python",      // Executable path
    "cmdline": "python script.py",  // Command line
    "memory_usage": 52428800,       // Bytes (50 MB)
    "start_time": 1707696000        // Timestamp
}
```

### Thread Info
```levy
{
    "tid": 4567,             // Thread ID
    "pid": 1234,             // Parent process ID
    "status": "R",           // Status (Linux)
    "priority": 0            // Thread priority
}
```

---

## Priority Constants

### Windows
```levy
os.ProcessManager.IDLE_PRIORITY           -> 0x00000040
os.ProcessManager.BELOW_NORMAL_PRIORITY   -> 0x00004000
os.ProcessManager.NORMAL_PRIORITY         -> 0x00000020
os.ProcessManager.ABOVE_NORMAL_PRIORITY   -> 0x00008000
os.ProcessManager.HIGH_PRIORITY           -> 0x00000080
os.ProcessManager.REALTIME_PRIORITY       -> 0x00000100
```

### Unix/Linux/macOS
```levy
os.ProcessManager.PRIORITY_HIGHEST  -> -20
os.ProcessManager.PRIORITY_HIGH     -> -10
os.ProcessManager.PRIORITY_NORMAL   -> 0
os.ProcessManager.PRIORITY_LOW      -> 10
os.ProcessManager.PRIORITY_LOWEST   -> 19
```

---

## Platform Support

| Feature | Windows | Linux | macOS |
|---------|---------|-------|-------|
| Basic enumeration | ✅ | ✅ | ✅ |
| Memory operations | ✅ | ✅ | ⚠️ |
| DLL injection | ✅ | ⚠️ | ❌ |

Legend: ✅ Full support | ⚠️ Limited | ❌ Not supported

---

## Error Handling Tips

```levy
// Always use try-catch
try {
    result <- os.ProcessManager.some_operation(pid)
} catch(e) {
    say("Operation failed: " + e)
}

// Check if process exists before operations
processes <- os.ProcessManager.list()
pid_exists <- no
for proc in processes {
    if proc["pid"] == target_pid {
        pid_exists <- yes
        break
    }
}

if pid_exists {
    // Safely operate on process
}
```

---

## Performance Tips

1. **Cache process lists** - Don't call `list()` repeatedly
   ```levy
   procs <- os.ProcessManager.list()  // Cache this
   // Use 'procs' multiple times
   ```

2. **Use appropriate timeouts** - Don't wait forever
   ```levy
   exit_code <- os.ProcessManager.wait(pid, 5000)  // 5 second timeout
   ```

3. **Batch operations** - Gather info once
   ```levy
   info <- os.ProcessManager.get_info(pid)
   memory <- info["memory_usage"]
   name <- info["name"]
   // etc.
   ```

---

## Security Checklist

- [ ] Validate PIDs before operations
- [ ] Use try-catch for all operations
- [ ] Don't run as admin/root unless necessary
- [ ] Test on non-critical processes first
- [ ] Respect system security policies
- [ ] Consider anti-virus/anti-cheat implications
- [ ] Have proper authorization for process access
- [ ] Document why elevated privileges are needed

---

## Common Use Cases

### 1. System Monitoring
```levy
// Monitor all Python processes
procs <- os.ProcessManager.list()
for proc in procs {
    if proc["name"].contains("python") {
        info <- os.ProcessManager.get_info(proc["pid"])
        say(proc["name"] + ": " + (info["memory_usage"] / 1024 / 1024) + " MB")
    }
}
```

### 2. Process Cleanup
```levy
// Kill all processes matching a pattern
act kill_all(pattern) {
    procs <- os.ProcessManager.list()
    killed <- 0
    
    for proc in procs {
        if proc["name"].contains(pattern) {
            try {
                os.ProcessManager.terminate(proc["pid"], yes)
                killed <- killed + 1
            } catch(e) {
                say("Failed to kill " + proc["pid"] + ": " + e)
            }
        }
    }
    
    -> killed
}
```

### 3. Automated Testing
```levy
// Start test server, run tests, cleanup
server_pid <- os.ProcessManager.create("./test_server", [], {})
os.sleep(2)  // Wait for server to start

try {
    // Run tests here
    test_results <- run_tests()
} finally {
    // Always cleanup
    os.ProcessManager.terminate(server_pid, yes)
}
```

### 4. Resource Limiting
```levy
// Lower priority of background tasks
act deprioritize(pattern) {
    procs <- os.ProcessManager.list()
    for proc in procs {
        if proc["name"].contains(pattern) {
            try {
                priority <- if os.name() == "windows" {
                    os.ProcessManager.IDLE_PRIORITY
                } else {
                    os.ProcessManager.PRIORITY_LOWEST
                }
                os.ProcessManager.set_priority(proc["pid"], priority)
            } catch(e) {}
        }
    }
}
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Failed to open process" | Check process exists and you have permissions |
| "Access denied" | Run with administrator/root privileges |
| "Process not found" | Process may have exited; check PID validity |
| DLL injection fails | Ensure DLL architecture matches process (32/64-bit) |
| Memory read fails | Address may be invalid or protected |
| Can't change priority | Requires elevated privileges to increase |

---

## Examples Location

See `examples/30_os_processmanager_demo.levy` for comprehensive usage examples.

## Full Documentation

See `OS_PROCESSMANAGER_MODULE.md` for complete API documentation.
