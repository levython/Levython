# OS.ProcessManager Module Documentation

## Overview

The **OS.ProcessManager** module provides comprehensive process management capabilities within Levython. It enables scripts to enumerate, create, control, and monitor operating system processes, making it ideal for system administration, debugging, automation, and security research.

## Module Structure

```
OS.ProcessManager
├── Process Enumeration
│   ├── list()
│   └── get_info(pid)
├── Process Lifecycle
│   ├── create(path, args, env)
│   ├── terminate(pid, force)
│   ├── wait(pid, timeout_ms)
│   ├── suspend(pid)
│   └── resume(pid)
├── Memory Operations
│   ├── read_memory(pid, address, size)
│   └── write_memory(pid, address, data)
├── Code Injection
│   └── inject_dll(pid, dll_path)
├── Thread Management
│   └── list_threads(pid)
└── Priority Management
    ├── get_priority(pid)
    └── set_priority(pid, priority)
```

## API Reference

### Process Enumeration

#### OS.ProcessManager.list()
Lists all running processes in the system.

**Returns:** `LIST` - Array of process information maps

**Example:**
```levy
processes <- os.ProcessManager.list()
for proc in processes {
    say("PID: " + proc["pid"] + ", Name: " + proc["name"])
}
```

**Process Info Map Contents:**
- `pid` (INTEGER) - Process ID
- `ppid` (INTEGER) - Parent Process ID
- `name` (STRING) - Process name
- `threads` (INTEGER) - Number of threads (platform-dependent)
- `priority` (INTEGER) - Process priority (platform-dependent)
- `status` (STRING) - Process status (Linux only: R=running, S=sleeping, Z=zombie, etc.)
- `cmdline` (STRING) - Command line (Linux/macOS)

---

#### OS.ProcessManager.get_info(pid)
Gets detailed information about a specific process.

**Parameters:**
- `pid` (INTEGER) - Process ID to query

**Returns:** `MAP` - Detailed process information

**Example:**
```levy
my_pid <- os.getpid()
info <- os.ProcessManager.get_info(my_pid)
say("Memory usage: " + info["memory_usage"] + " bytes")
say("Path: " + info["path"])
```

**Extended Info Map Contents:**
- All fields from `list()` plus:
- `path` (STRING) - Full executable path
- `cmdline` (STRING) - Complete command line
- `memory_usage` (INTEGER) - Memory usage in bytes (RSS/Working Set)
- `start_time` (INTEGER) - Process start timestamp (platform-dependent)

**Platform Notes:**
- Windows: Uses `OpenProcess` + `QueryFullProcessImageName` + `GetProcessMemoryInfo`
- Linux: Reads `/proc/[pid]/stat`, `/proc/[pid]/status`, `/proc/[pid]/exe`
- macOS: Uses `sysctl` + `task_info`

---

### Process Lifecycle Management

#### OS.ProcessManager.create(path, args=[], env={})
Creates a new process.

**Parameters:**
- `path` (STRING) - Executable path or command name
- `args` (LIST, optional) - Command-line arguments
- `env` (MAP, optional) - Environment variables (merged with parent environment)

**Returns:** `INTEGER` - New process PID

**Example:**
```levy
// Simple process creation
pid <- os.ProcessManager.create("python", ["script.py"], {})

// With environment variables
pid <- os.ProcessManager.create("node", ["app.js"], {
    "NODE_ENV": "production",
    "PORT": "8080"
})

// Platform-specific commands
cmd <- if os.name() == "windows" { "cmd.exe" } else { "bash" }
args <- if os.name() == "windows" { ["/c", "dir"] } else { ["-c", "ls"] }
pid <- os.ProcessManager.create(cmd, args, {})
```

**Platform Implementation:**
- Windows: Uses `CreateProcess` API
- Unix/Linux/macOS: Uses `fork()` + `execvp()` pattern

**Error Handling:**
- Throws exception if executable not found or creation fails
- Child process inherits parent's file descriptors (Unix) or handles (Windows)

---

#### OS.ProcessManager.terminate(pid, force=false)
Terminates a process.

**Parameters:**
- `pid` (INTEGER) - Process ID to terminate
- `force` (BOOLEAN, optional) - Force termination (default: false)

**Returns:** `BOOLEAN` - Success status

**Example:**
```levy
// Graceful termination
success <- os.ProcessManager.terminate(pid, no)

// Forced termination (kill -9 / TerminateProcess)
success <- os.ProcessManager.terminate(pid, yes)
```

**Behavior:**
- `force=false`: Sends SIGTERM (Unix) or normal termination (Windows)
- `force=true`: Sends SIGKILL (Unix) or forceful termination (Windows)

