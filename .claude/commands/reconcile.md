---
name: reconcile
description: Reconcile state drift between planning and implementation
---

# /reconcile

When user runs `/reconcile [ModuleName?]`, detect and fix inconsistencies between planning contracts and implementation state.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist
- Status MUST be 🚧 Stage 2 or higher

**If module not in implementation:**
```
[ModuleName] is not yet in implementation (Status: [Current]).

Reconciliation is not needed until Stage 2+.

Use /implement [ModuleName] to start building.
```

## Behavior

**Without argument:**
List modules in implementation state that might have drift:
```
Modules eligible for reconciliation:
1. [ModuleName] - Stage [N]
2. [ModuleName] - Stage [N]

Choose module: _
```

**With module name:**
```bash
/reconcile [ModuleName]
```

Run reconciliation checks.

## Reconciliation Checks

The skill will:

1. **Compare planning contracts with current state:**
   - Verify architecture.md matches DSP implementation
   - Verify plan.md matches actual stage progress
   - Verify parameter-spec.md matches widget code
   - Verify creative-brief.md aligns with current module vision

2. **Detect drift patterns:**
   - Unimplemented features from plan.md
   - Extra features not in architecture.md
   - Parameter mismatches (spec vs code)
   - UI differences (mockup vs implementation)

3. **Categorize issues:**
   - Breaking changes (major rework needed)
   - Non-critical drifts (documentation fixes)
   - Improvements (implementation exceeds plan)

## Output

Reconciliation report:
```
✓ [ModuleName] reconciliation complete

State consistency: [Status]

Checks:
[✓/✗] architecture.md ↔ DSP implementation
[✓/✗] plan.md ↔ current stage progress
[✓/✗] parameter-spec.md ↔ widget code
[✓/✗] creative-brief.md ↔ module vision

Issues found: [N]

[If issues exist]
Recommended actions:
1. [Issue 1 with fix option]
2. [Issue 2 with fix option]
3. [Issue 3 with fix option]

Run: /reconcile --auto-fix [ModuleName]
To automatically fix non-breaking issues.
```

## Auto-Fix Mode

```bash
/reconcile [ModuleName] --auto-fix
```

Automatically reconciles:
- Updates architecture.md to match implementation
- Updates plan.md to match actual progress
- Notes code changes in CHANGELOG
- Creates commit documenting drift resolution

Does NOT auto-fix breaking changes - those require manual review.

## Routes To

State reconciliation (built-in to platform)
