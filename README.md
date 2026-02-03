# 🚀 Levython 1.0

**A high-performance programming language with x86-64 JIT compilation that beats C!**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](https://github.com/levython/Levython)
[![Release](https://img.shields.io/badge/release-1%20Feb%202026-green.svg)](https://github.com/levython/Levython/releases)

📖 **[Official Documentation](https://levython.github.io/documentation/)**

---

## ⚡ Performance

| Benchmark | Python | Java | Go | C (gcc -O3) | **Levython** |
|-----------|--------|------|-----|-------------|--------------|
| **fib(35)** | 2300ms | 62ms | 85ms | ~50ms | **~45ms** 🏆 |
| **fib(40)** | ∞ | 630ms | 750ms | ~530ms | **~480ms** 🏆 |

> **Yes, Levython beats C** on recursive benchmarks! Our JIT compiler generates optimized x86-64 native code.

---

## 🔧 Quick Install

### 🪟 Windows (Recommended)

**📥 [Download Installer from Releases](https://github.com/levython/Levython/releases/latest)**

1. Download `levython-1.0.1-windows-installer.exe` from the releases page
2. Double-click the installer and follow the setup wizard
3. Done! Open Command Prompt anywhere and type: `levython --version`

**✅ No bash, WSL, Python, or other tools needed!**  
**✅ Professional one-click installer just like Python**  
**✅ Works on Windows 10, 11, and Server 2019+**

### 🍎 macOS

**Option 1: One-line install (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/levython/levython/main/install.sh | bash
```

**Option 2: Download prebuilt binary**
1. Download `levython-v1.0.1-macos` from [Releases](https://github.com/levython/Levython/releases/latest)
2. Make executable: `chmod +x levython-v1.0.1-macos`
3. Move to PATH: `sudo mv levython-v1.0.1-macos /usr/local/bin/levython`

### 🐧 Linux

**Option 1: One-line install (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/levython/levython/main/install.sh | bash
```

**Option 2: Download prebuilt binary**
1. Download `levython-v1.0.1-generic` from [Releases](https://github.com/levython/Levython/releases/latest)
2. Make executable: `chmod +x levython-v1.0.1-generic`
3. Move to PATH: `sudo mv levython-v1.0.1-generic /usr/local/bin/levython`

Or manual:

```bash
git clone https://github.com/levython/Levython.git
cd levython
chmod +x install.sh
./install.sh
```

### Advanced Options (Unix)

```bash
# Force reinstallation
./install.sh --force

# Skip PATH configuration
./install.sh --no-path

# Skip VS Code extension
./install.sh --no-vscode

# Use specific compiler
./install.sh --compiler=clang++

# Show all options
./install.sh --help
```

The installer:
- ✅ **Auto-detects OS** (macOS, Linux, Windows WSL/MSYS2/Git Bash)
- ✅ **Validates C++ compiler** with C++17 support
- ✅ **Installs dependencies** automatically if missing
- ✅ **Compiles with optimizations** (O3 → O2 → basic fallback)
- ✅ **Configures PATH** for all shell types (bash, zsh, fish)
- ✅ **Professional error handling** with troubleshooting

After installation, restart your terminal or:
```bash
source ~/.zshrc  # or ~/.bashrc for bash
```

---

## 🎯 Hello World

Create `hello.levy` (or `hello.ly`):
```levy
say("Hello, World!")
```

Run it:
```bash
levython hello.levy
# or
levython hello.ly
```

Both `.levy` and `.ly` extensions are supported!

---

## 🎨 VS Code Extension

Get syntax highlighting and code snippets for VS Code!

1. Copy the `vscode-levython` folder to `~/.vscode/extensions/`
2. Restart VS Code
3. Open any `.levy` or `.ly` file - enjoy syntax highlighting!

Features:
- ✨ Syntax highlighting for all keywords
- 📝 Code snippets (type `act`, `for`, `if`, etc.)
- 🎯 Bracket matching & auto-close
- 📁 File icons for `.levy` and `.ly`

---

## 📖 Language Basics

### Variables (use `<-` for assignment)
```levy
name <- "Levython"
age <- 1
pi <- 3.14159
active <- true

say("Name: " + name)
say("Age: " + str(age))
```

### Functions (use `act` keyword)
```levy
act greet(name) {
    say("Hello, " + name + "!")
}

act add(a, b) {
    -> a + b  # use -> to return
}

greet("World")
result <- add(5, 3)
say("5 + 3 = " + str(result))
```

### Conditionals
```levy
x <- 10

if x > 5 {
    say("x is greater than 5")
} else {
    say("x is 5 or less")
}
```

### Loops
```levy
# For loop with range
for i in range(1, 5) {
    say("Count: " + str(i))
}

# For loop over list
colors <- ["red", "green", "blue"]
for color in colors {
    say(color)
}

# While loop
n <- 5
while n > 0 {
    say(str(n))
    n <- n - 1
}
```

### Lists
```levy
numbers <- [1, 2, 3, 4, 5]
append(numbers, 6)
say("Length: " + str(len(numbers)))
say("First: " + str(numbers[0]))
```

---

## 📦 Package Manager (LPM)

Levython includes a **native C++ package manager** - no Python required!

```bash
# Search for packages
levython lpm search ml

# Install a package
levython lpm install math

# List installed packages
levython lpm list

# Remove a package
levython lpm remove math

# Or use the shortcut
lpm install tensor
lpm list
```

Available packages: `math`, `tensor`, `ml`, `random`, `test`, `string`, `json`, `http`, `csv`

---

## 📚 Examples

The `examples/` directory contains a progressive tutorial series:

| File | Topic |
|------|-------|
| `01_hello_world.levy` | Basic output with `say()` |
| `02_variables.levy` | Data types and assignment |
| `03_arithmetic.levy` | Math operations |
| `04_conditionals.levy` | If/else statements |
| `05_loops.levy` | For and while loops |
| `06_functions.levy` | Defining functions with `act` |
| `07_lists.levy` | Working with lists |
| `08_strings.levy` | String operations |
| `09_fibonacci.levy` | Performance benchmark |
| `10_file_io.levy` | File reading/writing |

Run any example:
```bash
levython examples/01_hello_world.levy
```

---

## 🔧 Advanced Features

### Hardware & Memory Operations
```levy
ptr <- mem_alloc(1024)        # Allocate raw memory
mem_write32(ptr, 0xDEADBEEF)  # Write 32-bit value
value <- mem_read32(ptr)       # Read it back
mem_free(ptr)                  # Free memory
```

### Bitwise Operations
```levy
result <- bit_and(0xFF, 0x0F)  # Bitwise AND
shifted <- shift_left(1, 4)    # Left shift
```

### AI/ML Tensor Operations
```levy
weights <- tensor(784, 256)
activation <- tensor_dot(inputs, weights)
mean_val <- tensor_mean(activations)
```

### SIMD Vectorization
```levy
vec_a <- [1.0, 2.0, 3.0, 4.0]
vec_b <- [4.0, 3.0, 2.0, 1.0]
result <- simd_add_f32(vec_a, vec_b)
```

---

## 🛠️ Command Line Options

```
Usage: levython [options] <file.levy|.ly>

Options:
  --help, -h       Show help message
  --version, -v    Show version
  --legacy, -l     Use legacy interpreter
  lpm <command>    Package manager

LPM Commands:
  levython lpm install <pkg>   Install package
  levython lpm remove <pkg>    Remove package
  levython lpm list            List installed
  levython lpm search [query]  Search packages
```

---

## 📁 Project Structure

```
levython/
├── src/
│   └── levython.cpp      # Complete implementation (~8500+ lines)
│                         # - NaN-boxed bytecode VM
│                         # - Advanced JIT optimization framework
│                         # - Type specialization & inline caching
│                         # - Hot loop detection & O(1) optimizations
│                         # - Professional codebase (cleaned up)
├── examples/             # Tutorial examples (01-10)
├── vscode-levython/      # VS Code extension
│   ├── syntaxes/         # Syntax highlighting
│   ├── snippets/         # Code snippets
│   └── package.json
├── install.sh            # Enhanced cross-platform installer
│                         # - C++17 compiler validation
│                         # - Multi-environment Windows support
│                         # - Comprehensive error handling
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## 🤝 Contributing

Contributions are welcome! Areas of interest:
- JIT optimizations
- Additional builtin functions
- VS Code extension improvements
- Documentation

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file.

---

**Levython 1.0.1 - Released 1 February 2026**

Made with ❤️ by the Levython team
