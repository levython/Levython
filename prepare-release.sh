#!/bin/bash
# Prepare Windows Release Package
# Run this on macOS to prepare files for Windows build

set -e

echo "========================================"
echo "  LEVYTHON WINDOWS RELEASE PREPARATION"
echo "========================================"
echo ""

# Configuration
VERSION="1.0.1"
RELEASE_DIR="releases"

echo "==> Checking environment..."
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is for macOS preparation"
    echo "    On Windows, run: cd windows && build-installer.bat"
fi

echo "✓ Running on macOS"
echo ""

echo "==> Preparing release directory..."
mkdir -p "$RELEASE_DIR"
echo "✓ Created: $RELEASE_DIR/"
echo ""

echo "==> Building macOS binary..."
cd src
clang++ -std=c++17 -O3 -march=native -o "../$RELEASE_DIR/levython-v$VERSION-macos" levython.cpp
cd ..
chmod +x "$RELEASE_DIR/levython-v$VERSION-macos"
echo "✓ Built: levython-v$VERSION-macos"
echo ""

echo "==> Building generic Linux binary..."
cd src
clang++ -std=c++17 -O3 -o "../$RELEASE_DIR/levython-v$VERSION-generic" levython.cpp
cd ..
chmod +x "$RELEASE_DIR/levython-v$VERSION-generic"
echo "✓ Built: levython-v$VERSION-generic"
echo ""

echo "==> Checking file sizes..."
ls -lh "$RELEASE_DIR/"
echo ""

echo "========================================"
echo "  ✓ MACOS & LINUX BINARIES READY"
echo "========================================"
echo ""
echo "📦 Created:"
echo "   • levython-v$VERSION-macos"
echo "   • levython-v$VERSION-generic"
echo ""
echo "🪟 For Windows installer:"
echo "   1. Copy this entire repository to a Windows machine"
echo "   2. Run: cd windows && build-installer.bat"
echo "   3. Get: releases/levython-$VERSION-windows-installer.exe"
echo ""
echo "📤 Then upload all to GitHub Releases:"
echo "   • levython-v$VERSION-macos"
echo "   • levython-v$VERSION-generic"
echo "   • levython-$VERSION-windows-installer.exe"
echo ""
echo "📖 See RELEASE_GUIDE.md for detailed instructions"
echo ""
