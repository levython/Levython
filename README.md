# Levython 1.0.2

Levython is a high‑performance, general‑purpose programming language with an x86‑64 JIT, a fast bytecode VM, and a practical standard library.

Motto: **Be better than yesterday**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](https://github.com/levython/Levython)
[![Release](https://img.shields.io/badge/release-8%20Feb%202026-green.svg)](https://github.com/levython/Levython/releases)

Documentation: https://levython.github.io/documentation/

---

## Contents

- Overview
- Installation (Windows / macOS / Linux)
- Quick Start
- Language Guide
- Standard Library
- HTTP Server (Userland)
- Package Manager (LPM)
- Build System
- CLI Reference
- Project Layout
- Contributing
- License

---

## Overview

Levython focuses on fast execution and developer ergonomics:
- JIT‑accelerated execution and a high‑performance VM
- Clean syntax, functions, classes, inheritance, and exceptions
- Batteries‑included standard library for real programs
- Cross‑platform tooling: macOS, Linux, Windows

---

## Installation

### Windows

**Option 1: GUI Installer (Recommended)**
- Download the installer: https://github.com/levython/Levython/releases/latest
- Supports both 32‑bit and 64‑bit Windows

**Option 2: Pre‑built Binaries**
- levython‑windows‑x64.exe
- levython‑windows‑x86.exe

Manual PATH instructions: `WINDOWS_INSTALL.md`

**Build from Source (Windows):**
```batch
build-windows.bat
build-windows.bat --arch=both
build-installer.bat
```

**Important (Windows Installer EXE):**
- The **GUI installer EXE** is built from `installer/levython-setup.iss` (Inno Setup).
- `Install-Levython.bat` / `LevythonInstaller.ps1` are for **local install from source** and do **not** produce the GUI EXE.

### macOS & Linux

**One‑line install:**
```bash
curl -fsSL https://raw.githubusercontent.com/levython/levython/main/install.sh | bash
```

**Manual install:**
```bash
git clone https://github.com/levython/Levython.git
cd levython
chmod +x install.sh
./install.sh
```

---

## Quick Start

```levy
name <- "Levython"

act greet(who) {
    say("Hello, " + who)
}

greet(name)
```

Run:
```bash
levython hello.levy
```

---

## Language Guide

### Variables and Types

```levy
name <- "Levython"
count <- 3
pi <- 3.14159
active <- true
nothing <- none
```

### Functions

```levy
act add(a, b) { -> a + b }
result <- add(2, 3)
```

### Conditionals

```levy
if count > 2 {
    say("big")
} else {
    say("small")
}
```

### Loops

```levy
for i in range(1, 4) {
    say(str(i))
}

items <- ["a", "b", "c"]
for x in items {
    say(x)
}

n <- 3
while n > 0 {
    say(str(n))
    n <- n - 1
}
```

### Lists and Maps

```levy
nums <- [1, 2, 3]
append(nums, 4)

m <- {"a": 1, "b": 2}
ks <- keys(m)
```

### Classes and Inheritance

```levy
class Counter {
    init(label) { self.label <- label; self.value <- 0 }
    inc() { self.value <- self.value + 1 }
}

class NamedCounter is a Counter {
    init(label) { super.init(label) }
}

c <- Counter("hits")
c.inc()
```

### Exceptions

```levy
try {
    x <- 1 / 0
} catch {
    say("failed")
}
```

---

## Standard Library

### Core Builtins

- `say`, `ask`, `print`, `println`
- `len`, `range`, `append`, `keys`
- `str`, `int`, `float`, `type`
- `min`, `max`, `sum`, `sorted`, `reversed`
- `upper`, `lower`, `trim`, `replace`, `split`, `join`, `contains`, `find`, `startswith`, `endswith`
- `time`, `sqrt`, `pow`, `floor`, `ceil`, `round`

### Modules

#### `http`
- `get`, `post`, `put`, `patch`, `delete`, `head`, `request`
- `set_timeout`, `set_verify_ssl`

#### `os`
- `name`, `sep`, `cwd`, `chdir`, `listdir`, `exists`, `is_file`, `is_dir`
- `mkdir`, `remove`, `rmdir`, `rename`, `abspath`, `getenv`, `setenv`, `unsetenv`

#### `fs`
- `exists`, `is_file`, `is_dir`, `mkdir`, `remove`, `rmdir`, `listdir`
- `read_text`, `write_text`, `append_text`, `copy`, `move`, `abspath`

#### `path`
- `join`, `basename`, `dirname`, `ext`, `stem`, `norm`, `abspath`
- `exists`, `is_file`, `is_dir`, `read_text`, `write_text`, `listdir`, `mkdir`, `remove`, `rmdir`

#### `process`
- `getpid`, `run`, `cwd`, `chdir`, `getenv`, `setenv`, `unsetenv`

#### `json`
- `parse`, `stringify`

#### `url`
- `parse`, `encode`, `decode`

#### `net`
- `tcp_connect`, `tcp_listen`, `tcp_accept`, `tcp_try_accept`
- `tcp_send`, `tcp_try_send`, `tcp_recv`, `tcp_try_recv`, `tcp_close`
- `udp_bind`, `udp_sendto`, `udp_recvfrom`, `udp_close`
- `set_nonblocking`, `dns_lookup`

#### `thread`
- `spawn`, `join`, `is_done`, `sleep`

#### `channel`
- `create`, `send`, `recv`, `try_recv`, `close`

#### `async`
- `spawn`, `sleep`, `tcp_recv`, `tcp_send`, `tick`, `done`, `status`, `result`, `cancel`, `pending`, `await`

#### `crypto`
- `sha256`, `sha512`, `hmac_sha256`
- `random_bytes`, `hex_encode`, `hex_decode`, `base64_encode`, `base64_decode`

#### `datetime`
- `now_utc`, `now_local`, `format`, `parse`, `sleep_ms`, `epoch_ms`

#### `log`
- `set_level`, `set_output`, `set_json`, `log`, `debug`, `info`, `warn`, `error`, `flush`

#### `config`
- `load_env`, `get`, `set`, `get_int`, `get_float`, `get_bool`, `has`

#### `input`
- `enable_raw`, `disable_raw`, `key_available`, `poll`, `read_key`

---

## HTTP Server (Userland)

Use the included helper module: `http_server.levy`

```levy
import http_server

act handler(req) {
    if req["path"] == "/health" { -> {"status": 200, "body": "ok"} }
    -> {"status": 404, "body": "not found"}
}

http_server.serve("127.0.0.1", 18082, handler)
```

---

## Package Manager (LPM)

```bash
levython lpm search ml
levython lpm install math
levython lpm list
levython lpm remove math
```

---

## Build System

```
levython build <input.levy|.ly> [options]
  -o, --output <file>      Output executable path
  --target <t>             native|windows|linux|macos|<target-triple>
  --runtime <file>         Use prebuilt runtime binary instead of compiling
  --source-root <dir>      Source root for cross-runtime compile (default: .)
  --verbose                Print cross-compile command
```

Examples:
```
levython build app.levy -o app
levython build app.levy --target windows -o app.exe
levython build app.levy --target aarch64-macos -o app-mac
```

---

## CLI Reference

```
Usage: levython [options] <file.levy|.ly>

Options:
  --help, -h       Show help message
  --version, -v    Show version
  --no-update-check Disable update checks
  lpm <command>    Package manager
  build <src>      Build standalone executable
```

---

## Project Layout

```
levython/
├── src/                 # Core implementation
├── examples/            # Example programs
├── tests/               # Tests
├── installer/           # Windows installer assets
├── install.sh           # Cross-platform installer
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Contributing

Contributions are welcome. Areas of interest:
- JIT/VM optimizations
- Standard library modules
- Tooling and documentation

---

## License

MIT
