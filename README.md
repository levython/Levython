# Levython 1.0.3

Levython is a high‑performance, general‑purpose programming language with an x86‑64 JIT, a fast bytecode VM, and a practical standard library.

Motto: **Be better than yesterday**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://github.com/levython/Levython)
[![Release](https://img.shields.io/badge/release-14%20Feb%202026-green.svg)](https://github.com/levython/Levython/releases)

Documentation: https://levython.github.io/documentation/

---

## Contents

- Overview
- Installation (Windows / macOS / Linux)
- Quick Start
- Language Guide
- Standard Library
- HTTP Server (Userland)
- Package Manager (LPM)
- Build System
- CLI Reference
- Project Layout
- Contributing
- License

---

## Overview

Levython focuses on fast execution and developer ergonomics:
- JIT‑accelerated execution and a high‑performance VM
- Clean syntax, functions, classes, inheritance, and exceptions
- Batteries‑included standard library for real programs
- Cross‑platform tooling: macOS, Linux, Windows

---

## Installation

### Windows

**Option 1: GUI Installer (Recommended)**
- Download the installer: https://github.com/levython/Levython/releases/latest
- Supports both 32‑bit and 64‑bit Windows

**Option 2: Pre‑built Binaries**
- levython‑windows‑x64.exe
- levython‑windows‑x86.exe

Manual PATH instructions: `WINDOWS_INSTALL.md`

**Build from Source (Windows):**
```batch
build-windows.bat
build-windows.bat --arch=both
build-installer.bat
```

**Important (Windows Installer EXE):**
- The **GUI installer EXE** is built from `installer/levython-setup.iss` (Inno Setup).
- `Install-Levython.bat` / `LevythonInstaller.ps1` are for **local install from source** and do **not** produce the GUI EXE.

### macOS & Linux

**One‑line install:**
```bash
curl -fsSL https://raw.githubusercontent.com/levython/levython/main/install.sh | bash
```

**Manual install:**
```bash
git clone https://github.com/levython/Levython.git
cd levython
chmod +x install.sh
./install.sh
```

---

## Quick Start

```levy
name <- "Levython"

act greet(who) {
    say("Hello, " + who)
}

greet(name)
```

Run:
```bash
levython hello.levy
```

---

## Language Guide

### Variables and Types

```levy
name <- "Levython"
count <- 3
pi <- 3.14159
active <- true
nothing <- none
```

### Functions

```levy
act add(a, b) { -> a + b }
result <- add(2, 3)
```

### Conditionals

```levy
if count > 2 {
    say("big")
} else {
    say("small")
}

# Ternary operator (new in 1.0.3)
status <- count > 10 ? "large" : "small"
result <- is_active ? "ON" : "OFF"
```

### Loops

```levy
for i in range(1, 4) {
    say(str(i))
}

items <- ["a", "b", "c"]
for x in items {
    say(x)
}

n <- 3
while n > 0 {
    say(str(n))
    n <- n - 1
}
```

### Lists and Maps

```levy
nums <- [1, 2, 3]
append(nums, 4)

m <- {"a": 1, "b": 2}
ks <- keys(m)
```

### Classes and Inheritance

```levy
class Counter {
    init(label) { self.label <- label; self.value <- 0 }
    inc() { self.value <- self.value + 1 }
}

class NamedCounter is a Counter {
    init(label) { super.init(label) }
}

c <- Counter("hits")
c.inc()
```

### Exceptions

```levy
try {
    x <- 1 / 0
} catch {
    say("failed")
}
```

---

## Standard Library

### Core Builtins

- `say`, `ask`, `print`, `println`
- `len`, `range`, `append`, `keys`
- `str`, `int`, `float`, `type`
- `min`, `max`, `sum`, `sorted`, `reversed`
- `upper`, `lower`, `trim`, `replace`, `split`, `join`, `contains`, `find`, `startswith`, `endswith`
- `time`, `sqrt`, `pow`, `floor`, `ceil`, `round`

### Core Modules

#### `os`
**Basic System Operations**
- `name`, `sep`, `path_sep` - Platform identification
- `cwd`, `chdir`, `listdir` - Directory operations
- `exists`, `is_file`, `is_dir` - Path checks
- `mkdir`, `remove`, `rmdir`, `rename`, `copy`, `move` - File operations
- `abspath`, `realpath`, `symlink`, `readlink` - Path resolution
- `getenv`, `setenv`, `unsetenv`, `env`, `getenvs`, `env_list` - Environment
- `expanduser`, `expandvars`, `path_expand`, `homedir`, `username` - Path expansion

**Advanced Filesystem**
- `stat`, `lstat`, `fstat` - File metadata
- `chmod` - Permissions (supports octal and symbolic modes like `u+rwx,g-w`)
- `chown` - Ownership
- `scandir`, `walk`, `glob` - Directory traversal
- `link`, `renameat` - Advanced linking
- `disk_usage`, `statvfs` - Disk information
- `touch`, `rmdir_rf`, `mkdir_p` - Convenience operations

**File Descriptors**
- `open`, `read`, `write`, `fsync`, `close`, `fdopen` - Low-level I/O
- `chdir_push`, `chdir_pop` - Directory stack

**Process Management**
- `getpid`, `ppid`, `argv`, `exit` - Current process
- `exec`, `spawn`, `kill`, `kill_tree` - Process control
- `ps` - List processes
- `run(cmd, args=[], timeout_ms=0)` - Execute with timeout
- `run_capture(cmd, args=[], timeout_ms=0, input="")` - Capture stdout/stderr/exit code
- `popen(cmd, args=[], input="")` - Simple stdout capture
- `spawn_io(cmd, args=[], stdin_path="", stdout_path="", stderr_path="", append=false)` - Process with I/O redirection
- `waitpid(pid, nohang=false)` - Wait for process

**User & Permissions**
- `user`, `uid`, `gid`, `getlogin`, `getgroups` - Current user
- `is_admin`, `elevate` - Privilege checks
- `uid_name(uid)`, `gid_name(gid)` - ID to name lookup
- `getpwnam(name)`, `getgrnam(name)` - Name to ID lookup
- `setuid`, `setgid`, `getpgid`, `setpgid`, `setsid` - POSIX user/group (stubs on Windows)
- `nice`, `getpriority`, `setpriority` - Process priority

**Signal Handling (POSIX)**
- `signal(sig, action)` - Set signal handler (`"ignore"` or `"default"`)
- `alarm`, `pause`, `killpg` - Signal operations (throw on Windows)
- Signal constants: `SIGINT`, `SIGTERM`, `SIGKILL`, `SIGHUP`, etc.

**System Information**
- `hostname`, `set_hostname` - Host name
- `uptime`, `boot_time` - System uptime
- `cpu_count`, `cpu_info` - CPU information
- `mem_total`, `mem_free` - Memory stats
- `loadavg` - Load averages
- `platform`, `os_release` - OS details
- `locale`, `timezone` - Regional settings
- `mounts` - Mounted filesystems

**System Control**
- `shutdown`, `restart`, `logout`, `lock`, `hibernate` - Power management
- `sleep`, `sleep_ms` - Delays
- `which`, `tempdir` - Utilities

**Platform-Specific**
- macOS: `chflags`, power/battery stats
- Windows: Service control
- Linux: cgroups, process namespaces

#### `http`
- `get`, `post`, `put`, `patch`, `delete`, `head`, `request`
- `set_timeout`, `set_verify_ssl`

#### `fs`
- `exists`, `is_file`, `is_dir`, `mkdir`, `remove`, `rmdir`, `listdir`
- `read_text`, `write_text`, `append_text`, `copy`, `move`, `abspath`

#### `path`
- `join`, `basename`, `dirname`, `ext`, `stem`, `norm`, `abspath`
- `exists`, `is_file`, `is_dir`, `read_text`, `write_text`, `listdir`, `mkdir`, `remove`, `rmdir`

#### `process`
- `getpid`, `run`, `cwd`, `chdir`, `getenv`, `setenv`, `unsetenv`

#### `json`
- `parse`, `stringify`

#### `url`
- `parse`, `encode`, `decode`

#### `net`
- `tcp_connect`, `tcp_listen`, `tcp_accept`, `tcp_try_accept`
- `tcp_send`, `tcp_try_send`, `tcp_recv`, `tcp_try_recv`, `tcp_close`
- `udp_bind`, `udp_sendto`, `udp_recvfrom`, `udp_close`
- `set_nonblocking`, `dns_lookup`

#### `thread`
- `spawn`, `join`, `is_done`, `sleep`

#### `channel`
- `create`, `send`, `recv`, `try_recv`, `close`

#### `async`
- `spawn`, `sleep`, `tcp_recv`, `tcp_send`, `tick`, `done`, `status`, `result`, `cancel`, `pending`, `await`

#### `crypto`
- `sha256`, `sha512`, `hmac_sha256`
- `random_bytes`, `hex_encode`, `hex_decode`, `base64_encode`, `base64_decode`

#### `datetime`
- `now_utc`, `now_local`, `format`, `parse`, `sleep_ms`, `epoch_ms`

#### `log`
- `set_level`, `set_output`, `set_json`, `log`, `debug`, `info`, `warn`, `error`, `flush`

#### `config`
- `load_env`, `get`, `set`, `get_int`, `get_float`, `get_bool`, `has`

#### `input`
- `enable_raw`, `disable_raw`, `key_available`, `poll`, `read_key`
- `chr(ascii)` - Convert ASCII code to character
- `ord(key)` - Convert character to ASCII code

---

## Advanced System Modules (New in 1.0.3)

Levython provides powerful OS-level modules for system automation, security research, and low-level control.

### OS.Hooks - System Event Hooking

Monitor and intercept system events in real-time.

```levy
# Register hooks
hook_id <- OS.Hooks.register("PROCESS_CREATE", "Monitor new processes")
OS.Hooks.set_callback(hook_id, act(event) { say("Process: " + event["pid"]) })
OS.Hooks.enable(hook_id)

# Specific event hooks
OS.Hooks.hook_process_create(1234)
OS.Hooks.hook_file_access("/etc/config", "read")
OS.Hooks.hook_network_connect("example.com", 443, "tcp")
OS.Hooks.hook_keyboard(65, true)  # 'A' key pressed
OS.Hooks.hook_mouse(100, 200, 0, true)

# List and manage
hooks <- OS.Hooks.list()
OS.Hooks.disable(hook_id)
OS.Hooks.unregister(hook_id)
```

**Functions:**
- `register(type, description='')`, `unregister(hook_id)`
- `list()`, `enable(hook_id)`, `disable(hook_id)`
- `set_callback(hook_id, callback)`
- `hook_process_create(pid)`, `hook_process_exit(pid, exit_code=0)`
- `hook_file_access(path, mode='read')`, `hook_network_connect(host, port, protocol='tcp')`
- `hook_keyboard(key_code, pressed)`, `hook_mouse(x, y, button=0, pressed=true)`
- `hook_syscall(syscall_number, args=[])`, `inject_library(pid, library_path)`
- `hook_memory_access(pid, address, size=8)`

### OS.InputControl - Input Automation

Control keyboard, mouse, and touch input programmatically.

```levy
# Keyboard control
OS.InputControl.capture_keyboard()
OS.InputControl.keyboard_send("A", true)  # Press 'A' (can use ASCII or key name)
OS.InputControl.keyboard_send(65, true)   # Same as above using ASCII code
OS.InputControl.type_text("Hello World")  # With natural delays
OS.InputControl.type_text_raw("Fast typing")  # No delays
OS.InputControl.press_key("A")
OS.InputControl.release_key("A")
OS.InputControl.tap_key("ENTER")
OS.InputControl.remap_key("A", "B")  # Remap A to B
OS.InputControl.block_key("ESC")
OS.InputControl.unblock_key("ESC")
state <- OS.InputControl.get_keyboard_state()

# Mouse control
OS.InputControl.capture_mouse()
OS.InputControl.move_mouse(500, 300)
OS.InputControl.mouse_click("LEFT", true)
OS.InputControl.press_mouse_button("LEFT")
OS.InputControl.release_mouse_button("LEFT")
OS.InputControl.click_mouse_button("LEFT", 2)  # Double click
OS.InputControl.scroll_mouse(0, -10)
OS.InputControl.block_mouse_button("RIGHT")
OS.InputControl.unblock_mouse_button("RIGHT")
pos <- OS.InputControl.get_mouse_position()
OS.InputControl.set_mouse_position(100, 100)

# Touch (mobile/tablet)
OS.InputControl.capture_touch()
OS.InputControl.send_touch_event(100, 200, 0.8)
OS.InputControl.release_touch()

# Utility
OS.InputControl.clear_input_buffer()
capturing_state <- OS.InputControl.is_capturing()  # Returns {keyboard, mouse, touch}
OS.InputControl.release_keyboard()
OS.InputControl.release_mouse()
```

**Key Conversion:**
- `input.chr(ascii)` - Convert ASCII code to character
- `input.ord(key)` - Convert character to ASCII code

### OS.Processes - Process Control

Advanced process management and memory operations.

```levy
# List and inspect processes
procs <- OS.Processes.list()
info <- OS.Processes.get_info(1234)

# Create and control
opts <- {"cwd": "/tmp", "env": {"VAR": "value"}}
pid <- OS.Processes.create("myapp", ["arg1"], opts)
OS.Processes.suspend(pid)
OS.Processes.resume(pid)
OS.Processes.terminate(pid, false)  # Graceful
OS.Processes.wait(pid, 5000)  # 5 second timeout

# Memory operations
data <- OS.Processes.read_memory(pid, 0x400000, 256)
OS.Processes.write_memory(pid, 0x400000, data)

# Priority control
OS.Processes.set_priority(pid, "HIGH")
prio <- OS.Processes.get_priority(pid)

# Thread inspection
threads <- OS.Processes.list_threads(pid)
```

### OS.Display - Display & Graphics

Screen capture, pixel manipulation, and overlay rendering.

```levy
# Display info
displays <- OS.Display.get_displays()
primary <- OS.Display.get_primary()

# Screen capture
img <- OS.Display.capture_screen(0)
region <- OS.Display.capture_region(0, 0, 800, 600)
color <- OS.Display.get_pixel(100, 100)

# Overlay graphics
config <- {"width": 800, "height": 600, "transparent": true}
overlay <- OS.Display.create_overlay(config)
OS.Display.draw_rect(overlay, 10, 10, 100, 50, 0xFF0000)
OS.Display.draw_text(overlay, 20, 20, "Hello", 0xFFFFFF)
OS.Display.update_overlay(overlay)

# Display modes
modes <- OS.Display.get_modes(0)
OS.Display.set_mode(0, 1920, 1080, 60)

# Cursor control
OS.Display.hide_cursor()
OS.Display.show_cursor()
```

### OS.Audio - Audio Management

Control audio devices, playback, and recording.

```levy
# Device management
devices <- OS.Audio.list_devices("all")
default_out <- OS.Audio.get_default_device("playback")
OS.Audio.set_default_device(device_id)
info <- OS.Audio.get_device_info(device_id)

# Volume control
vol <- OS.Audio.get_volume()  # Default device
vol <- OS.Audio.get_volume(device_id)  # Specific device
OS.Audio.set_volume(0.75)  # 75% on default device
OS.Audio.set_volume(0.75, device_id)  # 75% on specific device
is_muted <- OS.Audio.is_muted()
OS.Audio.set_mute(true)

# Playback
OS.Audio.play_sound("/path/to/sound.wav", 0.8, device_id)
OS.Audio.play_tone(440, 1000, 0.5)  # 440Hz for 1 second
OS.Audio.stop(stream_id)

# Streaming
config <- {"sample_rate": 44100, "channels": 2}
stream <- OS.Audio.create_stream(config)
OS.Audio.write_stream(stream, audio_data)
OS.Audio.close_stream(stream)

# Recording
audio <- OS.Audio.record(5000)  # 5 seconds
audio <- OS.Audio.record(5000, device_id)  # Specific device
OS.Audio.stop_recording(stream_id)

# Sample rate
rate <- OS.Audio.get_sample_rate()
OS.Audio.set_sample_rate(48000)

# Mixing
mixed <- OS.Audio.mix_streams([audio1, audio2], [0.5, 0.5])
```

### OS.Privileges - Permission Management

Handle privilege elevation and user impersonation.

```levy
# Check privileges
if OS.Privileges.is_elevated() {
    say("Running with elevated privileges")
}

level <- OS.Privileges.get_level()  
# Returns: "STANDARD_USER", "ELEVATED_USER", "ADMINISTRATOR", "SYSTEM", "UNKNOWN"

# Request elevation
if OS.Privileges.can_elevate() {
    OS.Privileges.request_elevation("Need admin access")
}

# Run as admin
OS.Privileges.run_as_admin("mycommand", ["arg1", "arg2"])

# Privilege management
OS.Privileges.enable("SeDebugPrivilege")
has_priv <- OS.Privileges.check("SeDebugPrivilege")
OS.Privileges.drop()

# User information
user_info <- OS.Privileges.get_user_info()
token_info <- OS.Privileges.get_token_info()
OS.Privileges.impersonate_user("username")
```

### OS.Events - Event Monitoring

Monitor filesystem, network, and power events.

```levy
# File monitoring
listener_id <- OS.Events.watch_file("/var/log", ["created", "modified"], act(event) {
    say("File changed: " + event["path"])
})

# Network monitoring
net_listener <- OS.Events.watch_network(act(event) {
    say("Network event: " + event["type"])
})

# Power events
pwr_listener <- OS.Events.watch_power(act(event) {
    say("Power status: " + event["status"])
})

# Event processing
events <- OS.Events.poll(1000)  # 1 second timeout
OS.Events.start_loop()  # Blocking
OS.Events.stop_loop()
count <- OS.Events.dispatch()
recent <- OS.Events.get_recent(10)

# Management
listeners <- OS.Events.list()
OS.Events.set_callback("file_change", callback)
OS.Events.remove_callback("file_change")
OS.Events.unwatch(listener_id)
```

### OS.Persistence - System Persistence

Manage autostart, services, and scheduled tasks.

```levy
# Autostart entries
OS.Persistence.add_autostart("myapp", "/path/to/app", "user")
entries <- OS.Persistence.list_autostart("system")
OS.Persistence.remove_autostart("myapp", "user")

# Service management (Windows/Linux)
OS.Persistence.install_service(
    "myservice",
    "My Service",
    "Service description",
    "/path/to/service",
    true
)
OS.Persistence.start_service("myservice")
status <- OS.Persistence.get_service_status("myservice")
OS.Persistence.stop_service("myservice")
OS.Persistence.restart_service("myservice")
OS.Persistence.uninstall_service("myservice")

# Scheduled tasks
OS.Persistence.add_scheduled_task("backup", "/path/to/backup.sh", "daily", "09:00")
OS.Persistence.remove_scheduled_task("backup")
```

---

## HTTP Server (Userland)

Use the included helper module: `http_server.levy`

```levy
import http_server

act handler(req) {
    if req["path"] == "/health" { -> {"status": 200, "body": "ok"} }
    -> {"status": 404, "body": "not found"}
}

http_server.serve("127.0.0.1", 18082, handler)
```

---

## Package Manager (LPM)

```bash
levython lpm search ml
levython lpm install math
levython lpm list
levython lpm remove math
```

---

## Build System

```
levython build <input.levy|.ly> [options]
  -o, --output <file>      Output executable path
  --target <t>             native|windows|linux|macos|<target-triple>
  --runtime <file>         Use prebuilt runtime binary instead of compiling
  --source-root <dir>      Source root for cross-runtime compile (default: .)
  --verbose                Print cross-compile command
```

Examples:
```
levython build app.levy -o app
levython build app.levy --target windows -o app.exe
levython build app.levy --target aarch64-macos -o app-mac
```

---

## CLI Reference

```
Usage: levython [options] <file.levy|.ly>

Options:
  --help, -h       Show help message
  --version, -v    Show version
  --no-update-check Disable update checks
  lpm <command>    Package manager
  build <src>      Build standalone executable
```

---

## Project Layout

```
levython/
├── src/                 # Core implementation
├── examples/            # Example programs
├── tests/               # Tests
├── installer/           # Windows installer assets
├── install.sh           # Cross-platform installer
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Contributing

Contributions are welcome. Areas of interest:
- JIT/VM optimizations
- Standard library modules
- Tooling and documentation

---

## License

MIT
