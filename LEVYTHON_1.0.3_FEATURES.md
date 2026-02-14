# Levython 1.0.3 - Complete Feature Guide

**Release Date:** February 14, 2026  
**Motto:** Be better than yesterday

---

## 🎯 What's New in 1.0.3

Levython 1.0.3 introduces **8 powerful system modules** for OS-level automation, security research, and low-level control, plus significant language and standard library enhancements.

---

## 🆕 Language Features

### Ternary Operator

Concise conditional expressions:

```levy
status <- count > 10 ? "large" : "small"
result <- is_active ? "ON" : "OFF"
message <- error ? "Failed: " + error : "Success"
```

### ASCII/Key Conversion

New input module utilities:

```levy
# Convert ASCII to character
char <- input.chr(65)  # Returns "A"

# Convert character to ASCII
code <- input.ord("A")  # Returns 65

# Use in input control
OS.InputControl.keyboard_send(65, true)      # Using ASCII
OS.InputControl.keyboard_send("A", true)     # Using character
```

---

## 🔧 Advanced System Modules

### 1. OS.Hooks - System Event Hooking

Monitor and intercept system events in real-time.

**Use Cases:****
- Security monitoring and threat detection
- Application behavior analysis
- System auditing and compliance
- Performance profiling

**Key Functions:**
```levy
# Register and manage hooks
hook_id <- OS.Hooks.register("PROCESS_CREATE", "Monitor new processes")
OS.Hooks.set_callback(hook_id, act(event) { say("Event: " + str(event)) })
OS.Hooks.enable(hook_id)
OS.Hooks.list()
OS.Hooks.disable(hook_id)
OS.Hooks.unregister(hook_id)

# Event-specific hooks
OS.Hooks.hook_process_create(pid)
OS.Hooks.hook_process_exit(pid, exit_code)
OS.Hooks.hook_file_access(path, "read")
OS.Hooks.hook_network_connect(host, port, "tcp")
OS.Hooks.hook_keyboard(key_code, pressed)
OS.Hooks.hook_mouse(x, y, button, pressed)
OS.Hooks.hook_syscall(syscall_number, args)
OS.Hooks.hook_memory_access(pid, address, size)
```

**Hook Types:**
- `PROCESS_CREATE` - New process creation
- `FILE_ACCESS` - File read/write operations
- `NETWORK_CONNECT` - Network connections
- `KEYBOARD` - Keyboard events
- `MOUSE` - Mouse events

---

### 2. OS.InputControl - Input Automation

Control keyboard, mouse, and touch input programmatically.

**Use Cases:**
- Test automation and UI testing
- Accessibility tools
- Gaming macros and bots
- Remote control applications

**Keyboard Control:**
```levy
OS.InputControl.capture_keyboard()
OS.InputControl.keyboard_send("A", true)          # Press
OS.InputControl.keyboard_send("A", false)         # Release
OS.InputControl.press_key("A")
OS.InputControl.release_key("A")
OS.InputControl.tap_key("ENTER")
OS.InputControl.type_text("Hello World")          # Natural delays
OS.InputControl.type_text_raw("Fast typing")      # No delays
OS.InputControl.remap_key("A", "B")
OS.InputControl.block_key("ESC")
OS.InputControl.unblock_key("ESC")
state <- OS.InputControl.get_keyboard_state()
OS.InputControl.release_keyboard()
```

**Mouse Control:**
```levy
OS.InputControl.capture_mouse()
OS.InputControl.move_mouse(500, 300)
OS.InputControl.mouse_click("LEFT", true)
OS.InputControl.press_mouse_button("LEFT")
OS.InputControl.release_mouse_button("LEFT")
OS.InputControl.click_mouse_button("LEFT", 2)  # Double click
OS.InputControl.scroll_mouse(0, -10)
pos <- OS.InputControl.get_mouse_position()
OS.InputControl.set_mouse_position(100, 100)
OS.InputControl.block_mouse_button("RIGHT")
OS.InputControl.unblock_mouse_button("RIGHT")
OS.InputControl.release_mouse()
```

**Touch Control (Mobile/Tablet):**
```levy
OS.InputControl.capture_touch()
OS.InputControl.send_touch_event(100, 200, 0.8)  # x, y, pressure
OS.InputControl.release_touch()
```

**Utilities:**
```levy
OS.InputControl.clear_input_buffer()
capturing <- OS.InputControl.is_capturing()  # Returns {keyboard, mouse, touch}
```

---

### 3. OS.Processes - Process Control

Advanced process management with memory operations.

**Use Cases:****
- Process monitoring and management
- Debugging and analysis
- Game modding and reverse engineering
- System administration

