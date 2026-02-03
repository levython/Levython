# 🚀 Levython Windows Installer - Quick Guide

## For End Users

### Download & Install (3 Steps)

```
1. Download ────→  levython-1.0.1-windows-installer.exe
                   (One file, ~10 MB)

2. Double-click ──→  [Run the installer]
                     • Welcome screen
                     • Choose install location
                     • Select options (PATH, file associations)
                     • Click Install

3. Done! ────────→  Open Command Prompt and type:
                     levython --version
```

### No Requirements!

❌ No bash  
❌ No WSL  
❌ No Python  
❌ No admin rights (optional)  
❌ No configuration  

✅ Just download and run!

---

## For Developers

### Build the Installer

```
Prerequisites:
  • Visual Studio OR MinGW-w64
  • Inno Setup 6.x (free download)

Build:
  1. cd windows
  2. build-installer.bat
  
Output:
  releases/levython-1.0.1-windows-installer.exe
  
  ^ THIS IS THE ONLY FILE YOU DISTRIBUTE
```

### What's Inside the Installer

The single .exe contains:
```
levython.exe ─────────────→ Main compiler
lpm.exe ──────────────────→ Package manager
docs/ ────────────────────→ Full documentation
examples/ ────────────────→ 10+ example programs
vscode-extension/ ────────→ Syntax highlighting
installer wizard ─────────→ Beautiful GUI
uninstaller ──────────────→ Clean removal
```

All compressed into ONE file!

### How It Works

```
User downloads ──→ levython-installer.exe
                   |
User runs it ────→ Inno Setup wizard appears
                   |
User clicks ─────→ Files extracted to Program Files
  "Install"        |
                   ├─ levython.exe installed
                   ├─ PATH updated
                   ├─ .levy files associated  
                   └─ VS Code extension added
                   |
                   ✓ Ready to use!
```

---

## Comparison

### Traditional Way (Complex)
```
1. Install WSL or Git Bash
2. Install compiler dependencies
3. Clone repository
4. Run install script
5. Deal with PATH issues
6. Troubleshoot errors
7. Maybe it works?
```

### Levython Way (Simple)
```
1. Download .exe
2. Run it
3. Done!
```

---

## Distribution Checklist

- [ ] Build installer: `cd windows && build-installer.bat`
- [ ] Test on clean Windows 10 VM
- [ ] Test on clean Windows 11 VM
- [ ] Upload to GitHub Releases
- [ ] Update download links in README
- [ ] Announce release

---

## File Sizes

```
Source files:           ~500 KB
Compiled levython.exe:  ~2-3 MB
Full installer.exe:     ~5-10 MB
Installed size:         ~15 MB
```

Compare to:
- Python installer: ~25 MB
- Node.js installer: ~20 MB
- Go installer: ~150 MB

Levython is lightweight!

---

**🎯 Bottom Line:**

Users get a professional, one-click installer experience.  
No technical knowledge required.  
Just like installing Python, Chrome, or any other Windows app.
