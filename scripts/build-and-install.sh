#!/bin/bash

# build-and-install.sh - VCV Rack Module Build and Installation Automation
# 7-phase pipeline: validate, build, install, verify

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform detection
PLATFORM=$(uname -s)
ARCH=$(uname -m)

# Determine VCV Rack plugins folder based on platform/arch
case "$PLATFORM" in
    Darwin)
        case "$ARCH" in
            arm64)
                RACK_USER_DIR="$HOME/Documents/Rack2"
                PLUGINS_DIR="$RACK_USER_DIR/plugins-mac-arm64"
                ;;
            x86_64)
                RACK_USER_DIR="$HOME/Documents/Rack2"
                PLUGINS_DIR="$RACK_USER_DIR/plugins-mac-x64"
                ;;
            *)
                echo -e "${RED}✗ Unsupported macOS architecture: $ARCH${NC}"
                exit 1
                ;;
        esac
        ;;
    Linux)
        RACK_USER_DIR="$HOME/.Rack2"
        PLUGINS_DIR="$RACK_USER_DIR/plugins-linux-x64"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        RACK_USER_DIR="$USERPROFILE/Documents/Rack2"
        PLUGINS_DIR="$RACK_USER_DIR/plugins-win-x64"
        ;;
    *)
        echo -e "${RED}✗ Unsupported platform: $PLATFORM${NC}"
        exit 1
        ;;
esac

# ============================================================================
# USAGE
# ============================================================================

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <module-name>

Build and install VCV Rack module using 7-phase pipeline.

ARGUMENTS:
    module-name         Name of module to build (directory name in modules/)

OPTIONS:
    --uninstall         Uninstall module (remove from plugins folder)
    --build-only        Build without installing
    --clean             Clean build artifacts before building
    --verify            Verify installation after completion
    --help              Show this help message

EXAMPLES:
    $0 MyOscillator                 # Build and install MyOscillator
    $0 --clean MyOscillator         # Clean build + install
    $0 --uninstall MyOscillator     # Uninstall MyOscillator
    $0 --build-only MyOscillator    # Build only (no install)

ENVIRONMENT:
    RACK_DIR            Path to Rack SDK (required)
                        Example: export RACK_DIR=/path/to/Rack-SDK

PHASES:
    1. Pre-flight validation (RACK_DIR, plugin.json, Makefile)
    2. Build module (make clean && make)
    3. Extract metadata (plugin slug from plugin.json)
    4. Remove old version (clear previous installation)
    5. Install new version (copy to plugins folder)
    6. Clear cache (force Rack to rescan)
    7. Verification (check installation, size, report)

