#!/bin/bash

#
# build_dylibs.sh
# Build script for standalone kfd and dmaFail dynamic libraries
#
# Created by Augment Agent on 2025-07-12.
#

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
DIST_DIR="$SCRIPT_DIR/dist"

# Project paths
KFD_DIR="$SCRIPT_DIR/kfd"
DMAFAIL_DIR="$SCRIPT_DIR/dmaFail"
TROLLINSTALLER_DIR="$SCRIPT_DIR/TrollInstallerX"

# Build configuration
ARCHS="arm64 arm64e"
MIN_IOS_VERSION="14.0"
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Xcode command line tools are installed
    if ! command -v xcrun &> /dev/null; then
        print_error "Xcode command line tools not found. Please install Xcode."
        exit 1
    fi
    
    # Check if iOS SDK is available
    if [ ! -d "$SDK_PATH" ]; then
        print_error "iOS SDK not found at $SDK_PATH"
        exit 1
    fi
    
    # Check if TrollInstallerX source exists
    if [ ! -d "$TROLLINSTALLER_DIR" ]; then
        print_error "TrollInstallerX source directory not found at $TROLLINSTALLER_DIR"
        print_error "Please ensure this script is run from the correct location."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create build directories
setup_build_dirs() {
    print_status "Setting up build directories..."
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$DIST_DIR"
    mkdir -p "$DIST_DIR/include"
    mkdir -p "$DIST_DIR/lib"
    
    print_success "Build directories created"
}

# Function to copy headers to distribution
copy_headers() {
    print_status "Copying headers to distribution..."
    
    cp "$KFD_DIR/libkfd.h" "$DIST_DIR/include/"
    cp "$DMAFAIL_DIR/libdmaFail.h" "$DIST_DIR/include/"
    
    print_success "Headers copied to $DIST_DIR/include/"
}

