#!/bin/bash
# PostToolUse hook - Real-time validation for VCV Rack module code
# Detects JSON reports from subagents and triggers checkpoint protocol

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# First, check for subagent JSON reports (return messages)
# VCV subagents return JSON reports like {"stage": N, "status": "complete", ...}
if [[ "$TOOL_NAME" == "Task" ]]; then
  TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // empty' 2>/dev/null)

  # Check if output contains JSON report with "stage" field
  if echo "$TOOL_OUTPUT" | jq -e '.stage' >/dev/null 2>&1; then
    STAGE=$(echo "$TOOL_OUTPUT" | jq -r '.stage')
    STATUS=$(echo "$TOOL_OUTPUT" | jq -r '.status // "unknown"')

    echo "🔔 Subagent checkpoint detected: Stage $STAGE - $STATUS" >&2
    echo "   Orchestrator must now:" >&2
    echo "   1. Commit changes" >&2
    echo "   2. Update .continue-here.md" >&2
    echo "   3. Update MODULES.md" >&2
    echo "   4. Present numbered decision menu" >&2
    echo "   5. Wait for user response" >&2
    echo "" >&2
  fi

  # Not blocking, just informational
  exit 0
fi

# Check relevance - only validate on Write/Edit to module source files
if [[ ! "$TOOL_NAME" =~ ^(Write|Edit)$ ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [[ ! "$FILE_PATH" =~ modules/.*/src/.*\.(cpp|hpp)$ ]]; then
  exit 0
fi

# Extract file content based on tool type
if [[ "$TOOL_NAME" == "Write" ]]; then
  FILE_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null)
elif [[ "$TOOL_NAME" == "Edit" ]]; then
  FILE_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty' 2>/dev/null)
fi

if [ -z "$FILE_CONTENT" ]; then
  exit 0
fi

# VCV Rack real-time safety checks (process() method)
# Extract process() method for validation
PROCESS_METHOD=$(echo "$FILE_CONTENT" | awk '/void\s+process\(.*ProcessArgs/{flag=1} flag{print} /^\s*}$/{if(flag) exit}')

if [ -z "$PROCESS_METHOD" ]; then
  # No process() method found, skip validation
  exit 0
fi

# Real-time safety violation checks for VCV Rack
ERRORS=""

# Check for heap allocation (not real-time safe)
if echo "$PROCESS_METHOD" | grep -qE '\bnew\s+|delete\s+|malloc|free\b'; then
  ERRORS="${ERRORS}\nERROR: Heap allocation detected in process() method (new/delete/malloc/free)"
fi

# Check for blocking locks
if echo "$PROCESS_METHOD" | grep -qE 'std::mutex|\.lock\(\)|\.try_lock\(\)|std::lock_guard|std::unique_lock'; then
  ERRORS="${ERRORS}\nERROR: Blocking mutex/lock detected in process() method"
fi

# Check for I/O operations
if echo "$PROCESS_METHOD" | grep -qE 'fopen|fclose|fread|fwrite|FILE\*|std::ifstream|std::ofstream'; then
  ERRORS="${ERRORS}\nERROR: File I/O operations detected in process() method"
fi

# Check for console output (slow and not real-time safe)
if echo "$PROCESS_METHOD" | grep -qE 'std::cout|std::cerr|printf|fprintf|DEBUG|INFO'; then
  ERRORS="${ERRORS}\nERROR: Console output detected in process() method (std::cout/printf/DEBUG)"
fi

# Check for std::string operations (allocations)
if echo "$PROCESS_METHOD" | grep -qE 'std::string|\.c_str\(\)|\.append\(|\.substr\('; then
  ERRORS="${ERRORS}\nWARNING: std::string operations in process() may cause allocations"
fi

# VCV Rack specific best practices
WARNINGS=""

# Check for proper voltage clamping (VCV uses ±10V standard)
if echo "$PROCESS_METHOD" | grep -q 'getVoltage\|setVoltage' && ! echo "$PROCESS_METHOD" | grep -q 'clamp'; then
  WARNINGS="${WARNINGS}\nWARNING: Consider clamping voltages to ±10V or ±5V range"
fi

# Check for light updates in process() (should be in module step or less frequent)
if echo "$PROCESS_METHOD" | grep -q '\.setBrightness\|lights\[.*\]\.value'; then
  WARNINGS="${WARNINGS}\nWARNING: Light updates in process() are expensive - consider updating less frequently"
fi

# Check for division by zero protection
if echo "$PROCESS_METHOD" | grep -qE '/\s*[a-zA-Z_]' && ! echo "$PROCESS_METHOD" | grep -qE 'if.*==.*0|std::abs.*<.*1e-|!= 0\.?f?'; then
  WARNINGS="${WARNINGS}\nWARNING: Check division operations for zero protection"
fi

# Report results
if [ -n "$ERRORS" ]; then
  echo "Real-time safety violations detected in $FILE_PATH:" >&2
  echo -e "$ERRORS" >&2
  echo "" >&2
  echo "These violations can cause audio dropouts, glitches, or crashes." >&2
  echo "process() method must be real-time safe (no allocations, locks, or I/O)." >&2
  exit 1  # Block workflow on ERROR
fi

if [ -n "$WARNINGS" ]; then
  echo "Code quality recommendations for $FILE_PATH:" >&2
  echo -e "$WARNINGS" >&2
  # Don't block on warnings, just inform
fi

exit 0
