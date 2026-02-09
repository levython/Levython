CXX ?= clang++
CXXFLAGS ?= -std=c++17 -O3 -DNDEBUG
LDFLAGS ?=
SRC = src/levython.cpp src/http_client.cpp
OUT = levython
HTTP_LIBS = -lssl -lcrypto

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
HTTP_LIBS += -framework Security -framework CoreFoundation
endif

# Default build (Terminal only with HTTP)
all: terminal

terminal:
	$(CXX) $(CXXFLAGS) $(SRC) -o $(OUT) $(LDFLAGS) $(HTTP_LIBS)
	@echo "Built levython (Terminal Mode with HTTP). Run ./levython"

# GUI build (Requires SDL2)
gui: checks
	$(CXX) $(CXXFLAGS) -DENABLE_SDL $(SRC) -o $(OUT) $$(sdl2-config --cflags --libs) -lSDL2_image -lSDL2_mixer -lSDL2_ttf $(HTTP_LIBS)
	@echo "Built levython (GUI Mode with HTTP). Run ./levython examples/gui_demo.levy"

checks:
	@which sdl2-config > /dev/null || (echo "Error: SDL2 not found. Run 'brew install sdl2 sdl2_image sdl2_mixer sdl2_ttf'" && exit 1)

clean:
	rm -f $(OUT)
