#!/bin/bash
# ==============================================================================
# LEVYTHON INSTALLER
# ==============================================================================
# Cross-platform installation script for Levython programming language
# Supports: macOS, Linux (Ubuntu, Debian, Fedora, Arch), Windows (WSL/Git Bash)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/levython/Levython/main/install.sh | bash
#   OR
#   ./install.sh
#
# This script will:
#   1. Compile Levython from source
#   2. Install to ~/.levython/bin
#   3. Add to PATH automatically
#   4. Install LPM (Levython Package Manager)
#   5. Install VS Code extension (automatic!)
# ==============================================================================

set -e

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

# Print banner
print_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${GREEN}🚀 LEVYTHON INSTALLER${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ${YELLOW}The Future of Systems Programming${NC}                             ${CYAN}║${NC}"
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

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    OS="macos" ;;
        Linux*)     OS="linux" ;;
        MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
        *)          OS="unknown" ;;
    esac
    echo "$OS"
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

# Check for required tools
check_dependencies() {
    step "Checking dependencies..."
    
    # Check for C++ compiler
    if command -v clang++ &> /dev/null; then
        CXX="clang++"
        success "Found clang++"
    elif command -v g++ &> /dev/null; then
        CXX="g++"
        success "Found g++"
    else
        error "No C++ compiler found. Please install clang++ or g++"
    fi
    
    # Note: LPM is built into levython (native C++)
    success "All dependencies satisfied"
}

# Install dependencies based on OS
install_dependencies() {
    OS=$(detect_os)
    step "Installing dependencies for $OS..."
    
    case "$OS" in
        macos)
            if ! command -v clang++ &> /dev/null; then
                xcode-select --install 2>/dev/null || true
            fi
            ;;
        linux)
            if command -v apt-get &> /dev/null; then
                sudo apt-get update -qq
                sudo apt-get install -y -qq build-essential
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y gcc-c++ make
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm base-devel
            fi
            ;;
    esac
    
    success "Dependencies installed"
}

# Compile Levython
compile_levython() {
    step "Compiling Levython..."
    
    # Create directories
    mkdir -p "$BIN_DIR"
    mkdir -p "$PACKAGES_DIR"
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Always expect src/levython.cpp relative to script (works for curl install and local)
    if [ -f "$SCRIPT_DIR/src/levython.cpp" ]; then
        SRC_FILE="$SCRIPT_DIR/src/levython.cpp"
    else
        error "Cannot find src/levython.cpp. Please clone the Levython repository and run install.sh from the project root.\n\nExample:\n  git clone https://github.com/levython/Levython.git\n  cd Levython\n  ./install.sh"
    fi
    
    # Compile with optimizations
    OS=$(detect_os)
    
    if [ "$OS" = "macos" ]; then
        $CXX -std=c++17 -O3 -march=native -DNDEBUG \
            -o "$BIN_DIR/levython" "$SRC_FILE" 2>/dev/null
    else
        $CXX -std=c++17 -O3 -march=native -DNDEBUG \
            -o "$BIN_DIR/levython" "$SRC_FILE" 2>/dev/null
    fi
    
    if [ $? -eq 0 ]; then
        success "Compiled levython -> $BIN_DIR/levython"
    else
        error "Compilation failed"
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
            mkdir -p "$VSCODE_EXT_DIR/levython.levython-1.0.0"
            cp -r "$SCRIPT_DIR/vscode-levython/"* "$VSCODE_EXT_DIR/levython.levython-1.0.0/"
            success "VS Code extension installed!"
            echo -e "    ${BLUE}ℹ${NC} Restart VS Code to activate syntax highlighting"
        else
            # VS Code not found, copy to .levython folder for manual install
            mkdir -p "$INSTALL_DIR/vscode-extension"
            cp -r "$SCRIPT_DIR/vscode-levython/"* "$INSTALL_DIR/vscode-extension/"
            warn "VS Code not detected. Extension copied to ~/.levython/vscode-extension/"
            echo -e "    ${BLUE}ℹ${NC} To install manually: cp -r ~/.levython/vscode-extension ~/.vscode/extensions/levython.levython-1.0.0"
        fi
    else
        warn "VS Code extension not found in package"
    fi
}

# Add to PATH
setup_path() {
    step "Setting up PATH..."
    
    SHELL_NAME=$(detect_shell)
    PATH_LINE="export PATH=\"\$HOME/.levython/bin:\$PATH\""
    
    case "$SHELL_NAME" in
        zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bash_profile" ]; then
                RC_FILE="$HOME/.bash_profile"
            else
                RC_FILE="$HOME/.bashrc"
            fi
            ;;
        fish)
            RC_FILE="$HOME/.config/fish/config.fish"
            PATH_LINE="set -gx PATH \$HOME/.levython/bin \$PATH"
            mkdir -p "$HOME/.config/fish"
            ;;
    esac
    
    # Check if already in PATH
    if grep -q ".levython/bin" "$RC_FILE" 2>/dev/null; then
        success "PATH already configured in $RC_FILE"
    else
        echo "" >> "$RC_FILE"
        echo "# Levython Programming Language" >> "$RC_FILE"
        echo "$PATH_LINE" >> "$RC_FILE"
        success "Added to PATH in $RC_FILE"
    fi
    
    # Export for current session
    export PATH="$BIN_DIR:$PATH"
}

# Verify installation
verify_installation() {
    step "Verifying installation..."
    
    if [ -x "$BIN_DIR/levython" ]; then
        VERSION=$("$BIN_DIR/levython" --version 2>&1 | head -1)
        success "levython installed: $VERSION"
    else
        error "levython installation failed"
    fi
    
    if [ -x "$BIN_DIR/lpm" ]; then
        success "lpm installed"
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

# Main installation
main() {
    print_banner
    
    check_dependencies
    compile_levython
    install_lpm
    install_vscode_extension
    setup_path
    verify_installation
    
    print_completion
}

# Run main
main "$@"
