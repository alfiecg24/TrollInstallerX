# Makefile for libdmaFail.dylib
# Standalone dmaFail PPL bypass library

# Project configuration
PROJECT_NAME = libdmaFail
VERSION = 1.0.0
DYLIB_NAME = $(PROJECT_NAME).dylib

# Paths
SRCDIR = ../TrollInstallerX/Exploitation
DMAFAIL_DIR = $(SRCDIR)/dmaFail
LIBJB_DIR = $(SRCDIR)/libjailbreak
EXTERNAL_DIR = ../TrollInstallerX/External

# Compiler and flags
CC = clang
CFLAGS = -Wall -Wextra -O2 -fPIC -arch arm64 -arch arm64e
CFLAGS += -miphoneos-version-min=14.0
CFLAGS += -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path)
CFLAGS += -fobjc-arc

# Include paths
INCLUDES = -I. \
           -I$(DMAFAIL_DIR) \
           -I$(LIBJB_DIR) \
           -I$(SRCDIR) \
           -I$(EXTERNAL_DIR)/include

# Linker flags
LDFLAGS = -dynamiclib -install_name @rpath/$(DYLIB_NAME)
LDFLAGS += -compatibility_version $(VERSION) -current_version $(VERSION)
LDFLAGS += -arch arm64 -arch arm64e
LDFLAGS += -miphoneos-version-min=14.0
LDFLAGS += -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path)

# External libraries
LIBS = -L$(EXTERNAL_DIR)/lib -lchoma -lgrabkernel2 -lpartial
LIBS += -framework Foundation -framework IOKit -framework CoreFoundation

# Source files
DMAFAIL_SOURCES = $(DMAFAIL_DIR)/dmaFail.c

# libjailbreak sources (static linking - only what's needed for dmaFail)
LIBJB_SOURCES = $(LIBJB_DIR)/info.c \
                $(LIBJB_DIR)/kernel.c \
                $(LIBJB_DIR)/primitives.c \
                $(LIBJB_DIR)/translation.c \
                $(LIBJB_DIR)/util.c \
                $(LIBJB_DIR)/util.m

# Wrapper source
WRAPPER_SOURCE = libdmaFail_wrapper.c

# All sources
SOURCES = $(DMAFAIL_SOURCES) $(LIBJB_SOURCES) $(WRAPPER_SOURCE)

# Object files
OBJECTS = $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.m=.o)

# Default target
all: $(DYLIB_NAME)

# Create wrapper source file
$(WRAPPER_SOURCE):
	@echo "Creating wrapper source file..."
	@echo '#include "libdmaFail.h"' > $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/dmaFail/dmaFail.h"' >> $(WRAPPER_SOURCE)
	@echo '#include <sys/sysctl.h>' >> $(WRAPPER_SOURCE)
	@echo '#include <string.h>' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Version information' >> $(WRAPPER_SOURCE)
	@echo 'const char* dmafail_get_version(void) { return "1.0.0"; }' >> $(WRAPPER_SOURCE)
	@echo 'const char* dmafail_get_build_info(void) { return "Built on " __DATE__ " " __TIME__; }' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Error strings' >> $(WRAPPER_SOURCE)
	@echo 'const char* dmafail_get_error_string(int error_code) {' >> $(WRAPPER_SOURCE)
	@echo '    switch (error_code) {' >> $(WRAPPER_SOURCE)
	@echo '        case 0: return "Success";' >> $(WRAPPER_SOURCE)
	@echo '        case -1: return "Initialization failed";' >> $(WRAPPER_SOURCE)
	@echo '        case -2: return "Device not supported";' >> $(WRAPPER_SOURCE)
	@echo '        case -3: return "Invalid address";' >> $(WRAPPER_SOURCE)
	@echo '        case -4: return "Write operation failed";' >> $(WRAPPER_SOURCE)
	@echo '        case -5: return "Hardware error";' >> $(WRAPPER_SOURCE)
	@echo '        default: return "Unknown error";' >> $(WRAPPER_SOURCE)
	@echo '    }' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Wrapper functions' >> $(WRAPPER_SOURCE)
	@echo 'bool dmafail_init(void) { return PPLRW_init(); }' >> $(WRAPPER_SOURCE)
	@echo 'bool dmafail_deinit(void) { return PPLRW_deinit(); }' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint32_t dmafail_get_cpu_family(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpuFamily = 0;' >> $(WRAPPER_SOURCE)
	@echo '    size_t cpuFamilySize = sizeof(cpuFamily);' >> $(WRAPPER_SOURCE)
	@echo '    sysctlbyname("hw.cpufamily", &cpuFamily, &cpuFamilySize, NULL, 0);' >> $(WRAPPER_SOURCE)
	@echo '    return cpuFamily;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'bool dmafail_is_a15_a16(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpuFamily = dmafail_get_cpu_family();' >> $(WRAPPER_SOURCE)
	@echo '    return (cpuFamily == 0x1b588bb3 || cpuFamily == 0xda33d83d);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'bool dmafail_is_supported(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpuFamily = dmafail_get_cpu_family();' >> $(WRAPPER_SOURCE)
	@echo '    switch (cpuFamily) {' >> $(WRAPPER_SOURCE)
	@echo '        case 0x07d34b9f: case 0x462504d2: case 0x1b588bb3:' >> $(WRAPPER_SOURCE)
	@echo '        case 0xda33d83d: case 0x8765edea: return true;' >> $(WRAPPER_SOURCE)
	@echo '        default: return false;' >> $(WRAPPER_SOURCE)
	@echo '    }' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)

# Build dynamic library
$(DYLIB_NAME): $(WRAPPER_SOURCE) $(SOURCES)
	@echo "Building $(DYLIB_NAME)..."
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) -o $@ $(SOURCES) $(LIBS)
	@echo "Successfully built $(DYLIB_NAME)"

# Clean
clean:
	rm -f $(DYLIB_NAME) $(WRAPPER_SOURCE) $(OBJECTS)
	@echo "Cleaned build artifacts"

# Install (copy to system library path)
install: $(DYLIB_NAME)
	@echo "Installing $(DYLIB_NAME)..."
	cp $(DYLIB_NAME) /usr/local/lib/
	@echo "Installed to /usr/local/lib/"

.PHONY: all clean install
