# Define the application name and source file
APP_NAME=json-filter-cli
SRC_FILE=main.go

# Define build paths
BIN_DIR=bin
RELEASE_DIR=$(BIN_DIR)/release
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
	@for platform in $(ALL_PLATFORMS); do \
		os=$$(echo $$platform | cut -d'/' -f1); \
		arch=$$(echo $$platform | cut -d'/' -f2); \
		echo "  -> Building for $$os/$$arch..."; \
		GOOS=$$os GOARCH=$$arch go build $(LDFLAGS) -o $(BIN_DIR)/$$os/$$arch/$(APP_NAME); \
	done

# Create a macOS universal binary
universal-mac: cross-compile
	@echo "Creating macOS universal binary..."
	@lipo -create -output $(BIN_DIR)/darwin/$(APP_NAME) $(BIN_DIR)/darwin/amd64/$(APP_NAME) $(BIN_DIR)/darwin/arm64/$(APP_NAME)
	@echo "Universal binary for macOS created at $(BIN_DIR)/darwin/$(APP_NAME)"

# Clean up build artifacts
clean:
	@echo "Cleaning up build directories..."
	@rm -rf $(BIN_DIR) $(RELEASE_DIR) $(TMP_DIR)

# Create a distributable package
release: clean universal-mac
	@echo "Creating release packages..."
	@mkdir -p $(RELEASE_DIR)
	
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
