---
name: sync-design
description: Validate mockup and brief consistency (detect drift)
---

# /sync-design

When user runs `/sync-design [ModuleName?]`, invoke the design-sync skill.

## Preconditions

**Check module state:**
- Module MUST exist in MODULES.md
- MUST have creative-brief.md
- MUST have UI mockup (at least one version)

**If contracts missing:**
```
[ModuleName] is missing required contracts for design sync.

Required:
[✓/✗] creative-brief.md
[✓/✗] UI mockup (in .ideas/mockups/)

Create these first with /dream [ModuleName]
```

## Behavior

**Without argument:**
List modules with both creative brief and UI mockups:
```
Modules available for design sync:
1. [ModuleName] - Brief ✓, Mockup ✓
2. [ModuleName] - Brief ✓, Mockup ✓
3. [ModuleName] - Brief ✓, Mockup ✗ (no mockup)

Choose module: _
```

**With module name:**
```bash
/sync-design [ModuleName]
```

Run design validation.

## Validation Checks

The design-sync skill validates:

1. **Brief → Mockup consistency:**
   - Module name matches
   - Category/function consistent
   - Parameter count reasonable
   - Visual style aligns with brief vision

2. **Mockup → Parameter spec consistency:**
   - All widgets in mockup have parameter entries
   - Parameter ranges match widget types
   - Default values are reasonable
   - All brief requirements are represented

3. **Drift detection:**
   - Warnings if mockup doesn't match latest brief
   - Suggestions for updates

## Output

Validation report:
```
✓ Design sync passed for [ModuleName]

Consistency checks:
✓ Brief → Mockup alignment
✓ Mockup → Parameter spec completeness
✓ No drift detected

All contracts in sync. Ready for planning/implementation.
```

Or if drift found:
```
⚠️  Design drift detected in [ModuleName]

Issues:
- Mockup shows [Feature] not mentioned in brief
- Parameter spec has [Param] missing from mockup
- Widget count mismatch

Recommend updating:
1. creative-brief.md (if design changed)
2. UI mockup (if brief changed)

Then run /sync-design again.
```

## Routes To

`design-sync` skill
