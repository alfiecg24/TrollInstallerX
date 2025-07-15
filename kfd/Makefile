# Makefile for libkfd.dylib
# Standalone kfd kernel exploit library

# Project configuration
PROJECT_NAME = libkfd
VERSION = 1.0.0
DYLIB_NAME = $(PROJECT_NAME).dylib

# Paths
SRCDIR = ../TrollInstallerX/Exploitation
KFD_DIR = $(SRCDIR)/kfd
LIBJB_DIR = $(SRCDIR)/libjailbreak
EXTERNAL_DIR = ../TrollInstallerX/External

# Compiler and flags
CC = clang
CFLAGS = -Wall -Wextra -O2 -fPIC -arch arm64 -arch arm64e
CFLAGS += -miphoneos-version-min=14.0
CFLAGS += -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path)

# Include paths
INCLUDES = -I. \
           -I$(KFD_DIR) \
           -I$(KFD_DIR)/Exploit \
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
KFD_SOURCES = $(KFD_DIR)/kfd.m

# libjailbreak sources (static linking)
LIBJB_SOURCES = $(LIBJB_DIR)/info.c \
                $(LIBJB_DIR)/kalloc_pt.m \
                $(LIBJB_DIR)/kernel.c \
                $(LIBJB_DIR)/physrw.c \
                $(LIBJB_DIR)/physrw_pte.c \
                $(LIBJB_DIR)/primitives.c \
                $(LIBJB_DIR)/primitives_IOSurface.m \
                $(LIBJB_DIR)/translation.c \
                $(LIBJB_DIR)/util.c \
                $(LIBJB_DIR)/util.m \
                $(LIBJB_DIR)/vnode.m

# kfd exploit sources (all the libkfd implementation files)
KFD_EXPLOIT_DIR = $(KFD_DIR)/Exploit/libkfd
KFD_EXPLOIT_SOURCES = $(shell find $(KFD_EXPLOIT_DIR) -name "*.c" -o -name "*.m")

# Wrapper source
WRAPPER_SOURCE = libkfd_wrapper.c

# All sources
SOURCES = $(KFD_SOURCES) $(LIBJB_SOURCES) $(KFD_EXPLOIT_SOURCES) $(WRAPPER_SOURCE)

# Object files
OBJECTS = $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.m=.o)

# Default target
all: $(DYLIB_NAME)

# Create wrapper source file
$(WRAPPER_SOURCE):
	@echo "Creating wrapper source file..."
	@echo '#include "libkfd.h"' > $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/kfd/Exploit/libkfd.h"' >> $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/kfd/kfd.h"' >> $(WRAPPER_SOURCE)
	@echo '#include <string.h>' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Version information' >> $(WRAPPER_SOURCE)
	@echo 'const char* kfd_get_version(void) {' >> $(WRAPPER_SOURCE)
	@echo '    return "1.0.0";' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'const char* kfd_get_build_info(void) {' >> $(WRAPPER_SOURCE)
	@echo '    return "Built on " __DATE__ " " __TIME__;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Wrapper functions that map to original kfd API' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t kfd_open(uint64_t puaf_pages, kfd_puaf_method_t puaf_method,' >> $(WRAPPER_SOURCE)
	@echo '                  kfd_kread_method_t kread_method, kfd_kwrite_method_t kwrite_method) {' >> $(WRAPPER_SOURCE)
	@echo '    return kopen(puaf_pages, (uint64_t)puaf_method, (uint64_t)kread_method, (uint64_t)kwrite_method);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_read(uint64_t kfd, uint64_t kaddr, void* uaddr, uint64_t size) {' >> $(WRAPPER_SOURCE)
	@echo '    kread(kfd, kaddr, uaddr, size);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_write(uint64_t kfd, void* uaddr, uint64_t kaddr, uint64_t size) {' >> $(WRAPPER_SOURCE)
	@echo '    kwrite(kfd, uaddr, kaddr, size);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_close(uint64_t kfd) {' >> $(WRAPPER_SOURCE)
	@echo '    kclose(kfd);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Convenience functions' >> $(WRAPPER_SOURCE)
	@echo 'uint8_t kfd_read8(uint64_t kfd, uint64_t kaddr) {' >> $(WRAPPER_SOURCE)
	@echo '    uint8_t value; kfd_read(kfd, kaddr, &value, sizeof(value)); return value;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'uint16_t kfd_read16(uint64_t kfd, uint64_t kaddr) {' >> $(WRAPPER_SOURCE)
	@echo '    uint16_t value; kfd_read(kfd, kaddr, &value, sizeof(value)); return value;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'uint32_t kfd_read32(uint64_t kfd, uint64_t kaddr) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t value; kfd_read(kfd, kaddr, &value, sizeof(value)); return value;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t kfd_read64(uint64_t kfd, uint64_t kaddr) {' >> $(WRAPPER_SOURCE)
	@echo '    uint64_t value; kfd_read(kfd, kaddr, &value, sizeof(value)); return value;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_write8(uint64_t kfd, uint64_t kaddr, uint8_t value) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_write(kfd, &value, kaddr, sizeof(value));' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_write16(uint64_t kfd, uint64_t kaddr, uint16_t value) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_write(kfd, &value, kaddr, sizeof(value));' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_write32(uint64_t kfd, uint64_t kaddr, uint32_t value) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_write(kfd, &value, kaddr, sizeof(value));' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'void kfd_write64(uint64_t kfd, uint64_t kaddr, uint64_t value) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_write(kfd, &value, kaddr, sizeof(value));' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'int kfd_read_buffer(uint64_t kfd, uint64_t kaddr, void* buffer, size_t size) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_read(kfd, kaddr, buffer, size); return 0;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'int kfd_write_buffer(uint64_t kfd, uint64_t kaddr, const void* buffer, size_t size) {' >> $(WRAPPER_SOURCE)
	@echo '    kfd_write(kfd, (void*)buffer, kaddr, size); return 0;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo 'bool kfd_init_physpuppet(void) { return krw_init_physpuppet(); }' >> $(WRAPPER_SOURCE)
	@echo 'bool kfd_init_smith(void) { return krw_init_smith(); }' >> $(WRAPPER_SOURCE)
	@echo 'bool kfd_init_landa(void) { return krw_init_landa(); }' >> $(WRAPPER_SOURCE)
	@echo 'bool kfd_deinit(void) { return krw_deinit(); }' >> $(WRAPPER_SOURCE)

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