EOF
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_phase() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  PHASE $1: $2${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# PHASE 1: PRE-FLIGHT VALIDATION
# ============================================================================

validate_environment() {
    log_phase 1 "Pre-flight Validation"

    # Check RACK_DIR
    if [ -z "${RACK_DIR:-}" ]; then
        log_error "RACK_DIR environment variable not set"
        echo ""
        echo "Set RACK_DIR to point to your Rack SDK:"
        echo "  export RACK_DIR=/path/to/Rack-SDK"
        echo ""
        echo "Add to shell profile for persistence:"
        echo "  echo 'export RACK_DIR=/path/to/Rack-SDK' >> ~/.bashrc"
        echo "  echo 'export RACK_DIR=/path/to/Rack-SDK' >> ~/.zshrc"
        exit 1
    fi
    log_success "RACK_DIR set: $RACK_DIR"

    # Verify RACK_DIR exists
    if [ ! -d "$RACK_DIR" ]; then
        log_error "RACK_DIR does not exist: $RACK_DIR"
        exit 1
    fi
    log_success "RACK_DIR exists"

    # Verify RACK_DIR is valid SDK
    if [ ! -f "$RACK_DIR/include/rack.hpp" ]; then
        log_error "Invalid Rack SDK (missing rack.hpp): $RACK_DIR"
        exit 1
    fi
    log_success "Valid Rack SDK detected"

    # Check module directory exists
    if [ ! -d "$MODULE_DIR" ]; then
        log_error "Module directory not found: $MODULE_DIR"
        exit 1
    fi
    log_success "Module directory exists: $MODULE_DIR"

    # Check plugin.json exists
    if [ ! -f "$MODULE_DIR/plugin.json" ]; then
        log_error "plugin.json not found in $MODULE_DIR"
        exit 1
    fi
    log_success "plugin.json found"

    # Verify plugin.json is valid JSON
    if ! jq empty "$MODULE_DIR/plugin.json" 2>/dev/null; then
        log_error "plugin.json is invalid JSON"
        exit 1
    fi
    log_success "plugin.json valid JSON"

    # Check Makefile exists
    if [ ! -f "$MODULE_DIR/Makefile" ]; then
        log_error "Makefile not found in $MODULE_DIR"
        exit 1
    fi
    log_success "Makefile found"

    # Check compiler
    if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
        log_error "No C++ compiler found (g++ or clang++)"
        echo ""
        echo "Install compiler:"
        echo "  macOS: xcode-select --install"
        echo "  Linux: sudo apt-get install build-essential"
        echo "  Windows: Install MSYS2 MinGW"
        exit 1
    fi
    log_success "C++ compiler available"

    # Check make
    if ! command -v make &> /dev/null; then
        log_error "make command not found"
        exit 1
    fi
    log_success "make available"

    log_success "Pre-flight validation complete"
}

# ============================================================================
# PHASE 2: BUILD MODULE
# ============================================================================

build_module() {
    log_phase 2 "Build Module"

    cd "$MODULE_DIR"

    # Clean if requested
    if [ "$CLEAN_BUILD" = true ]; then
        log_info "Running make clean..."
        if make clean; then
            log_success "Clean successful"
        else
            log_error "Clean failed"
            exit 1
        fi
    fi

    # Build
    log_info "Running make..."
    if make; then
        log_success "Build successful"
    else
        log_error "Build failed"
        echo ""
        echo "Build failed. Run troubleshooter for diagnostics:"
        echo "  Invoke troubleshooter with build error log"
        exit 1
    fi

    # Verify binary created
    local plugin_binary=""
    case "$PLATFORM" in
        Darwin)
            plugin_binary="plugin.dylib"
            ;;
        Linux)
            plugin_binary="plugin.so"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            plugin_binary="plugin.dll"
            ;;
    esac

    if [ ! -f "$MODULE_DIR/$plugin_binary" ]; then
        log_error "Build succeeded but binary not found: $plugin_binary"
        exit 1
    fi
    log_success "Binary created: $plugin_binary"

    cd "$PROJECT_ROOT"
}

# ============================================================================
# PHASE 3: EXTRACT METADATA
# ============================================================================

extract_metadata() {
    log_phase 3 "Extract Metadata"

    # Extract plugin slug from plugin.json
    PLUGIN_SLUG=$(jq -r '.slug' "$MODULE_DIR/plugin.json")
    if [ -z "$PLUGIN_SLUG" ] || [ "$PLUGIN_SLUG" = "null" ]; then
        log_error "Cannot extract plugin slug from plugin.json"
        exit 1
    fi
    log_success "Plugin slug: $PLUGIN_SLUG"

    # Extract version
    PLUGIN_VERSION=$(jq -r '.version' "$MODULE_DIR/plugin.json")
    if [ -z "$PLUGIN_VERSION" ] || [ "$PLUGIN_VERSION" = "null" ]; then
        log_warning "Cannot extract version from plugin.json"
        PLUGIN_VERSION="unknown"
    else
        log_success "Plugin version: $PLUGIN_VERSION"
    fi

    # Extract plugin name
    PLUGIN_NAME=$(jq -r '.name' "$MODULE_DIR/plugin.json")
    if [ -z "$PLUGIN_NAME" ] || [ "$PLUGIN_NAME" = "null" ]; then
        PLUGIN_NAME="$PLUGIN_SLUG"
    fi
    log_success "Plugin name: $PLUGIN_NAME"

    # Module installation path
    INSTALL_PATH="$PLUGINS_DIR/$PLUGIN_SLUG"
    log_info "Installation path: $INSTALL_PATH"
}

# ============================================================================
# PHASE 4: REMOVE OLD VERSION
# ============================================================================

