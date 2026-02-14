#!/bin/bash
# ==============================================================================
# LEVYTHON INSTALLER - Enhanced Edition
# ==============================================================================
# Cross-platform installation script for Levython programming language
# Supports: macOS, Linux (Ubuntu, Debian, Fedora, Arch), Windows (WSL/Git Bash/MSYS2)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/levython/Levython/main/install.sh | bash
#   OR
#   ./install.sh [options]
#
# Options:
#   --help, -h     Show this help message
#   --force        Force reinstallation even if already installed
#   --no-path      Skip PATH configuration
#   --no-vscode    Skip VS Code extension installation
#   --compiler=X   Use specific compiler (clang++, g++, etc.)
#
# This script will:
#   1. Check system requirements and install dependencies if needed
#   2. Compile Levython from source with optimizations
#   3. Install to ~/.levython/bin
#   4. Configure PATH automatically 
#   5. Install LPM (Levython Package Manager)
#   6. Install VS Code extension (if available)
# ==============================================================================

set -e

# Parse command line arguments
FORCE_INSTALL=false
NO_PATH=false
NO_VSCODE=false
SPECIFIED_COMPILER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            echo "Levython Installer"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --force        Force reinstallation"
            echo "  --no-path      Skip PATH configuration"
            echo "  --no-vscode    Skip VS Code extension"
            echo "  --compiler=X   Use specific compiler"
            echo ""
            echo "Environment Variables:"
            echo "  CXX            C++ compiler to use"
            echo "  PREFIX         Installation prefix (default: ~/.levython)"
            echo ""
            exit 0
            ;;
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        --no-path)
            NO_PATH=true
            shift
            ;;
        --no-vscode)
            NO_VSCODE=true
            shift
            ;;
        --compiler=*)
            SPECIFIED_COMPILER="${1#*=}"
            shift
            ;;
        *)
            warn "Unknown option: $1"
            shift
            ;;
    esac
done

# Allow override of install directory
if [ -n "$PREFIX" ]; then
    INSTALL_DIR="$PREFIX"
    BIN_DIR="$INSTALL_DIR/bin"
    PACKAGES_DIR="$INSTALL_DIR/packages"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.levython"
BIN_DIR="$INSTALL_DIR/bin"
PACKAGES_DIR="$INSTALL_DIR/packages"

# Global variables
CXX=""
OS=""
ANIM_PID=""

# Cleanup function for graceful exit
cleanup() {
    local exit_code=$?
    rm -f /tmp/test_cpp17_$$ /tmp/march_test$$ compile_error.log 2>/dev/null
    # Kill background animation if running
    if [ -n "$ANIM_PID" ]; then
        kill $ANIM_PID 2>/dev/null
        wait $ANIM_PID 2>/dev/null
    fi
    if [ $exit_code -ne 0 ]; then
        echo ""
        error "Installation failed. Check the error messages above."
    fi
    exit $exit_code
}

# Braille loading animation
show_loading_animation() {
    local message="$1"
    local braille_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    
    while true; do
        printf "\r${BLUE}${braille_chars[$i]}${NC} $message"
        i=$(( (i + 1) % ${#braille_chars[@]} ))
        sleep 0.1
    done
}

# Stop loading animation
stop_loading_animation() {
    if [ -n "$ANIM_PID" ]; then
        kill $ANIM_PID 2>/dev/null
        wait $ANIM_PID 2>/dev/null
        printf "\r\033[K"  # Clear the line
    fi
    ANIM_PID=""
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Print banner
print_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${GREEN}🚀 LEVYTHON INSTALLER v1.0.3${NC}                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ${YELLOW}Be better than yesterday${NC}                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print step
step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Print warning
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Print error
error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# Detect OS with better Windows support
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Detect Windows environment more precisely
detect_windows_env() {
    if [ -n "$MSYSTEM" ]; then
        echo "msys2"  # MSYS2 environment
    elif [ -n "$MINGW_PREFIX" ]; then
        echo "mingw"  # MinGW environment
    elif command -v cygpath &> /dev/null; then
        echo "cygwin"  # Cygwin environment
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"     # Windows Subsystem for Linux
    else
        echo "native"  # Native Windows (Git Bash, etc.)
    fi
}

# Detect shell
detect_shell() {
    case "$SHELL" in
        */zsh)  echo "zsh" ;;
        */bash) echo "bash" ;;
        */fish) echo "fish" ;;
        *)      echo "bash" ;;
    esac
}