**Platform Notes:**
- Windows: Uses `TerminateProcess` with specified exit code
- Unix: Uses `kill()` syscall with specified signal

---

#### OS.ProcessManager.wait(pid, timeout_ms=0)
Waits for a process to complete.

**Parameters:**
- `pid` (INTEGER) - Process ID to wait for
- `timeout_ms` (INTEGER, optional) - Timeout in milliseconds (0 = infinite)

**Returns:** 
- `INTEGER` - Exit code if process completed
- `NONE` - If timeout occurred

**Example:**
```levy
child_pid <- os.ProcessManager.create("sleep", ["5"], {})

// Wait indefinitely
exit_code <- os.ProcessManager.wait(child_pid)
say("Process exited with code: " + exit_code)

// Wait with timeout
exit_code <- os.ProcessManager.wait(child_pid, 3000)
if exit_code == none {
    say("Process still running after 3 seconds")
    os.ProcessManager.terminate(child_pid, yes)
}
```

**Platform Implementation:**
- Windows: `WaitForSingleObject` + `GetExitCodeProcess`
- Unix: `waitpid()` with polling for timeout support

---

#### OS.ProcessManager.suspend(pid)
Suspends all threads in a process (pauses execution).

**Parameters:**
- `pid` (INTEGER) - Process ID to suspend

**Returns:** `BOOLEAN` - Success status

**Example:**
```levy
pid <- os.ProcessManager.create("long_running_task", [], {})
os.sleep(2)
os.ProcessManager.suspend(pid)  // Pause execution
say("Process suspended")
os.sleep(5)
os.ProcessManager.resume(pid)   // Continue execution
```

**Platform Notes:**
- Windows: Suspends all threads using `SuspendThread`
- Unix: Sends SIGSTOP signal
- Requires appropriate permissions

---

#### OS.ProcessManager.resume(pid)
Resumes a suspended process.

**Parameters:**
- `pid` (INTEGER) - Process ID to resume

**Returns:** `BOOLEAN` - Success status

**Platform Notes:**
- Windows: Resumes all threads using `ResumeThread`
- Unix: Sends SIGCONT signal

---

### Memory Operations

#### OS.ProcessManager.read_memory(pid, address, size)
Reads memory from a process's address space.

**Parameters:**
- `pid` (INTEGER) - Target process ID
- `address` (INTEGER) - Memory address to read from
- `size` (INTEGER) - Number of bytes to read (max 1MB for safety)

**Returns:** `STRING` - Raw bytes as a string

**Example:**
```levy
// Read 64 bytes from address 0x400000
data <- os.ProcessManager.read_memory(pid, 0x400000, 64)
say("Read " + len(data) + " bytes")

// Find a string in memory
for i in range(0, 1000, 4) {
    try {
        bytes <- os.ProcessManager.read_memory(pid, base_addr + i, 4)
        if bytes.contains("test") {
            say("Found 'test' at offset: " + i)
        }
    } catch(e) {
        // Handle invalid memory access
    }
}
```

**Platform Implementation:**
- Windows: `ReadProcessMemory` API
- Linux: `/proc/[pid]/mem` or `process_vm_readv`
- macOS: `vm_read` Mach API

**Security Notes:**
- **Requires elevated privileges** (Administrator/root)
- Only works on accessible memory regions
- Validates size limit to prevent abuse
- Can fail if memory is protected or unmapped

---

#### OS.ProcessManager.write_memory(pid, address, data)
Writes memory to a process's address space.

**Parameters:**
- `pid` (INTEGER) - Target process ID
- `address` (INTEGER) - Memory address to write to
- `data` (STRING) - Data to write (max 1MB for safety)

**Returns:** `BOOLEAN` - Success status

**Example:**
```levy
// Write a NOP instruction (0x90) to disable a function
nop_bytes <- "\x90\x90\x90\x90"
success <- os.ProcessManager.write_memory(pid, 0x401000, nop_bytes)

// Patch a game value (example: set health to 100)
health_value <- "\x64\x00\x00\x00"  // 100 as 32-bit int
os.ProcessManager.write_memory(game_pid, health_addr, health_value)
```

**Platform Implementation:**
- Windows: `WriteProcessMemory` API
- Linux: `/proc/[pid]/mem` or `process_vm_writev`
- macOS: `vm_write` Mach API

**Security Notes:**
- **Extremely dangerous** - can crash target process
- **Requires elevated privileges**
- Memory must have write permissions
- Use with extreme caution

---

### Code Injection

