# Levython VS Code Extension - Changelog

All notable changes to the Levython VS Code extension will be documented in this file.

## [1.0.3] - 2026-02-14

### Added
- **Official Dragon Logo Icon** - Authentic Levython dragon for all .levy and .ly files
  - High-quality SVG rendering of the official Levython dragon
  - Fiery red/orange gradient matching brand identity
  - Auto-activates on extension installation
  - Works as overlay with any existing icon theme
  - Supported files: .levy, .ly, .levyrc, levython.config

- **150+ Comprehensive Snippets** - Complete coverage of all Levython features
  - 40+ core language snippets (functions, classes, loops, conditionals)
  - 10+ HTTP and networking snippets
  - 15+ file and OS operation snippets
  - 50+ OS submodule snippets for system automation
  - 15+ async and threading snippets
  - 25+ collection and data operation snippets
  - 10+ cryptography snippets
  - 10+ math and utility snippets

- **Enhanced Syntax Highlighting**
  - Complete support for OS.Hooks methods
  - Complete support for OS.InputControl methods
  - Complete support for OS.Processes methods
  - Complete support for OS.Audio methods
  - Complete support for OS.Display methods
  - Complete support for OS.Privileges methods
  - Complete support for OS.Events methods
  - Complete support for OS.Persistence methods
  - Ternary operator highlighting (`?` and `:`)
  - `super` keyword highlighting
  - `elif` keyword highlighting
  - Compound assignment operators (`+=`, `-=`, `*=`, `/=`, `%=`, `^=`)
  - Enhanced module detection including `lpm`

- **GitHub Copilot Optimization**
  - Comprehensive syntax definitions for better AI understanding
  - Detailed snippet descriptions for context
  - Module method highlighting for accurate suggestions
  - Enhanced IntelliSense configuration

- **Documentation**
  - Complete README with 150+ snippet descriptions
  - Real-world use case examples for each module
  - Copilot integration guide with best practices
  - Troubleshooting section
  - Comprehensive language reference

- **Editor Configuration**
  - Snippet suggestions at top priority
  - Enhanced quick suggestions
  - Accept suggestions on Enter
  - Show snippets by default

### Changed
- Updated description to emphasize Copilot readiness
- Enhanced keywords for better marketplace discoverability
- Improved package.json structure and metadata
- Updated icon reference in package.json

### Fixed
- Indentation rules for new keywords
- Auto-closing pairs for all bracket types
- Folding markers for code regions

## [1.0.2] - Previous Release

### Initial Features
- Basic syntax highlighting
- Core language snippets
- File associations (.levy, .ly)
- Auto-indentation
- Bracket matching

---

## Snippet Categories Summary

### Core Language (40+)
Variables, functions, classes, conditionals, loops, exceptions, imports

### OS Modules (50+)
- **OS.Hooks**: System event monitoring (10 snippets)
- **OS.InputControl**: Keyboard/mouse automation (15 snippets)
- **OS.Processes**: Process management (10 snippets)
- **OS.Display**: Screen capture (10 snippets)
- **OS.Audio**: Audio control (10 snippets)
- **OS.Privileges**: Permission management (8 snippets)
- **OS.Events**: Event monitoring (10 snippets)
- **OS.Persistence**: System persistence (8 snippets)

### Networking & HTTP (10+)
HTTP client, HTTP server, TCP server/client

### Data & Crypto (15+)
JSON, cryptography, encoding, datetime

### Collections & Math (25+)
List operations, map/filter/reduce, mathematical functions

### Async & Threading (8+)
Async tasks, threads, channels

---

## Future Enhancements

- Language server protocol support
- Debugging integration
- Code formatting provider
- Linting and diagnostics
- Refactoring actions
- Code completion based on imported modules
- Hover documentation
- Go to definition support
- Symbol search
- Workspace symbol provider

---

**Levython** - Be better than yesterday
