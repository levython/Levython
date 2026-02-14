# OS.Hook Module Documentation

## Overview

The **OS.Hook** submodule provides powerful APIs for system-level hooking and monitoring of operating system events. This module allows Levython scripts to intercept and monitor OS behaviors at runtime, including process creation/termination, file system access, network connections, keyboard/mouse input, system calls, and memory access.

## ⚠️ Security Warning

OS.Hook provides low-level system access that:
- May require elevated privileges (root/administrator)
- Can affect system stability
- May be blocked by antivirus/security software
- Should only be used ethically and legally on systems you own or have permission to monitor

## Module Structure

```
os.Hook
├── Core Management Functions
│   ├── register(type, description)
│   ├── unregister(hook_id)
│   ├── list()
│   ├── enable(hook_id)
│   ├── disable(hook_id)
│   └── set_callback(hook_id, callback)
├── Event-Specific Functions
│   ├── process_create(pid)
│   ├── process_exit(pid, exit_code)
│   ├── file_access(path, mode)
│   ├── network_connect(host, port, protocol)
│   ├── keyboard(key_code, pressed)
│   ├── mouse(x, y, button, pressed)
│   ├── syscall(syscall_number, args)
│   ├── inject_dll(pid, dll_path)
│   └── memory_access(pid, address, size)
└── Hook Type Constants
    ├── PROCESS_CREATE
    ├── PROCESS_EXIT
    ├── FILE_ACCESS
    ├── NETWORK_CONNECT
    ├── KEYBOARD
    ├── MOUSE
    ├── SYSCALL
    ├── MEMORY_ACCESS
    └── DLL_INJECTION
```

## API Reference

### Core Management Functions

#### `os.Hook.register(type, description="")`
Register a new system hook.

**Parameters:**
- `type` (string): Hook type constant (e.g., `os.Hook.PROCESS_CREATE`)
- `description` (string, optional): Human-readable description of the hook

**Returns:** 
- `hook_id` (integer): Unique hook identifier for subsequent operations

**Example:**
```levy
hook_id <- os.Hook.register(os.Hook.PROCESS_CREATE, "Monitor new processes")
```

---

#### `os.Hook.unregister(hook_id)`
Unregister and remove a hook.

**Parameters:**
- `hook_id` (integer): ID of the hook to remove

**Returns:** 
- `success` (boolean): `yes` if successfully unregistered, `no` otherwise

**Example:**
```levy
result <- os.Hook.unregister(hook_id)
```

---

#### `os.Hook.list()`
List all registered hooks.

**Returns:** 
- `hooks` (list): List of maps containing hook information
  - `id` (integer): Hook ID
  - `type` (string): Hook type
  - `enabled` (boolean): Whether hook is active
  - `description` (string): Hook description

**Example:**
```levy
hooks <- os.Hook.list()
i <- 0
while i < len(hooks) {
    say("Hook #" + str(hooks[i]["id"]) + ": " + hooks[i]["type"])
    i <- i + 1
}
```

---

#### `os.Hook.enable(hook_id)`
Enable a registered hook to start monitoring events.

**Parameters:**
- `hook_id` (integer): ID of the hook to enable

**Returns:** 
- `success` (boolean): `yes` if successfully enabled

**Platform-Specific Behavior:**
- **Windows**: Uses `SetWindowsHookEx` for keyboard/mouse, WMI for process monitoring
- **POSIX**: Uses `ptrace`, `inotify`/`FSEvents`, signal handlers depending on hook type

**Example:**
```levy
os.Hook.enable(hook_id)
```

---

#### `os.Hook.disable(hook_id)`
Disable a hook to stop monitoring events.

**Parameters:**
- `hook_id` (integer): ID of the hook to disable

**Returns:** 
- `success` (boolean): `yes` if successfully disabled

**Example:**
```levy
os.Hook.disable(hook_id)
```

---

#### `os.Hook.set_callback(hook_id, callback)`
Set a callback function to be invoked when the hook triggers.

**Parameters:**
- `hook_id` (integer): ID of the hook
- `callback` (function): Levython function to call when event occurs
  - The callback receives one argument: an event map containing event details

**Returns:** 
- `success` (boolean): `yes` if callback was set successfully

**Example:**
```levy
act on_event(event) {
    say("Event detected: " + event["type"])
}

os.Hook.set_callback(hook_id, on_event)
```

---

### Event-Specific Functions

#### `os.Hook.process_create(pid)`
Get information about a process creation event.

**Parameters:**
- `pid` (integer): Process ID

**Returns:** 
- `event` (map): Process creation event information
  - `pid` (integer): Process ID
  - `event` (string): Event type ("process_create")
  - `path` (string, if available): Executable path

**Example:**
```levy
info <- os.Hook.process_create(1234)
say("Process path: " + info["path"])
```

---

