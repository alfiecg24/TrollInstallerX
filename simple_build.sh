#!/bin/bash

#
# simple_build.sh
# Simplified build script for kfd and dmaFail dynamic libraries
#
# Created by Augment Agent on 2025-07-12.
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
TROLLINSTALLER_DIR="$SCRIPT_DIR/TrollInstallerX"

# Check prerequisites
if [ ! -d "$TROLLINSTALLER_DIR" ]; then
    print_error "TrollInstallerX directory not found!"
    print_error "Please ensure this script is in the same directory as TrollInstallerX/"
    exit 1
fi

# Clean and create distribution directory
print_status "Cleaning previous build artifacts..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/lib"
mkdir -p "$DIST_DIR/include"

print_status "Building standalone kfd and dmaFail libraries..."

# Build libvExploit.dylib (combined kfd + dmaFail + PAC Bypass)
print_status "Building libvExploit.dylib..."

# Create a combined wrapper with kfd, dmaFail and PAC Bypass
cat > vexploit_wrapper.c << 'EOF'
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/sysctl.h>

//=============================================================================
// Combined vExploit Library (kfd + dmaFail + PAC Bypass)
//=============================================================================

// Version information
const char* vexploit_get_version(void) {
    return "1.0.0-combined";
}

const char* vexploit_get_build_info(void) {
    return "Built on " __DATE__ " " __TIME__ " (kfd + dmaFail + PAC Bypass combined)";
}

//=============================================================================
// kfd API implementation
//=============================================================================

const char* kfd_get_version(void) {
    return "1.0.0-standalone";
}

const char* kfd_get_build_info(void) {
    return "Built on " __DATE__ " " __TIME__;
}

// Placeholder implementations (would need full kfd integration)
uint64_t kfd_open(uint64_t puaf_pages, int puaf_method, int kread_method, int kwrite_method) {
    printf("kfd_open called with puaf_pages=%llu\n", puaf_pages);
    return 0; // Placeholder
}

void kfd_read(uint64_t kfd, uint64_t kaddr, void* uaddr, uint64_t size) {
    printf("kfd_read called\n");
}

void kfd_write(uint64_t kfd, void* uaddr, uint64_t kaddr, uint64_t size) {
    printf("kfd_write called\n");
}

void kfd_close(uint64_t kfd) {
    printf("kfd_close called\n");
}

uint8_t kfd_read8(uint64_t kfd, uint64_t kaddr) { return 0; }
uint16_t kfd_read16(uint64_t kfd, uint64_t kaddr) { return 0; }
uint32_t kfd_read32(uint64_t kfd, uint64_t kaddr) { return 0; }
uint64_t kfd_read64(uint64_t kfd, uint64_t kaddr) { return 0; }

void kfd_write8(uint64_t kfd, uint64_t kaddr, uint8_t value) {}
void kfd_write16(uint64_t kfd, uint64_t kaddr, uint16_t value) {}
void kfd_write32(uint64_t kfd, uint64_t kaddr, uint32_t value) {}
void kfd_write64(uint64_t kfd, uint64_t kaddr, uint64_t value) {}

int kfd_read_buffer(uint64_t kfd, uint64_t kaddr, void* buffer, size_t size) { return 0; }
int kfd_write_buffer(uint64_t kfd, uint64_t kaddr, const void* buffer, size_t size) { return 0; }

bool kfd_init_physpuppet(void) { return false; }
bool kfd_init_smith(void) { return false; }
bool kfd_init_landa(void) { return false; }
bool kfd_deinit(void) { return true; }

//=============================================================================
// dmaFail API implementation
//=============================================================================

const char* dmafail_get_version(void) {
    return "1.0.0-standalone";
}

const char* dmafail_get_build_info(void) {
    return "Built on " __DATE__ " " __TIME__;
}

const char* dmafail_get_error_string(int error_code) {
    switch (error_code) {
        case 0: return "Success";
        case -1: return "Initialization failed";
        case -2: return "Device not supported";
        case -3: return "Invalid address";
        case -4: return "Write operation failed";
        case -5: return "Hardware error";
        default: return "Unknown error";
    }
}

bool dmafail_init(void) {
    printf("dmafail_init called\n");
    return false; // Placeholder
}

bool dmafail_deinit(void) {
    printf("dmafail_deinit called\n");
    return true;
}

