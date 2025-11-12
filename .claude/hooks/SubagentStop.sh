#!/bin/bash
# SubagentStop hook - Deterministic validation after each VCV Rack subagent completes
# Enforces checkpoint protocol and validates stage outputs

INPUT=$(cat)
SUBAGENT=$(echo "$INPUT" | jq -r '.subagent_name // empty' 2>/dev/null)

# Gracefully skip if we can't extract subagent name
if [ -z "$SUBAGENT" ]; then
  echo "Hook not relevant: no subagent_name in input, skipping gracefully"
  exit 0
fi

# Check relevance FIRST - only validate our VCV implementation subagents
if [[ ! "$SUBAGENT" =~ ^(foundation-agent|shell-agent|dsp-agent|gui-agent)$ ]]; then
  echo "Hook not relevant for subagent: $SUBAGENT, skipping gracefully"
  exit 0
fi

# Extract module name from context if available
MODULE_NAME=$(echo "$INPUT" | jq -r '.module_name // empty' 2>/dev/null)

# Enforce checkpoint protocol
echo "⚠️  CHECKPOINT PROTOCOL REQUIRED after $SUBAGENT completion" >&2
echo "" >&2
echo "The orchestrator MUST now:" >&2
echo "  1. Read subagent's return message (JSON report)" >&2
echo "  2. Commit changes with descriptive message" >&2
echo "  3. Update .continue-here.md with next stage info" >&2
echo "  4. Update MODULES.md with progress" >&2
echo "  5. Present numbered decision menu to user" >&2
echo "  6. WAIT for user response (do NOT auto-proceed)" >&2
echo "" >&2

# Execute hook logic based on subagent (VCV-specific validation)
case "$SUBAGENT" in
  foundation-agent)
    echo "Validating foundation-agent output (Stage 2)..."

    # Check for Makefile
    if [ -n "$MODULE_NAME" ] && [ -f "modules/$MODULE_NAME/Makefile" ]; then
      echo "✓ Makefile found"

      # Verify Makefile includes plugin.mk
      if grep -q "include.*plugin.mk" "modules/$MODULE_NAME/Makefile"; then
        echo "✓ Makefile includes plugin.mk"
      else
        echo "❌ Makefile missing plugin.mk include" >&2
        exit 2
      fi
    else
      echo "⚠️  Makefile validation skipped (module name not provided or file not found)"
    fi

    # Check for plugin.json
    if [ -n "$MODULE_NAME" ] && [ -f "modules/$MODULE_NAME/plugin.json" ]; then
      echo "✓ plugin.json found"

      # Verify valid JSON
      if jq empty "modules/$MODULE_NAME/plugin.json" 2>/dev/null; then
        echo "✓ plugin.json valid JSON"
      else
        echo "❌ plugin.json invalid JSON" >&2
        exit 2
      fi
    else
      echo "⚠️  plugin.json validation skipped"
    fi

    echo "Foundation validation PASSED"
    ;;

  shell-agent)
    echo "Validating shell-agent output (Stage 3)..."

    # Check for src/ directory with module definitions
    if [ -n "$MODULE_NAME" ] && [ -d "modules/$MODULE_NAME/src" ]; then
      # Count .cpp files
      CPP_COUNT=$(find "modules/$MODULE_NAME/src" -name "*.cpp" | wc -l)
      if [ $CPP_COUNT -gt 0 ]; then
        echo "✓ Found $CPP_COUNT .cpp files in src/"
      else
        echo "❌ No .cpp files found in src/" >&2
        exit 2
      fi

      # Check for module struct definitions (VCV pattern)
      if grep -r "struct.*Module" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ Module struct definition found"
      else
        echo "❌ No Module struct definition found" >&2
        exit 2
      fi

      # Check for parameter enums
      if grep -r "enum.*Param" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ Parameter enum found"
      else
        echo "⚠️  No parameter enum found (may be intentional)"
      fi
    else
      echo "⚠️  Shell validation skipped (module name not provided or src/ not found)"
    fi

    echo "Shell validation PASSED"
    ;;

  dsp-agent)
    echo "Validating dsp-agent output (Stage 4)..."

    # Check for process() method implementation
    if [ -n "$MODULE_NAME" ] && [ -d "modules/$MODULE_NAME/src" ]; then
      if grep -r "void.*process.*ProcessArgs" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ process() method found"

        # Check for input/output processing
        if grep -r "inputs\[.*\]\.getVoltage\|outputs\[.*\]\.setVoltage" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
          echo "✓ Input/output voltage processing found"
        else
          echo "⚠️  No voltage processing found (may be generator/utility module)"
        fi
      else
        echo "❌ No process() method implementation found" >&2
        exit 2
      fi
    else
      echo "⚠️  DSP validation skipped"
    fi

    echo "DSP component validation PASSED"
    ;;

  gui-agent)
    echo "Validating gui-agent output (Stage 5)..."

    # Check for widget definitions (panel, params, ports)
    if [ -n "$MODULE_NAME" ] && [ -d "modules/$MODULE_NAME/src" ]; then
      # Check for ModuleWidget struct
      if grep -r "struct.*Widget.*ModuleWidget" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ ModuleWidget struct found"
      else
        echo "❌ No ModuleWidget struct found" >&2
        exit 2
      fi

      # Check for addParam calls
      if grep -r "addParam\|createParam" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ Parameter widgets found"
      else
        echo "⚠️  No parameter widgets found (may be passive module)"
      fi

      # Check for addInput/addOutput
      if grep -r "addInput\|addOutput\|createInput\|createOutput" "modules/$MODULE_NAME/src" >/dev/null 2>&1; then
        echo "✓ Port widgets found"
      else
        echo "⚠️  No port widgets found"
      fi
    fi

    # Check for SVG panel in res/
    if [ -n "$MODULE_NAME" ] && [ -d "modules/$MODULE_NAME/res" ]; then
      SVG_COUNT=$(find "modules/$MODULE_NAME/res" -name "*.svg" | wc -l)
      if [ $SVG_COUNT -gt 0 ]; then
        echo "✓ Found $SVG_COUNT SVG panel file(s)"
      else
        echo "⚠️  No SVG panel files (using default appearance)"
      fi
    fi

    echo "GUI binding validation PASSED"
    ;;
esac

echo ""
echo "Subagent validation complete - orchestrator must now execute checkpoint protocol"
exit 0
