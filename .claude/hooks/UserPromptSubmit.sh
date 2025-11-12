#!/bin/bash
# UserPromptSubmit - Context injection and validation for VCV Rack workflows

# Check relevance FIRST - only process /continue commands
if [[ ! "$USER_PROMPT" =~ ^/continue ]]; then
  # Check for RACK_DIR validation if setup-related command
  if [[ "$USER_PROMPT" =~ ^/(setup|implement|build) ]]; then
    if [[ -z "$RACK_DIR" ]]; then
      echo "⚠️  WARNING: RACK_DIR environment variable not set" >&2
      echo "   Builds will fail without RACK_DIR pointing to Rack SDK" >&2
      echo "   Run: export RACK_DIR=/path/to/Rack-SDK" >&2
      echo ""
    fi
  fi

  # Check if in modules/ directory - validate contracts
  CURRENT_DIR=$(pwd)
  if [[ "$CURRENT_DIR" =~ /modules/[^/]+$ ]]; then
    MODULE_NAME=$(basename "$CURRENT_DIR")

    # Check for .ideas/ contracts
    if [[ ! -d ".ideas" ]]; then
      echo "⚠️  WARNING: No .ideas/ directory found for module: $MODULE_NAME" >&2
      echo "   Contracts missing - run /plan first" >&2
      echo ""
    fi

    # Validate plugin.json if it exists
    if [[ -f "plugin.json" ]]; then
      # Check slug format
      SLUG=$(jq -r '.slug // empty' plugin.json 2>/dev/null)
      if [[ -n "$SLUG" ]] && [[ ! "$SLUG" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "⚠️  WARNING: Invalid slug format in plugin.json: $SLUG" >&2
        echo "   VCV Rack slugs must be alphanumeric with _ or - only" >&2
        echo ""
      fi

      # Check for common SVG panel dimension issues
      if [[ -d "res" ]]; then
        for svg in res/*.svg; do
          if [[ -f "$svg" ]]; then
            # Check if SVG has width/height in mm (VCV Rack panels use mm)
            if ! grep -q 'width=".*mm"' "$svg" 2>/dev/null; then
              echo "⚠️  WARNING: SVG panel may be missing mm units: $(basename $svg)" >&2
              echo "   VCV Rack panels should use mm dimensions (e.g., width=\"30.48mm\")" >&2
              echo ""
              break
            fi
          fi
        done
      fi
    fi
  fi

  echo "Hook not relevant (not /continue command), skipping gracefully"
  exit 0
fi

# /continue command - inject context
# Extract module name
MODULE_NAME=$(echo "$USER_PROMPT" | awk '{print $2}')

# Find handoff file
if [ -n "$MODULE_NAME" ]; then
  HANDOFF="modules/$MODULE_NAME/.continue-here.md"
else
  HANDOFF=$(find modules -name ".continue-here.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2)
fi

if [ ! -f "$HANDOFF" ]; then
  echo "No handoff file found"
  exit 0
fi

# Inject handoff content into context
echo "Loading context from $HANDOFF..."
cat "$HANDOFF"

# Load referenced contracts
MODULE=$(dirname "$HANDOFF" | xargs basename)
echo ""
echo "--- Contracts ---"
[ -f "modules/$MODULE/.ideas/creative-brief.md" ] && cat "modules/$MODULE/.ideas/creative-brief.md"
[ -f "modules/$MODULE/.ideas/parameter-spec.md" ] && cat "modules/$MODULE/.ideas/parameter-spec.md"
[ -f "modules/$MODULE/.ideas/architecture.md" ] && cat "modules/$MODULE/.ideas/architecture.md"

exit 0