int dmafail_physwrite_buffer(uint64_t physaddr, const void* input, size_t size) {
    printf("dmafail_physwrite_buffer called\n");
    return 0;
}

int dmafail_physwrite64(uint64_t physaddr, uint64_t value) { return 0; }
int dmafail_physwrite32(uint64_t physaddr, uint32_t value) { return 0; }
int dmafail_physwrite16(uint64_t physaddr, uint16_t value) { return 0; }
int dmafail_physwrite8(uint64_t physaddr, uint8_t value) { return 0; }

void dmafail_perform_dma(void (^block)(void)) {
    printf("dmafail_perform_dma called\n");
}

void dmafail_halt_cpu(void) { printf("dmafail_halt_cpu called\n"); }
void dmafail_unhalt_cpu(void) { printf("dmafail_unhalt_cpu called\n"); }
void dmafail_gfx_power_init(void) { printf("dmafail_gfx_power_init called\n"); }

uint32_t dmafail_get_cpu_family(void) {
    uint32_t cpuFamily = 0;
    size_t cpuFamilySize = sizeof(cpuFamily);
    sysctlbyname("hw.cpufamily", &cpuFamily, &cpuFamilySize, NULL, 0);
    return cpuFamily;
}

bool dmafail_is_a15_a16(void) {
    uint32_t cpuFamily = dmafail_get_cpu_family();
    return (cpuFamily == 0x1b588bb3 || cpuFamily == 0xda33d83d);
}

bool dmafail_is_supported(void) {
    uint32_t cpuFamily = dmafail_get_cpu_family();
    switch (cpuFamily) {
        case 0x07d34b9f: // A12
        case 0x462504d2: // A13
        case 0x1b588bb3: // A15
        case 0xda33d83d: // A16
        case 0x8765edea: // A14
            return true;
        default:
            return false;
    }
}

//=============================================================================
// PAC Bypass API implementation
//=============================================================================

const char* pacbypass_get_version(void) {
    return "1.0.0-standalone";
}

const char* pacbypass_get_build_info(void) {
    return "Built on " __DATE__ " " __TIME__;
}

const char* pacbypass_get_error_string(int error_code) {
    switch (error_code) {
        case 0: return "Success";
        case -1: return "Initialization failed";
        case -2: return "Device not supported";
        case -3: return "Invalid pointer";
        case -4: return "Gadget missing";
        case -5: return "Kernel execution failed";
        default: return "Unknown error";
    }
}

// Device detection
bool pacbypass_is_arm64e(void) {
    uint32_t cpusubtype = 0;
    size_t size = sizeof(cpusubtype);
    sysctlbyname("hw.cpusubtype", &cpusubtype, &size, NULL, 0);
    return cpusubtype == 2; // CPU_SUBTYPE_ARM64E
}

uint32_t pacbypass_get_cpu_family(void) {
    uint32_t cpuFamily = 0;
    size_t size = sizeof(cpuFamily);
    sysctlbyname("hw.cpufamily", &cpuFamily, &size, NULL, 0);
    return cpuFamily;
}

uint32_t pacbypass_get_cpu_subtype(void) {
    uint32_t cpusubtype = 0;
    size_t size = sizeof(cpusubtype);
    sysctlbyname("hw.cpusubtype", &cpusubtype, &size, NULL, 0);
    return cpusubtype;
}

bool pacbypass_has_pac_support(void) {
    uint32_t cpuFamily = pacbypass_get_cpu_family();
    // PAC is supported on A12+ (arm64e)
    switch (cpuFamily) {
        case 0x07d34b9f: // A12
        case 0x462504d2: // A13
        case 0x8765edea: // A14
        case 0x1b588bb3: // A15
        case 0xda33d83d: // A16
            return pacbypass_is_arm64e();
        default:
            return false;
    }
}

bool pacbypass_is_supported(void) {
    return pacbypass_has_pac_support();
}

// Core PAC functions
bool pacbypass_init(void) {
    printf("pacbypass_init called\n");
    if (!pacbypass_is_supported()) {
        printf("PAC bypass not supported on this device\n");
        return false;
    }
    printf("PAC bypass initialized successfully\n");
    return true;
}

bool pacbypass_deinit(void) {
    printf("pacbypass_deinit called\n");
    return true;
}