# Check compiler version and C++17 support
check_compiler_version() {
    local compiler="$1"
    local min_version="$2"
    
    if ! command -v "$compiler" &> /dev/null; then
        return 1
    fi
    
    # Test C++17 support
    local test_file="/tmp/test_cpp17_$$.cpp"
    cat > "$test_file" << 'EOF'
#include <iostream>
#include <optional>
int main() {
    std::optional<int> x = 42;
    return x.has_value() ? 0 : 1;
}
EOF
    
    if "$compiler" -std=c++17 -o "/tmp/test_cpp17_$$" "$test_file" &>/dev/null; then
        rm -f "$test_file" "/tmp/test_cpp17_$$" 2>/dev/null
        return 0
    else
        rm -f "$test_file" "/tmp/test_cpp17_$$" 2>/dev/null
        return 1
    fi
}

# Check for required tools
check_dependencies() {
    step "Checking dependencies..."
    
    CXX=""
    
    # Check for C++ compiler with version validation
    if check_compiler_version "clang++" "9.0"; then
        CXX="clang++"
        local version=$(clang++ --version | head -1)
        success "Found clang++: $version"
    elif check_compiler_version "g++" "7.0"; then
        CXX="g++"
        local version=$(g++ --version | head -1)
        success "Found g++: $version"
    elif command -v clang++ &> /dev/null; then
        warn "clang++ found but C++17 support test failed"
        CXX="clang++"
    elif command -v g++ &> /dev/null; then
        warn "g++ found but C++17 support test failed"
        CXX="g++"
    else
        error "No suitable C++ compiler found. Please install:
  • macOS: xcode-select --install
  • Ubuntu/Debian: sudo apt install build-essential
  • Fedora: sudo dnf install gcc-c++
  • Arch: sudo pacman -S base-devel
  • Windows: Install Visual Studio or MinGW"
    fi
    
    # Additional checks
    if ! command -v make &> /dev/null && [ "$(detect_os)" != "windows" ]; then
        warn "make not found - some features may not work"
    fi
    
    success "Dependencies check completed"
}

# Install dependencies based on OS with error recovery
install_dependencies() {
    OS=$(detect_os)
    step "Installing dependencies for $OS..."
    
    case "$OS" in
        macos)
            if ! check_compiler_version "clang++" "9.0"; then
                step "Installing Xcode Command Line Tools..."
                if ! xcode-select --install 2>/dev/null; then
                    if xcode-select -p &>/dev/null; then
                        warn "Xcode Command Line Tools already installed but may need update"
                        warn "Run: sudo xcode-select --reset"
                    fi
                fi
                # Wait a bit and recheck
                sleep 2
                if ! check_compiler_version "clang++" "9.0"; then
                    error "Failed to install suitable C++ compiler. Please install Xcode or Command Line Tools manually."
                fi
            fi
            ;;
        linux|wsl)
            local installed=false
            if command -v apt-get &> /dev/null; then
                step "Installing via apt-get..."
                if sudo apt-get update -qq && sudo apt-get install -y -qq build-essential; then
                    installed=true
                else
                    warn "apt-get installation failed, trying alternative packages"
                    sudo apt-get install -y -qq gcc g++ make libc6-dev || true
                fi
            elif command -v dnf &> /dev/null; then
                step "Installing via dnf..."
                if sudo dnf install -y gcc-c++ make; then
                    installed=true
                fi
            elif command -v yum &> /dev/null; then
                step "Installing via yum..."
                if sudo yum groupinstall -y "Development Tools"; then
                    installed=true
                fi
            elif command -v pacman &> /dev/null; then
                step "Installing via pacman..."
                if sudo pacman -S --noconfirm base-devel; then
                    installed=true
                fi
            elif command -v zypper &> /dev/null; then
                step "Installing via zypper..."
                if sudo zypper install -y gcc-c++ make; then
                    installed=true
                fi
            elif command -v apk &> /dev/null; then
                step "Installing via apk..."
                if sudo apk add build-base; then
                    installed=true
                fi
            fi
            
            if ! $installed; then
                warn "Could not auto-install dependencies. Please install manually:"
                warn "  Ubuntu/Debian: sudo apt install build-essential"
                warn "  Fedora: sudo dnf install gcc-c++ make"
                warn "  Arch: sudo pacman -S base-devel"
            fi
            ;;
        windows)
            local win_env=$(detect_windows_env)
            case "$win_env" in
                "msys2")
                    if command -v pacman &> /dev/null; then
                        pacman -S --noconfirm mingw-w64-x86_64-gcc || warn "Failed to install gcc via pacman"
                    fi
                    ;;
                *)
                    warn "Windows detected. Please ensure you have a C++ compiler installed:"
                    warn "  • Visual Studio Community (recommended)"
                    warn "  • MinGW-w64"
                    warn "  • MSYS2 with development tools"
                    ;;
            esac
            ;;
    esac
    
    # Re-check after installation attempt
    if ! command -v "$CXX" &> /dev/null; then
        check_dependencies
    fi
    
    success "Dependencies installation completed"
}

