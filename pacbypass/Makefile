# Makefile for libPACBypass.dylib
# Standalone PAC Bypass library

# Project configuration
PROJECT_NAME = libPACBypass
VERSION = 1.0.0
DYLIB_NAME = $(PROJECT_NAME).dylib

# Paths
SRCDIR = ../TrollInstallerX/Exploitation
LIBJB_DIR = $(SRCDIR)/libjailbreak
EXTERNAL_DIR = ../TrollInstallerX/External

# Compiler and flags
CC = clang
CFLAGS = -Wall -Wextra -O2 -fPIC -arch arm64
CFLAGS += -miphoneos-version-min=14.0
CFLAGS += -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path)
CFLAGS += -fobjc-arc

# Include paths
INCLUDES = -I. \
           -I$(LIBJB_DIR) \
           -I$(SRCDIR) \
           -I$(EXTERNAL_DIR)/include

# Linker flags
LDFLAGS = -dynamiclib -install_name @rpath/$(DYLIB_NAME)
LDFLAGS += -compatibility_version $(VERSION) -current_version $(VERSION)
LDFLAGS += -arch arm64
LDFLAGS += -miphoneos-version-min=14.0
LDFLAGS += -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path)

# External libraries
LIBS = -L$(EXTERNAL_DIR)/lib -lchoma -lgrabkernel2 -lpartial
LIBS += -framework Foundation -framework IOKit -framework CoreFoundation

# libjailbreak sources (static linking - PAC related)
LIBJB_SOURCES = $(LIBJB_DIR)/util.c \
                $(LIBJB_DIR)/util.m \
                $(LIBJB_DIR)/primitives.c \
                $(LIBJB_DIR)/kernel.c \
                $(LIBJB_DIR)/info.c

# Wrapper source
WRAPPER_SOURCE = libPACBypass_wrapper.c

# All sources
SOURCES = $(LIBJB_SOURCES) $(WRAPPER_SOURCE)

# Object files
OBJECTS = $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.m=.o)

# Default target
all: $(DYLIB_NAME)

