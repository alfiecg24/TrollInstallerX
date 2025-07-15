#!/bin/bash

#
# setup.sh
# Setup script for kfd and dmaFail dynamic library build environment
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
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

print_status "Setting up kfd and dmaFail dynamic library build environment..."

# Set execute permissions on all shell scripts
print_status "Setting execute permissions on shell scripts..."
chmod +x build_dylibs.sh
chmod +x simple_build.sh
chmod +x full_build.sh
chmod +x setup.sh

print_success "Execute permissions set"

# Check if TrollInstallerX directory exists
if [ ! -d "TrollInstallerX" ]; then
    print_warning "TrollInstallerX directory not found!"
    print_status "You have several options:"
    echo ""
    echo "1. Clone TrollInstallerX repository:"
    echo "   git clone https://github.com/alfiecg24/TrollInstallerX.git"
    echo ""
    echo "2. If you already have TrollInstallerX, create a symlink:"
    echo "   ln -s /path/to/your/TrollInstallerX ./TrollInstallerX"
    echo ""
    echo "3. Copy your TrollInstallerX directory here:"
    echo "   cp -r /path/to/your/TrollInstallerX ./TrollInstallerX"
    echo ""
    print_warning "Please ensure TrollInstallerX is available before running build scripts."
else
    print_success "TrollInstallerX directory found"
    
    # Check key directories
    if [ -d "TrollInstallerX/Exploitation/kfd" ]; then
        print_success "kfd directory found"
    else
        print_error "kfd directory not found in TrollInstallerX/Exploitation/"
    fi
    
    if [ -d "TrollInstallerX/Exploitation/dmaFail" ]; then
        print_success "dmaFail directory found"
    else
        print_error "dmaFail directory not found in TrollInstallerX/Exploitation/"
    fi
    
    if [ -d "TrollInstallerX/Exploitation/libjailbreak" ]; then
        print_success "libjailbreak directory found"
    else
        print_error "libjailbreak directory not found in TrollInstallerX/Exploitation/"
    fi
    
    if [ -d "TrollInstallerX/External" ]; then
        print_success "External dependencies directory found"
    else
        print_warning "External dependencies directory not found"
        print_status "Some external libraries may be missing"
    fi
fi

# Check build tools
print_status "Checking build tools..."

if command -v clang &> /dev/null; then
    print_success "clang compiler found"
    clang --version | head -1
else
    print_error "clang compiler not found"
    print_status "Please install Xcode command line tools:"
    print_status "xcode-select --install"
fi

if command -v xcrun &> /dev/null; then
    print_success "xcrun found"
    SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || echo "")
    if [ -n "$SDK_PATH" ] && [ -d "$SDK_PATH" ]; then
        print_success "iOS SDK found at: $SDK_PATH"
    else
        print_warning "iOS SDK not found or not accessible"
        print_status "Please ensure Xcode is properly installed"
    fi
else
    print_error "xcrun not found"
    print_status "Please install Xcode command line tools"
fi

# Check system architecture
print_status "Checking system architecture..."
ARCH=$(uname -m)
print_status "System architecture: $ARCH"

if [ "$ARCH" = "arm64" ]; then
    print_success "Running on Apple Silicon (arm64)"
elif [ "$ARCH" = "x86_64" ]; then
    print_success "Running on Intel (x86_64)"
    print_warning "Cross-compilation to arm64/arm64e will be required"
else
    print_warning "Unknown architecture: $ARCH"
fi

# Create necessary directories
print_status "Creating build directories..."
mkdir -p build
mkdir -p dist/lib
mkdir -p dist/include

print_success "Build directories created"

# Display usage information
echo ""
print_status "Setup completed! Here's how to proceed:"
echo ""
echo "📋 Available build scripts:"
echo "  ./simple_build.sh    - Quick build with minimal dependencies (recommended for testing)"
echo "  ./full_build.sh      - Full build with complete integration"
echo "  ./build_dylibs.sh    - Advanced build using Makefiles"
echo ""
echo "🧪 Testing:"
echo "  After building, test with: cd dist && DYLD_LIBRARY_PATH=./lib ./test_dylibs"
echo ""
echo "📚 Documentation:"
echo "  Read README_DYLIBS.md for detailed usage instructions"
echo ""
echo "🔧 Troubleshooting:"
echo "  - Ensure TrollInstallerX directory is present"
echo "  - Check that Xcode command line tools are installed"
echo "  - Verify iOS SDK is accessible"
echo ""

if [ ! -d "TrollInstallerX" ]; then
    print_warning "⚠️  TrollInstallerX directory is missing!"
    print_status "Please set it up before running build scripts."
    exit 1
else
    print_success "✅ Environment setup complete!"
    print_status "You can now run any of the build scripts."
fi
