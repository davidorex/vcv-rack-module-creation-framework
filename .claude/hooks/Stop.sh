#!/bin/bash
# Stop - Stage completion enforcement for VCV Rack workflows
# Verifies proper commit and state tracking before session ends

# Check if workflow in progress
MODULE_STATUS=$(grep "🚧" MODULES.md 2>/dev/null | head -1)
if [ -z "$MODULE_STATUS" ]; then
  echo "No workflow in progress, skipping"
  exit 0
fi

# Extract module name and stage
MODULE_NAME=$(echo "$MODULE_STATUS" | sed -n 's/^### \([A-Za-z0-9_-]*\).*/\1/p')
CURRENT_STAGE=$(echo "$MODULE_STATUS" | sed -n 's/.*Stage \([0-9]\+\).*/\1/p')

if [ -z "$MODULE_NAME" ] || [ -z "$CURRENT_STAGE" ]; then
  echo "⚠️  Warning: Could not parse module status from MODULES.md"
  exit 0
fi

# Verify stage committed
LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null)
if [[ ! "$LAST_COMMIT" =~ "Stage $CURRENT_STAGE" ]] && [[ ! "$LAST_COMMIT" =~ "$MODULE_NAME" ]]; then
  echo "⚠️  Warning: Stage $CURRENT_STAGE for $MODULE_NAME may not be committed" >&2
  echo "   Last commit: $LAST_COMMIT" >&2
  echo "" >&2
  echo "   Expected commit mentioning Stage $CURRENT_STAGE or $MODULE_NAME" >&2
  echo "   Workflow state may be lost if session ends without proper commit" >&2
  exit 1  # Block if stage not properly committed
fi

# Check for .continue-here.md
if [ -f "modules/$MODULE_NAME/.continue-here.md" ]; then
  echo "✓ Stage $CURRENT_STAGE properly committed and .continue-here.md exists"
else
  echo "⚠️  Warning: .continue-here.md not found for $MODULE_NAME" >&2
  echo "   Resume context may be incomplete" >&2
fi

exit 0
