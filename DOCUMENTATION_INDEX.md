# Levython 1.0.3 Documentation Index

**Complete Guide to Levython Documentation**

---

## 📚 Getting Started

### Essential Reading
1. **[README.md](README.md)** - Start here! Overview, installation, and quick start
2. **[QUICKSTART_WINDOWS.md](QUICKSTART_WINDOWS.md)** - Windows-specific quick start guide
3. **[QUICKREF.md](QUICKREF.md)** - Complete API reference in one page
4. **[LEVYTHON_1.0.3_FEATURES.md](LEVYTHON_1.0.3_FEATURES.md)** - Comprehensive feature guide

### Installation
- **[install.sh](install.sh)** - Cross-platform installation script
- **[WINDOWS_INSTALL.md](WINDOWS_INSTALL.md)** - Windows installation guide
- **[BUILD.md](BUILD.md)** - Building from source
- **[Makefile](Makefile)** - Build system

### Release Information
- **[CHANGELOG.md](CHANGELOG.md)** - Complete version history
- **[RELEASE_NOTES_1.0.3.md](RELEASE_NOTES_1.0.3.md)** - 1.0.3 release summary
- **[UPGRADING_TO_1.0.3.md](UPGRADING_TO_1.0.3.md)** - Migration guide from 1.0.2
- **[WINDOWS_SUPPORT_SUMMARY.md](WINDOWS_SUPPORT_SUMMARY.md)** - Windows support details

---

## 🔧 Core Language

### Language Features
- **[README.md](README.md)** - Language syntax guide
  - Variables and types
  - Functions
  - Conditionals (including ternary operator)
  - Loops
  - Classes and inheritance
  - Exceptions

### Advanced Topics
- **[JIT_OPTIMIZATIONS.md](JIT_OPTIMIZATIONS.md)** - JIT compiler optimizations
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation overview

---

## 📦 Standard Library

### Core Modules (Built-in)
All documented in [README.md](README.md) and [QUICKREF.md](QUICKREF.md):
- **os** - Operating system interface
- **http** - HTTP client
- **fs** - Filesystem operations
- **path** - Path utilities
- **json** - JSON parsing
- **net** - Networking (TCP/UDP)
- **thread** - Threading
- **channel** - Channel communication
- **async** - Async operations
- **crypto** - Cryptography
- **datetime** - Date/time handling
- **log** - Logging
- **config** - Configuration management
- **input** - Input handling

---

## 🖥️ System Modules (1.0.3+)

### Module Documentation

#### OS.Hooks - System Hooking
- **[OS_HOOK_MODULE.md](OS_HOOK_MODULE.md)** - Complete module documentation
- **[OS_HOOK_QUICKREF.md](OS_HOOK_QUICKREF.md)** - Quick reference
- **[OS_HOOK_IMPLEMENTATION.md](OS_HOOK_IMPLEMENTATION.md)** - Implementation details
- **Example:** [examples/28_os_hooks_demo.levy](examples/28_os_hooks_demo.levy)

#### OS.InputControl - Input Automation
- **[OS_INPUTCONTROL_MODULE.md](OS_INPUTCONTROL_MODULE.md)** - Complete module documentation
- **[OS_INPUTCONTROL_QUICKREF.md](OS_INPUTCONTROL_QUICKREF.md)** - Quick reference
- **[OS_INPUTCONTROL_IMPLEMENTATION.md](OS_INPUTCONTROL_IMPLEMENTATION.md)** - Implementation details
- **Example:** [examples/29_os_inputcontrol_demo.levy](examples/29_os_inputcontrol_demo.levy)

#### OS.Processes - Process Control
- **[OS_PROCESSMANAGER_MODULE.md](OS_PROCESSMANAGER_MODULE.md)** - Complete module documentation
- **[OS_PROCESSMANAGER_QUICKREF.md](OS_PROCESSMANAGER_QUICKREF.md)** - Quick reference
- **[OS_PROCESSMANAGER_IMPLEMENTATION.md](OS_PROCESSMANAGER_IMPLEMENTATION.md)** - Implementation details
- **Example:** [examples/30_os_processes_demo.levy](examples/30_os_processes_demo.levy)

#### OS.Audio - Audio Management
- **[OS_AUDIOCONTROL_MODULE.md](OS_AUDIOCONTROL_MODULE.md)** - Complete module documentation
- **[OS_AUDIOCONTROL_QUICKREF.md](OS_AUDIOCONTROL_QUICKREF.md)** - Quick reference
- **[OS_AUDIOCONTROL_IMPLEMENTATION.md](OS_AUDIOCONTROL_IMPLEMENTATION.md)** - Implementation details
- **Summaries:**
  - [OS_API_REFACTORING_COMPLETE.md](OS_API_REFACTORING_COMPLETE.md)
  - [AUDIOCONTROL_IMPLEMENTATION_SUMMARY.md](AUDIOCONTROL_IMPLEMENTATION_SUMMARY.md)
