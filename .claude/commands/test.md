---
name: test
description: Run validation suite for module
---

# /test

When user runs `/test [ModuleName?]`, invoke the module-testing skill.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist
- Status MUST be at least 🚧 Stage 3 or higher (skeleton compiles)

**If module not ready:**
```
[ModuleName] is not ready for testing (Status: [Current]).

Module must be at Stage 3 or higher to run tests.

Use /implement or /continue to reach compilable state.
```

## Behavior

**Without argument:**
List modules eligible for testing:
- Status: 🚧 Stage 3+ (compiling)
- Status: ✅ Working
- Status: 📦 Installed

Present numbered menu of eligible modules.

**With module name:**
```bash
/test [ModuleName]
```

Run validation suite.

## Validation Suite

The module-testing skill executes automated checks:

1. **Compilation** - Verify module builds without errors
2. **Unit tests** - If any test code exists
3. **Binary inspection** - Check plugin is properly formatted
4. **DSP validation** - Audio processing doesn't crash
5. **Widget validation** - UI elements respond correctly
6. **Edge cases** - Parameter limits, bypass behavior
7. **Performance** - CPU usage, latency measurements

## Test Reports

Reports generated at:
- `logs/[ModuleName]/test_TIMESTAMP.log` - Full test output
- `logs/[ModuleName]/test_TIMESTAMP.json` - Structured results

## Output

Test results with:
- Pass/fail status for each check
- Warnings about potential issues
- Performance baseline if applicable
- Recommendations for fixes if failures found