**Process Management:**
```levy
# List and inspect
procs <- OS.Processes.list()
info <- OS.Processes.get_info(pid)

# Create with options
opts <- {
    "cwd": "/tmp",
    "env": {"VAR": "value"},
    "stdin": "/dev/null"
}
pid <- OS.Processes.create("myapp", ["arg1", "arg2"], opts)

# Control
OS.Processes.suspend(pid)
OS.Processes.resume(pid)
OS.Processes.terminate(pid, false)  # Graceful
OS.Processes.terminate(pid, true)   # Force
OS.Processes.wait(pid, 5000)        # 5 second timeout
```

**Memory Operations:**
```levy
# Read process memory
data <- OS.Processes.read_memory(pid, 0x400000, 256)

# Write process memory
OS.Processes.write_memory(pid, 0x400000, data)

# Inject DLL/library
OS.Processes.inject_library(pid, "/path/to/library.so")
```

**Thread Management:**
```levy
threads <- OS.Processes.list_threads(pid)
for thread in threads {
    say("Thread ID: " + str(thread["id"]))
}
```

**Priority Control:**
```levy
OS.Processes.set_priority(pid, "HIGH")
prio <- OS.Processes.get_priority(pid)
# Priority levels: "LOW", "BELOW_NORMAL", "NORMAL", "ABOVE_NORMAL", "HIGH", "REALTIME"
```

---

### 4. OS.Display - Display & Graphics

Screen capture, pixel manipulation, and overlay rendering.

**Use Cases:****
- Screen recording and streaming
- Computer vision and image processing
- Game overlays and HUDs
- Accessibility tools

**Display Information:**
```levy
displays <- OS.Display.list()
for display in displays {
    say("Display " + str(display["id"]) + ": " + str(display["width"]) + "x" + str(display["height"]))
}

primary <- OS.Display.get_primary()
```

**Screen Capture:**
```levy
# Capture entire screen
img <- OS.Display.capture_screen(0)

# Capture region
region <- OS.Display.capture_region(0, 0, 800, 600)

# Capture specific window
window_img <- OS.Display.capture_window(window_id)

# Get individual pixel
color <- OS.Display.get_pixel(100, 100, 0)
```

**Overlay Graphics:**
```levy
# Note: Overlay functions may not be available in current implementation
# Cursor control
OS.Display.hide_cursor()
OS.Display.show_cursor()
```

---

### 5. OS.Audio - Audio Management

Control audio devices, playback, and recording.

**Use Cases:****
- Audio playback and recording
- Voice assistants
- Audio processing applications
- System sound control

**Device Management:**
```levy
# List devices
playback_devs <- OS.Audio.list_devices("playback")
recording_devs <- OS.Audio.list_devices("recording")
all_devs <- OS.Audio.list_devices("all")

# Default device
default_out <- OS.Audio.get_default_device("playback")
default_in <- OS.Audio.get_default_device("recording")
OS.Audio.set_default_device(device_id)

# Device info
info <- OS.Audio.get_device_info(device_id)
```

**Volume Control:**
```levy
# Get/set volume (0.0 - 1.0)
vol <- OS.Audio.get_volume()  # Default device
vol <- OS.Audio.get_volume(device_id)  # Specific device
OS.Audio.set_volume(0.75)  # 75% on default
OS.Audio.set_volume(0.75, device_id)  # 75% on specific device

# Mute control
is_muted <- OS.Audio.is_muted()
OS.Audio.set_mute(true)
OS.Audio.set_mute(false)
```

**Playback:**
```levy
# Play sound file
OS.Audio.play_sound("/path/to/sound.wav", 0.8, device_id)

# Generate tone
OS.Audio.play_tone(440, 1000, 0.5)  # 440Hz, 1 second, 50% volume

# Stop playback
OS.Audio.stop(stream_id)
```

**Audio Streaming:**
```levy
# Create stream
config <- {
    "sample_rate": 44100,
    "channels": 2,
    "format": "float32"
}
stream <- OS.Audio.create_stream(config)

# Write audio data
OS.Audio.write_stream(stream, audio_data)

# Close stream
OS.Audio.close_stream(stream)
```

**Recording:**
```levy
# Record audio  
audio_data <- OS.Audio.record(5000)  # 5 seconds from default device
audio_data <- OS.Audio.record(5000, device_id)  # 5 seconds from specific device
OS.Audio.stop_recording(stream_id)
```

**Mixing:**
```levy
mixed <- OS.Audio.mix_streams([audio1, audio2], [0.5, 0.5])
```

**Sample Rate:**
```levy
rate <- OS.Audio.get_sample_rate()
rate <- OS.Audio.get_sample_rate(device_id)
OS.Audio.set_sample_rate(48000)
OS.Audio.set_sample_rate(48000, device_id)
```

---

### 6. OS.Privileges - Permission Management

Handle privilege elevation and user impersonation.

**Use Cases:****
- Administrative task automation
- Security tools
- System maintenance scripts
- Privilege management