# Compile Levython with enhanced error handling
compile_levython() {
    step "Compiling Levython..."
    
    # Create directories
    mkdir -p "$BIN_DIR"
    mkdir -p "$PACKAGES_DIR"
    
    # Get script directory and source file
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$SCRIPT_DIR/src/levython.cpp" ]; then
        SRC_FILE="$SCRIPT_DIR/src/levython.cpp"
    else
        step "Source not found. Cloning Levython repository..."
        CLONE_DIR="$HOME/Levython"
        if [ -d "$CLONE_DIR" ]; then
            warn "Directory $CLONE_DIR already exists. Updating..."
            cd "$CLONE_DIR" && git pull --depth=1 origin main 2>/dev/null || true
        else
            if ! git clone --depth=1 https://github.com/levython/Levython.git "$CLONE_DIR"; then
                error "Failed to clone repository. Check internet connection."
            fi
        fi
        cd "$CLONE_DIR"
        exec bash install.sh "$@"
        exit 1
    fi
    
    # Verify source file exists and is readable
    if [ ! -r "$SRC_FILE" ]; then
        error "Source file not found or not readable: $SRC_FILE"
    fi
    
    # Determine optimal compilation flags
    OS=$(detect_os)
    COMPILE_FLAGS="-std=c++17 -O3 -DNDEBUG"
    SRC_FILES="$SRC_FILE"
    LINK_LIBS="-lssl -lcrypto"
    
    # Test if march=native works
    if echo 'int main(){}' | $CXX -x c++ -march=native - -o /tmp/march_test$$ 2>/dev/null; then
        COMPILE_FLAGS="$COMPILE_FLAGS -march=native"
        rm -f /tmp/march_test$$
    else
        warn "march=native not supported, using generic optimization"
    fi
    
    # Platform-specific adjustments
    case "$OS" in
        "windows")
            # Windows may need static linking
            COMPILE_FLAGS="$COMPILE_FLAGS -static-libgcc -static-libstdc++"
            ;;
        "macos")
            # macOS optimizations
            COMPILE_FLAGS="$COMPILE_FLAGS -mmacosx-version-min=10.14"
            LINK_LIBS="$LINK_LIBS -framework Security -framework CoreFoundation -framework CoreGraphics -framework CoreAudio -framework AudioToolbox"
            ;;
    esac

    # HTTP client is implemented in a separate translation unit
    if [ -f "$SCRIPT_DIR/src/http_client.cpp" ]; then
        SRC_FILES="$SRC_FILES $SCRIPT_DIR/src/http_client.cpp"
    fi
    
    # Try compilation with multiple fallback strategies
    local compiled=false
    local output_file="$BIN_DIR/levython"
    
    # Strategy 1: Full optimization
    step "Compiling Levython with full optimizations..."
    show_loading_animation "Compiling Levython (this may take a minute)..." &
    ANIM_PID=$!
    
    if $CXX $COMPILE_FLAGS -o "$output_file" $SRC_FILES $LINK_LIBS 2>/dev/null; then
        stop_loading_animation
        compiled=true
        success "Compiled with full optimizations"
    else
        stop_loading_animation
        warn "Optimized compilation failed, trying with reduced optimization..."
        
        # Strategy 2: Reduced optimization
        COMPILE_FLAGS="-std=c++17 -O2 -DNDEBUG"
        show_loading_animation "Compiling with reduced optimization..." &
        ANIM_PID=$!
        
        if $CXX $COMPILE_FLAGS -o "$output_file" $SRC_FILES $LINK_LIBS 2>/dev/null; then
            stop_loading_animation
            compiled=true
            success "Compiled with reduced optimization"
        else
            stop_loading_animation
            warn "O2 compilation failed, trying basic compilation..."
            
            # Strategy 3: Basic compilation
            COMPILE_FLAGS="-std=c++17"
            show_loading_animation "Compiling with basic flags..." &
            ANIM_PID=$!
            
            if $CXX $COMPILE_FLAGS -o "$output_file" $SRC_FILES $LINK_LIBS 2>compile_error.log; then
                stop_loading_animation
                compiled=true
                warn "Compiled with basic flags (no optimization)"
            else
                stop_loading_animation
                # Strategy 4: Show detailed error and suggest fixes
                error "Compilation failed. Error details:\n$(cat compile_error.log 2>/dev/null || echo 'No error log available')\n\nTroubleshooting:\n  1. Ensure C++17 support: $CXX -std=c++17 --version\n  2. Check disk space: df -h\n  3. Verify source integrity: wc -l $SRC_FILE\n  4. Try manual compilation: $CXX -std=c++17 -o levython $SRC_FILES $LINK_LIBS"
            fi
        fi
    fi
    
    # Cleanup and verify
    rm -f compile_error.log 2>/dev/null
    
    if $compiled && [ -x "$output_file" ]; then
        success "Compiled levython -> $output_file"
        # Test the binary
        if "$output_file" --version >/dev/null 2>&1; then
            success "Binary verification passed"
        else
            warn "Binary compiled but version check failed - may still work"
        fi
    else
        error "Compilation failed completely"
    fi
}

