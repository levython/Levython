# Changelog

All notable changes to Levython will be documented in this file.

## [1.0.3] - 2026-02-14

### 🚀 Major Features & System Modules

**Advanced System Control Modules:**
- ✅ **OS.Hooks**: System event hooking for process, file, network, keyboard, and mouse monitoring
  - `register(type, description='')`, `unregister(hook_id)`, `enable(hook_id)`, `disable(hook_id)`
  - `hook_process_create(pid)`, `hook_process_exit(pid, exit_code=0)`
  - `hook_file_access(path, mode='read')`, `hook_network_connect(host, port, protocol='tcp')`
  - `hook_keyboard(key_code, pressed)`, `hook_mouse(x, y, button=0, pressed=true)`
  - `hook_syscall(syscall_number, args=[])`, `inject_library(pid, library_path)`
  - `hook_memory_access(pid, address, size=8)`
- ✅ **OS.InputControl**: Keyboard, mouse, and touch automation with key remapping and blocking
  - `capture_keyboard()`, `release_keyboard()`, `keyboard_send(key, pressed)`
  - `press_key(key)`, `release_key(key)`, `tap_key(key, duration=0)`
  - `type_text(text)`, `type_text_raw(text)`, `block_key(key)`, `unblock_key(key)`
  - `remap_key(from_key, to_key)`, `get_keyboard_state()`
  - `capture_mouse()`, `release_mouse()`, `move_mouse(x, y)`
  - `mouse_click(button, pressed)`, `press_mouse_button(button)`, `release_mouse_button(button)`
  - `click_mouse_button(button, clicks=1)`, `scroll_mouse(dx, dy)`
  - `block_mouse_button(button)`, `unblock_mouse_button(button)`
  - `get_mouse_position()`, `set_mouse_position(x, y)`
  - `capture_touch()`, `release_touch()`, `send_touch_event(x, y, pressure=1.0)`
  - `clear_input_buffer()`, `is_capturing()` returns {keyboard, mouse, touch}
- ✅ **OS.Processes**: Advanced process management with memory operations and thread control
- ✅ **OS.Display**: Screen capture, pixel manipulation, and overlay rendering
  - `list()`, `get_primary()`, `capture_screen(display_id=0)`
  - `capture_region(x, y, width, height, display_id=0)`, `capture_window(window_id)`
  - `get_pixel(x, y, display_id=0)`, `show_cursor()`, `hide_cursor()`
- ✅ **OS.Audio**: Audio device management, playback, recording, and streaming
  - `list_devices(type='all')`, `get_default_device(type='playback')`, `set_default_device(device_id)`
  - `get_device_info(device_id)`, `get_volume(device_id=default)`, `set_volume(volume, device_id=default)`
  - `is_muted(device_id=default)`, `set_mute(muted, device_id=default)`
  - `play_sound(file_path, volume=1.0, device_id=default)`, `play_tone(frequency, duration, volume=0.5)`
  - `stop(stream_id)`, `create_stream(config)`, `write_stream(stream_id, audio_data)`
  - `close_stream(stream_id)`, `get_sample_rate(device_id=default)`, `set_sample_rate(sample_rate, device_id=default)`
  - `record(duration, device_id=default)`, `stop_recording(stream_id)`, `mix_streams(audio_data_list, weights)`
- ✅ **OS.Privileges**: Privilege elevation and user impersonation
  - `is_elevated()`, `is_admin()`, `is_root()`, `get_level()`, `can_elevate()`
  - `request_elevation(reason='')`, `elevate_and_restart(args=[])`
  - `check(privilege_name)`, `enable(privilege_name)`, `drop()`
  - `run_as_admin(command, args=[])`, `get_user_info()`, `get_token_info()`
  - `impersonate_user(username)`
- ✅ **OS.Events**: File, network, and power event monitoring
  - `watch_file(path, event_types, callback)`, `watch_network(callback)`, `watch_power(callback)`
  - `unwatch(listener_id)`, `poll(timeout_ms=0)`, `start_loop()`, `stop_loop()`
  - `list()`, `set_callback(event_type, callback)`, `remove_callback(event_type)`
  - `dispatch()`, `get_recent(count=10)`
- ✅ **OS.Persistence**: Autostart, service, and scheduled task management
  - `add_autostart(name, command, location=None)`, `remove_autostart(name, location=None)`
  - `list_autostart(location=None)`, `install_service(name, display_name, description, command, auto_start=true)`
  - `uninstall_service(name)`, `start_service(name)`, `stop_service(name)`, `restart_service(name)`
  - `get_service_status(name)`, `add_scheduled_task(name, command, schedule, schedule_time=None)`
  - `remove_scheduled_task(name)`

