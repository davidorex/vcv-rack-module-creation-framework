#!/bin/bash
# PreCompact - Preserve VCV Rack contracts and critical patterns before context compaction
# Ensures essential module state and knowledge base are not lost

# Preserve global state
if [ -f "MODULES.md" ]; then
  echo "=== MODULES.md (Global State) ==="
  cat "MODULES.md"
  echo ""
fi

# Preserve critical patterns (Required Reading)
if [ -f "troubleshooting/patterns/vcv-critical-patterns.md" ]; then
  echo "=== vcv-critical-patterns.md (REQUIRED READING) ==="
  cat "troubleshooting/patterns/vcv-critical-patterns.md"
  echo ""
fi

# Find all modules with contracts
MODULES=$(find modules -type d -maxdepth 1 -mindepth 1 2>/dev/null)

for MODULE in $MODULES; do
  MODULE_NAME=$(basename "$MODULE")

  echo "=== Module: $MODULE_NAME ==="

  # Preserve all contract files
  if [ -f "$MODULE/.ideas/creative-brief.md" ]; then
    echo "--- creative-brief.md ---"
    cat "$MODULE/.ideas/creative-brief.md"
    echo ""
  fi

  if [ -f "$MODULE/.ideas/parameter-spec.md" ]; then
    echo "--- parameter-spec.md ---"
    cat "$MODULE/.ideas/parameter-spec.md"
    echo ""
  fi

  if [ -f "$MODULE/.ideas/architecture.md" ]; then
    echo "--- architecture.md ---"
    cat "$MODULE/.ideas/architecture.md"
    echo ""
  fi

  if [ -f "$MODULE/.ideas/plan.md" ]; then
    echo "--- plan.md ---"
    cat "$MODULE/.ideas/plan.md"
    echo ""
  fi

  # CRITICAL: Preserve workflow state
  if [ -f "$MODULE/.ideas/.continue-here.md" ]; then
    echo "--- .continue-here.md (WORKFLOW STATE) ---"
    cat "$MODULE/.ideas/.continue-here.md"
    echo ""
  fi

  # Preserve plugin.json (VCV module manifest)
  if [ -f "$MODULE/plugin.json" ]; then
    echo "--- plugin.json (Module Manifest) ---"
    cat "$MODULE/plugin.json"
    echo ""
  fi

  # List SVG panels if they exist
  if [ -d "$MODULE/res" ]; then
    echo "--- res/ (Panel Graphics) ---"
    ls -lh "$MODULE/res" 2>/dev/null
    SVG_COUNT=$(find "$MODULE/res" -name "*.svg" | wc -l)
    echo "SVG panel files: $SVG_COUNT"
    echo ""
  fi

  # List mockups if they exist
  if [ -d "$MODULE/.ideas/mockups" ]; then
    echo "--- mockups/ ---"
    ls -lh "$MODULE/.ideas/mockups" 2>/dev/null
    echo "Mockup files preserved in repository"
    echo ""
  fi
done

# Preserve RACK_DIR environment info
if [ -n "$RACK_DIR" ]; then
  echo "=== Environment ==="
  echo "RACK_DIR=$RACK_DIR"
  echo ""
fi

exit 0
