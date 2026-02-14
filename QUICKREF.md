# Levython 1.0.3 - Quick Reference Guide

**Complete API Reference for Levython Programming Language**

---

## 📋 Table of Contents

1. [Language Syntax](#language-syntax)
2. [Core Builtins](#core-builtins)
3. [Standard Modules](#standard-modules)
4. [System Modules](#system-modules)
5. [Code Examples](#code-examples)

---

## Language Syntax

### Variables & Types
```levy
name <- "string"
count <- 42
price <- 9.99
active <- true
nothing <- none
list <- [1, 2, 3]
map <- {"key": "value"}
```

### Functions
```levy
act greet(name) {
    say("Hello, " + name)
}

act add(a, b) { -> a + b }
result <- add(5, 3)
```

### Conditionals
```levy
if x > 10 {
    say("big")
} else if x > 5 {
    say("medium")
} else {
    say("small")
}

# Ternary operator (1.0.3+)
status <- x > 10 ? "big" : "small"
```

### Loops
```levy
for i in range(1, 10) { say(str(i)) }
for item in list { say(item) }
while x > 0 { x <- x - 1 }
```

### Classes
```levy
class Person {
    init(name, age) {
        self.name <- name
        self.age <- age
    }
    greet() { say("Hi, I'm " + self.name) }
}

class Employee is a Person {
    init(name, age, title) {
        super.init(name, age)
        self.title <- title
    }
}
```

### Exceptions
```levy
try {
    risky_operation()
} catch {
    say("Error occurred")
}
```

---

## Core Builtins

### I/O
- `say(msg)` - Print with newline
- `print(msg)` - Print without newline
- `println(msg)` - Print with newline
- `ask(prompt)` - Get user input

### Type Conversion
- `str(val)` - Convert to string
- `int(val)` - Convert to integer
- `float(val)` - Convert to float
- `type(val)` - Get type name

### Collections
- `len(collection)` - Get length
- `append(list, item)` - Add to list
- `keys(map)` - Get map keys
- `range(start, end)` - Generate range
- `sorted(list)` - Sort list
- `reversed(list)` - Reverse list

### Math
- `min(a, b, ...)` - Minimum value
- `max(a, b, ...)` - Maximum value
- `sum(list)` - Sum of list
- `sqrt(n)` - Square root
- `pow(base, exp)` - Power
- `floor(n)` - Floor
- `ceil(n)` - Ceiling
- `round(n)` - Round

### Strings
- `upper(s)` - Uppercase
- `lower(s)` - Lowercase
- `trim(s)` - Remove whitespace
- `replace(s, old, new)` - Replace substring  
- `split(s, delim)` - Split string
- `join(list, delim)` - Join strings
- `contains(s, substr)` - Check substring
- `find(s, substr)` - Find position
- `startswith(s, prefix)` - Check prefix
- `endswith(s, suffix)` - Check suffix

### Utilities
- `time()` - Current timestamp

---

## Standard Modules

### os - Operating System

**Paths & Files**
```levy
os.name              # Platform name
os.sep               # Path separator
os.path_sep          # PATH separator
os.cwd()             # Current directory
os.chdir(path)       # Change directory
os.listdir(path)     # List directory
os.exists(path)      # Check existence
os.is_file(path)     # Is file?
os.is_dir(path)      # Is directory?
os.mkdir(path)       # Create directory
os.remove(path)      # Delete file
os.rmdir(path)       # Delete directory
os.rename(old, new)  # Rename
os.copy(src, dst)    # Copy
os.move(src, dst)    # Move
```

**Path Operations**
```levy
os.abspath(path)      # Absolute path
os.realpath(path)     # Resolve symlinks
os.symlink(src, dst)  # Create symlink
os.readlink(path)     # Read symlink
os.expanduser(path)   # Expand ~
os.expandvars(path)   # Expand $VAR
os.path_expand(path)  # Expand both
os.homedir()          # Home directory
os.username()         # Username
```

**Environment**
```levy
os.getenv(key)        # Get env var
os.setenv(key, val)   # Set env var
os.unsetenv(key)      # Remove env var
os.env()              # All env vars (map)
os.getenvs()          # All env vars (list of maps)
os.env_list()         # Env var names
```

**File Metadata**
```levy
os.stat(path)         # File stats
os.lstat(path)        # Link stats (no follow)
os.fstat(fd)          # FD stats
os.chmod(path, mode)  # Change permissions (octal or symbolic)
os.chown(path, uid, gid) # Change owner
```

**Advanced FS**
```levy
os.scandir(path)      # Efficient directory scan
os.walk(path)         # Recursive walk
os.glob(pattern)      # Pattern matching
os.link(src, dst)     # Hard link
os.renameat(...)      # Rename with FDs
os.disk_usage(path)   # Disk space
os.statvfs(path)      # FS statistics
os.touch(path)        # Create/update file
os.rmdir_rf(path)     # Recursive remove
os.mkdir_p(path)      # Create parent dirs
```

**File Descriptors**
```levy
fd <- os.open(path, mode)  # Open file
data <- os.read(fd, size)  # Read
os.write(fd, data)         # Write
os.fsync(fd)               # Sync to disk
os.close(fd)               # Close
file <- os.fdopen(fd, mode) # Convert to file object
os.chdir_push(path)        # Push and change dir
os.chdir_pop()             # Pop and restore dir
```

**Processes**
```levy
os.getpid()           # Current PID
os.ppid()             # Parent PID
os.argv()             # Command line args
os.exit(code)         # Exit process
os.exec(cmd)          # Replace process
os.spawn(cmd, args)   # Spawn process
os.kill(pid, signal)  # Send signal
os.kill_tree(pid, sig) # Kill process tree
os.ps()               # List processes
```

**Process Execution**
```levy
# Simple run with timeout
os.run(cmd, args, timeout_ms)

# Capture output
result <- os.run_capture(cmd, args, timeout_ms, input)
# result: {stdout, stderr, code, timed_out}

# Simple stdout capture
output <- os.popen(cmd, args, input)

# Spawn with I/O redirection
pid <- os.spawn_io(cmd, args, stdin_path, stdout_path, stderr_path, append)

# Wait for process
status <- os.waitpid(pid, nohang)
```

**User & Groups**
```levy
os.user()             # Username
os.uid()              # User ID
os.gid()              # Group ID
os.getlogin()         # Login name
os.getgroups()        # Group IDs
os.is_admin()         # Is admin/root?
os.elevate()          # Request elevation
os.uid_name(uid)      # UID to name
os.gid_name(gid)      # GID to name
os.getpwnam(name)     # Name to user info
os.getgrnam(name)     # Name to group info
os.setuid(uid)        # Set UID (POSIX, stub on Windows)
os.setgid(gid)        # Set GID (POSIX, stub on Windows)
os.getpgid(pid)       # Get process group
os.setpgid(pid, pgid) # Set process group
os.setsid()           # Create session
os.nice(inc)          # Adjust priority
os.getpriority(which, who) # Get priority
os.setpriority(which, who, prio) # Set priority
```

**Signals (POSIX)**
```levy
os.signal(sig, action) # "ignore" or "default"
os.alarm(seconds)      # Set alarm
os.pause()             # Wait for signal
os.killpg(pgid, sig)   # Kill process group

# Signal constants
os.SIGINT, os.SIGTERM, os.SIGKILL, os.SIGHUP, os.SIGABRT,
os.SIGUSR1, os.SIGUSR2, os.SIGALRM, os.SIGCHLD, os.SIGCONT,
os.SIGSTOP, os.SIGTSTP, os.SIGTTIN, os.SIGTTOU, os.SIGPIPE
```

**System Info**
```levy
os.hostname()         # Host name
os.set_hostname(name) # Set host name
os.uptime()           # System uptime
os.boot_time()        # Boot timestamp
os.cpu_count()        # CPU cores
os.cpu_info()         # CPU details
os.mem_total()        # Total memory
os.mem_free()         # Free memory
os.loadavg()          # Load averages
os.platform()         # Platform string
os.os_release()       # OS release info
os.locale()           # System locale
os.timezone()         # Timezone
os.mounts()           # Mounted filesystems
```

**Power Management**
```levy
os.shutdown()         # Shutdown system
os.restart()          # Restart system
os.logout()           # Logout user
os.lock()             # Lock screen
os.hibernate()        # Hibernate
os.sleep(seconds)     # Sleep seconds
os.sleep_ms(ms)       # Sleep milliseconds
```

**Utilities**
```levy
os.which(cmd)         # Find command in PATH
os.tempdir()          # Temporary directory
```

### http - HTTP Client

```levy
http.get(url)
http.post(url, data)
http.put(url, data)
http.patch(url, data)
http.delete(url)
http.head(url)
http.request(method, url, options)
http.set_timeout(seconds)
http.set_verify_ssl(enabled)
```

### fs - Filesystem

```levy
fs.exists(path)
fs.is_file(path)
fs.is_dir(path)
fs.mkdir(path)
fs.remove(path)
fs.rmdir(path)
fs.listdir(path)
fs.read_text(path)
fs.write_text(path, content)
fs.append_text(path, content)
fs.copy(src, dst)
fs.move(src, dst)
fs.abspath(path)
```

### path - Path Utilities

```levy
path.join(parts...)
path.basename(path)
path.dirname(path)
path.ext(path)
path.stem(path)
path.norm(path)
path.abspath(path)
path.exists(path)
path.is_file(path)
path.is_dir(path)
```

### json - JSON Processing

```levy
obj <- json.parse(json_string)
json_str <- json.stringify(obj)
```

### net - Networking

**TCP**
```levy
sock <- net.tcp_connect(host, port)
server <- net.tcp_listen(host, port)
client <- net.tcp_accept(server)
client <- net.tcp_try_accept(server)
net.tcp_send(sock, data)
net.tcp_try_send(sock, data)
data <- net.tcp_recv(sock, size)
data <- net.tcp_try_recv(sock, size)
net.tcp_close(sock)
```

**UDP**
```levy
sock <- net.udp_bind(host, port)
net.udp_sendto(sock, data, host, port)
result <- net.udp_recvfrom(sock, size)
net.udp_close(sock)
```

**Utilities**
```levy
net.set_nonblocking(sock)
ips <- net.dns_lookup(hostname)
```

### thread - Threading

```levy
tid <- thread.spawn(function)
thread.join(tid)
is_done <- thread.is_done(tid)
thread.sleep(seconds)
```

### channel - Channels

```levy
ch <- channel.create()
channel.send(ch, value)
value <- channel.recv(ch)
value <- channel.try_recv(ch)
channel.close(ch)
```

### async - Async Operations

```levy
task <- async.spawn(function)
async.sleep(seconds)
data <- async.tcp_recv(sock, size)
async.tcp_send(sock, data)
async.tick()
is_done <- async.done(task)
status <- async.status(task)
result <- async.result(task)
async.cancel(task)
count <- async.pending()
async.await(task)
```

### crypto - Cryptography

```levy
hash <- crypto.sha256(data)
hash <- crypto.sha512(data)
hmac <- crypto.hmac_sha256(key, data)
bytes <- crypto.random_bytes(length)
hex <- crypto.hex_encode(bytes)
bytes <- crypto.hex_decode(hex)
b64 <- crypto.base64_encode(data)
data <- crypto.base64_decode(b64)
```

### datetime - Date/Time

```levy
dt <- datetime.now_utc()
dt <- datetime.now_local()
str <- datetime.format(dt, format)
dt <- datetime.parse(str, format)
datetime.sleep_ms(ms)
ms <- datetime.epoch_ms()
```

### log - Logging

```levy
log.set_level(level)      # "debug", "info", "warn", "error"
log.set_output(path)
log.set_json(enabled)
log.log(level, message)
log.debug(message)
log.info(message)
log.warn(message)
log.error(message)
log.flush()
```

### config - Configuration

```levy
config.load_env(path)
value <- config.get(key)
config.set(key, value)
num <- config.get_int(key)
num <- config.get_float(key)
bool <- config.get_bool(key)
exists <- config.has(key)
```

### input - Input Control

```levy
input.enable_raw()
input.disable_raw()
available <- input.key_available()
key <- input.poll(timeout_ms)
key <- input.read_key()

# ASCII conversion (1.0.3+)
char <- input.chr(65)     # ASCII to char
code <- input.ord("A")    # Char to ASCII
```

---

## System Modules (1.0.3+)

### OS.Hooks - System Hooking

```levy
# Management
hook_id <- OS.Hooks.register(type, description)
OS.Hooks.unregister(hook_id)
hooks <- OS.Hooks.list()
OS.Hooks.enable(hook_id)
OS.Hooks.disable(hook_id)
OS.Hooks.set_callback(hook_id, callback)

# Event hooks
OS.Hooks.hook_process_create(pid)
OS.Hooks.hook_process_exit(pid, exit_code)
OS.Hooks.hook_file_access(path, mode)
OS.Hooks.hook_network_connect(host, port, protocol)
OS.Hooks.hook_keyboard(key_code, pressed)
OS.Hooks.hook_mouse(x, y, button, pressed)
OS.Hooks.hook_syscall(syscall_number, args)
OS.Hooks.inject_library(pid, library_path)
OS.Hooks.hook_memory_access(pid, address, size)
```

### OS.InputControl - Input Automation

```levy
# Keyboard
OS.InputControl.capture_keyboard()
OS.InputControl.release_keyboard()
OS.InputControl.keyboard_send(key, pressed)
OS.InputControl.press_key(key)
OS.InputControl.release_key(key)
OS.InputControl.tap_key(key, duration)
OS.InputControl.type_text(text)
OS.InputControl.type_text_raw(text)
OS.InputControl.block_key(key)
OS.InputControl.unblock_key(key)
OS.InputControl.remap_key(from_key, to_key)
state <- OS.InputControl.get_keyboard_state()

# Mouse
OS.InputControl.capture_mouse()
OS.InputControl.release_mouse()
OS.InputControl.move_mouse(x, y)
OS.InputControl.mouse_click(button, pressed)
OS.InputControl.press_mouse_button(button)
OS.InputControl.release_mouse_button(button)
OS.InputControl.click_mouse_button(button, clicks)
OS.InputControl.scroll_mouse(dx, dy)
OS.InputControl.block_mouse_button(button)
OS.InputControl.unblock_mouse_button(button)
pos <- OS.InputControl.get_mouse_position()
OS.InputControl.set_mouse_position(x, y)

# Touch
OS.InputControl.capture_touch()
OS.InputControl.release_touch()
OS.InputControl.send_touch_event(x, y, pressure)

# Utilities
OS.InputControl.clear_input_buffer()
capturing <- OS.InputControl.is_capturing()
```

### OS.Processes - Process Control

```levy
# Management
procs <- OS.Processes.list()
info <- OS.Processes.get_info(pid)
pid <- OS.Processes.create(command, args, options)
OS.Processes.terminate(pid, force)
OS.Processes.wait(pid, timeout)

# Memory
data <- OS.Processes.read_memory(pid, address, size)
OS.Processes.write_memory(pid, address, data)
OS.Processes.inject_library(pid, library_path)

# Threads & Priority
threads <- OS.Processes.list_threads(pid)
OS.Processes.suspend(pid)
OS.Processes.resume(pid)
prio <- OS.Processes.get_priority(pid)
OS.Processes.set_priority(pid, priority)
```

### OS.Display - Display Control

```levy
# Display info
displays <- OS.Display.list()
primary <- OS.Display.get_primary()

# Capture
img <- OS.Display.capture_screen(display_id)
region <- OS.Display.capture_region(x, y, width, height, display_id)
window <- OS.Display.capture_window(window_id)
color <- OS.Display.get_pixel(x, y, display_id)

# Cursor
OS.Display.show_cursor()
OS.Display.hide_cursor()
```

### OS.Audio - Audio Management

```levy
# Devices
devices <- OS.Audio.list_devices(type)
default <- OS.Audio.get_default_device(type)
OS.Audio.set_default_device(device_id)
info <- OS.Audio.get_device_info(device_id)

# Volume
vol <- OS.Audio.get_volume(device_id)
OS.Audio.set_volume(volume, device_id)
muted <- OS.Audio.is_muted(device_id)
OS.Audio.set_mute(muted, device_id)

# Playback
OS.Audio.play_sound(file_path, volume, device_id)
OS.Audio.play_tone(frequency, duration, volume)
OS.Audio.stop(stream_id)

# Streaming
stream <- OS.Audio.create_stream(config)
OS.Audio.write_stream(stream_id, data)
OS.Audio.close_stream(stream_id)

# Sample rate
rate <- OS.Audio.get_sample_rate(device_id)
OS.Audio.set_sample_rate(sample_rate, device_id)

# Recording
audio <- OS.Audio.record(duration, device_id)
OS.Audio.stop_recording(stream_id)

# Mixing
mixed <- OS.Audio.mix_streams(audio_data_list, weights)
```

### OS.Privileges - Privilege Management

```levy
# Checks
is_elevated <- OS.Privileges.is_elevated()
is_admin <- OS.Privileges.is_admin()
is_root <- OS.Privileges.is_root()
level <- OS.Privileges.get_level()
can_elevate <- OS.Privileges.can_elevate()

# Elevation
OS.Privileges.request_elevation(reason)
OS.Privileges.elevate_and_restart(args)
OS.Privileges.run_as_admin(command, args)

# Privileges
OS.Privileges.check(privilege_name)
OS.Privileges.enable(privilege_name)
OS.Privileges.drop()

# User info
user_info <- OS.Privileges.get_user_info()
token_info <- OS.Privileges.get_token_info()
OS.Privileges.impersonate_user(username)
```

### OS.Events - Event Monitoring

```levy
# Registration
listener <- OS.Events.watch_file(path, event_types, callback)
listener <- OS.Events.watch_network(callback)
listener <- OS.Events.watch_power(callback)
OS.Events.unwatch(listener_id)

# Event processing
events <- OS.Events.poll(timeout_ms)
OS.Events.start_loop()
OS.Events.stop_loop()
listeners <- OS.Events.list()

# Callbacks
OS.Events.set_callback(event_type, callback)
OS.Events.remove_callback(event_type)
count <- OS.Events.dispatch()
recent <- OS.Events.get_recent(count)
```

### OS.Persistence - System Persistence

```levy
# Autostart
OS.Persistence.add_autostart(name, command, location)
OS.Persistence.remove_autostart(name, location)
entries <- OS.Persistence.list_autostart(location)

# Services
OS.Persistence.install_service(name, display_name, description, command, auto_start)
OS.Persistence.uninstall_service(name)
OS.Persistence.start_service(name)
OS.Persistence.stop_service(name)
OS.Persistence.restart_service(name)
status <- OS.Persistence.get_service_status(name)

# Scheduled tasks
OS.Persistence.add_scheduled_task(name, command, schedule, schedule_time)
OS.Persistence.remove_scheduled_task(name)
```

---

## Code Examples

### Hello World
```levy
say("Hello, World!")
```

###Fibonacci
```levy
act fib(n) {
    if n < 2 { -> n }
    -> fib(n - 1) + fib(n - 2)
}
say(str(fib(10)))
```

### HTTP Request
```levy
response <- http.get("https://api.example.com/data")
data <- json.parse(response["body"])
say(data["message"])
```

### File Processing
```levy
content <- fs.read_text("input.txt")
lines <- split(content, "\n")
for line in lines {
    if contains(line, "ERROR") {
        say(line)
    }
}
```

### TCP Server
```levy
server <- net.tcp_listen("0.0.0.0", 8080)
say("Server listening on port 8080")
while true {
    client <- net.tcp_accept(server)
    data <- net.tcp_recv(client, 1024)
    net.tcp_send(client, "Echo: " + data)
    net.tcp_close(client)
}
```

### Process Monitoring
```levy
hook_id <- OS.Hooks.register("PROCESS_CREATE", "Monitor processes")
OS.Hooks.set_callback(hook_id, act(event) {
    say("New process: " + str(event["pid"]) + " - " + event["name"])
})
OS.Hooks.enable(hook_id)
say("Monitoring processes... Press Ctrl+C to stop")
os.pause()
```

### Keyboard Automation
```levy
os.sleep(3)  # Wait 3 seconds
OS.InputControl.type_text("Hello from Levython!")
OS.InputControl.press_key("ENTER")
```

### Screen Capture
```levy
displays <- OS.Display.list()
img <- OS.Display.capture_screen(0)
fs.write_text("screenshot.bin", img)
say("Screenshot saved!")
```

---

**Levython 1.0.3** - *Be better than yesterday*

GitHub: https://github.com/levython/Levython  
Documentation: https://levython.github.io/documentation/
