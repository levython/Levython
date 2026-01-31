# Changelog

All notable changes to Levython will be documented in this file.

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