remove_old_version() {
    log_phase 4 "Remove Old Version"

    if [ -d "$INSTALL_PATH" ]; then
        log_info "Removing existing installation: $INSTALL_PATH"
        rm -rf "$INSTALL_PATH"
        log_success "Old version removed"
    else
        log_info "No previous installation found (clean install)"
    fi
}

# ============================================================================
# PHASE 5: INSTALL NEW VERSION
# ============================================================================

install_new_version() {
    log_phase 5 "Install New Version"

    # Create plugins directory if missing
    if [ ! -d "$PLUGINS_DIR" ]; then
        log_info "Creating plugins directory: $PLUGINS_DIR"
        mkdir -p "$PLUGINS_DIR"
        log_success "Plugins directory created"
    fi

    # Create installation directory
    log_info "Creating installation directory: $INSTALL_PATH"
    mkdir -p "$INSTALL_PATH"

    # Copy plugin.json
    log_info "Copying plugin.json..."
    cp "$MODULE_DIR/plugin.json" "$INSTALL_PATH/"
    log_success "plugin.json copied"

    # Copy binary
    local plugin_binary=""
    case "$PLATFORM" in
        Darwin)
            plugin_binary="plugin.dylib"
            ;;
        Linux)
            plugin_binary="plugin.so"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            plugin_binary="plugin.dll"
            ;;
    esac

    log_info "Copying $plugin_binary..."
    cp "$MODULE_DIR/$plugin_binary" "$INSTALL_PATH/"
    log_success "$plugin_binary copied"

    # Copy res/ directory if exists
    if [ -d "$MODULE_DIR/res" ]; then
        log_info "Copying res/ directory..."
        cp -r "$MODULE_DIR/res" "$INSTALL_PATH/"
        log_success "res/ directory copied"
    else
        log_warning "No res/ directory found (skipping)"
    fi

    # Copy presets/ directory if exists
    if [ -d "$MODULE_DIR/presets" ]; then
        log_info "Copying presets/ directory..."
        cp -r "$MODULE_DIR/presets" "$INSTALL_PATH/"
        log_success "presets/ directory copied"
    else
        log_warning "No presets/ directory found (skipping)"
    fi

    # Copy LICENSE if exists
    if [ -f "$MODULE_DIR/LICENSE.txt" ] || [ -f "$MODULE_DIR/LICENSE" ]; then
        log_info "Copying LICENSE..."
        if [ -f "$MODULE_DIR/LICENSE.txt" ]; then
            cp "$MODULE_DIR/LICENSE.txt" "$INSTALL_PATH/"
        else
            cp "$MODULE_DIR/LICENSE" "$INSTALL_PATH/LICENSE.txt"
        fi
        log_success "LICENSE copied"
    else
        log_warning "No LICENSE file found (optional)"
    fi

    log_success "Installation complete"
}

# ============================================================================
# PHASE 6: CLEAR CACHE
# ============================================================================

clear_cache() {
    log_phase 6 "Clear Cache"

    # VCV Rack auto-scans plugins folder on startup
    # No explicit cache clearing needed, but we can touch the plugins folder
    # to trigger modification time update

    log_info "Touching plugins directory to trigger rescan..."
    touch "$PLUGINS_DIR"
    log_success "Plugins directory updated"

    log_info "VCV Rack will rescan plugins on next launch"
}

# ============================================================================
# PHASE 7: VERIFICATION
# ============================================================================