**Language Features:**
- ✅ **Ternary Operator**: Conditional expressions with `condition ? true_value : false_value` syntax
- ✅ **Input Module Enhancement**: `input.chr()` and `input.ord()` for ASCII/key conversion

**OS Module Enhancements:**
- ✅ **Advanced Filesystem APIs**: `scandir`, `link`, `renameat`, `lstat`, `fstat`
- ✅ **File Descriptor Operations**: `open`, `read`, `write`, `fsync`, `close`, `fdopen`
- ✅ **Directory Stack**: `chdir_push`, `chdir_pop` for directory navigation
- ✅ **Signal Handling** (POSIX): `signal`, `alarm`, `pause`, `killpg` with signal constants
- ✅ **Enhanced Process Control**: 
  - `run_capture(cmd, args, timeout_ms, input)` - Capture stdout/stderr/exit code
  - `popen(cmd, args, input)` - Simple stdout capture
  - `spawn_io(cmd, args, stdin_path, stdout_path, stderr_path, append)` - I/O redirection
  - `waitpid(pid, nohang)` - Non-blocking wait
  - `kill_tree(pid, signal)` - Kill process tree
- ✅ **User/Group Management**: `uid_name`, `gid_name`, `getpwnam`, `getgrnam`, `getlogin`, `getgroups`
- ✅ **Enhanced Permissions**: `chmod` supports symbolic modes (`u+rwx,g-w`) and octal strings
- ✅ **System Information**: 
  - `cpu_info()`, `os_release()`, `boot_time()`
  - `locale()`, `timezone()`, `mounts()`
  - `loadavg()` - System load averages
- ✅ **Path Operations**: `expanduser`, `expandvars`, `path_expand`
- ✅ **Filesystem Utilities**: `walk`, `glob`, `disk_usage`, `statvfs`, `touch`, `rmdir_rf`, `mkdir_p`
- ✅ **Environment Management**: `getenvs`, `env_list` with atomic updates and typed access

**Platform-Specific Features:**
- ✅ **macOS**: `chflags`, power/battery stats
- ✅ **Windows**: Service control, proper Windows API integration
- ✅ **Linux**: cgroups, process namespaces support

**Build System Improvements:**
- ✅ **Enhanced Makefile**: Full cross-platform support (macOS/Linux/Windows MinGW)
- ✅ **Architecture Detection**: Automatic ARM64/x86_64 detection on macOS
- ✅ **Platform-Specific Libraries**: Automatic library linking per platform
- ✅ **Install/Uninstall Targets**: System-wide installation support

**Bug Fixes & Improvements:**
- ✅ Fixed Windows compatibility for signal operations (stubs where not supported)
- ✅ Improved error handling across all OS modules
- ✅ Enhanced cross-platform path handling
- ✅ Better memory management in low-level operations

## [1.0.2] - 2026-02-08

### 🚀 Standard Library Expansion

**New Modules & APIs:**
- ✅ **crypto**: `sha256`, `sha512`, `hmac_sha256`, `random_bytes`, `hex/base64 encode/decode`
- ✅ **datetime**: `now_utc`, `now_local`, `format`, `parse`, `sleep_ms`, `epoch_ms`
- ✅ **log**: structured logging with JSON or text output
- ✅ **config**: `.env` loader and typed getters
- ✅ **input**: non-blocking key input for games/interactive apps

**Filesystem & Process:**
- ✅ **path**: `exists`, `is_file`, `is_dir`, `read_text`, `write_text`, `listdir`, `mkdir`, `remove`, `rmdir`
- ✅ **process.run**: argv lists, env, cwd, stdout/stderr capture

**Networking:**
- ✅ **net**: `dns_lookup`
- ✅ **http_server.levy**: userland HTTP server helper with request parsing and response builder

**Build/Runtime:**
- ✅ Local module imports supported at runtime when `.levy/.ly` files exist
- ✅ Version bumps and documentation alignment

### 🪟 Windows Support & Professional Installer

**Native Windows Support:**
- ✅ **Cross-Platform Compatibility**: Full Windows 10/11 support (32-bit & 64-bit)
- ✅ **Platform Abstraction Layer**: Windows-compatible memory mapping (VirtualAlloc/MapViewOfFile)
- ✅ **File I/O Compatibility**: Windows-specific file descriptor handling
- ✅ **JIT Compilation**: Executable memory allocation works natively on Windows
- ✅ **No Code Duplication**: Single source code supports Windows, macOS, and Linux