- **Example:** [examples/31_os_audio_demo.levy](examples/31_os_audio_demo.levy)

#### OS.Privileges - Privilege Management
- **[OS_PRIVILEGEESCALATOR_MODULE.md](OS_PRIVILEGEESCALATOR_MODULE.md)** - Complete module documentation
- **[OS_PRIVILEGEESCALATOR_QUICKREF.md](OS_PRIVILEGEESCALATOR_QUICKREF.md)** - Quick reference
- **[OS_PRIVILEGEESCALATOR_IMPLEMENTATION.md](OS_PRIVILEGEESCALATOR_IMPLEMENTATION.md)** - Implementation details
- **Summary:** [PRIVILEGEESCALATOR_IMPLEMENTATION_SUMMARY.md](PRIVILEGEESCALATOR_IMPLEMENTATION_SUMMARY.md)
- **Example:** [examples/30_os_privileges_demo.levy](examples/30_os_privileges_demo.levy)

#### OS.Persistence - System Persistence
- **[OS_PERSISTENCEHANDLER_MODULE.md](OS_PERSISTENCEHANDLER_MODULE.md)** - Complete module documentation

#### OS.EventListener - Event Monitoring
- **Summary:** [EVENTLISTENER_IMPLEMENTATION_SUMMARY.md](EVENTLISTENER_IMPLEMENTATION_SUMMARY.md)

#### OS.DisplayAccess - Display Control
- Documentation: See [LEVYTHON_1.0.3_FEATURES.md](LEVYTHON_1.0.3_FEATURES.md)

---

## 💻 Examples

### Location
All examples in `examples/` directory

### Core Language Examples
- `01_hello_world.levy` - Hello World
- `02_variables.levy` - Variables and types
- `03_arithmetic.levy` - Arithmetic operations
- `04_conditionals.levy` - If/else statements
- `05_loops.levy` - For/while loops
- `06_functions.levy` - Function definitions
- `07_lists.levy` - List operations
- `08_strings.levy` - String manipulation
- `09_fibonacci.levy` - Fibonacci sequence
- `10_file_io.levy` - File I/O
- `11_oop_basics.levy` - Object-oriented basics
- `12_oop_inheritance.levy` - Inheritance
- `13_async_demo.levy` - Async programming
- `36_ternary_operator.levy` - Ternary operator (1.0.3+)

### Networking Examples
- `14_async_echo_server.levy` - Async echo server
- `15_chat_client.levy` - Chat client
- `16_chat_server.levy` - Chat server
- `19_http_client.levy` - HTTP client
- `20_http_server.levy` - HTTP server

### System Examples
- `17_cross_platform_demo.levy` - Cross-platform code
- `25_os_module.levy` - OS module usage
- `27_system_info.levy` - System information
- `28_os_hooks_demo.levy` - OS.Hooks demonstration
- `29_os_inputcontrol_demo.levy` - OS.InputControl demonstration
- `30_os_processes_demo.levy` - OS.Processes demonstration
- `30_os_privileges_demo.levy` - OS.Privileges demonstration
- `31_os_audio_demo.levy` - OS.Audio demonstration

### Standard Library Examples
- `23_native_modules.levy` - Native modules
- `26_stdlib_demo.levy` - Standard library overview

---

## 🔨 Build & Development

### Build System
- **[Makefile](Makefile)** - Cross-platform build system
- **[BUILD.md](BUILD.md)** - Building from source
- **[build-release.sh](build-release.sh)** - Release build script

### Installation
- **[install.sh](install.sh)** - Unix installer
- **[Install-Levython.bat](installer/Install-Levython.bat)** - Windows batch installer
- **[LevythonInstaller.ps1](LevythonInstaller.ps1)** - Windows PowerShell installer

### Testing
- **[test_all_os_modules.levy](test_all_os_modules.levy)** - OS module tests
- **[test_keywords.levy](test_keywords.levy)** - Keyword tests
- **[test_examples.fish](test_examples.fish)** - Example runner
- **[run_all_tests.sh](run_all_tests.sh)** - Test runner
- **[comprehensive_test.sh](comprehensive_test.sh)** - Comprehensive tests
- **[TEST_REPORT.md](TEST_REPORT.md)** - Test results

---

## 🪟 Windows-Specific