verify_installation() {
    log_phase 7 "Verification"

    # Check installation directory exists
    if [ ! -d "$INSTALL_PATH" ]; then
        log_error "Installation directory not found: $INSTALL_PATH"
        exit 1
    fi
    log_success "Installation directory exists"

    # Check plugin.json
    if [ ! -f "$INSTALL_PATH/plugin.json" ]; then
        log_error "plugin.json not found in installation"
        exit 1
    fi
    log_success "plugin.json present"

    # Check binary
    local plugin_binary=""
    case "$PLATFORM" in
        Darwin)
            plugin_binary="plugin.dylib"
            ;;
        Linux)
            plugin_binary="plugin.so"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            plugin_binary="plugin.dll"
            ;;
    esac

    if [ ! -f "$INSTALL_PATH/$plugin_binary" ]; then
        log_error "$plugin_binary not found in installation"
        exit 1
    fi
    log_success "$plugin_binary present"

    # Check binary size (sanity check)
    local binary_size=$(stat -f%z "$INSTALL_PATH/$plugin_binary" 2>/dev/null || stat -c%s "$INSTALL_PATH/$plugin_binary" 2>/dev/null)
    if [ -z "$binary_size" ] || [ "$binary_size" -lt 1000 ]; then
        log_warning "Binary size suspiciously small: $binary_size bytes"
    else
        log_success "Binary size: $binary_size bytes"
    fi

    # Check res/ directory
    if [ -d "$INSTALL_PATH/res" ]; then
        log_success "res/ directory present"
    else
        log_warning "res/ directory missing (panels may not load)"
    fi

    # Check presets/
    if [ -d "$INSTALL_PATH/presets" ]; then
        local preset_count=$(ls -1 "$INSTALL_PATH/presets"/*.vcvm 2>/dev/null | wc -l)
        log_success "presets/ directory present ($preset_count presets)"
    else
        log_info "No presets directory (optional)"
    fi

    log_success "Verification complete"
}

# ============================================================================
# UNINSTALL
# ============================================================================

uninstall_module() {
    log_phase "UNINSTALL" "Remove Module"

    extract_metadata

    if [ ! -d "$INSTALL_PATH" ]; then
        log_info "Module not installed: $PLUGIN_SLUG"
        exit 0
    fi

    log_info "Removing installation: $INSTALL_PATH"
    rm -rf "$INSTALL_PATH"
    log_success "Module uninstalled: $PLUGIN_SLUG"

    clear_cache
}

# ============================================================================
# FINAL REPORT
# ============================================================================

print_final_report() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  BUILD AND INSTALL COMPLETE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Plugin:           ${BLUE}$PLUGIN_NAME${NC}"
    echo -e "Slug:             ${BLUE}$PLUGIN_SLUG${NC}"
    echo -e "Version:          ${BLUE}$PLUGIN_VERSION${NC}"
    echo -e "Platform:         ${BLUE}$PLATFORM ($ARCH)${NC}"
    echo -e "Installed to:     ${BLUE}$INSTALL_PATH${NC}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Launch VCV Rack"
    echo "  2. Right-click in rack to open Module Browser"
    echo "  3. Search for \"$PLUGIN_NAME\" or \"$PLUGIN_SLUG\""
    echo "  4. Add module to patch"
    echo ""
    echo -e "${YELLOW}Manual testing checklist:${NC}"
    echo "  □ All parameters work (knobs, switches, buttons)"
    echo "  □ CV inputs respond correctly"
    echo "  □ Audio outputs produce sound (if applicable)"
    echo "  □ Lights respond correctly"
    echo "  □ Polyphony works (if applicable)"
    echo "  □ No crashes or audio glitches"
    echo ""
    echo -e "${BLUE}If issues found:${NC}"
    echo "  - Run '/improve $MODULE_NAME' to fix bugs"
    echo "  - Rebuild with this script"
    echo "  - Test again"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Parse arguments
    UNINSTALL=false
    BUILD_ONLY=false
    CLEAN_BUILD=false
    VERIFY_ONLY=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --verify)
                VERIFY_ONLY=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                MODULE_NAME="$1"
                shift
                ;;
        esac
    done

    # Check module name provided
    if [ -z "${MODULE_NAME:-}" ]; then
        log_error "Module name required"
        echo ""
        usage
        exit 1
    fi

    MODULE_DIR="$PROJECT_ROOT/modules/$MODULE_NAME"

    # Uninstall mode
    if [ "$UNINSTALL" = true ]; then
        uninstall_module
        exit 0
    fi

    # Verify-only mode
    if [ "$VERIFY_ONLY" = true ]; then
        extract_metadata
        verify_installation
        exit 0
    fi

    # Full pipeline
    validate_environment
    build_module

    if [ "$BUILD_ONLY" = true ]; then
        log_success "Build-only mode: Skipping installation"
        exit 0
    fi

    extract_metadata
    remove_old_version
    install_new_version
    clear_cache
    verify_installation

    print_final_report
}

main "$@"