#### `os.Hook.process_exit(pid, exit_code=0)`
Get information about a process exit event.

**Parameters:**
- `pid` (integer): Process ID
- `exit_code` (integer, optional): Exit code (default: 0)

**Returns:** 
- `event` (map): Process exit event information
  - `pid` (integer): Process ID
  - `exit_code` (integer): Exit code
  - `event` (string): Event type ("process_exit")

**Example:**
```levy
info <- os.Hook.process_exit(1234, 0)
```

---

#### `os.Hook.file_access(path, mode="read")`
Monitor file system access events.

**Parameters:**
- `path` (string): File or directory path
- `mode` (string, optional): Access mode ("read", "write", "execute")

**Returns:** 
- `event` (map): File access event information
  - `path` (string): File path
  - `mode` (string): Access mode
  - `event` (string): Event type ("file_access")
  - `timestamp` (integer): Unix timestamp

**Example:**
```levy
event <- os.Hook.file_access("/etc/passwd", "read")
say("File accessed at: " + str(event["timestamp"]))
```

---

#### `os.Hook.network_connect(host, port, protocol="tcp")`
Monitor network connection events.

**Parameters:**
- `host` (string): Hostname or IP address
- `port` (integer): Port number
- `protocol` (string, optional): Protocol ("tcp", "udp")

**Returns:** 
- `event` (map): Network connection event information
  - `host` (string): Target host
  - `port` (integer): Target port
  - `protocol` (string): Protocol used
  - `event` (string): Event type ("network_connect")
  - `timestamp` (integer): Unix timestamp

**Example:**
```levy
event <- os.Hook.network_connect("example.com", 443, "tcp")
```

---

#### `os.Hook.keyboard(key_code, pressed)`
Monitor keyboard input events.

**Parameters:**
- `key_code` (integer): Virtual key code (platform-specific)
- `pressed` (boolean): `yes` for key press, `no` for key release

**Returns:** 
- `event` (map): Keyboard event information
  - `key_code` (integer): Key code
  - `pressed` (boolean): Press state
  - `event` (string): Event type ("keyboard")
  - `timestamp` (integer): Unix timestamp

**Example:**
```levy
event <- os.Hook.keyboard(65, yes)  # 'A' key pressed
if event["pressed"] {
    say("Key pressed: " + str(event["key_code"]))
}
```

---

#### `os.Hook.mouse(x, y, button=0, pressed=yes)`
Monitor mouse input events.

**Parameters:**
- `x` (integer): X coordinate
- `y` (integer): Y coordinate
- `button` (integer, optional): Mouse button (0=left, 1=right, 2=middle)
- `pressed` (boolean, optional): Button state

**Returns:** 
- `event` (map): Mouse event information
  - `x` (integer): X coordinate
  - `y` (integer): Y coordinate
  - `button` (integer): Button identifier
  - `pressed` (boolean): Button state
  - `event` (string): Event type ("mouse")
  - `timestamp` (integer): Unix timestamp

**Example:**
```levy
event <- os.Hook.mouse(100, 200, 0, yes)
say("Mouse clicked at: (" + str(event["x"]) + ", " + str(event["y"]) + ")")
```

---

#### `os.Hook.syscall(syscall_number, args=[])`
Monitor system call events.

**Parameters:**
- `syscall_number` (integer): System call number (OS-specific)
- `args` (list, optional): System call arguments

**Returns:** 
- `event` (map): System call event information
  - `syscall_number` (integer): Syscall number
  - `args` (list, if provided): Arguments
  - `event` (string): Event type ("syscall")
  - `timestamp` (integer): Unix timestamp

**Example:**
```levy
# Monitor write syscall (number varies by OS)
event <- os.Hook.syscall(1, [1, "stdout", 5])
```

---

#### `os.Hook.inject_dll(pid, dll_path)`
Inject a DLL/shared library into a target process.

**⚠️ Warning:** This is an advanced operation requiring elevated privileges.

**Parameters:**
- `pid` (integer): Target process ID
- `dll_path` (string): Full path to DLL/SO file

**Returns:** 
- `success` (boolean): `yes` if injection succeeded

**Platform-Specific:**
- **Windows**: Uses `CreateRemoteThread` and `LoadLibraryA`
- **POSIX**: Requires `ptrace`-based injection (complex, not fully implemented)

**Example:**
```levy
# Windows example
success <- os.Hook.inject_dll(1234, "C:\\path\\to\\hook.dll")
if success {
    say("DLL injected successfully")
}
```

---

#### `os.Hook.memory_access(pid, address, size=8)`
Read memory from a target process.

**⚠️ Warning:** Requires appropriate permissions. May fail on protected processes.

**Parameters:**
- `pid` (integer): Target process ID
- `address` (integer): Memory address to read
- `size` (integer, optional): Number of bytes to read (default: 8)

