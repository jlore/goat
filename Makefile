# Thin wrapper around the CMake build used for the GOAT executable.
#
# Expected workflow:
#   source setup.csh
#   make
#   make goat_debug

.PHONY: all goat goat_debug clean cleanbuilds deepclean legacy

CMAKE ?= cmake
RELEASE_BUILD_DIR := build-cmake/release
DEBUG_BUILD_DIR := build-cmake/debug

all: goat

goat:
	$(CMAKE) -S . -B $(RELEASE_BUILD_DIR) -DCMAKE_BUILD_TYPE=Release -DGOAT_OUTPUT_NAME=goat.exe
	$(CMAKE) --build $(RELEASE_BUILD_DIR) --target goat
	mkdir -p executables
	cp $(RELEASE_BUILD_DIR)/goat.exe executables/goat.exe

goat_debug:
	$(CMAKE) -S . -B $(DEBUG_BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug -DGOAT_OUTPUT_NAME=goat_debug.exe
	$(CMAKE) --build $(DEBUG_BUILD_DIR) --target goat
	mkdir -p executables
	cp $(DEBUG_BUILD_DIR)/goat_debug.exe executables/goat_debug.exe

clean:
	$(CMAKE) --build $(RELEASE_BUILD_DIR) --target clean || true
	$(CMAKE) --build $(DEBUG_BUILD_DIR) --target clean || true

cleanbuilds:
	rm -rf build-cmake

deepclean: cleanbuilds
	rm -rf executables/goat.exe executables/goat_debug.exe

legacy:
	$(MAKE) -f Makefile.legacy goat
