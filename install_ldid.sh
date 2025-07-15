#!/bin/bash

#
# install_ldid.sh
# Script to install ldid for iOS app signing
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

print_status "Installing ldid for iOS app signing..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "ldid installation is only supported on macOS"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is required but not installed"
    print_status "Please install Homebrew first:"
    print_status "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Method 1: Try installing from Homebrew
print_status "Attempting to install ldid via Homebrew..."

if brew install ldid; then
    print_success "ldid installed successfully via Homebrew"
    ldid --version || print_warning "ldid installed but version check failed"
    exit 0
fi

# Method 2: Install from source if Homebrew fails
print_warning "Homebrew installation failed, trying manual installation..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

print_status "Downloading ldid source..."

# Download ldid source
if command -v git &> /dev/null; then
    git clone https://github.com/ProcursusTeam/ldid.git
    cd ldid
else
    print_error "Git is required for manual installation"
    exit 1
fi

print_status "Building ldid from source..."

# Build ldid
if make; then
    print_status "Installing ldid to /usr/local/bin..."
    
    # Install to /usr/local/bin
    sudo cp ldid /usr/local/bin/
    sudo chmod +x /usr/local/bin/ldid
    
    print_success "ldid installed successfully from source"
    
    # Verify installation
    if ldid --version; then
        print_success "ldid installation verified"
    else
        print_warning "ldid installed but version check failed"
    fi
else
    print_error "Failed to build ldid from source"
    exit 1
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

print_success "ldid installation completed!"
print_status "You can now run the original TrollInstallerX build script:"
print_status "  ./build.sh"
