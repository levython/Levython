# Upgrading to Levython 1.0.3

**Migration Guide for Existing Users**

---

## Overview

Levython 1.0.3 introduces significant enhancements while maintaining **full backward compatibility** with 1.0.2. All existing code will continue to work without modifications.

---

## What's Changed

### ✅ New Features (No Breaking Changes)

All new features are **additions only** - existing code remains compatible.

#### 1. Ternary Operator
New syntax for conditional expressions:

```levy
# Old way (still works)
if condition {
    result <- "yes"
} else {
    result <- "no"
}

# New way (1.0.3+)
result <- condition ? "yes" : "no"
```

#### 2. Input Module Enhancements
New functions for ASCII/character conversion:

```levy
# Convert between ASCII and characters
char <- input.chr(65)     # Returns "A"
code <- input.ord("A")    # Returns 65

# Use with InputControl
OS.InputControl.keyboard_send(65, true)      # ASCII
OS.InputControl.keyboard_send("A", true)     # Character - both work!
```

#### 3. Enhanced OS Module
**All existing os.* functions work exactly as before.**

New additions:
```levy
# Advanced filesystem
os.scandir(path)
os.walk(path)
os.glob(pattern)
os.link(src, dst)
os.disk_usage(path)

# File descriptors
fd <- os.open(path, mode)
os.read(fd, size)
os.write(fd, data)
os.close(fd)

# Process enhancements
result <- os.run_capture(cmd, args, timeout, input)
output <- os.popen(cmd, args)
pid <- os.spawn_io(cmd, args, stdin, stdout, stderr)

# User/group management
os.uid_name(uid)
os.getpwnam(name)
os.getlogin()

# Signal handling (POSIX)
os.signal(os.SIGINT, "ignore")
os.alarm(5)

# System information
os.cpu_info()
os.loadavg()
os.boot_time()
os.mounts()
```

#### 4. New System Modules
Eight powerful new modules for system-level operations:

- **OS.Hooks** - System event hooking
- **OS.InputControl** - Input automation
- **OS.Processes** - Advanced process control
- **OS.Display** - Screen capture and overlays
- **OS.Audio** - Audio device management
- **OS.Privileges** - Privilege management
- **OS.Events** - Event monitoring
- **OS.Persistence** - System persistence

---

## Upgrade Steps

### Option 1: Quick Upgrade (Recommended)

```bash
# Backup your current installation (optional)
mv ~/.levython ~/.levython.bak

# Install 1.0.3
curl -fsSL https://raw.githubusercontent.com/levython/Levython/main/install.sh | bash

# Verify installation
levython --version  # Should show 1.0.3
```

### Option 2: Build from Source

```bash
cd Levython
git pull origin main
make clean
make
sudo make install
```

### Windows

Download the new installer from [GitHub Releases](https://github.com/levython/Levython/releases/latest)

---

## Post-Upgrade Verification

### 1. Check Version
```bash
levython --version
```

Expected output:
```
Levython 1.0.3 - Just a programming language
~ Be better than yesterday
Engine: FastVM with NaN-boxing + x86-64 JIT
```

### 2. Test Compatibility
Run your existing code - it should work exactly as before:

```bash
levython your_existing_script.levy
```

### 3. Try New Features

**Test ternary operator:**
```levy
result <- 5 > 3 ? "yes" : "no"
say(result)  # Should print: yes
```

**Test input module:**
```levy
code <- input.ord("A")
say(str(code))  # Should print: 65
```

**Test enhanced OS module:**
```levy
info <- os.cpu_info()
say("CPU: " + info["model"])
say("Cores: " + str(info["count"]))

# Test OS.Audio
vol <- OS.Audio.get_volume()
say("Volume: " + str(vol))

# Test OS.Display
displays <- OS.Display.list()
say("Displays: " + str(len(displays)))
```

---

## Known Issues & Compatibility Notes

### Signal Handling (Windows)
On Windows, these functions throw errors (platform limitation):
- `os.alarm()`
- `os.pause()`
- `os.killpg()`

**Workaround:** Check platform before using:
```levy
if os.name != "Windows" {
    os.alarm(5)
}
```

### POSIX-Specific Functions
These return stub values on Windows:
- `os.setuid()`, `os.setgid()`
- `os.getpgid()`, `os.setpgid()`
- `os.setsid()`
- `os.nice()`, `os.getpriority()`, `os.setpriority()`

### File Permissions
Windows doesn't fully support Unix permission modes. `os.chmod()` works but may have limited effect on Windows.

---

## Deprecations

**None!** All 1.0.2 APIs remain fully supported in 1.0.3.

---

## Performance Considerations

### Same Performance
- Core language performance unchanged
- Existing code runs at same speed
- JIT compilation works identically

### Potential Improvements
New modules may offer faster alternatives:

**Before (1.0.2):**
```levy
# Process execution
result <- process.run("mycommand", ["arg1"])
```

**After (1.0.3) - with timeout and output capture:**
```levy
# More control, same performance
result <- os.run_capture("mycommand", ["arg1"], 5000, "")
say("stdout: " + result["stdout"])
say("stderr: " + result["stderr"])
```

---

## Getting Help

### Documentation
- [Complete Feature Guide](LEVYTHON_1.0.3_FEATURES.md)
- [Quick Reference](QUICKREF.md)
- [Changelog](CHANGELOG.md)
- Module docs: `OS_*_MODULE.md`

### Community
- GitHub Issues: https://github.com/levython/Levython/issues
- Discussions: https://github.com/levython/Levython/discussions

### Examples
Check the `examples/` directory for demonstrations of new features:
```bash
levython examples/36_ternary_operator.levy
levython examples/28_os_hooks_demo.levy
levython examples/29_os_inputcontrol_demo.levy
```

---

## Rollback (If Needed)

If you encounter issues, you can roll back:

```bash
# Restore backup
rm -rf ~/.levython
mv ~/.levython.bak ~/.levython

# Or reinstall 1.0.2
git clone https://github.com/levython/Levython.git
cd Levython
git checkout v1.0.2
make
sudo make install
```

**Note:** We recommend reaching out for support before rolling back - 1.0.3 is fully backward compatible!

---

## What's Next

### Explore New Features
- Try the ternary operator for cleaner conditional code
- Explore OS.* modules for system automation
- Use enhanced process control for better subprocess management

### Share Feedback
Your feedback helps shape Levython's future:
- Report bugs: https://github.com/levython/Levython/issues
- Suggest features: https://github.com/levython/Levython/discussions
- Contribute: Pull requests welcome!

---

**Welcome to Levython 1.0.3!**

*Be better than yesterday* 🚀
