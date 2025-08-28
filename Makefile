# Define the application name and source file
APP_NAME=json-filter
SRC_FILE=main.go

# Define build paths
BIN_DIR=bin
RELEASE_DIR=$(BIN_DIR)
TMP_DIR=tmp

# Define the platforms for cross-compilation
# For macOS, we target two architectures (amd64 and arm64) for universal binary.
PLATFORMS_MAC="darwin/amd64 darwin/arm64"
PLATFORMS_LINUX="linux/amd64"
PLATFORMS_WINDOWS="windows/amd64"

# Define all platforms
ALL_PLATFORMS=$(PLATFORMS_MAC) $(PLATFORMS_LINUX) $(PLATFORMS_WINDOWS)

# Get version, commit, and date from git
# Use git describe to get version from tags, fall back to "dev"
VERSION=$(shell git describe --tags --always --abbrev=0 2>/dev/null || echo "dev")
COMMIT=$(shell git rev-parse HEAD)
DATE=$(shell date -u +"%Y-%m-%d_%H:%M:%S")

# Set LDFLAGS for embedding version information
LDFLAGS=-ldflags="-X 'main.version=$(VERSION)' -X 'main.commit=$(COMMIT)' -X 'main.date=$(DATE)'"

.PHONY: all build clean release

all: build

# Build the binary for the current platform
build:
	@echo "Building for current platform..."
	go build -o $(BIN_DIR)/$(APP_NAME) $(LDFLAGS) ./...

# Build binaries for all specified platforms
cross-compile: clean
	@echo "Building binaries for all platforms..."
	@mkdir -p $(BIN_DIR)
	# macOS builds
	@echo "  -> Building for darwin/amd64..."
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BIN_DIR)/darwin/amd64/$(APP_NAME) ./...
	@echo "  -> Building for darwin/arm64..."
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(BIN_DIR)/darwin/arm64/$(APP_NAME) ./...
	# Linux build
	@echo "  -> Building for linux/amd64..."
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BIN_DIR)/linux/amd64/$(APP_NAME) ./...
	# Windows build
	@echo "  -> Building for windows/amd64..."
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BIN_DIR)/windows/amd64/$(APP_NAME).exe ./...

# Create a macOS universal binary
universal-mac: 
	@echo "Building macOS universal binary..."
	@mkdir -p $(BIN_DIR)/darwin/amd64 $(BIN_DIR)/darwin/arm64
	@echo "  -> Building for darwin/amd64..."
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BIN_DIR)/darwin/amd64/$(APP_NAME) ./...
	@echo "  -> Building for darwin/arm64..."
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(BIN_DIR)/darwin/arm64/$(APP_NAME) ./...
	@echo "Creating macOS universal binary..."
	@lipo -create -output $(BIN_DIR)/darwin/$(APP_NAME) $(BIN_DIR)/darwin/amd64/$(APP_NAME) $(BIN_DIR)/darwin/arm64/$(APP_NAME)
	@echo "Universal binary for macOS created at $(BIN_DIR)/darwin/$(APP_NAME)"

# Clean up build artifacts
clean:
	@echo "Cleaning up build directories..."
	@rm -rf $(BIN_DIR) $(RELEASE_DIR) $(TMP_DIR)

# Create a distributable package
release: clean cross-compile
	@echo "Creating release packages..."
	@mkdir -p $(RELEASE_DIR)
	
	# Create macOS universal binary for release
	@echo "  -> Creating macOS universal binary for release..."
	@lipo -create -output $(BIN_DIR)/darwin/$(APP_NAME) $(BIN_DIR)/darwin/amd64/$(APP_NAME) $(BIN_DIR)/darwin/arm64/$(APP_NAME)

	# Package for macOS
	@echo "  -> Packaging for macOS..."
	@tar -czf $(RELEASE_DIR)/$(APP_NAME)_$(VERSION)_darwin_universal.tar.gz -C $(BIN_DIR)/darwin $(APP_NAME)

	# Package for Linux
	@echo "  -> Packaging for Linux..."
	@tar -czf $(RELEASE_DIR)/$(APP_NAME)_$(VERSION)_linux_amd64.tar.gz -C $(BIN_DIR)/linux/amd64 $(APP_NAME)
	
	# Package for Windows
	@echo "  -> Packaging for Windows..."
	@cd $(BIN_DIR)/windows/amd64 && zip $(CURDIR)/$(RELEASE_DIR)/$(APP_NAME)_$(VERSION)_windows_amd64.zip $(APP_NAME).exe

	@echo "Release packages created in $(RELEASE_DIR)"
