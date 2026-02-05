# 🪟 Levython for Windows

Complete installation and build guide for Windows users.

## 📥 Quick Install (Recommended)

### Option 1: GUI Installer (Easiest)

Download and run the professional installer:

1. **Download** the latest installer:
   - [levython-1.0.1-windows-installer.exe](https://github.com/levython/Levython/releases/latest) (All versions: 32-bit & 64-bit)

2. **Run** the installer with administrator privileges

3. **Follow** the installation wizard:
   - ✅ Add to system PATH (recommended)
   - ✅ Associate .levy files with Levython
   - ✅ Install VS Code extension (if VS Code is installed)

4. **Verify** installation:
   ```cmd
   levython --version
   ```

### Option 2: Manual Installation

1. **Download** the pre-built binary for your architecture:
   - [levython-windows-x64.exe](https://github.com/levython/Levython/releases/latest) (64-bit)
   - [levython-windows-x86.exe](https://github.com/levython/Levython/releases/latest) (32-bit)

2. **Rename** to `levython.exe` and place in a directory like `C:\levython\`

3. **Add to PATH**:
   - Right-click "This PC" → Properties → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add `C:\levython\`
   - Click "OK" to save

4. **Verify** installation:
   ```cmd
   levython --version
   ```

---

## 🔨 Building from Source

### Prerequisites

Install one of the following compilers:

#### Option A: MinGW-w64 (Recommended)

1. **Download** MinGW-w64:
   - [w64devkit](https://github.com/skeeto/w64devkit/releases) (Portable, easiest)
   - Or [MSYS2](https://www.msys2.org/) + mingw-w64-gcc

2. **Extract** and add to PATH

3. **Verify**:
   ```cmd
   g++ --version
   ```

#### Option B: Microsoft Visual Studio

1. **Download** [Visual Studio 2022 Community](https://visualstudio.microsoft.com/)
2. **Install** with "Desktop development with C++" workload
3. Use the `x64 Native Tools Command Prompt`

### Build Commands

#### Using the Build Script (Easiest)

```batch
# Build for 64-bit (default)
build-windows.bat

# Build for 32-bit
build-windows.bat --arch=x86

# Build for both architectures
build-windows.bat --arch=both

# Debug build
build-windows.bat --debug

# Using MSVC instead of GCC
build-windows.bat --compiler=msvc
```

#### Manual Compilation

**With MinGW-w64 (GCC):**
```batch
# 64-bit
g++ -m64 -std=c++17 -O3 -march=native -DNDEBUG -ffast-math -funroll-loops -flto src\levython.cpp -o levython.exe

# 32-bit
g++ -m32 -std=c++17 -O3 -march=native -DNDEBUG -ffast-math -funroll-loops -flto src\levython.cpp -o levython.exe
```

**With MSVC:**
```batch
cl /EHsc /std:c++17 /O2 /GL /DNDEBUG src\levython.cpp /Fe:levython.exe /link /LTCG
```

### Building the Installer

1. **Install** [Inno Setup 6](https://jrsoftware.org/isinfo.php)

2. **Build binaries** for both architectures:
   ```batch
   build-windows.bat --arch=both
   ```

3. **Create installer**:
   ```batch
   build-installer.bat
   ```

4. **Output**: `releases\levython-1.0.1-windows-installer.exe`

---

## 🚀 Usage

### Running Levython Programs

```batch
# Run a script
levython script.levy

# Run with arguments
levython script.levy arg1 arg2

# REPL mode
levython

# Show version
levython --version

# Show help
levython --help
```

### Examples

```batch
# Navigate to examples
cd examples

# Run Hello World
levython 01_hello_world.levy

# Run Fibonacci benchmark
levython 09_fibonacci.levy
```

---

## 🛠️ Development Setup

### VS Code Integration

The installer automatically installs the VS Code extension. For manual installation:

1. **Open** VS Code
2. **Press** `Ctrl+Shift+P`
3. **Type**: "Extensions: Install from VSIX"
4. **Select**: `vscode-levython\levython-1.0.0.vsix`

Features:
- Syntax highlighting
- Code snippets
- Integrated terminal support

### File Associations

The installer associates `.levy` files with Levython. To run scripts:
- **Double-click** any `.levy` file
- Or right-click → "Open with Levython"

---

## 🔧 Troubleshooting

### Common Issues

#### "levython is not recognized as a command"
**Solution**: Add Levython to your PATH (see installation steps above)

#### "VCRUNTIME140.dll is missing"
**Solution**: Install [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

#### "Access denied" when installing
**Solution**: Run the installer as Administrator (right-click → Run as administrator)

#### Build fails with "g++ not found"
**Solution**: Install MinGW-w64 or MSVC (see Prerequisites)

#### Installer doesn't detect VS Code
**Solution**: The extension can be installed manually from `vscode-levython\` folder

### Performance Notes

- **32-bit vs 64-bit**: 64-bit version is ~15-20% faster due to more registers
- **Windows Defender**: May slow first run (add exclusion for better performance)
- **JIT Compilation**: Windows may show security warnings for executable memory (this is normal)

---

## 🆚 Architecture Comparison

| Feature | 32-bit (x86) | 64-bit (x64) |
|---------|--------------|--------------|
| **Max Memory** | 4 GB | 16 TB |
| **Performance** | Good | Excellent |
| **Compatibility** | Older systems | Modern systems |
| **Recommended** | Legacy only | ✅ Yes |

**Recommendation**: Use 64-bit unless you're on a 32-bit Windows system.

---

## 📦 System Requirements

### Minimum
- **OS**: Windows 7 SP1 or later
- **RAM**: 512 MB
- **Disk**: 50 MB free space
- **Processor**: Any x86/x64 CPU

### Recommended
- **OS**: Windows 10/11 (64-bit)
- **RAM**: 2 GB or more
- **Disk**: 100 MB free space
- **Processor**: Modern x64 CPU with AVX support

---

## 🔐 Security

The installer is signed and safe. If Windows SmartScreen shows a warning:
1. Click "More info"
2. Click "Run anyway"

This is normal for new applications without an expensive EV code signing certificate.

---

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/levython/Levython/issues)
- **Documentation**: [levython.github.io](https://levython.github.io)
- **Discussions**: [GitHub Discussions](https://github.com/levython/Levython/discussions)

---

## 📄 License

Levython is licensed under the MIT License. See [LICENSE](../LICENSE) for details.

---

**Made with ❤️ for Windows developers**
