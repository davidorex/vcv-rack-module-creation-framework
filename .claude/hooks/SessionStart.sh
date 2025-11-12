#!/bin/bash
# SessionStart hook - Validate VCV Rack development environment
# Runs once at session start, non-blocking warnings only

echo "Validating VCV Rack development environment..."

# Check Python 3 availability (needed for validators)
if ! command -v python3 &> /dev/null; then
  echo "WARNING: python3 not found - validation scripts won't work" >&2
else
  PYTHON_VERSION=$(python3 --version 2>&1)
  echo "✓ $PYTHON_VERSION"
fi

# Check jq availability (needed for JSON parsing in hooks)
if ! command -v jq &> /dev/null; then
  echo "WARNING: jq not found - hooks may fail" >&2
else
  JQ_VERSION=$(jq --version 2>&1)
  echo "✓ jq $JQ_VERSION"
fi

# Check RACK_DIR environment variable
if [[ -z "$RACK_DIR" ]]; then
  echo "WARNING: RACK_DIR environment variable not set" >&2
  echo "  Set RACK_DIR to your Rack SDK installation directory:" >&2
  echo "  export RACK_DIR=/path/to/Rack-SDK" >&2
else
  echo "✓ RACK_DIR=$RACK_DIR"

  # Validate Rack SDK if RACK_DIR present
  if [[ -f "$RACK_DIR/include/rack.hpp" ]]; then
    echo "✓ Rack SDK validated (rack.hpp found)"
  else
    echo "WARNING: RACK_DIR set but include/rack.hpp not found" >&2
    echo "  Verify RACK_DIR points to valid Rack SDK" >&2
  fi

  # Check for plugin.mk (required for builds)
  if [[ -f "$RACK_DIR/plugin.mk" ]]; then
    echo "✓ plugin.mk found (build system ready)"
  else
    echo "WARNING: plugin.mk not found in RACK_DIR" >&2
  fi
fi

# Check for make
if command -v make &> /dev/null; then
  MAKE_VERSION=$(make --version | head -1)
  echo "✓ $MAKE_VERSION"
else
  echo "WARNING: make not found - builds will fail" >&2
fi

# Check for g++ or clang++ (C++ compiler)
if command -v g++ &> /dev/null; then
  GCC_VERSION=$(g++ --version | head -1)
  echo "✓ $GCC_VERSION"
elif command -v clang++ &> /dev/null; then
  CLANG_VERSION=$(clang++ --version | head -1)
  echo "✓ $CLANG_VERSION"
else
  echo "WARNING: C++ compiler not found (g++ or clang++ required)" >&2
fi

# Check for Inkscape (SVG panel editing)
if command -v inkscape &> /dev/null; then
  INKSCAPE_VERSION=$(inkscape --version 2>&1 | head -1)
  echo "✓ $INKSCAPE_VERSION (panel design ready)"
else
  echo "INFO: inkscape not found (optional - for SVG panel editing)"
fi

# Check git availability
if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version 2>&1)
  echo "✓ $GIT_VERSION"
else
  echo "WARNING: git not found - version control disabled" >&2
fi

# Display VCV system status
if [[ -f "MODULES.md" ]]; then
  echo ""
  echo "=== VCV Module Status ==="
  MODULE_COUNT=$(grep -c "^### " MODULES.md 2>/dev/null || echo "0")
  echo "Total modules: $MODULE_COUNT"

  # Show in-progress modules
  IN_PROGRESS=$(grep "🚧" MODULES.md 2>/dev/null || true)
  if [[ -n "$IN_PROGRESS" ]]; then
    echo ""
    echo "In progress:"
    echo "$IN_PROGRESS" | head -5
  fi

  # Show recently completed
  COMPLETED=$(grep "✅" MODULES.md 2>/dev/null | tail -3 || true)
  if [[ -n "$COMPLETED" ]]; then
    echo ""
    echo "Recently completed:"
    echo "$COMPLETED"
  fi
fi

echo ""
echo "Environment validation complete"
exit 0  # Never block session start
