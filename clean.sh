#!/bin/bash

#
# clean.sh
# Clean script for vExploit library build artifacts
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
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

print_status "Cleaning vExploit build artifacts..."

# Remove build directories
if [ -d "dist" ]; then
    print_status "Removing dist directory..."
    rm -rf dist
    print_success "Removed dist directory"
else
    print_status "dist directory not found"
fi

if [ -d "build" ]; then
    print_status "Removing build directory..."
    rm -rf build
    print_success "Removed build directory"
else
    print_status "build directory not found"
fi

# Remove temporary wrapper files
print_status "Removing temporary wrapper files..."
rm -f vexploit_wrapper.c
rm -f vexploit_full_wrapper.c
rm -f troll_exploit_wrapper.c  # Old naming
rm -f troll_exploit_full_wrapper.c  # Old naming

# Remove old library files (in case they exist in root)
print_status "Removing any old library files..."
rm -f libvExploit.dylib
rm -f libTrollExploit.dylib  # Old naming
rm -f libkfd.dylib
rm -f libdmaFail.dylib
rm -f libPACBypass.dylib

# Remove compiled test programs (in case they exist in root)
rm -f test_dylibs
rm -f demo_vexploit
rm -f demo_trollexploit  # Old naming

# Clean individual component builds
print_status "Cleaning individual component builds..."

if [ -d "kfd" ] && [ -f "kfd/Makefile" ]; then
    cd kfd
    make clean 2>/dev/null || true
    cd ..
    print_status "Cleaned kfd build artifacts"
fi

if [ -d "dmaFail" ] && [ -f "dmaFail/Makefile" ]; then
    cd dmaFail
    make clean 2>/dev/null || true
    cd ..
    print_status "Cleaned dmaFail build artifacts"
fi

if [ -d "pacbypass" ] && [ -f "pacbypass/Makefile" ]; then
    cd pacbypass
    make clean 2>/dev/null || true
    cd ..
    print_status "Cleaned PAC Bypass build artifacts"
fi

# Remove any .o files
find . -name "*.o" -type f -delete 2>/dev/null || true

# Remove any .dSYM directories
find . -name "*.dSYM" -type d -exec rm -rf {} + 2>/dev/null || true

print_success "✅ Clean completed successfully!"
print_status "All vExploit build artifacts have been removed."
print_status ""
print_status "To rebuild the library, run:"
print_status "  ./simple_build.sh    # Quick build"
print_status "  ./full_build.sh      # Full build"
print_status "  ./build_dylibs.sh    # Advanced build"
