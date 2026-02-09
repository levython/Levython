# Levython Windows Installer

## Quick Install

1. **Download** the latest release: `levython-1.0.2-windows-installer.zip`
2. **Extract** the ZIP file
3. **Run** `Install-Levython.bat` as Administrator
4. Follow the GUI installer

## What Gets Installed

- **Levython executable** (`levython.exe`) - JIT-compiled bytecode VM
- **System PATH** configuration (optional)
- **VS Code extension** for syntax highlighting (optional)
- **File associations** for `.levy` and `.ly` files (optional)
- **Example programs** in `examples/` folder

## Architecture Support

The installer automatically detects your system architecture:
- **x64** (64-bit Intel/AMD)
- **x86** (32-bit Intel/AMD)  
- **ARM64** (Windows on ARM)

## Build From Source

If you want to build the installer from source:

```batch
# Full build (compiles + creates installer)
build-complete-installer.bat

# Build x64 only
build-complete-installer.bat --x64

# Build both architectures
build-complete-installer.bat --all

# Skip compilation, use existing binaries
build-complete-installer.bat --skip-build

# Also create Inno Setup installer (requires Inno Setup 6)
build-complete-installer.bat --inno
```

## Requirements for Building

- **C++ Compiler** (one of):
  - MinGW-w64 with g++ (recommended)
  - Visual Studio with C++ workload
  - Clang

- **OpenSSL Dev Libraries**:
  - Required for HTTP + crypto modules (libssl/libcrypto)
  - Set `OPENSSL_DIR` or install via vcpkg/MSYS2/OpenSSL installer

- **Optional**:
  - [Inno Setup 6](https://jrsoftware.org/isinfo.php) for professional installer

## Silent Installation

```powershell
# Install with defaults
powershell -ExecutionPolicy Bypass -File LevythonInstaller.ps1 -Silent

# Install to custom path
powershell -ExecutionPolicy Bypass -File LevythonInstaller.ps1 -Silent -InstallPath "C:\Tools\Levython"
```

## Uninstallation

- Use Windows "Add or Remove Programs"
- Or run `Uninstall.ps1` from the installation directory

## Files Included

```
levython-1.0.2-windows-installer.zip
├── levython.exe           # Main executable
├── Install-Levython.bat   # GUI installer launcher
├── LevythonInstaller.ps1  # PowerShell installer
├── README.md              # Documentation
├── LICENSE                # MIT License
├── CHANGELOG.md           # Version history
├── examples/              # Example programs
│   ├── 01_hello_world.levy
│   ├── 02_variables.levy
│   ├── ...
│   ├── 11_oop_basics.levy
│   └── 12_oop_inheritance.levy
└── vscode-levython/       # VS Code extension
    ├── package.json
    ├── syntaxes/
    └── snippets/
```

## Verification

After installation, open a new terminal and run:

```bash
levython --version
# Output: Levython 1.0.2 - High Performance Programming

levython examples\01_hello_world.levy
# Output: Hello, World!
```

## Features

- **JIT-Compiled Bytecode VM** - No interpreter fallback for compiled code
- **NaN-boxing** - Efficient value representation
- **Native OOP** - Classes, inheritance, methods all in bytecode VM
- **Performance** - fib(35) ~45ms, fib(40) ~480ms (faster than equivalent C)