# Install LPM (symlink to levython lpm)
install_lpm() {
    step "Setting up LPM (Levython Package Manager)..."
    
    # Create lpm as a wrapper script that calls levython lpm
    cat > "$BIN_DIR/lpm" << 'EOF'
#!/bin/bash
# LPM - Levython Package Manager
# This is a wrapper that calls the native LPM built into levython
exec "$HOME/.levython/bin/levython" lpm "$@"
EOF
    chmod +x "$BIN_DIR/lpm"
    success "Installed lpm -> $BIN_DIR/lpm (native C++, no Python!)"
}

# Install VS Code Extension
install_vscode_extension() {
    step "Installing VS Code extension..."
    
    # Check if VS Code is installed
    VSCODE_EXT_DIR=""
    
    if [ -d "$HOME/.vscode/extensions" ]; then
        VSCODE_EXT_DIR="$HOME/.vscode/extensions"
    elif [ -d "$HOME/.vscode-server/extensions" ]; then
        VSCODE_EXT_DIR="$HOME/.vscode-server/extensions"
    elif [ -d "$HOME/Library/Application Support/Code/User/extensions" ]; then
        VSCODE_EXT_DIR="$HOME/Library/Application Support/Code/User/extensions"
    fi
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check if vscode-levython folder exists
    if [ -d "$SCRIPT_DIR/vscode-levython" ]; then
        if [ -n "$VSCODE_EXT_DIR" ]; then
            # Copy extension to VS Code extensions folder
            mkdir -p "$VSCODE_EXT_DIR/levython.levython-1.0.3"
            cp -r "$SCRIPT_DIR/vscode-levython/"* "$VSCODE_EXT_DIR/levython.levython-1.0.3/"
            success "VS Code extension installed!"
            echo -e "    ${BLUE}ℹ${NC} Restart VS Code to activate syntax highlighting"
        else
            # VS Code not found, copy to .levython folder for manual install
            mkdir -p "$INSTALL_DIR/vscode-extension"
            cp -r "$SCRIPT_DIR/vscode-levython/"* "$INSTALL_DIR/vscode-extension/"
            warn "VS Code not detected. Extension copied to ~/.levython/vscode-extension/"
            echo -e "    ${BLUE}ℹ${NC} To install manually: cp -r ~/.levython/vscode-extension ~/.vscode/extensions/levython.levython-1.0.3"
        fi
    else
        warn "VS Code extension not found in package"
    fi
}

