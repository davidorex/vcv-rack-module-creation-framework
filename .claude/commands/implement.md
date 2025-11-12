---
name: implement
description: Build module through implementation stages 2-6
---

# /implement

When user runs `/implement [ModuleName?]`, invoke the module-workflow skill to build the module (stages 2-6 only).

**NOTE:** Planning (stages 0-1) must be completed first via `/plan` command.

## Preconditions

**1. Check MODULES.md status:**

Valid starting states:
- 🚧 Stage 1 (planning complete) → Start at stage 2
- 🚧 Stage 2-6 (in progress) → Resume from current stage

**Block if wrong state:**

If 💡 Ideated or 🚧 Stage 0:
```
[ModuleName] planning is not complete.

Run /plan [ModuleName] first to complete stages 0-1:
- Stage 0: Research → architecture.md
- Stage 1: Planning → plan.md

Then run /implement to build (stages 2-6).
```

If ✅ Working:
```
[ModuleName] is already implemented and working.

Use /improve [ModuleName] to make changes or add features.
```

**2. REQUIRE planning artifacts exist:**

Check for required contracts:
```bash
test -f "modules/${MODULE_NAME}/.ideas/architecture.md" || echo "✗ architecture.md MISSING"
test -f "modules/${MODULE_NAME}/.ideas/plan.md" || echo "✗ plan.md MISSING"
test -f "modules/${MODULE_NAME}/.ideas/parameter-spec.md" || echo "✗ parameter-spec.md MISSING"
```

If any missing, BLOCK with:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ BLOCKED: Missing planning artifacts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation requires complete planning contracts:

Required contracts:
[✓/✗] architecture.md - [exists/MISSING]
[✓/✗] plan.md - [exists/MISSING]
[✓/✗] parameter-spec.md - [exists/MISSING]

HOW TO UNBLOCK:
1. Run: /plan [ModuleName]
   - Completes Stage 0 (Research) → architecture.md
   - Completes Stage 1 (Planning) → plan.md

2. If parameter-spec.md missing:
   - Run: /dream [ModuleName]
   - Create and finalize UI mockup
   - Finalization generates parameter-spec.md

Once all contracts exist, /implement will proceed.
```

## Behavior

**Without argument:**
List modules eligible for implementation:
- Status: 🚧 Stage 1 (ready to start)
- Status: 🚧 Stage 2-6 (in progress)

Present numbered menu of eligible modules.

**With module name:**
```bash
/implement [ModuleName]
```

Verify preconditions, then invoke the module-workflow skill.

## The Implementation Stages

The module-workflow skill executes stages 2-6 using subagent dispatcher pattern:

1. **Stage 2:** Foundation (10-15 min) → CMakeLists.txt, structure (foundation-agent)
2. **Stage 3:** Shell (5-10 min) → Compiling skeleton (shell-agent)
3. **Stage 4:** DSP (30 min - 3 hrs) → Module processing logic (dsp-agent)
4. **Stage 5:** GUI (20-60 min) → Widget interface (gui-agent)
5. **Stage 6:** Validation (20-40 min) → Plugin format, presets, docs (validator)

Each stage:
1. Invokes specialized subagent via Task tool
2. Commits changes after subagent completes
3. Updates state files (.continue-here.md, MODULES.md)
4. Presents numbered decision menu
5. Waits for user response

## Decision Menus

At each stage completion, you'll see:
```
✓ Stage [N] complete: [accomplishment]

What's next?
1. Continue to Stage [N+1] (recommended)
2. Review [what was created]
3. [Stage-specific option]
4. Run tests/validation
5. Pause here
6. Other

Choose (1-6): _
```

## Pause & Resume

If user pauses:
- .continue-here.md updated with current stage
- MODULES.md status updated
- Changes committed

Resume with `/continue [ModuleName]`

## Output

By completion, you have:
- ✅ Compiling VCV Rack plugin
- ✅ Working module processing logic
- ✅ Functional widget interface
- ✅ Properly formatted plugin
- ✅ Factory presets
- ✅ Git history with all stages

## Workflow Integration

Complete module development flow:
1. `/dream [ModuleName]` - Creative brief + UI mockup
2. `/plan [ModuleName]` - Research and planning (Stages 0-1)
3. `/implement [ModuleName]` - Build module (Stages 2-6)
4. `/install-module [ModuleName]` - Deploy to system folders
