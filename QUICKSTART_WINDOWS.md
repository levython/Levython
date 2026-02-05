# 🚀 Quick Start - Windows Users

Get started with Levython on Windows in 5 minutes!

## Step 1: Download & Install

### Option A: GUI Installer (Recommended) ⭐

1. **Download** the installer:
   - [levython-1.0.1-windows-installer.exe](https://github.com/levython/Levython/releases/latest)

2. **Run** the installer (right-click → Run as administrator)

3. **Follow** the wizard:
   - ✅ Check "Add Levython to system PATH"
   - ✅ Check "Associate .levy files with Levython"
   - ✅ Check "Install VS Code extension" (if you use VS Code)

4. **Done!** Close the installer

### Option B: Manual Download

1. Download the executable for your system:
   - **64-bit Windows**: [levython-windows-x64.exe](https://github.com/levython/Levython/releases/latest)
   - **32-bit Windows**: [levython-windows-x86.exe](https://github.com/levython/Levython/releases/latest)

2. Rename to `levython.exe` and place in `C:\levython\`

3. Add to PATH:
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add `C:\levython\`
   - Click "OK" on all dialogs

---

## Step 2: Verify Installation

Open **Command Prompt** or **PowerShell** and run:

```cmd
levython --version
```

You should see:
```
Levython 1.0.2
```

---

## Step 3: Your First Program

Create a file called `hello.levy`:

```levy
say("Hello, Windows!")
say("Welcome to Levython!")

name <- "World"
say("Hello, " + name + "!")
```

Run it:

```cmd
levython hello.levy
```

Output:
```
Hello, Windows!
Welcome to Levython!
Hello, World!
```

---

## Step 4: Try More Examples

### Fibonacci (JIT Compilation Demo)

Create `fib.levy`:
```levy
act fib(n) {
    if n < 2 { -> n }
    -> fib(n - 1) + fib(n - 2)
}

result <- fib(35)
say("fib(35) = " + str(result))
```

Run it:
```cmd
levython fib.levy
```

This runs with **JIT compilation** - as fast as C!

### Variables and Math

```levy
x <- 10
y <- 20
sum <- x + y
say("Sum: " + str(sum))

# Lists
numbers <- [1, 2, 3, 4, 5]
say("First number: " + str(numbers[0]))
say("Length: " + str(len(numbers)))
```

### Loops

```levy
# For loop
for i in range(5) {
    say("Count: " + str(i))
}

# While loop
i <- 0
while i < 3 {
    say("i = " + str(i))
    i <- i + 1
}
```

### Functions

```levy
act greet(name) {
    -> "Hello, " + name + "!"
}

act add(a, b) {
    -> a + b
}

message <- greet("Alice")
say(message)

result <- add(5, 3)
say("5 + 3 = " + str(result))
```

---

## Step 5: Explore Examples

The installer includes many examples:

```cmd
cd "C:\Program Files\Levython\examples"
dir
```

Try them all:

```cmd
levython 01_hello_world.levy
levython 02_variables.levy
levython 03_arithmetic.levy
levython 04_conditionals.levy
levython 05_loops.levy
levython 06_functions.levy
levython 07_lists.levy
levython 08_strings.levy
levython 09_fibonacci.levy
levython 10_file_io.levy
```

---

## 🎨 VS Code Setup (Optional)

If you use VS Code:

1. The installer should have installed the extension automatically
2. Open any `.levy` file and enjoy syntax highlighting!
3. If not installed, manually install from:
   - `C:\Program Files\Levython\vscode-extension\`

---

## 📚 Next Steps

- **Full Tutorial**: Check out the [examples/](examples/) folder
- **Language Reference**: See [README.md](README.md) for complete syntax
- **Advanced**: Read [BUILD.md](BUILD.md) to compile from source
- **Benchmarks**: Compare performance with [JIT_OPTIMIZATIONS.md](JIT_OPTIMIZATIONS.md)

---

## 🐛 Common Issues

### "levython is not recognized as a command"

**Solution**: Add to PATH (see Step 1, Option B above)

Or run with full path:
```cmd
C:\levython\levython.exe hello.levy
```

### "VCRUNTIME140.dll is missing"

**Solution**: Install Microsoft Visual C++ Redistributable:
- [Download VC++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### File association not working

**Solution**: Right-click a `.levy` file → Open with → Choose Levython

Or reinstall with file associations checked.

---

## ⚡ Performance Tips

1. **Use 64-bit version** for best performance (15-20% faster)
2. **Disable Windows Defender** for the Levython folder (if safe)
3. **Run in Command Prompt** instead of PowerShell for slightly faster startup
4. **Use SSD** for faster file I/O operations

---

## 🎯 Quick Reference

```levy
# Variables
x <- 10
name <- "Alice"

# Output
say("Hello!")
say(x)

# Math
a <- 5 + 3
b <- 10 * 2
c <- 20 / 4

# Strings
text <- "Hello" + " World"
say(text)

# Lists
items <- [1, 2, 3]
items[0]  # First element
len(items)  # Length

# Conditionals
if x > 5 {
    say("Big")
} else {
    say("Small")
}

# Loops
for i in range(10) {
    say(i)
}

# Functions
act add(a, b) {
    -> a + b
}

result <- add(5, 3)
```

---

**You're all set! Start coding in Levython! 🎉**

Need help? Open an issue on [GitHub](https://github.com/levython/Levython/issues)