# Install file type icons for .levy files in all icon themes
install_file_icons() {
    step "Installing file type icons..."
    
    local OS=$(detect_os)
    
    # Only install icons on Linux with desktop environment
    if [ "$OS" != "linux" ]; then
        warn "Icon installation is only supported on Linux desktop environments"
        return
    fi
    
    # Check if we have icon files
    local ICON_DIR="$SCRIPT_DIR/icons"
    if [ ! -d "$ICON_DIR" ]; then
        # Create default icon if not exists
        mkdir -p "$INSTALL_DIR/share/icons"
        
        # Create SVG icon (simple document icon with "LY")
        cat > "$INSTALL_DIR/share/icons/text-x-levython.svg" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" rx="8" fill="#4A90E2"/>
  <text x="32" y="44" font-family="Arial" font-size="24" font-weight="bold" fill="white" text-anchor="middle">LY</text>
</svg>
EOF
        ICON_DIR="$INSTALL_DIR/share/icons"
    fi
    
    # Find all icon theme directories
    local ICON_THEME_DIRS=(
        "$HOME/.local/share/icons"
        "$HOME/.icons"
        "/usr/share/icons"
        "/usr/local/share/icons"
    )
    
    local installed_count=0
    
    for theme_base in "${ICON_THEME_DIRS[@]}"; do
        if [ -d "$theme_base" ]; then
            # Find all theme directories
            for theme_dir in "$theme_base"/*; do
                if [ -d "$theme_dir" ]; then
                    # Inject icon into each theme's mimetypes directory
                    for size_dir in "$theme_dir"/{scalable,48x48,32x32,24x24,22x22,16x16}; do
                        local mimetype_dir="$size_dir/mimetypes"
                        
                        # Create directory if writable
                        if [ -w "$(dirname "$size_dir")" ] || [ -w "$size_dir" ]; then
                            mkdir -p "$mimetype_dir" 2>/dev/null
                            
                            if [ -w "$mimetype_dir" ]; then
                                # Copy icon
                                cp "$ICON_DIR/text-x-levython.svg" "$mimetype_dir/" 2>/dev/null && \
                                    installed_count=$((installed_count + 1))
                                
                                # Also create PNG versions for non-scalable
                                if [ -f "$ICON_DIR/text-x-levython.png" ]; then
                                    cp "$ICON_DIR/text-x-levython.png" "$mimetype_dir/" 2>/dev/null
                                fi
                            fi
                        fi
                    done
                fi
            done
        fi
    done
    
    # Update icon caches
    if command -v gtk-update-icon-cache &> /dev/null; then
        for theme_base in "${ICON_THEME_DIRS[@]}"; do
            if [ -d "$theme_base" ]; then
                for theme_dir in "$theme_base"/*; do
                    if [ -w "$theme_dir" ]; then
                        gtk-update-icon-cache -f -t "$theme_dir" 2>/dev/null
                    fi
                done
            fi
        done
    fi
    
    # Install MIME type definition
    local MIME_DIR="$HOME/.local/share/mime/packages"
    mkdir -p "$MIME_DIR"
    
    cat > "$MIME_DIR/levython.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="text/x-levython">
    <comment>Levython source code</comment>
    <glob pattern="*.levy"/>
    <glob pattern="*.ly"/>
    <icon name="text-x-levython"/>
  </mime-type>
</mime-info>
EOF
    
    # Update MIME database
    if command -v update-mime-database &> /dev/null; then
        update-mime-database "$HOME/.local/share/mime" 2>/dev/null
    fi
    
    # Install desktop file association
    local DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    
    cat > "$DESKTOP_DIR/levython.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Levython
Comment=Run Levython scripts
Exec=$BIN_DIR/levython %F
Icon=text-x-levython
Terminal=true
Categories=Development;Programming;
MimeType=text/x-levython;
StartupNotify=false
EOF
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null
    fi
    
    if [ $installed_count -gt 0 ]; then
        success "Injected Levython icons into $installed_count icon theme locations"
        success "Registered .levy and .ly file types"
    else
        warn "Could not inject icons (insufficient permissions or no themes found)"
        echo -e "    ${BLUE}ℹ${NC} Icons saved to: $INSTALL_DIR/share/icons/"
    fi
}

# Add to PATH with enhanced Windows support
setup_path() {
    step "Setting up PATH..."
    
    local OS=$(detect_os)
    SHELL_NAME=$(detect_shell)
    PATH_LINE="export PATH=\"\$HOME/.levython/bin:\$PATH\""
    
    # Handle different environments
    if [ "$OS" = "windows" ] || [ "$OS" = "wsl" ]; then
        setup_windows_path
        return
    fi
    
    case "$SHELL_NAME" in
        zsh)
            RC_FILE="$HOME/.zshrc"
            # Also check .zprofile for macOS
            if [ "$OS" = "macos" ] && [ -f "$HOME/.zprofile" ]; then
                setup_shell_path "$HOME/.zprofile"
            fi
            ;;
        bash)
            if [ -f "$HOME/.bash_profile" ]; then
                RC_FILE="$HOME/.bash_profile"
            elif [ -f "$HOME/.profile" ]; then
                RC_FILE="$HOME/.profile"
            else
                RC_FILE="$HOME/.bashrc"
                # Ensure .bashrc is sourced from .bash_profile
                if [ ! -f "$HOME/.bash_profile" ]; then
                    echo '[ -f ~/.bashrc ] && source ~/.bashrc' > "$HOME/.bash_profile"
                fi
            fi
            ;;
        fish)
            RC_FILE="$HOME/.config/fish/config.fish"
            PATH_LINE="set -gx PATH \$HOME/.levython/bin \$PATH"
            mkdir -p "$HOME/.config/fish"
            ;;
        *)
            RC_FILE="$HOME/.profile"
            ;;
    esac
    
    setup_shell_path "$RC_FILE"
    
    # Export for current session
    export PATH="$BIN_DIR:$PATH"
}

# Setup shell PATH helper
setup_shell_path() {
    local rc_file="$1"
    
    # Create file if it doesn't exist
    touch "$rc_file"
    
    # Check if already in PATH
    if grep -q ".levython/bin" "$rc_file" 2>/dev/null; then
        success "PATH already configured in $rc_file"
    else
        echo "" >> "$rc_file"
        echo "# Levython Programming Language" >> "$rc_file"
        echo "$PATH_LINE" >> "$rc_file"
        success "Added to PATH in $rc_file"
    fi
}

# Windows-specific PATH setup
setup_windows_path() {
    local win_env=$(detect_windows_env)
    
    case "$win_env" in
        "wsl")
            # WSL: Standard Unix approach
            setup_shell_path "$HOME/.bashrc"
            # Also try to add to Windows PATH if possible
            if command -v powershell.exe &> /dev/null; then
                local win_path=$(powershell.exe -c "[System.Environment]::GetEnvironmentVariable('PATH', 'User')" 2>/dev/null | tr -d '\r')
                local levy_path="%USERPROFILE%\\.levython\\bin"
                if [[ "$win_path" != *"$levy_path"* ]]; then
                    warn "Consider adding to Windows PATH: $levy_path"
                fi
            fi
            ;;
        "msys2"|"mingw")
            # MSYS2/MinGW: Use their profile
            local msys_profile="$HOME/.bash_profile"
            [ ! -f "$msys_profile" ] && msys_profile="$HOME/.bashrc"
            setup_shell_path "$msys_profile"
            ;;
        "cygwin")
            # Cygwin: Standard approach
            setup_shell_path "$HOME/.bashrc"
            ;;
        *)
            # Git Bash or other: Try multiple locations
            local git_bash_profile="$HOME/.bash_profile"
            if [ ! -f "$git_bash_profile" ]; then
                git_bash_profile="$HOME/.bashrc"
            fi
            setup_shell_path "$git_bash_profile"
            
            # Try to detect and suggest Windows PATH addition
            warn "For persistent PATH on Windows, consider adding to System Environment Variables:"
            warn "  Path: %USERPROFILE%\\.levython\\bin"
            ;;
    esac
}

# Verify installation with comprehensive checks
verify_installation() {
    step "Verifying installation..."
    
    local success_count=0
    local total_checks=3
    
    # Check 1: Binary exists and is executable
    if [ -x "$BIN_DIR/levython" ]; then
        success "✓ levython binary is executable"
        ((success_count++))
        
        # Check version output
        local version_output
        if version_output=$("$BIN_DIR/levython" --version 2>&1); then
            success "✓ Version: $(echo "$version_output" | head -1)"
            ((success_count++))
        else
            warn "✗ Version check failed: $version_output"
        fi
    else
        error "✗ levython binary not found or not executable at $BIN_DIR/levython"
    fi
    
    # Check 2: LPM wrapper
    if [ -x "$BIN_DIR/lpm" ]; then
        success "✓ lpm wrapper installed"
        ((success_count++))
    else
        warn "✗ lpm wrapper missing"
    fi
    
    # Check 3: PATH configuration
    if command -v levython &> /dev/null; then
        success "✓ levython is in PATH"
    else
        warn "✗ levython not found in PATH (may need to restart terminal)"
        echo "  Current PATH includes: $(echo $PATH | tr ':' '\n' | grep -E '(levython|\.levython)' || echo 'No levython paths found')"
    fi
    
    # Summary
    echo ""
    if [ $success_count -eq $total_checks ]; then
        success "All verification checks passed ($success_count/$total_checks)"
    elif [ $success_count -gt 0 ]; then
        warn "Partial installation success ($success_count/$total_checks checks passed)"
    else
        error "Installation verification failed (0/$total_checks checks passed)"
    fi
}

# Print completion message
print_completion() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}     ${GREEN}✓ INSTALLATION COMPLETE!${NC}                                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}To get started:${NC}"
    echo ""
    echo -e "    ${YELLOW}1.${NC} Restart your terminal or run:"
    echo -e "       ${GREEN}source ~/.$(detect_shell)rc${NC}"
    echo ""
    echo -e "    ${YELLOW}2.${NC} Create your first program:"
    echo -e "       ${GREEN}echo 'say(\"Hello, Levython!\")' > hello.levy${NC}"
    echo ""
    echo -e "    ${YELLOW}3.${NC} Run it:"
    echo -e "       ${GREEN}levython hello.levy${NC}"
    echo ""
    echo -e "    ${YELLOW}4.${NC} Install packages:"
    echo -e "       ${GREEN}lpm install math tensor ml${NC}"
    echo ""
    echo -e "  ${CYAN}VS Code:${NC} Restart VS Code for syntax highlighting"
    echo -e "  ${CYAN}Docs:${NC} https://github.com/levython/Levython"
    echo ""
}

# Main installation with enhanced error handling
main() {
    print_banner
    
    # Check if already installed
    if [ -x "$BIN_DIR/levython" ] && [ "$FORCE_INSTALL" = false ]; then
        warn "Levython appears to already be installed at $BIN_DIR/levython"
        read -p "Do you want to reinstall? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            step "Verifying existing installation..."
            verify_installation
            exit 0
        fi
    fi
    
    # Use specified compiler if provided
    if [ -n "$SPECIFIED_COMPILER" ]; then
        if command -v "$SPECIFIED_COMPILER" &> /dev/null; then
            CXX="$SPECIFIED_COMPILER"
            success "Using specified compiler: $SPECIFIED_COMPILER"
        else
            error "Specified compiler not found: $SPECIFIED_COMPILER"
        fi
    fi
    
    # Installation steps with error recovery
    local failed_steps=()
    
    # Step 1: Check dependencies
    if ! check_dependencies; then
        failed_steps+=("dependency_check")
        step "Attempting to install missing dependencies..."
        install_dependencies
        # Retry dependency check
        if ! check_dependencies; then
            failed_steps+=("dependency_install")
            error "Failed to satisfy dependencies. Please install manually and try again."
        fi
    fi
    
    # Step 2: Compilation
    if ! compile_levython; then
        failed_steps+=("compilation")
        error "Compilation failed. Check the error messages above."
    fi
    
    # Step 3: Setup components (these are optional, failures won't stop installation)
    install_lpm || warn "LPM installation failed"
    if [ "$NO_VSCODE" = false ]; then
        install_vscode_extension || warn "VS Code extension installation failed"
    else
        step "Skipping VS Code extension installation (--no-vscode specified)"
    fi
    
    # Install file type icons (Linux only)
    install_file_icons || warn "Icon installation failed (this is optional)"
    
    # Step 4: PATH setup
    if [ "$NO_PATH" = false ]; then
        if ! setup_path; then
            failed_steps+=("path_setup")
            warn "PATH setup failed - you may need to add $BIN_DIR to PATH manually"
        fi
    else
        step "Skipping PATH configuration (--no-path specified)"
        warn "Remember to add $BIN_DIR to your PATH manually"
    fi
    
    # Step 5: Verification
    verify_installation
    
    # Summary
    if [ ${#failed_steps[@]} -eq 0 ]; then
        print_completion
    else
        echo ""
        warn "Installation completed with some issues:"
        for step in "${failed_steps[@]}"; do
            warn "  - $step failed"
        done
        echo ""
        echo -e "${CYAN}Troubleshooting:${NC}"
        echo -e "  1. Check error messages above"
        echo -e "  2. Ensure you have a C++17 compatible compiler"
        echo -e "  3. Try manual compilation: $CXX -std=c++17 -o levython src/levython.cpp"
        echo -e "  4. Add to PATH manually: export PATH=\"$BIN_DIR:\$PATH\""
    fi
}

# Run main
main "$@"
