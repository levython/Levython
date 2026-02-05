# Changelog

All notable changes to Levython will be documented in this file.

## [1.0.2] - 2026-02-03

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