#### OS.ProcessManager.inject_dll(pid, dll_path)
Injects a DLL/shared library into a running process.

**Parameters:**
- `pid` (INTEGER) - Target process ID
- `dll_path` (STRING) - Full path to DLL/SO to inject

**Returns:** `BOOLEAN` - Successfully injected

**Example:**
```levy
// Windows DLL injection
success <- os.ProcessManager.inject_dll(game_pid, "C:\\mods\\trainer.dll")

// Linux .so injection (requires gdb)
success <- os.ProcessManager.inject_dll(app_pid, "/usr/lib/custom_hook.so")
```

**Platform Implementation:**

**Windows:** Classic DLL injection technique
1. Opens target process with `PROCESS_ALL_ACCESS`
2. Allocates memory in target process with `VirtualAllocEx`
3. Writes DLL path to allocated memory with `WriteProcessMemory`
4. Creates remote thread calling `LoadLibraryA` with `CreateRemoteThread`
5. Waits for thread completion and cleans up

**Linux:** Uses `ptrace` or `gdb` to inject shared library
- Simplified implementation uses gdb batch mode
- Full implementation would use `ptrace` + `dlopen` injection

**macOS:** Limited support
- Would require `DYLD_INSERT_LIBRARIES` or similar
- Currently throws "not supported" error

**Use Cases:**
- Plugin systems
- API hooking for debugging
- Game modding
- Instrumentation and monitoring
- Security research

**Security Notes:**
- **Requires Administrator/root privileges**
- Can trigger antivirus/anti-cheat software
- Target process must support dynamic library loading
- Only works on same-architecture processes (32-bit to 32-bit, etc.)
- Potential for system instability

---

### Thread Management

#### OS.ProcessManager.list_threads(pid)
Lists all threads belonging to a process.

**Parameters:**
- `pid` (INTEGER) - Process ID to query

**Returns:** `LIST` - Array of thread information maps

**Example:**
```levy
threads <- os.ProcessManager.list_threads(os.getpid())
say("This process has " + len(threads) + " threads")

for thread in threads {
    say("Thread " + thread["tid"] + " - Status: " + thread.get("status", "?"))
}
```

**Thread Info Map Contents:**
- `tid` (INTEGER) - Thread ID
- `pid` (INTEGER) - Parent process ID
- `status` (STRING) - Thread status (Linux: R/S/D/Z/T)
- `priority` (INTEGER) - Thread priority (platform-dependent)

**Platform Implementation:**
- Windows: `CreateToolhelp32Snapshot` with `TH32CS_SNAPTHREAD`
- Linux: Read `/proc/[pid]/task/*` directories
- macOS: `task_threads` Mach API

---

### Priority Management

#### OS.ProcessManager.get_priority(pid)
Gets the scheduling priority of a process.

**Parameters:**
- `pid` (INTEGER) - Process ID to query

**Returns:** `INTEGER` - Priority value (platform-specific format)

**Example:**
```levy
priority <- os.ProcessManager.get_priority(os.getpid())
say("Current priority: " + priority)
```

**Platform Notes:**
- Windows: Returns priority class (see constants below)
- Unix: Returns nice value (-20 to 19)

---

#### OS.ProcessManager.set_priority(pid, priority)
Sets the scheduling priority of a process.

**Parameters:**
- `pid` (INTEGER) - Process ID to modify
- `priority` (INTEGER) - New priority value

**Returns:** `BOOLEAN` - Success status

**Example:**
```levy
// Windows: Set to high priority
os.ProcessManager.set_priority(pid, os.ProcessManager.HIGH_PRIORITY)

// Unix: Set nice value to -10 (high priority)
os.ProcessManager.set_priority(pid, os.ProcessManager.PRIORITY_HIGH)
```

**Priority Constants:**

**Windows:**
```levy
os.ProcessManager.IDLE_PRIORITY         // Lowest priority
os.ProcessManager.BELOW_NORMAL_PRIORITY
os.ProcessManager.NORMAL_PRIORITY       // Default
os.ProcessManager.ABOVE_NORMAL_PRIORITY
os.ProcessManager.HIGH_PRIORITY
os.ProcessManager.REALTIME_PRIORITY     // Highest (dangerous!)
```

**Unix/Linux/macOS:**
```levy
os.ProcessManager.PRIORITY_HIGHEST  // -20 (nice value)
os.ProcessManager.PRIORITY_HIGH     // -10
os.ProcessManager.PRIORITY_NORMAL   // 0
os.ProcessManager.PRIORITY_LOW      // 10
os.ProcessManager.PRIORITY_LOWEST   // 19
```

