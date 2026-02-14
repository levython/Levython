# ============================================================================
# LEVYTHON MAKEFILE - Cross-Platform Build System
# ============================================================================
# Supports: macOS, Linux, Windows (via MinGW/MSYS2)
# Version: 1.0.3
# ============================================================================

# Compiler configuration
CXX ?= clang++
CXXFLAGS ?= -std=c++17 -O3 -DNDEBUG
LDFLAGS ?=
SRC = src/levython.cpp src/http_client.cpp
OUT = levython
HTTP_LIBS = -lssl -lcrypto

# Detect platform
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Platform-specific configuration
ifeq ($(UNAME_S),Darwin)
    PLATFORM = macOS
    HTTP_LIBS += -framework Security -framework CoreFoundation -framework CoreGraphics -framework ApplicationServices -framework CoreAudio -framework AudioToolbox
    INSTALL_DIR = /usr/local/bin
    ifeq ($(UNAME_M),arm64)
        ARCH_FLAGS = -arch arm64
    else
        ARCH_FLAGS = -arch x86_64
    endif
else ifeq ($(UNAME_S),Linux)
    PLATFORM = Linux
    HTTP_LIBS += -lpthread -ldl -lasound -lX11 -lXtst
    INSTALL_DIR = /usr/local/bin
else ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
    PLATFORM = Windows
    OUT = levython.exe
    HTTP_LIBS += -lws2_32 -lcrypt32
    INSTALL_DIR = C:/Program Files/Levython
else ifeq ($(findstring MSYS,$(UNAME_S)),MSYS)
    PLATFORM = Windows
    OUT = levython.exe
    HTTP_LIBS += -lws2_32 -lcrypt32
    INSTALL_DIR = C:/Program Files/Levython
else ifeq ($(findstring CYGWIN,$(UNAME_S)),CYGWIN)
    PLATFORM = Windows
    OUT = levython.exe
    HTTP_LIBS += -lws2_32 -lcrypt32
    INSTALL_DIR = C:/Program Files/Levython
else
    PLATFORM = Unknown
    $(warning Warning: Unknown platform detected. Build may fail.)
endif

# Build targets
.PHONY: all terminal gui clean install uninstall help

# Default build (Terminal mode with HTTP)
all: terminal
	@echo ""
	@echo "✓ Levython 1.0.3 built successfully for $(PLATFORM)"
	@echo "  Run: ./$(OUT)"

terminal:
	@echo "Building Levython for $(PLATFORM) (Terminal Mode)..."
	$(CXX) $(CXXFLAGS) $(ARCH_FLAGS) $(SRC) -o $(OUT) $(LDFLAGS) $(HTTP_LIBS)

# GUI build (Requires SDL2)
gui: checks
	@echo "Building Levython for $(PLATFORM) (GUI Mode)..."
	$(CXX) $(CXXFLAGS) $(ARCH_FLAGS) -DENABLE_SDL $(SRC) -o $(OUT) $$(sdl2-config --cflags --libs) -lSDL2_image -lSDL2_mixer -lSDL2_ttf $(HTTP_LIBS)
	@echo "✓ GUI mode enabled. Run: ./$(OUT) examples/gui_demo.levy"

checks:
	@which sdl2-config > /dev/null || (echo "Error: SDL2 not found. Install with: brew install sdl2 sdl2_image sdl2_mixer sdl2_ttf (macOS) or apt install libsdl2-dev (Linux)" && exit 1)

# Install to system
install: terminal
	@echo "Installing Levython to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(OUT) $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/$(OUT)
	@echo "✓ Levython installed to $(INSTALL_DIR)/$(OUT)"
	@echo "  Make sure $(INSTALL_DIR) is in your PATH"

# Uninstall from system
uninstall:
	@echo "Removing Levython from $(INSTALL_DIR)..."
	@rm -f $(INSTALL_DIR)/$(OUT)
	@echo "✓ Levython uninstalled"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(OUT) levython.exe
	@echo "✓ Clean complete"

# Help message
help:
	@echo "Levython 1.0.3 - Cross-Platform Build System"
	@echo ""
	@echo "Detected Platform: $(PLATFORM)"
	@echo ""
	@echo "Available targets:"
	@echo "  make          - Build terminal mode (default)"
	@echo "  make terminal - Build terminal mode"
	@echo "  make gui      - Build with SDL2 GUI support"
	@echo "  make install  - Install to system"
	@echo "  make uninstall- Remove from system"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Build for current platform"
	@echo "  make CXX=g++            # Use GCC instead of Clang"
	@echo "  make CXXFLAGS='-O0 -g'  # Debug build"
	@echo ""
