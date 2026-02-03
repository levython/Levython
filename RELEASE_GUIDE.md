# Building Windows Release for GitHub

## Quick Build

Run this on a Windows machine with Visual Studio or MinGW:

```batch
cd windows
build-installer.bat
```

This creates: `releases/levython-1.0.1-windows-installer.exe`

## Upload to GitHub Releases

### Step 1: Create Release on GitHub

1. Go to: https://github.com/levython/Levython/releases
2. Click **"Draft a new release"**
3. Fill in:
   - **Tag:** `v1.0.1`
   - **Release title:** `Levython 1.0.1 - High Performance Programming`
   - **Description:** (see template below)

### Step 2: Upload the Installer

1. **Attach files** section
2. Upload: `releases/levython-1.0.1-windows-installer.exe`
3. Also upload (optional):
   - `releases/levython-v1.0.1-macos` (macOS binary)
   - `releases/levython-v1.0.1-generic` (Linux binary)

### Step 3: Publish

Click **"Publish release"**

## Release Notes Template

```markdown
# 🚀 Levython 1.0.1

High-performance programming language with JIT compilation that beats C!

## 📥 Installation

### Windows (Recommended)
**[⬇️ Download Installer](levython-1.0.1-windows-installer.exe)** (10 MB)

Just download and run - no other software needed!
- ✅ One-click installer
- ✅ No bash, WSL, or Python required
- ✅ Automatic PATH setup
- ✅ VS Code extension included

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/levython/levython/main/install.sh | bash
```

Or download prebuilt binaries:
- **[macOS (x64)](levython-v1.0.1-macos)**
- **[Linux (x64)](levython-v1.0.1-generic)**

## ✨ What's New in 1.0.1

- 🪟 Professional Windows installer
- 📦 Single-file distribution
- 🔧 Improved PATH integration
- 📚 Enhanced documentation
- 🐛 Bug fixes and stability improvements

## 🎯 Quick Start

After installation:

```bash
# Create hello.levy
echo 'say("Hello, Levython!")' > hello.levy

# Run it
levython hello.levy
```

## 📊 Performance

| Benchmark | Python | Java | C (gcc -O3) | **Levython** |
|-----------|--------|------|-------------|--------------|
| fib(35)   | 2300ms | 62ms | ~50ms       | **~45ms** 🏆 |

## 🔗 Links

- **[Documentation](https://levython.github.io/documentation/)**
- **[GitHub Repository](https://github.com/levython/Levython)**
- **[Examples](https://github.com/levython/Levython/tree/main/examples)**
- **[Report Issues](https://github.com/levython/Levython/issues)**

---

**Full Changelog:** [v1.0.0...v1.0.1](https://github.com/levython/Levython/compare/v1.0.0...v1.0.1)
```

## Checklist Before Release

- [ ] Windows installer built and tested
- [ ] macOS binary compiled
- [ ] Linux binary compiled
- [ ] All binaries tested on clean systems
- [ ] README updated with release links
- [ ] CHANGELOG.md updated
- [ ] Version numbers consistent everywhere
- [ ] Examples tested
- [ ] Documentation updated

## File Names

Use consistent naming:
- `levython-1.0.1-windows-installer.exe` (Windows)
- `levython-v1.0.1-macos` (macOS)
- `levython-v1.0.1-generic` (Linux)

## After Release

1. Update README.md with direct download link
2. Update documentation site
3. Announce on social media / forums
4. Monitor issues for any installation problems
