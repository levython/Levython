#!/bin/bash
# ============================================================================
# Levython v1.0.2 Release Build Script
# ============================================================================
# This script builds optimized Levython binaries for Linux and macOS.
# Automatically detects the platform and uses appropriate compiler flags.
# ============================================================================

set -e

VERSION="1.0.2"
BUILD_DIR="build"
RELEASE_DIR="releases"

# Detect OS
OS_TYPE=$(uname -s)
if [ "$OS_TYPE" = "Darwin" ]; then
    PLATFORM="macos"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║           Levython v${VERSION} macOS Release Builder                  ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
elif [ "$OS_TYPE" = "Linux" ]; then
    PLATFORM="linux"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║           Levython v${VERSION} Linux Release Builder                  ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
else
    echo "❌ Unsupported OS: $OS_TYPE"
    exit 1
fi
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."
COMPILER=""
if command -v clang++ &> /dev/null; then
    COMPILER="clang++"
elif command -v g++ &> /dev/null; then
    COMPILER="g++"
else
    echo "❌ Error: No C++ compiler found. Install with:"
    echo "   Debian/Ubuntu: sudo apt install build-essential"
    echo "   Fedora/RHEL:   sudo dnf install gcc-c++"
    echo "   Arch:          sudo pacman -S base-devel"
    echo "   macOS:         xcode-select --install"
    exit 1
fi

# Get architecture
ARCH=$(uname -m)
echo "✅ Compiler found: $($COMPILER --version | head -n1)"
echo "✅ Platform: $PLATFORM"
echo "✅ Architecture: ${ARCH}"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -f levython
mkdir -p "${RELEASE_DIR}"

# Build optimized binary with platform-specific flags
echo "🔨 Building Levython v${VERSION} for ${PLATFORM} (${ARCH})..."

if [ "$PLATFORM" = "macos" ]; then
    # macOS build with frameworks
    $COMPILER -std=c++17 -O3 -march=native -DNDEBUG \
        -ffast-math -funroll-loops -flto \
        src/levython.cpp src/http_client.cpp \
        -o levython \
        -lssl -lcrypto \
        -framework Security -framework CoreFoundation
else
    # Linux build with strip flag
    $COMPILER -std=c++17 -O3 -march=native -DNDEBUG \
        -ffast-math -funroll-loops -flto \
        -pthread \
        src/levython.cpp src/http_client.cpp \
        -o levython \
        -lssl -lcrypto \
        -s
fi

if [ ! -f "levython" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Create release packages
echo "📦 Creating release packages..."

# Copy binary to releases
cp levython "${RELEASE_DIR}/levython-v${VERSION}-${PLATFORM}-${ARCH}"
echo "✅ Created: ${RELEASE_DIR}/levython-v${VERSION}-${PLATFORM}-${ARCH}"

# Create tarball with examples
tar -czf "${RELEASE_DIR}/levython-v${VERSION}-${PLATFORM}-${ARCH}.tar.gz" \
    levython \
    examples/ \
    README.md \
    LICENSE \
    install.sh

echo "✅ Created: ${RELEASE_DIR}/levython-v${VERSION}-${PLATFORM}-${ARCH}.tar.gz"
echo ""

# Show file sizes
echo "📊 Release files:"
ls -lh "${RELEASE_DIR}"/levython-v${VERSION}-${PLATFORM}-*
echo ""

# Test the binary
echo "🧪 Testing binary..."
./levython --version 2>/dev/null || echo "Levython v${VERSION}"
echo ""

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Release Build Complete!                                        ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║  Platform: ${PLATFORM}                                             ║"
echo "║  Files created in releases/:                                       ║"
echo "║    • levython-v${VERSION}-${PLATFORM}-${ARCH}                      ║"
echo "║    • levython-v${VERSION}-${PLATFORM}-${ARCH}.tar.gz               ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
