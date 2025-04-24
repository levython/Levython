# Levython

**Levython** is an alpha-stage, lightweight scripting language inspired by Python’s simplicity, featuring a unique syntax for rapid prototyping and learning. This repository (`github.com/levython/levython`) is the official home of the Levython language, doubling as its GitHub profile page.

**Alpha 0.1.0** | **Status**: Experimental | **License**: MIT

## Overview
Levython is a C++-based scripting language designed for simplicity and ease of use. Its unique syntax (e.g., `say` for output, `repeat` for loops, `<-` for assignment) makes it ideal for learning, prototyping, and small scripts. Built as a single-file interpreter, Levython is easy to compile and extend, perfect for early adopters and language enthusiasts.

### Features
- **Unique Syntax**: `say`, `repeat`, `<-`, and `act` for functions.
- **Lightweight**: Single-file C++ interpreter, compiles with one command.
- **Built-ins**: `range`, `len`, `open`, `append`, and math functions (`math.sin`, `math.cos`).
- **Use Cases**: Learning, prototyping, small scripts.

### Limitations (Alpha)
- Upcoming: `break`, `continue`, tuples, advanced modules.
- Performance: Slower than modern interpreters for compute tasks; competitive for file I/O.
- Experimental: Expect bugs and incomplete features.

## Getting Started

### Prerequisites
- C++17 compiler (e.g., g++ 7.0+)
- Standard C++ library


### Build
Clone the repository and compile the single-file interpreter for your platform.

#### Linux
```bash
git clone https://github.com/levython/levython.git
cd levython/src
g++ levython.cpp -o levython -std=c++17
```

#### macOS
Install Xcode Command Line Tools (`xcode-select --install`) or Homebrew (`brew install gcc`).
```bash
git clone https://github.com/levython/levython.git
cd levython/src
clang++ levython.cpp -o levython -std=c++17  # or g++ if using Homebrew
```

#### Windows
Install MinGW-w64 via MSYS2 (`pacman -S mingw-w64-x86_64-gcc`) or Visual Studio Community.
- **MinGW-w64 (MSYS2)**:
  ```bash
  git clone https://github.com/levython/levython.git
  cd levython/src
  g++ levython.cpp -o levython.exe -std=c++17
  ```
- **Visual Studio (MSVC)**:
  Open a Developer Command Prompt for VS, then:
  ```bash
  git clone https://github.com/levython/levython.git
  cd levython/src
  cl /EHsc /std:c++17 levython.cpp /Fe:levython.exe
  ```

### Run
Use the compiled binary or downloaded release binary to run scripts or start the REPL.

- **Linux/macOS**:
  - Run a script:
    ```bash
    ./levython examples/file_io.ly
    ```
  - Start REPL:
    ```bash
    ./levython
    ```

- **Windows**:
  - Run a script:
    ```bash
    levython.exe examples\file_io.ly
    ```
  - Start REPL:
    ```bash
    levython.exe
    ```

## Examples
Explore scripts in `examples/`:
- `arithmetic.levy`: Arithmetic loop.
- `loops.levy`: For-loop with `range`.
- `file_io.levy`: File writing.
- `fibonacci.levy`: Recursive function.
- `list_ops.levy`: List operations.

Example (`file_io.levy`):
```levython
file <- open("output.txt", "w")
repeat 1000 {
    file.write("Hello, Levython!\n")
}
file.close()
say("Done")
```

## Repository Structure
```
levython/
├── src/
│   └── levython.cpp          # Interpreter source
├── examples/
│   ├── arithmetic.levy        # Arithmetic benchmark
│   ├── loops.levy             # Loop benchmark
│   ├── file_io.levy           # File I/O benchmark
│   ├── fibonacci.levy         # Recursive function
│   └── list_ops.levy          # List operations
├── README.md                  # This file
├── LICENSE                    # MIT License
├── CHANGELOG.md               # Alpha 0.1.0 changes
└── .gitignore                 # Ignore artifacts
```

## Contributing
Levython is in alpha, and feedback is crucial for its growth! Please:
- Report bugs via GitHub Issues.
- Suggest features (e.g., `break`, `tuples`).
- Share performance feedback privately via Discussions.

## License
MIT License (see `LICENSE`).

## Changelog
- **Alpha 0.1.0** (2025-04-25): Initial release with core syntax, file I/O, and built-ins.

## Join the Journey
- Try Levython by running the example scripts!
- Share ideas or collaborate via GitHub Discussions.
- Stay updated on GitHub for new releases and features.