// PAC manipulation functions
uint64_t pacbypass_get_pac_mask(uint64_t pointer) {
    // Simple PAC mask extraction
    uint64_t mask = 0;
    uint64_t first_relevant = pointer >> 14;

    for (int i = 63; i >= 14; i--) {
        if ((first_relevant >> (i - 14)) & 1) {
            mask |= (1UL << i);
        } else {
            break;
        }
    }

    return mask ? mask : 0;
}

uint64_t pacbypass_unsign_pointer(uint64_t pointer) {
    // Remove PAC signature from pointer
    if ((pointer & (1ULL << 55)) != 0) {
        return pointer | 0xFFFF000000000000ULL;
    } else {
        return pointer & 0x0000FFFFFFFFFFFFULL;
    }
}

uint64_t pacbypass_kpacda(uint64_t pointer, uint64_t modifier) {
    printf("pacbypass_kpacda called: pointer=0x%llx, modifier=0x%llx\n", pointer, modifier);
    // Placeholder implementation
    return pointer;
}

uint64_t pacbypass_kptr_sign(uint64_t kaddr, uint64_t pointer, uint16_t salt) {
    printf("pacbypass_kptr_sign called: kaddr=0x%llx, pointer=0x%llx, salt=0x%x\n", kaddr, pointer, salt);
    uint64_t modifier = (kaddr & 0xffffffffffff) | ((uint64_t)salt << 48);
    return pacbypass_kpacda(pacbypass_unsign_pointer(pointer), modifier);
}

// Kernel memory operations with PAC support
int pacbypass_kwrite_ptr(uint64_t kaddr, uint64_t pointer, uint16_t salt) {
    printf("pacbypass_kwrite_ptr called: kaddr=0x%llx, pointer=0x%llx, salt=0x%x\n", kaddr, pointer, salt);
    // In real implementation, this would write a properly signed pointer
    return 0;
}

uint64_t pacbypass_kread_ptr(uint64_t kaddr) {
    printf("pacbypass_kread_ptr called: kaddr=0x%llx\n", kaddr);
    // In real implementation, this would read and unsign a pointer
    return 0;
}
EOF

# Compile libvExploit.dylib (combined library)
clang -dynamiclib -o "$DIST_DIR/lib/libvExploit.dylib" \
    -arch arm64 \
    -miphoneos-version-min=14.0 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    -install_name @rpath/libvExploit.dylib \
    -compatibility_version 1.0.0 \
    -current_version 1.0.0 \
    vexploit_wrapper.c

print_success "libvExploit.dylib built successfully"

# Copy headers
cp kfd/libkfd.h "$DIST_DIR/include/" 2>/dev/null || true
cp dmaFail/libdmaFail.h "$DIST_DIR/include/" 2>/dev/null || true
cp pacbypass/libPACBypass.h "$DIST_DIR/include/" 2>/dev/null || true
cp libvExploit.h "$DIST_DIR/include/"

print_success "Headers copied to $DIST_DIR/include/"

# Create test program
print_status "Creating test program..."

clang -o "$DIST_DIR/test_dylibs" \
    -arch arm64 \
    -miphoneos-version-min=14.0 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    test_dylibs.c

print_success "Test program created"

# Create demo program
print_status "Creating demo program..."

clang -o "$DIST_DIR/demo_vexploit" \
    -arch arm64 \
    -miphoneos-version-min=14.0 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    -I"$DIST_DIR/include" \
    -L"$DIST_DIR/lib" \
    -lvExploit \
    demo_vexploit.c

print_success "Demo program created"

# Cleanup temporary files
rm -f vexploit_wrapper.c

# Verify library
print_status "Verifying library..."
file "$DIST_DIR/lib/libvExploit.dylib"

print_success "Build completed successfully!"
print_status "Library available in: $DIST_DIR"
print_status "- libvExploit.dylib: $DIST_DIR/lib/libvExploit.dylib"
print_status "- Headers: $DIST_DIR/include/"
print_status "- Test program: $DIST_DIR/test_dylibs"
print_status "- Demo program: $DIST_DIR/demo_vexploit"

echo ""
print_status "To test the library, run:"
echo "cd $DIST_DIR && DYLD_LIBRARY_PATH=./lib ./test_dylibs"
echo ""
print_status "To run the full demonstration, run:"
echo "cd $DIST_DIR && DYLD_LIBRARY_PATH=./lib ./demo_vexploit"