# Function to build kfd library
build_kfd() {
    print_status "Building libkfd.dylib..."
    
    cd "$KFD_DIR"
    
    # Clean previous build
    make clean 2>/dev/null || true
    
    # Build the library
    if make; then
        print_success "libkfd.dylib built successfully"
        
        # Copy to distribution
        cp libkfd.dylib "$DIST_DIR/lib/"
        print_success "libkfd.dylib copied to $DIST_DIR/lib/"
    else
        print_error "Failed to build libkfd.dylib"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to build dmaFail library
build_dmafail() {
    print_status "Building libdmaFail.dylib..."
    
    cd "$DMAFAIL_DIR"
    
    # Clean previous build
    make clean 2>/dev/null || true
    
    # Build the library
    if make; then
        print_success "libdmaFail.dylib built successfully"
        
        # Copy to distribution
        cp libdmaFail.dylib "$DIST_DIR/lib/"
        print_success "libdmaFail.dylib copied to $DIST_DIR/lib/"
    else
        print_error "Failed to build libdmaFail.dylib"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to verify built libraries
verify_libraries() {
    print_status "Verifying built libraries..."
    
    local kfd_lib="$DIST_DIR/lib/libkfd.dylib"
    local dmafail_lib="$DIST_DIR/lib/libdmaFail.dylib"
    
    if [ -f "$kfd_lib" ]; then
        print_status "libkfd.dylib info:"
        file "$kfd_lib"
        otool -L "$kfd_lib" | head -10
        print_success "libkfd.dylib verification passed"
    else
        print_error "libkfd.dylib not found"
        return 1
    fi
    
    if [ -f "$dmafail_lib" ]; then
        print_status "libdmaFail.dylib info:"
        file "$dmafail_lib"
        otool -L "$dmafail_lib" | head -10
        print_success "libdmaFail.dylib verification passed"
    else
        print_error "libdmaFail.dylib not found"
        return 1
    fi
}

# Function to create usage example
create_example() {
    print_status "Creating usage example..."
    
    cat > "$DIST_DIR/example.c" << 'EOF'
/*
 * Example usage of libkfd and libdmaFail
 * Compile with: clang -o example example.c -L./lib -lkfd -ldmaFail -framework Foundation
 */

#include <stdio.h>
#include <stdint.h>
#include "include/libkfd.h"
#include "include/libdmaFail.h"

int main() {
    printf("libkfd version: %s\n", kfd_get_version());
    printf("libdmaFail version: %s\n", dmafail_get_version());
    
    // Check if dmaFail is supported on this device
    if (dmafail_is_supported()) {
        printf("dmaFail is supported on this device\n");
        printf("CPU Family: 0x%x\n", dmafail_get_cpu_family());
        printf("Is A15/A16: %s\n", dmafail_is_a15_a16() ? "Yes" : "No");
    } else {
        printf("dmaFail is not supported on this device\n");
    }
    
    // Example kfd initialization (commented out for safety)
    /*
    uint64_t kfd_handle = kfd_open(512, KFD_PUAF_LANDA, KFD_KREAD_IOSURFACE, KFD_KWRITE_IOSURFACE);
    if (kfd_handle) {
        printf("kfd initialized successfully\n");
        kfd_close(kfd_handle);
    } else {
        printf("Failed to initialize kfd\n");
    }
    */
    
    return 0;
}
EOF
    
    print_success "Usage example created at $DIST_DIR/example.c"
}

# Function to create README
create_readme() {
    print_status "Creating README..."
    
    cat > "$DIST_DIR/README.md" << 'EOF'
# libkfd and libdmaFail - Standalone Dynamic Libraries

This package contains standalone dynamic libraries for kfd kernel exploit and dmaFail PPL bypass.

## Contents

- `lib/libkfd.dylib` - kfd kernel exploit library
- `lib/libdmaFail.dylib` - dmaFail PPL bypass library  
- `include/libkfd.h` - kfd public API header
- `include/libdmaFail.h` - dmaFail public API header
- `example.c` - Usage example

## Usage

### Linking

```bash
clang -o your_app your_app.c -L./lib -lkfd -ldmaFail -framework Foundation
```

### Runtime

Make sure the libraries are in your app's bundle or in a location where they can be loaded:

```bash
export DYLD_LIBRARY_PATH=/path/to/lib:$DYLD_LIBRARY_PATH
```

### API Overview

#### libkfd
- `kfd_open()` - Initialize kfd exploit
- `kfd_read()` / `kfd_write()` - Kernel memory access
- `kfd_close()` - Cleanup

#### libdmaFail  
- `dmafail_init()` - Initialize PPL bypass
- `dmafail_physwrite_*()` - Physical memory write functions
- `dmafail_deinit()` - Cleanup

## Compatibility

- iOS 14.0+
- arm64 and arm64e architectures
- Requires appropriate entitlements and code signing

## Security Notice

These libraries provide low-level system access and should only be used in authorized security research contexts.
EOF
    
    print_success "README created at $DIST_DIR/README.md"
}

# Main build function
main() {
    print_status "Starting build process for kfd and dmaFail dynamic libraries"
    print_status "Build directory: $BUILD_DIR"
    print_status "Distribution directory: $DIST_DIR"
    
    check_prerequisites
    setup_build_dirs
    copy_headers
    
    # Build libraries
    if build_kfd && build_dmafail; then
        verify_libraries
        create_example
        create_readme
        
        print_success "Build completed successfully!"
        print_status "Libraries and headers are available in: $DIST_DIR"
        print_status "- libkfd.dylib: $DIST_DIR/lib/libkfd.dylib"
        print_status "- libdmaFail.dylib: $DIST_DIR/lib/libdmaFail.dylib"
        print_status "- Headers: $DIST_DIR/include/"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    "clean")
        print_status "Cleaning build artifacts..."
        rm -rf "$BUILD_DIR" "$DIST_DIR"
        cd "$KFD_DIR" && make clean 2>/dev/null || true
        cd "$DMAFAIL_DIR" && make clean 2>/dev/null || true
        cd "$SCRIPT_DIR"
        print_success "Clean completed"
        ;;
    "kfd")
        check_prerequisites
        setup_build_dirs
        copy_headers
        build_kfd
        ;;
    "dmafail")
        check_prerequisites
        setup_build_dirs
        copy_headers
        build_dmafail
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  Build both libraries"
        echo "  kfd        Build only libkfd.dylib"
        echo "  dmafail    Build only libdmaFail.dylib"
        echo "  clean      Clean all build artifacts"
        echo "  help       Show this help message"
        ;;
    *)
        main
        ;;
esac
