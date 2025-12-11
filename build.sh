#!/bin/bash

# StudKit Build Script
# This script builds the StudKit application for macOS

set -e

echo "=========================================="
echo "StudKit - Mac Text Selection Copy Tool"
echo "=========================================="
echo ""

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "Error: Swift is not installed."
    echo "Please install Xcode or Swift toolchain from https://swift.org/download/"
    exit 1
fi

echo "Swift version:"
swift --version
echo ""

# Parse arguments
BUILD_TYPE="debug"
if [ "$1" == "release" ]; then
    BUILD_TYPE="release"
fi

echo "Building in $BUILD_TYPE mode..."
echo ""

# Build the project
if [ "$BUILD_TYPE" == "release" ]; then
    swift build -c release
    BUILD_DIR=".build/release"
else
    swift build
    BUILD_DIR=".build/debug"
fi

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="
echo ""
echo "Executable location: $BUILD_DIR/StudKit"
echo ""
echo "To run the application:"
echo "  $BUILD_DIR/StudKit"
echo ""
echo "To install system-wide:"
echo "  sudo cp $BUILD_DIR/StudKit /usr/local/bin/studkit"
echo ""
echo "Note: StudKit requires Accessibility permissions to work."
echo "You will be prompted to grant permissions on first run."
echo ""
