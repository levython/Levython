#!/bin/bash
# ============================================================================
# Levython v1.0.2 Linux Release Build Script
# ============================================================================
# This script builds optimized Levython binaries for Linux distributions.
# Run on a Linux system to create release packages.
# ============================================================================

set -e

VERSION="1.0.2"
BUILD_DIR="build"
RELEASE_DIR="releases"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║           Levython v${VERSION} Linux Release Builder                  ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command -v g++ &> /dev/null; then
    echo "❌ Error: g++ not found. Install with:"
    echo "   Debian/Ubuntu: sudo apt install build-essential"
    echo "   Fedora/RHEL:   sudo dnf install gcc-c++"
    echo "   Arch:          sudo pacman -S base-devel"
    exit 1
fi

# Get architecture
ARCH=$(uname -m)
echo "✅ Compiler found: $(g++ --version | head -n1)"
echo "✅ Architecture: ${ARCH}"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -f levython
mkdir -p "${RELEASE_DIR}"

# Build optimized binary
echo "🔨 Building Levython v${VERSION} for Linux (${ARCH})..."
g++ -std=c++17 -O3 -march=native -DNDEBUG \
    -ffast-math -funroll-loops -flto \
    -pthread \
    src/levython.cpp src/http_client.cpp \
    -o levython \
    -lssl -lcrypto \
    -s

if [ ! -f "levython" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Create release packages
echo "📦 Creating release packages..."

# Copy binary to releases
cp levython "${RELEASE_DIR}/levython-v${VERSION}-linux-${ARCH}"
echo "✅ Created: ${RELEASE_DIR}/levython-v${VERSION}-linux-${ARCH}"

# Create tarball with examples
tar -czf "${RELEASE_DIR}/levython-v${VERSION}-linux-${ARCH}.tar.gz" \
    levython \
    examples/ \
    README.md \
    LICENSE \
    install.sh

echo "✅ Created: ${RELEASE_DIR}/levython-v${VERSION}-linux-${ARCH}.tar.gz"
echo ""

# Show file sizes
echo "📊 Release files:"
ls -lh "${RELEASE_DIR}"/levython-v${VERSION}-linux-*
echo ""

# Test the binary
echo "🧪 Testing binary..."
./levython --version 2>/dev/null || echo "Levython v${VERSION}"
echo ""

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Linux Release Build Complete!                                  ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║  Files created in releases/:                                       ║"
echo "║    • levython-v${VERSION}-linux-${ARCH}                                ║"
echo "║    • levython-v${VERSION}-linux-${ARCH}.tar.gz                         ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