**Privilege Checks:**
```levy
# Check current privilege level
if OS.Privileges.is_elevated() {
    say("Running with elevated privileges")
}

if OS.Privileges.is_admin() {
    say("Running as administrator")
}

if OS.Privileges.is_root() {
    say("Running as root (Unix)")
}

# Get detailed level
level <- OS.Privileges.get_level()
# Returns: "STANDARD_USER", "ELEVATED_USER", "ADMINISTRATOR", "SYSTEM", "UNKNOWN"
```

**Elevation:**
```levy
# Check if can elevate
if OS.Privileges.can_elevate() {
    # Request elevation
    OS.Privileges.request_elevation("Need admin access")
    
    # Or elevate and restart
    OS.Privileges.elevate_and_restart(["arg1", "arg2"])
}
```

**Run as Admin:**
```levy
OS.Privileges.run_as_admin("mycommand", ["arg1", "arg2"])
```

**Privilege Management:**
```levy
# Enable specific privilege (Windows)
OS.Privileges.enable("SeDebugPrivilege")

# Check privilege
has_priv <- OS.Privileges.check("SeDebugPrivilege")

# Drop privileges
OS.Privileges.drop()
```

**User Information:**
```levy
user_info <- OS.Privileges.get_user_info()
token_info <- OS.Privileges.get_token_info()

# Impersonate (Windows)
OS.Privileges.impersonate_user("username")
```

---

### 7. OS.Events - Event Monitoring

Monitor filesystem, network, and power events.

**Use Cases:****
- File change monitoring
- Network activity logging
- Power management
- System event automation

**File Monitoring:**
```levy
# Watch directory for changes
listener_id <- OS.Events.watch_file("/var/log", ["created", "modified", "deleted"], act(event) {
    say("File changed: " + event["path"])
    say("Event type: " + event["type"])  # created, modified, deleted
    say("Timestamp: " + str(event["timestamp"]))
})
```

**Network Monitoring:**
```levy
net_listener <- OS.Events.watch_network(act(event) {
    say("Network event: " + event["type"])
    say("Interface: " + event["interface"])
    say("Status: " + event["status"])
})
```

**Power Events:**
```levy
pwr_listener <- OS.Events.watch_power(act(event) {
    say("Power status: " + event["status"])
    # Events: suspend, resume, battery_low, ac_connected, ac_disconnected
})
```

**Event Processing:**
```levy
# Poll for events
events <- OS.Events.poll(1000)  # 1 second timeout

# Start event loop (blocking)
OS.Events.start_loop()

# Stop event loop
OS.Events.stop_loop()

# Dispatch pending events
count <- OS.Events.dispatch()

# Get recent events
recent <- OS.Events.get_recent(10)
```

**Management:**
```levy
# List active listeners
listeners <- OS.Events.list()

# Update callback
OS.Events.set_callback("file_change", new_callback)

# Remove callback
OS.Events.remove_callback("file_change")

# Unregister
OS.Events.unwatch(listener_id)
```

---

### 8. OS.Persistence - System Persistence

Manage autostart entries, services, and scheduled tasks.

**Use Cases:****
- Application autostart configuration
- Service management
- Scheduled maintenance tasks
- System automation

**Autostart Management:**
```levy
# Add autostart entry
OS.Persistence.add_autostart("myapp", "/path/to/app", "user")
OS.Persistence.add_autostart("system-tool", "/path/to/tool", "system")

# List autostart entries
user_apps <- OS.Persistence.list_autostart("user")
system_apps <- OS.Persistence.list_autostart("system")

# Remove autostart
OS.Persistence.remove_autostart("myapp", "user")
```

**Service Management (Windows/Linux):**
```levy
# Install service
OS.Persistence.install_service(
    "myservice",              # Name
    "My Service",             # Display name
    "Service description",    # Description
    "/path/to/service",       # Command/executable
    true                      # Auto-start on boot
)

# Control service
OS.Persistence.start_service("myservice")
OS.Persistence.stop_service("myservice")
OS.Persistence.restart_service("myservice")

# Get status
status <- OS.Persistence.get_service_status("myservice")
# Status: "running", "stopped", "paused", "starting", "stopping"

# Uninstall service
OS.Persistence.uninstall_service("myservice")
```

**Scheduled Tasks:**
```levy
# Add scheduled task
OS.Persistence.add_scheduled_task("backup", "/path/to/backup.sh", "daily", "09:00")
OS.Persistence.add_scheduled_task("weekly-report", "/path/to/report.sh", "weekly", "Monday 08:00")

# Remove scheduled task
OS.Persistence.remove_scheduled_task("backup")
```

---

## 📚 Enhanced OS Module

### Advanced Filesystem Operations