### Installation & Setup
- **[WINDOWS_INSTALL.md](WINDOWS_INSTALL.md)** - Installation guide
- **[QUICKSTART_WINDOWS.md](QUICKSTART_WINDOWS.md)** - Quick start
- **[WINDOWS_SUPPORT_SUMMARY.md](WINDOWS_SUPPORT_SUMMARY.md)** - Support details

### Installer
- **[installer/](installer/)** - Installer directory
- **[installer/levython-setup.iss](installer/levython-setup.iss)** - Inno Setup script
- **[installer/Build-Installer.ps1](installer/Build-Installer.ps1)** - Installer builder
- **[installer/README.md](installer/README.md)** - Installer documentation

---

## 🎨 VS Code Extension

### Extension Files
- **[vscode-levython/](vscode-levython/)** - VS Code extension
- **[vscode-levython/package.json](vscode-levython/package.json)** - Extension manifest
- Includes syntax highlighting, snippets, and language support

---

## 📖 Reference Documents

### Quick References
- **[QUICKREF.md](QUICKREF.md)** - Complete API reference
- **[OS_HOOK_QUICKREF.md](OS_HOOK_QUICKREF.md)** - OS.Hooks quick reference
- **[OS_INPUTCONTROL_QUICKREF.md](OS_INPUTCONTROL_QUICKREF.md)** - OS.InputControl quick reference
- **[OS_PROCESSMANAGER_QUICKREF.md](OS_PROCESSMANAGER_QUICKREF.md)** - OS.Processes quick reference
- **[OS_AUDIOCONTROL_QUICKREF.md](OS_AUDIOCONTROL_QUICKREF.md)** - OS.Audio quick reference
- **[OS_PRIVILEGEESCALATOR_QUICKREF.md](OS_PRIVILEGEESCALATOR_QUICKREF.md)** - OS.Privileges quick reference

### Implementation Details
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Core implementation
- **[JIT_OPTIMIZATIONS.md](JIT_OPTIMIZATIONS.md)** - JIT optimizations
- **[OS_API_REFACTORING_COMPLETE.md](OS_API_REFACTORING_COMPLETE.md)** - API refactoring notes
- Module-specific implementation docs (OS_*_IMPLEMENTATION.md)

---

## 🆘 Support & Community

### Getting Help
1. **README** - Start with the README for basic questions
2. **QUICKREF** - Look up function signatures and usage
3. **Examples** - Check examples for code patterns
4. **GitHub Issues** - Report bugs and request features
5. **GitHub Discussions** - Ask questions and share ideas

### Contributing
- Read [README.md](README.md) contributing section
- Check open issues and discussions
- Follow code style from existing examples
- Test on multiple platforms if possible

---

## 📋 Document Categories

### By Type
- **Guides**: README, QUICKSTART_WINDOWS, BUILD, UPGRADING_TO_1.0.3
- **References**: QUICKREF, OS_*_QUICKREF
- **Release Info**: CHANGELOG, RELEASE_NOTES_1.0.3
- **Implementation**: *_IMPLEMENTATION.md, *_SUMMARY.md
- **Module Docs**: OS_*_MODULE.md
- **Windows**: WINDOWS_*, QUICKSTART_WINDOWS
- **Examples**: examples/*.levy

### By Audience
- **New Users**: README, QUICKSTART_WINDOWS, examples/01-10
- **Developers**: BUILD, JIT_OPTIMIZATIONS, IMPLEMENTATION_SUMMARY
- **System Programmers**: OS_*_MODULE.md, examples/28-31
- **Windows Users**: WINDOWS_*, QUICKSTART_WINDOWS
- **Contributors**: README (contributing), build scripts

---

## 🗺️ Documentation Roadmap

### Completed (1.0.3)
✅ Complete API documentation  
✅ Module-specific guides  
✅ Quick references  
✅ Migration guide  
✅ Release notes  
✅ Cross-platform build docs  

### Future Plans
- Video tutorials
- Interactive documentation site
- More code examples
- Best practices guide
- Performance optimization guide
- Security hardening guide

---

## 📞 Quick Links

- **GitHub**: https://github.com/levython/Levython
- **Documentation Site**: https://levython.github.io/documentation/
- **Releases**: https://github.com/levython/Levython/releases
- **Issues**: https://github.com/levython/Levython/issues
- **Discussions**: https://github.com/levython/Levython/discussions

---

## 📄 License

All documentation is covered under the MIT License. See [LICENSE](LICENSE) for details.

---

**Levython 1.0.3** - *Be better than yesterday*

**Last Updated:** February 14, 2026
