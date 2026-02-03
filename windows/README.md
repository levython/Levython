# Levython Windows Installer

**One-click installer for Windows** - Just like Python! No bash, no WSL, no complexity.

Users simply download ONE .exe file and double-click to install. That's it!

## 📦 What Users Get

A professional Windows installer that includes:

- ✅ **Levython Compiler** - Full featured, JIT-enabled
- ✅ **LPM Package Manager** - Install packages with ease
- ✅ **Documentation** - Complete offline docs
- ✅ **Examples** - 10+ tutorial programs
- ✅ **VS Code Extension** - Syntax highlighting
- ✅ **PATH Integration** - Works from any folder
- ✅ **File Associations** - Double-click .levy files
- ✅ **Uninstaller** - Clean removal

## 🚀 For Users

### Installation (Super Easy!)

1. **Download** `levython-1.0.1-windows-installer.exe`
2. **Double-click** the installer
3. **Follow the wizard** (Next, Next, Install)
4. **Done!** Start coding

No bash, no Python, no admin rights required!

### After Installation

Open Command Prompt or PowerShell anywhere:

```batch
levython hello.levy
lpm install math
```

That's it! Works exactly like Python.

## 🛠️ For Developers (Building the Installer)

### Prerequisites

**Only 2 things needed:**

1. **C++ Compiler** (pick one):
   - Visual Studio 2019+ with C++ tools
   - MinGW-w64 from https://www.mingw-w64.org/

2. **Inno Setup 6.x** from https://jrsoftware.org/isinfo.php
   - Free, open source, industry standard
   - Used by Python, Node.js, etc.

**That's all!** No Python, no complicated setup.

### Build the Installer (1 Command)

```batch
cd windows
build-installer.bat
```

**Done!** You get: `releases/levython-1.0.1-windows-installer.exe`

The script automatically:
- ✅ Compiles Levython
- ✅ Generates icons and graphics
- ✅ Packages everything into ONE .exe
- ✅ Creates uninstaller
- ✅ Sets up file associations

### Even Easier: Just Double-Click

Don't like command line? Just double-click `BUILD.bat`

### What Gets Built

**OUTPUT:** One single file
```
releases/levython-1.0.1-windows-installer.exe  (~ 5-10 MB)
```

This ONE file contains everything:
- Levython compiler (levython.exe)
- Package manager (lpm.exe)  
- All documentation
- All examples
- VS Code extension
- Installer wizard
- Uninstaller

Users just download and run this one file. That's it!

## 🎨 Customization

### Your Own Logo

Replace these files before building:
```
windows/assets/levython.ico          (Icon, any size)
windows/assets/wizard-large.bmp      (164x314 pixels)
windows/assets/wizard-small.bmp      (55x55 pixels)
```

If they don't exist, the build script creates nice defaults automatically.

### Branding

Edit `windows/installer.iss`:
```ini
#define MyAppName "YourName"
#define MyAppVersion "1.0.1"  
#define MyAppPublisher "Your Company"
```

## 📦 Distribution

### Quick Start for End Users

1. Upload `levython-1.0.1-windows-installer.exe` to:
   - GitHub Releases
   - Your website
   - Google Drive / Dropbox

2. Users download and run it

3. Done! No instructions needed

### Download Page Example

```markdown
## Download Levython for Windows

**[⬇️ Download Installer (10 MB)](levython-1.0.1-windows-installer.exe)**

Just download and run - no other software needed!

Works on: Windows 10, 11, Server 2019+
```

## 🐛 Troubleshooting

### "ISCC.exe not found"
**Fix:** Install Inno Setup from https://jrsoftware.org/isinfo.php

### "Compiler not found"  
**Fix:** Install Visual Studio with C++ or MinGW-w64

### "Assets missing"
**Fix:** Nothing! They're auto-generated. Just run the build script.

## ✅ Tested On

- ✅ Windows 11 (x64)
- ✅ Windows 10 (x64)  
- ✅ Windows Server 2019+

## 📝 License

MIT License (same as Levython)

---

**🎯 GOAL ACHIEVED:** One-file installer, just like Python! No bash, no complexity.