**Security Notes:**
- Increasing priority typically requires elevated privileges
- REALTIME priority can cause system instability
- Use with caution in production environments

---

## Complete Example

```levy
// Comprehensive process management example

// 1. List all processes and find a specific one
processes <- os.ProcessManager.list()
target_pid <- none

for proc in processes {
    if proc["name"].contains("chrome") {
        target_pid <- proc["pid"]
        break
    }
}

if target_pid != none {
    // 2. Get detailed information
    info <- os.ProcessManager.get_info(target_pid)
    say("Found Chrome: " + info["path"])
    say("Memory usage: " + (info["memory_usage"] / 1024 / 1024) + " MB")
    
    // 3. List its threads
    threads <- os.ProcessManager.list_threads(target_pid)
    say("Thread count: " + len(threads))
}

// 4. Create and manage a child process
child_pid <- os.ProcessManager.create("python", ["script.py"], {
    "MY_VAR": "test_value"
})

// 5. Monitor the child
try {
    exit_code <- os.ProcessManager.wait(child_pid, 10000)
    if exit_code != none {
        say("Child exited with code: " + exit_code)
    } else {
        say("Child timeout, terminating...")
        os.ProcessManager.terminate(child_pid, yes)
    }
} catch(e) {
    say("Error: " + e)
}
```

---

## Platform Compatibility

| Feature | Windows | Linux | macOS |
|---------|---------|-------|-------|
| Process enumeration | ✅ Full | ✅ Full | ✅ Full |
| Process creation | ✅ Full | ✅ Full | ✅ Full |
| Process termination | ✅ Full | ✅ Full | ✅ Full |
| Process wait | ✅ Full | ✅ Full | ✅ Full |
| Suspend/Resume | ✅ Full | ✅ Full | ✅ Full |
| Memory read/write | ✅ Full | ✅ Full | ✅ Partial |
| DLL injection | ✅ Full | ⚠️ Limited | ❌ Not supported |
| Thread listing | ✅ Full | ✅ Full | ✅ Full |
| Priority management | ✅ Full | ✅ Full | ✅ Full |

---

## Security Considerations

### Permissions Required
- **Basic operations** (list, get_info): Normal user privileges
- **Process creation/termination**: User must own process or have appropriate rights
- **Memory operations**: Administrator/root privileges required
- **DLL injection**: Administrator/root privileges required
- **Priority changes**: May require elevated privileges for increases

### Best Practices
1. ✅ Always validate PIDs before operations
2. ✅ Use try-catch for error handling
3. ✅ Respect system security policies
4. ✅ Test with non-critical processes first
5. ❌ Never inject code into system processes
6. ❌ Avoid memory operations in production without testing
7. ❌ Don't run with elevated privileges unless necessary

### Legal and Ethical Considerations
- Some operations may violate terms of service (especially in games)
- Code injection can trigger anti-cheat/anti-virus systems
- Always have proper authorization before accessing other processes
- Use these capabilities responsibly and ethically

---

## Error Handling

All ProcessManager functions can throw exceptions. Always use try-catch:

```levy
try {
    info <- os.ProcessManager.get_info(12345)
    say("Process found: " + info["name"])
} catch(e) {
    say("Error accessing process: " + e)
    // Handle gracefully
}
```

Common errors:
- "Failed to open process" - Insufficient permissions or PID doesn't exist
- "Failed to read/write memory" - Invalid address or insufficient permissions
- "Process not found" - PID no longer exists
- "Not supported on this platform" - Feature unavailable on current OS

---

## Performance Notes

- Process enumeration is relatively expensive (hundreds of processes)
- Cache results when possible rather than polling repeatedly
- Memory operations are fast but can impact target process
- DLL injection involves thread creation overhead
- Use appropriate timeouts for wait operations

---

## Related Modules

- **os**: General OS operations (`os.getpid()`, `os.kill()`, etc.)
- **os.Hook**: System event hooking
- **os.InputControl**: Input device control
- **thread**: Thread management for current process

---

## Version History

- **v1.0.2** (2026-02-11): Initial release of OS.ProcessManager module
  - Full cross-platform process enumeration
  - Process lifecycle management
  - Memory read/write operations
  - DLL injection (Windows/Linux)
  - Thread enumeration
  - Priority management

---

## See Also

- [OS Module Documentation](OS_MODULE.md)
- [OS.Hook Module Documentation](OS_HOOK_MODULE.md)
- [OS.InputControl Module Documentation](OS_INPUTCONTROL_MODULE.md)
- [Example: 30_os_processmanager_demo.levy](../examples/30_os_processmanager_demo.levy)
