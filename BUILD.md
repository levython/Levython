# 🏗️ Levython Build Guide

Complete guide for building Levython from source on all platforms.

## 📋 Table of Contents

- [Windows](#-windows)
- [macOS](#-macos)
- [Linux](#-linux)
- [Build Options](#-build-options)
- [Troubleshooting](#-troubleshooting)

---

## 🪟 Windows

### Prerequisites

Choose one of these compiler toolchains:

#### Option A: MinGW-w64 (Recommended for ease)

**Quick Install with w64devkit:**
1. Download [w64devkit](https://github.com/skeeto/w64devkit/releases/latest)
2. Extract to `C:\w64devkit\`
3. Run `w64devkit.exe` - you're ready!

**Or with MSYS2:**
```bash
# Install MSYS2 from https://www.msys2.org/
# Then in MSYS2 terminal:
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake make
```

#### Option B: Microsoft Visual Studio

1. Download [Visual Studio 2022 Community](https://visualstudio.microsoft.com/)
2. Install with "Desktop development with C++" workload
3. Open "x64 Native Tools Command Prompt for VS 2022"

### Building

#### Method 1: Build Script (Easiest)

```batch
# Clone repository
git clone https://github.com/levython/Levython.git
cd Levython

# Build for 64-bit (default)
build-windows.bat

# Build for 32-bit
build-windows.bat --arch=x86

# Build both architectures
build-windows.bat --arch=both

# Debug build
build-windows.bat --debug

# Using MSVC
build-windows.bat --compiler=msvc
```

#### Method 2: CMake (Advanced)

```batch
# Create build directory
mkdir build && cd build

# Configure (64-bit)
cmake .. -A x64 -DCMAKE_BUILD_TYPE=Release

# Or for 32-bit
cmake .. -A Win32 -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --config Release

# Output: releases\levython-windows-x64.exe
```

#### Method 3: Manual Compilation

**With MinGW-w64:**
```batch
g++ -m64 -std=c++17 -O3 -march=native -DNDEBUG ^
    -ffast-math -funroll-loops -flto ^
    src\levython.cpp -o levython.exe -s
```

**With MSVC:**
```batch
cl /EHsc /std:c++17 /O2 /GL /DNDEBUG ^
   src\levython.cpp /Fe:levython.exe /link /LTCG
```

### Creating the Installer

```batch
# 1. Build binaries for both architectures
build-windows.bat --arch=both

# 2. Install Inno Setup from https://jrsoftware.org/isinfo.php

# 3. Build installer
build-installer.bat

# Output: releases\levython-1.0.2-windows-installer.exe
```

---

## 🍎 macOS

### Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Or install full Xcode from App Store

# Optional: Homebrew for package management
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Building

#### Method 1: Install Script (Easiest)

```bash
git clone https://github.com/levython/Levython.git
cd Levython
chmod +x install.sh
./install.sh
```

#### Method 2: CMake

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .

# Output: releases/levython-macos-x64
```

#### Method 3: Manual Compilation

```bash
clang++ -std=c++17 -O3 -march=native -DNDEBUG \
    -ffast-math -funroll-loops -flto \
    src/levython.cpp -o levython
```

### Universal Binary (Apple Silicon + Intel)

```bash
# Build for Apple Silicon
clang++ -arch arm64 -std=c++17 -O3 src/levython.cpp -o levython-arm64

# Build for Intel
clang++ -arch x86_64 -std=c++17 -O3 src/levython.cpp -o levython-x64

# Create universal binary
lipo -create levython-arm64 levython-x64 -output levython
```

---

## 🐧 Linux

### Prerequisites

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install build-essential cmake git
```

**Fedora/RHEL:**
```bash
sudo dnf install gcc-c++ cmake git
```

**Arch Linux:**
```bash
sudo pacman -S base-devel cmake git
```

**Alpine:**
```bash
sudo apk add build-base cmake git
```

### Building

#### Method 1: Install Script (Easiest)

```bash
git clone https://github.com/levython/Levython.git
cd Levython
chmod +x install.sh
./install.sh
```

#### Method 2: CMake

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

# Output: releases/levython-linux-x64
```

#### Method 3: Manual Compilation

```bash
g++ -std=c++17 -O3 -march=native -DNDEBUG \
    -ffast-math -funroll-loops -flto \
    -pthread src/levython.cpp -o levython -s
```

---

## ⚙️ Build Options

### Optimization Levels

**Maximum Performance (Default):**
```bash
# GCC/Clang
-O3 -march=native -ffast-math -funroll-loops -flto

# MSVC
/O2 /GL /LTCG
```

**Debug Build:**
```bash
# GCC/Clang
-O0 -g -Wall -Wextra

# MSVC
/Od /Zi
```

**Size Optimization:**
```bash
# GCC/Clang
-Os -s

# MSVC
/O1 /Os
```

### CMake Options

```bash
# Link-Time Optimization
cmake .. -DENABLE_LTO=ON

# Native CPU optimization
cmake .. -DENABLE_NATIVE=ON

# Build examples
cmake .. -DBUILD_EXAMPLES=ON

# Specify compiler
cmake .. -DCMAKE_CXX_COMPILER=clang++

# Combined
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DENABLE_LTO=ON \
         -DENABLE_NATIVE=ON
```

### Architecture-Specific Builds

**64-bit:**
```bash
# GCC/Clang
g++ -m64 ...

# CMake
cmake .. -A x64  # Windows
cmake .. -DCMAKE_CXX_FLAGS="-m64"  # Unix
```

**32-bit:**
```bash
# GCC/Clang
g++ -m32 ...

# CMake
cmake .. -A Win32  # Windows
cmake .. -DCMAKE_CXX_FLAGS="-m32"  # Unix
```

---

## 🐛 Troubleshooting

### Windows

**Issue: "g++ is not recognized"**
```batch
# Add MinGW to PATH
set PATH=C:\w64devkit\bin;%PATH%

# Or permanently:
# System Properties → Environment Variables → Path → Add C:\w64devkit\bin
```

**Issue: "LINK : fatal error LNK1104: cannot open file"**
```batch
# Make sure you're in "x64 Native Tools Command Prompt"
# Not regular Command Prompt
```

**Issue: Build fails with "out of memory"**
```batch
# For 32-bit builds, add:
g++ -m32 -Wl,--large-address-aware ...
```

### macOS

**Issue: "xcrun: error: invalid active developer path"**
```bash
# Install Command Line Tools
xcode-select --install
```

**Issue: "clang: error: unsupported option '-march=native'"**
```bash
# On Apple Silicon, use:
clang++ -mcpu=apple-m1 ...  # M1/M2/M3

# On Intel:
clang++ -march=native ...   # OK
```

### Linux

**Issue: "fatal error: filesystem: No such file or directory"**
```bash
# Update GCC to version 8 or higher
sudo apt install g++-9
export CXX=g++-9
```

**Issue: "undefined reference to pthread_create"**
```bash
# Add -pthread flag
g++ ... -pthread
```

**Issue: "/usr/bin/ld: cannot find -lstdc++"**
```bash
# Install C++ standard library
sudo apt install libstdc++-9-dev
```

### All Platforms

**Issue: "error: no member named 'filesystem' in namespace 'std'"**
- **Solution**: Requires C++17 compiler (GCC 8+, Clang 7+, MSVC 2017+)

**Issue: JIT compilation fails**
- **Solution**: Ensure executable memory permissions work on your system
- Windows: May need to disable some security features
- Linux: Check SELinux/AppArmor settings

**Issue: Slow compilation**
- **Solution**: Use `-j` flag for parallel builds
  ```bash
  make -j$(nproc)          # Linux
  make -j$(sysctl -n hw.ncpu)  # macOS
  ```

---

## 📊 Performance Comparison

| Compiler | Optimization | fib(35) Time | Relative |
|----------|-------------|--------------|----------|
| GCC 11 | -O3 -march=native -flto | ~42ms | 100% ⚡ |
| Clang 14 | -O3 -march=native -flto | ~44ms | 95% |
| MSVC 2022 | /O2 /GL /LTCG | ~48ms | 87% |
| GCC 11 | -O2 | ~55ms | 76% |
| GCC 11 | -O0 | ~180ms | 23% |

**Recommendation**: Use the default optimization flags for best performance.

---

## 🧪 Verify Build

After building, verify your installation:

```bash
# Test version
./levython --version

# Run examples
./levython examples/09_fibonacci.levy

# Expected output: ~45ms for fib(35)
```

---

## 🚀 Next Steps

After building:
1. Add to PATH (see [WINDOWS_INSTALL.md](WINDOWS_INSTALL.md))
2. Install VS Code extension
3. Try the examples in `examples/`
4. Read the documentation

---

## 📝 Notes

- **Default optimizations** are already aggressive (match or beat C)
- **Native optimization** (`-march=native`) makes binary non-portable
- **LTO** (Link-Time Optimization) adds ~30% to compile time but improves runtime
- **32-bit builds** are slower than 64-bit due to fewer registers

---

**Happy Building! 🎉**
