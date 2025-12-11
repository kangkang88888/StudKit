.PHONY: build clean run release install help

# Default target
all: build

# Build in debug mode
build:
	@echo "Building StudKit in debug mode..."
	swift build

# Build in release mode
release:
	@echo "Building StudKit in release mode..."
	swift build -c release

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build

# Run the application
run: build
	@echo "Running StudKit..."
	.build/debug/StudKit

# Run release version
run-release: release
	@echo "Running StudKit (Release)..."
	.build/release/StudKit

# Install to /usr/local/bin
install: release
	@echo "Installing StudKit to /usr/local/bin..."
	cp .build/release/StudKit /usr/local/bin/studkit
	@echo "Installation complete! Run 'studkit' to start the application."

# Uninstall
uninstall:
	@echo "Uninstalling StudKit..."
	rm -f /usr/local/bin/studkit
	@echo "Uninstallation complete."

# Show help
help:
	@echo "StudKit - Mac System-Level Text Selection Copy Tool"
	@echo ""
	@echo "Available targets:"
	@echo "  make build        - Build in debug mode"
	@echo "  make release      - Build in release mode"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make run          - Build and run in debug mode"
	@echo "  make run-release  - Build and run in release mode"
	@echo "  make install      - Install to /usr/local/bin"
	@echo "  make uninstall    - Uninstall from /usr/local/bin"
	@echo "  make help         - Show this help message"