**Returns:** 
- `info` (map): Memory access information
  - `pid` (integer): Process ID
  - `address` (integer): Memory address
  - `size` (integer): Requested size
  - `data` (string, if successful): Hex-encoded memory contents
  - `bytes_read` (integer, if successful): Actual bytes read
  - `event` (string): Event type ("memory_access")

**Example:**
```levy
info <- os.Hook.memory_access(1234, 0x400000, 16)
if info.has("data") {
    say("Memory data: " + info["data"])
}
```

---

## Hook Type Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `os.Hook.PROCESS_CREATE` | `"process_create"` | Monitor process creation |
| `os.Hook.PROCESS_EXIT` | `"process_exit"` | Monitor process termination |
| `os.Hook.FILE_ACCESS` | `"file_access"` | Monitor file system access |
| `os.Hook.NETWORK_CONNECT` | `"network_connect"` | Monitor network connections |
| `os.Hook.KEYBOARD` | `"keyboard"` | Monitor keyboard events |
| `os.Hook.MOUSE` | `"mouse"` | Monitor mouse events |
| `os.Hook.SYSCALL` | `"syscall"` | Monitor system calls |
| `os.Hook.MEMORY_ACCESS` | `"memory_access"` | Monitor memory read/write |
| `os.Hook.DLL_INJECTION` | `"dll_injection"` | Inject code into processes |

## Complete Example

```levy
import os

# Register a process monitoring hook
hook_id <- os.Hook.register(os.Hook.PROCESS_CREATE, "Monitor new processes")

# Define callback
act on_process_created(event) {
    say("New process: PID " + str(event["pid"]))
    if event.has("path") {
        say("  Path: " + event["path"])
    }
}

# Set callback and enable
os.Hook.set_callback(hook_id, on_process_created)
os.Hook.enable(hook_id)

# ... application logic ...

# Cleanup
os.Hook.disable(hook_id)
os.Hook.unregister(hook_id)
```

## Error Handling

All hook functions may throw exceptions on errors:

```levy
try {
    hook_id <- os.Hook.register(os.Hook.PROCESS_CREATE, "Monitor")
    os.Hook.enable(hook_id)
} catch e {
    say("Hook error: " + str(e))
}
```

## Platform Compatibility

| Feature | Windows | Linux | macOS |
|---------|---------|-------|-------|
| Process hooks | ✅ | ✅ | ✅ |
| File hooks | ✅ | ✅ (inotify) | ✅ (FSEvents) |
| Network hooks | ✅ | ✅ | ✅ |
| Keyboard/Mouse | ✅ (requires admin) | ⚠️ (X11/Wayland) | ⚠️ (accessibility) |
| System calls | ⚠️ (limited) | ✅ (ptrace) | ⚠️ (limited) |
| DLL injection | ✅ | ⚠️ (complex) | ⚠️ (complex) |
| Memory access | ✅ | ✅ (/proc/pid/mem) | ✅ |

**Legend:**
- ✅ Fully supported
- ⚠️ Partially supported or requires special permissions
- ❌ Not supported

## Best Practices

1. **Always clean up hooks:** Use `disable()` and `unregister()` when done
2. **Check permissions:** Many hooks require root/administrator privileges
3. **Handle errors:** Wrap hook operations in try/catch blocks
4. **Test safely:** Test in controlled environments first
5. **Be ethical:** Only monitor systems you own or have permission to access
6. **Performance:** Excessive hooks can impact system performance
7. **Security tools:** Be aware that security software may block hooks

## Use Cases

- **Security monitoring:** Detect suspicious process creation or file access
- **Debugging:** Monitor system calls and memory access for troubleshooting
- **Automation:** Respond to system events with custom scripts
- **Quality assurance:** Monitor application behavior during testing
- **Research:** Study OS behavior and application interactions
- **Accessibility:** Create custom input handlers

## Limitations

1. **Privileges:** Most hooks require elevated permissions
2. **Protected processes:** System processes may be protected from hooking
3. **Anti-virus:** Security software may block or flag hooking attempts
4. **Performance:** Intensive monitoring can slow down the system
5. **Stability:** Improper hooking can cause crashes or instability
6. **Platform differences:** Hook implementations vary across operating systems

## Legal and Ethical Considerations

⚠️ **Important:** System hooking has serious legal and ethical implications:

- Only use on systems you own or have explicit permission to monitor
- Respect user privacy and data protection laws (e.g., GDPR, CCPA)
- Be aware of software licenses and terms of service
- Do not use for malicious purposes (spying, unauthorized access, etc.)
- Comply with computer fraud and abuse laws in your jurisdiction
- Consider security implications of hooking production systems

## See Also

- [os module documentation](OS_MODULE.md)
- [Example: 28_os_hook_demo.levy](../examples/28_os_hook_demo.levy)
- [Process management functions](PROCESS_MODULE.md)
- [System monitoring examples](SYSTEM_INFO.md)