# Create wrapper source file
$(WRAPPER_SOURCE):
	@echo "Creating PAC bypass wrapper source file..."
	@echo '#include "libPACBypass.h"' > $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/libjailbreak/util.h"' >> $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/libjailbreak/primitives.h"' >> $(WRAPPER_SOURCE)
	@echo '#include "../TrollInstallerX/Exploitation/libjailbreak/kernel.h"' >> $(WRAPPER_SOURCE)
	@echo '#include <sys/sysctl.h>' >> $(WRAPPER_SOURCE)
	@echo '#include <string.h>' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Global state' >> $(WRAPPER_SOURCE)
	@echo 'static bool g_pacbypass_initialized = false;' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Version information' >> $(WRAPPER_SOURCE)
	@echo 'const char* pacbypass_get_version(void) { return "1.0.0"; }' >> $(WRAPPER_SOURCE)
	@echo 'const char* pacbypass_get_build_info(void) { return "Built on " __DATE__ " " __TIME__; }' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Error strings' >> $(WRAPPER_SOURCE)
	@echo 'const char* pacbypass_get_error_string(int error_code) {' >> $(WRAPPER_SOURCE)
	@echo '    switch (error_code) {' >> $(WRAPPER_SOURCE)
	@echo '        case 0: return "Success";' >> $(WRAPPER_SOURCE)
	@echo '        case -1: return "Initialization failed";' >> $(WRAPPER_SOURCE)
	@echo '        case -2: return "Device not supported";' >> $(WRAPPER_SOURCE)
	@echo '        case -3: return "Invalid pointer";' >> $(WRAPPER_SOURCE)
	@echo '        case -4: return "Gadget missing";' >> $(WRAPPER_SOURCE)
	@echo '        case -5: return "Kernel execution failed";' >> $(WRAPPER_SOURCE)
	@echo '        default: return "Unknown error";' >> $(WRAPPER_SOURCE)
	@echo '    }' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Device detection' >> $(WRAPPER_SOURCE)
	@echo 'bool pacbypass_is_arm64e(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpusubtype = 0;' >> $(WRAPPER_SOURCE)
	@echo '    size_t size = sizeof(cpusubtype);' >> $(WRAPPER_SOURCE)
	@echo '    sysctlbyname("hw.cpusubtype", &cpusubtype, &size, NULL, 0);' >> $(WRAPPER_SOURCE)
	@echo '    return cpusubtype == 2; // CPU_SUBTYPE_ARM64E' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint32_t pacbypass_get_cpu_family(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpuFamily = 0;' >> $(WRAPPER_SOURCE)
	@echo '    size_t size = sizeof(cpuFamily);' >> $(WRAPPER_SOURCE)
	@echo '    sysctlbyname("hw.cpufamily", &cpuFamily, &size, NULL, 0);' >> $(WRAPPER_SOURCE)
	@echo '    return cpuFamily;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint32_t pacbypass_get_cpu_subtype(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpusubtype = 0;' >> $(WRAPPER_SOURCE)
	@echo '    size_t size = sizeof(cpusubtype);' >> $(WRAPPER_SOURCE)
	@echo '    sysctlbyname("hw.cpusubtype", &cpusubtype, &size, NULL, 0);' >> $(WRAPPER_SOURCE)
	@echo '    return cpusubtype;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'bool pacbypass_has_pac_support(void) {' >> $(WRAPPER_SOURCE)
	@echo '    uint32_t cpuFamily = pacbypass_get_cpu_family();' >> $(WRAPPER_SOURCE)
	@echo '    // PAC is supported on A12+ (arm64e)' >> $(WRAPPER_SOURCE)
	@echo '    switch (cpuFamily) {' >> $(WRAPPER_SOURCE)
	@echo '        case 0x07d34b9f: // A12' >> $(WRAPPER_SOURCE)
	@echo '        case 0x462504d2: // A13' >> $(WRAPPER_SOURCE)
	@echo '        case 0x8765edea: // A14' >> $(WRAPPER_SOURCE)
	@echo '        case 0x1b588bb3: // A15' >> $(WRAPPER_SOURCE)
	@echo '        case 0xda33d83d: // A16' >> $(WRAPPER_SOURCE)
	@echo '            return pacbypass_is_arm64e();' >> $(WRAPPER_SOURCE)
	@echo '        default: return false;' >> $(WRAPPER_SOURCE)
	@echo '    }' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'bool pacbypass_is_supported(void) {' >> $(WRAPPER_SOURCE)
	@echo '    return pacbypass_has_pac_support();' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Core PAC functions' >> $(WRAPPER_SOURCE)
	@echo 'bool pacbypass_init(void) {' >> $(WRAPPER_SOURCE)
	@echo '    if (!pacbypass_is_supported()) return false;' >> $(WRAPPER_SOURCE)
	@echo '    g_pacbypass_initialized = true;' >> $(WRAPPER_SOURCE)
	@echo '    return true;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'bool pacbypass_deinit(void) {' >> $(WRAPPER_SOURCE)
	@echo '    g_pacbypass_initialized = false;' >> $(WRAPPER_SOURCE)
	@echo '    return true;' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// PAC manipulation (placeholder implementations)' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t pacbypass_get_pac_mask(uint64_t pointer) {' >> $(WRAPPER_SOURCE)
	@echo '    return get_pac_mask(pointer);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t pacbypass_unsign_pointer(uint64_t pointer) {' >> $(WRAPPER_SOURCE)
	@echo '    if ((pointer & (1ULL << 55)) != 0) {' >> $(WRAPPER_SOURCE)
	@echo '        return pointer | 0xFFFF000000000000ULL;' >> $(WRAPPER_SOURCE)
	@echo '    } else {' >> $(WRAPPER_SOURCE)
	@echo '        return pointer & 0x0000FFFFFFFFFFFFULL;' >> $(WRAPPER_SOURCE)
	@echo '    }' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t pacbypass_kpacda(uint64_t pointer, uint64_t modifier) {' >> $(WRAPPER_SOURCE)
	@echo '    return kpacda(pointer, modifier);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t pacbypass_kptr_sign(uint64_t kaddr, uint64_t pointer, uint16_t salt) {' >> $(WRAPPER_SOURCE)
	@echo '    return kptr_sign(kaddr, pointer, salt);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Kernel memory operations' >> $(WRAPPER_SOURCE)
	@echo 'int pacbypass_kwrite_ptr(uint64_t kaddr, uint64_t pointer, uint16_t salt) {' >> $(WRAPPER_SOURCE)
	@echo '    return kwrite_ptr(kaddr, pointer, salt);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo 'uint64_t pacbypass_kread_ptr(uint64_t kaddr) {' >> $(WRAPPER_SOURCE)
	@echo '    return kread_ptr(kaddr);' >> $(WRAPPER_SOURCE)
	@echo '}' >> $(WRAPPER_SOURCE)
	@echo '' >> $(WRAPPER_SOURCE)
	@echo '// Placeholder implementations for other functions' >> $(WRAPPER_SOURCE)
	@echo 'int pacbypass_proc_get_cred(uint64_t proc, bool is_ios14, void* cred_out) { return -1; }' >> $(WRAPPER_SOURCE)
	@echo 'int pacbypass_proc_set_cred(uint64_t proc, const void* cred, bool is_ios14) { return -1; }' >> $(WRAPPER_SOURCE)
	@echo 'int pacbypass_kcall(uint64_t func_addr, int argc, const uint64_t* argv, uint64_t* result_out) { return -1; }' >> $(WRAPPER_SOURCE)
	@echo 'int pacbypass_sign_kernel_thread(uint64_t proc, uint32_t thread_port) { return -1; }' >> $(WRAPPER_SOURCE)

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
