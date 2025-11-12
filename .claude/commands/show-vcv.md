---
name: show-vcv
description: Launch VCV Rack with module for visual testing
---

# /show-vcv

When user runs `/show-vcv [ModuleName?]`, invoke the module-lifecycle skill.

## Preconditions

**Check module state:**
- Module MUST be at least Stage 3+ (compiling skeleton)
- VCV Rack MUST be installed on system
- Module MUST be installed or available in build folder

**If module not ready:**
```
[ModuleName] is not ready for visual testing (Status: [Current]).

Module must be at Stage 3 or higher.

Use /implement or /continue to reach compilable state.
```

## Behavior

1. Verify module exists and is compilable
2. Build module in Debug mode (for fastest iteration)
3. Install to temporary test location or user plugins folder
4. Launch VCV Rack
5. Module should appear in module browser
6. User can:
   - Drag module into patch
   - Test widget interactions
   - Test audio processing (if at Stage 4+)
   - Adjust UI layout visually

## Success Output

```
✓ VCV Rack launched with [ModuleName]

Module loaded in browser as:
- Category: [Category from creative-brief]
- Name: [ModuleName]

Module location: [Path in Rack]

To iterate:
1. Exit Rack
2. Make code changes
3. Run /show-vcv [ModuleName] again

VCV Rack will auto-reload modified modules.
```

## Use Cases

- Visual inspection of widget layout
- Testing knob ranges and parameter behavior
- Audio routing and signal flow testing
- Real-time iteration while designing UI

## Routes To

`module-lifecycle` skill