```levy
# Advanced directory traversal
for entry in os.scandir("/path") {
    say(entry["name"] + " - " + entry["type"])
}

# Walk directory tree
for item in os.walk("/path") {
    say("Dir: " + item["path"])
    say("Files: " + str(item["files"]))
}

# Glob pattern matching
files <- os.glob("/path/*.levy")

# Hard links
os.link("/path/to/original", "/path/to/link")

# Get disk usage
usage <- os.disk_usage("/")
say("Total: " + str(usage["total"]))
say("Used: " + str(usage["used"]))
say("Free: " + str(usage["free"]))
```

### File Descriptor Operations

```levy
# Low-level file I/O
fd <- os.open("/path/to/file", "r+")
data <- os.read(fd, 1024)
os.write(fd, "new data")
os.fsync(fd)
os.close(fd)

# Convert FD to file object
file_obj <- os.fdopen(fd, "w")
```

### Signal Handling (POSIX)

```levy
# Set signal handler
os.signal(os.SIGINT, "ignore")
os.signal(os.SIGTERM, "default")

# Alarm
os.alarm(5)  # Trigger SIGALRM in 5 seconds

# Pause until signal
os.pause()

# Kill process group
os.killpg(pgid, os.SIGTERM)
```

### Process Control Enhancements

```levy
# Capture stdout/stderr with timeout
result <- os.run_capture("mycommand", ["arg1"], 5000, "input data")
say("stdout: " + result["stdout"])
say("stderr: " + result["stderr"])
say("exit code: " + str(result["code"]))
if result["timed_out"] { say("Command timed out!") }

# Simple stdout capture
output <- os.popen("ls", ["-la"])

# Spawn with I/O redirection
pid <- os.spawn_io(
    "myapp",
    ["arg1"],
    "/path/to/stdin.txt",
    "/path/to/stdout.log",
    "/path/to/stderr.log",
    true  # append mode
)

# Non-blocking wait
status <- os.waitpid(pid, true)  # nohang=true
```

### User/Group Management

```levy
# Convert UID/GID to names
username <- os.uid_name(1000)
groupname <- os.gid_name(1000)

# Convert names to UID/GID
user_info <- os.getpwnam("username")
group_info <- os.getgrnam("groupname")

# Current user
login <- os.getlogin()
groups <- os.getgroups()  # List of numeric GIDs
```

### Enhanced Permissions

```levy
# Symbolic mode
os.chmod("/path/to/file", "u+rwx,g+r,o-rwx")
os.chmod("/path/to/file", "a+x")

# Octal string
os.chmod("/path/to/file", "0755")
os.chmod("/path/to/file", "0644")

# macOS file flags
os.chflags("/path/to/file", 0x00000002)  # UF_IMMUTABLE
```

### System Information

```levy
# CPU information
cpu <- os.cpu_info()
say("Model: " + cpu["model"])
say("Cores: " + str(cpu["count"]))

# Load averages (Unix)
load <- os.loadavg()
say("1min: " + str(load["1min"]))

# OS release
release <- os.os_release()
say("Name: " + release["name"])
say("Version: " + release["version"])

# Boot time
boot <- os.boot_time()

# Locale and timezone
locale <- os.locale()
tz <- os.timezone()

# Mounted filesystems
mounts <- os.mounts()
for mount in mounts {
    say(mount["device"] + " on " + mount["mountpoint"])
}
```

---

## 🔨 Build System Improvements

### Enhanced Makefile

```bash
# Cross-platform build
make                    # Build for current platform
make CXX=g++            # Use GCC
make CXXFLAGS='-O0 -g'  # Debug build

# Platform-specific
make terminal           # Terminal mode (default)
make gui                # GUI mode with SDL2

# System installation
make install            # Install to /usr/local/bin
make uninstall          # Remove from system

# Utilities
make clean              # Remove build artifacts
make help               # Show help message
```

**Features:**
- Automatic platform detection (macOS, Linux, Windows)
- Architecture detection (ARM64, x86_64)
- Platform-specific library linking
- Install/uninstall targets
- Comprehensive help system

---

## 📦 Installation

### Quick Install (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/levython/Levython/main/install.sh | bash
```

### Windows

Download the installer from [GitHub Releases](https://github.com/levython/Levython/releases/latest)

### Build from Source

```bash
git clone https://github.com/levython/Levython.git
cd Levython
make
sudo make install
```

---

## 📖 Documentation

- **README**: [README.md](README.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **Quick References**: `OS_*_QUICKREF.md` files
- **Implementation Details**: `OS_*_IMPLEMENTATION.md` files
- **Module Documentation**: `OS_*_MODULE.md` files

---

## 🤝 Contributing

Contributions welcome! Areas of interest:
- Module enhancements
- Cross-platform compatibility
- Performance optimizations
- Documentation improvements

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

**Levython 1.0.3** - *Be better than yesterday*