**Professional GUI Installer:**
- 🎨 **Modern Inno Setup Installer**: Python-style GUI installer for Windows
- 🔧 **Automatic PATH Configuration**: Adds Levython to system PATH automatically
- 📁 **File Associations**: Associates .levy files with Levython
- 🎯 **VS Code Integration**: Automatic VS Code extension installation
- 🌍 **Multi-Language Support**: English, Spanish, French, German, Japanese, Chinese
- ⚙️ **Both Architectures**: Single installer supports both 32-bit and 64-bit Windows

**Build System Improvements:**
- 📜 **Windows Build Script**: `build-windows.bat` for easy compilation
- 🏗️ **CMake Support**: Professional CMake build system for all platforms
- 🤖 **GitHub Actions**: Automated Windows builds with CI/CD
- 📦 **Installer Builder**: `build-installer.bat` for creating distributable installer

**Documentation:**
- 📖 **Windows Installation Guide**: Comprehensive [WINDOWS_INSTALL.md](WINDOWS_INSTALL.md)
- 🔨 **Build Guide**: Complete [BUILD.md](BUILD.md) for all platforms
- 📋 **Updated README**: Windows installation instructions in main README
- 🐛 **Troubleshooting**: Platform-specific solutions for common issues

**Technical Details:**
- Platform-specific memory management (mmap → VirtualAlloc on Windows)
- Windows file I/O compatibility (_fstat, _open, _close)
- Cross-platform JIT compiler with RWX memory support
- MSVC and MinGW-w64 compiler support
- Universal builds: Single codebase for all platforms

## [1.0.1] - 2026-02-01

### 🎯 Code Quality & Professional Polish

**Major Improvements:**
- **Professional Code Cleanup**: Removed all informal comments, emojis, and unprofessional language
- **Enterprise-Ready Codebase**: All 8500+ lines now use technical, professional documentation
- **Enhanced Installer**: Comprehensive cross-platform installation with advanced error handling

**Installer Enhancements:**
- ✅ **C++17 Compiler Validation**: Tests actual C++17 support with compilation checks
- ✅ **Advanced Error Recovery**: Multiple compilation strategies (O3 → O2 → basic fallback)
- ✅ **Cross-Platform Windows Support**: WSL, MSYS2, MinGW, Git Bash, Cygwin support
- ✅ **Command Line Options**: `--help`, `--force`, `--no-path`, `--no-vscode`, `--compiler=X`
- ✅ **Comprehensive Dependency Management**: Auto-install for apt, dnf, yum, pacman, zypper, apk
- ✅ **Professional Error Messages**: Detailed troubleshooting with OS-specific instructions
- ✅ **Multi-Shell PATH Configuration**: Proper support for bash, zsh, fish across all platforms

**Code Quality:**
- **Professional Comments**: All function and feature documentation uses technical language
- **Maintainable Structure**: Clean, readable code suitable for enterprise environments
- **Industry Standards**: Follows software engineering best practices throughout

**Repository Cleanup:**
- **Clean Git History**: Removed temporary files, demo scripts, and build artifacts
- **Professional .gitignore**: Comprehensive exclusion patterns for development files
- **Documentation**: Updated README with latest installation features

## [1.0.0] - 2026-01-31

### 🚀 Initial Release

**Core Features:**
- Complete language implementation with Python-like syntax
- Variable assignment using `<-` operator
- Functions with `act` keyword and `->` returns
- Control flow: `if`/`else`, `for`, `while`
- Lists, strings, numbers, booleans
- Built-in functions: `say()`, `str()`, `len()`, `append()`, `range()`
- File I/O: `read_file()`, `write_file()`, `file_exists()`

**Performance:**
- x86-64 JIT compilation (~45ms for fib(35), beating C!)
- NaN-boxed FastVM with 8-byte values
- Computed-goto bytecode dispatch

**Tools:**
- `levython` - Main interpreter with JIT support
- `lpm` - Package manager (install, search, list, remove)
- `install.sh` - Cross-platform installer

**Advanced Features:**
- Hardware memory operations (`mem_alloc`, `mem_read32`, etc.)
- Bitwise operations (`bit_and`, `bit_or`, `shift_left`, etc.)
- AI/ML tensor operations
- SIMD vectorization support

**Examples:**
- 10 tutorial examples covering basics to advanced topics
- Progressive learning from Hello World to File I/O
