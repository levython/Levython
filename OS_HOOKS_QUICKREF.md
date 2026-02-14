# OS.Hook Quick Reference

## Import
```levy
import os
```

## Hook Types
```levy
os.Hook.PROCESS_CREATE      # Monitor process creation
os.Hook.PROCESS_EXIT        # Monitor process termination
os.Hook.FILE_ACCESS         # Monitor file system access
os.Hook.NETWORK_CONNECT     # Monitor network connections
os.Hook.KEYBOARD            # Monitor keyboard events
os.Hook.MOUSE               # Monitor mouse events
os.Hook.SYSCALL             # Monitor system calls
os.Hook.MEMORY_ACCESS       # Monitor memory access
os.Hook.DLL_INJECTION       # Inject code into processes
```

## Basic Operations

### Register Hook
```levy
hook_id <- os.Hook.register(os.Hook.PROCESS_CREATE, "Description")
```

### Set Callback
```levy
act my_callback(event) {
    say("Event: " + event["type"])
}
os.Hook.set_callback(hook_id, my_callback)
```

### Enable/Disable
```levy
os.Hook.enable(hook_id)
os.Hook.disable(hook_id)
```

### List Hooks
```levy
hooks <- os.Hook.list()
# Returns: [{id: 1, type: "...", enabled: yes/no, description: "..."}]
```

### Unregister
```levy
os.Hook.unregister(hook_id)
```

## Event Functions

### Process Events
```levy
info <- os.Hook.hook_process_create(pid)
# Returns: {pid: 1234, event: "process_create", path: "..."}

info <- os.Hook.hook_process_exit(pid, exit_code)
# Returns: {pid: 1234, exit_code: 0, event: "process_exit"}
```

### File Events
```levy
info <- os.Hook.hook_file_access("/path/to/file", "read")
# Returns: {path: "...", mode: "read", event: "file_access", timestamp: ...}
```

### Network Events
```levy
info <- os.Hook.hook_network_connect("example.com", 443, "tcp")
# Returns: {host: "...", port: 443, protocol: "tcp", event: "network_connect", timestamp: ...}
```

### Input Events
```levy
# Keyboard
info <- os.Hook.hook_keyboard(65, yes)  # Key 'A' pressed
# Returns: {key_code: 65, pressed: yes, event: "keyboard", timestamp: ...}

# Mouse
info <- os.Hook.hook_mouse(100, 200, 0, yes)  # Left click at (100, 200)
# Returns: {x: 100, y: 200, button: 0, pressed: yes, event: "mouse", timestamp: ...}
```

### System Call Events
```levy
info <- os.Hook.hook_syscall(1, [arg1, arg2])
# Returns: {syscall_number: 1, args: [...], event: "syscall", timestamp: ...}
```

### Memory Access
```levy
info <- os.Hook.hook_memory_access(pid, 0x400000, 16)
# Returns: {pid: ..., address: ..., size: 16, data: "hex...", bytes_read: 16, event: "memory_access"}
```

### DLL Injection
```levy
success <- os.Hook.inject_library(pid, "/path/to/library.dll")
# Returns: yes/no
```

## Complete Example

```levy
import os

# 1. Register
hook <- os.Hook.register(os.Hook.FILE_ACCESS, "Monitor files")

# 2. Set callback
act on_file_access(event) {
    say("File accessed: " + event["path"])
    say("Mode: " + event["mode"])
}
os.Hook.set_callback(hook, on_file_access)

# 3. Enable
os.Hook.enable(hook)

# 4. Trigger event (in real use, this happens automatically)
event <- os.Hook.file_access("/etc/passwd", "read")

# 5. Cleanup
os.Hook.disable(hook)
os.Hook.unregister(hook)
```

## Error Handling

```levy
try {
    hook <- os.Hook.register(os.Hook.PROCESS_CREATE, "Monitor")
    os.Hook.enable(hook)
    # ... use hook ...
    os.Hook.disable(hook)
    os.Hook.unregister(hook)
} catch e {
    say("Error: " + str(e))
}
```

## Best Practices

✅ **DO:**
- Always unregister hooks when done
- Use try/catch for error handling
- Check return values
- Test with appropriate privileges
- Clean up in reverse order (disable → unregister)

❌ **DON'T:**
- Leave hooks enabled indefinitely
- Hook protected system processes
- Use in production without testing
- Ignore permission errors
- Forget to disable before unregistering

## Platform Notes

### Windows
- Most hooks require Administrator privileges
- Keyboard/mouse use `SetWindowsHookEx`
- DLL injection fully supported
- Process hooks may require driver for kernel callbacks

### Linux
- Most hooks require root
- File hooks use `inotify`
- System calls via `ptrace`
- Memory access via `/proc/pid/mem`

### macOS
- Most hooks require root or accessibility permissions
- File hooks use `FSEvents`
- Input hooks require accessibility API
- DLL injection complex (use `DYLD_INSERT_LIBRARIES`)

## Common Use Cases

**Security Monitoring:**
```levy
hook <- os.Hook.register(os.Hook.PROCESS_CREATE, "Security")
act alert(e) { say("New process: " + str(e["pid"])) }
os.Hook.set_callback(hook, alert)
os.Hook.enable(hook)
```

**File Auditing:**
```levy
hook <- os.Hook.register(os.Hook.FILE_ACCESS, "Audit")
act audit(e) { say("Accessed: " + e["path"]) }
os.Hook.set_callback(hook, audit)
os.Hook.enable(hook)
```

**Network Monitoring:**
```levy
hook <- os.Hook.register(os.Hook.NETWORK_CONNECT, "NetMon")
act log_conn(e) { say(e["host"] + ":" + str(e["port"])) }
os.Hook.set_callback(hook, log_conn)
os.Hook.enable(hook)
```

## Security Warnings

⚠️ **Requires elevated privileges**
⚠️ **May be blocked by antivirus**
⚠️ **Legal implications - use responsibly**
⚠️ **Only hook systems you own/control**
⚠️ **Can affect system stability**

## See Also

- Full Documentation: `OS_HOOK_MODULE.md`
- Implementation: `OS_HOOK_IMPLEMENTATION.md`
- Demo: `examples/28_os_hook_demo.levy`
- Test: `examples/28_os_hook_test.levy`
