---
name: plan
description: Interactive research and planning for module (Stages 0-1)
---

# /plan

When user runs `/plan [ModuleName?]`, invoke the module-planning skill to handle Stages 0-1 (Research and Planning).

## Preconditions

**Check MODULES.md status:**

1. Verify module exists in MODULES.md
2. Check current status:
   - If 💡 Ideated: OK to proceed (start fresh)
   - If 🚧 Stage 0: OK to proceed (resume research)
   - If 🚧 Stage 1: OK to proceed (resume planning)
   - If 🚧 Stage 2+: **BLOCK** - Module already in implementation

**If module is Stage 2 or beyond:**
```
[ModuleName] is already in implementation (Stage [N]).

Stages 0-1 (planning) are complete. Use:
- /continue [ModuleName] - Resume from current stage
- /implement [ModuleName] - Review implementation workflow
```

**Check for creative brief:**
```
modules/[ModuleName]/.ideas/creative-brief.md
```

If missing, offer:
```
✗ No creative brief found for [ModuleName]

Planning requires a creative brief to define module vision.

Would you like to:
1. Create one now (/dream [ModuleName])
2. Skip planning (not recommended - leads to implementation drift)
```

## Behavior

**Without argument:**
List modules eligible for planning:
- Status: 💡 Ideated
- Status: 🚧 Stage 0 (resume)
- Status: 🚧 Stage 1 (resume)

Present numbered menu of eligible modules or offer to create new module.

**With module name:**
```bash
/plan [ModuleName]
```

Verify preconditions, then invoke the module-planning skill.

## The Planning Stages

The module-planning skill executes:

**Stage 0: Research (5-10 min)**
- Identify module technical approach
- Research VCV Rack module patterns
- Research professional module examples
- Research parameter ranges
- Design sync (if mockup exists)
- Output: architecture.md (implementation specification)

**Stage 1: Planning (2-5 min)**
- Calculate complexity score
- Determine implementation strategy (single-pass vs phased)
- Create phase breakdown for complex modules
- Output: plan.md (implementation strategy)

## Contract Enforcement

**Stage 0 (Research):**
- Requires: creative-brief.md
- Creates: architecture.md

**Stage 1 (Planning) BLOCKS if missing:**
- parameter-spec.md (from UI mockup finalization)
- architecture.md (from Stage 0)

If blocked at Stage 1:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ BLOCKED: Cannot proceed to Stage 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Missing implementation contracts:
✓ creative-brief.md - exists
✗ parameter-spec.md - MISSING (required)
[✓/✗] architecture.md - [status]

HOW TO UNBLOCK:
1. parameter-spec.md: Complete ui-mockup workflow
   Run: /dream [ModuleName] → Choose "Create UI mockup" → Finalize

2. architecture.md: Complete Stage 0 (Research)
   Run: /plan [ModuleName] → Complete Stage 0 first

Once both contracts exist, Stage 1 will proceed.
```

## Handoff to Implementation

After Stage 1 completes, the skill creates handoff state:
- .continue-here.md updated with "ready_for_implementation: true"
- User runs `/implement [ModuleName]` to begin Stage 2 (Foundation)

## Workflow Integration

Complete module development flow:
1. `/dream [ModuleName]` - Create creative brief + UI mockup
2. `/plan [ModuleName]` - Research and planning (Stages 0-1)
3. `/implement [ModuleName]` - Build module (Stages 2-6)

## Output

By completion of planning, you have:
- ✅ architecture.md (implementation specification)
- ✅ plan.md (implementation strategy with complexity score)
- ✅ Updated MODULES.md status
- ✅ Git commits for both stages
- ✅ Ready for implementation handoff
