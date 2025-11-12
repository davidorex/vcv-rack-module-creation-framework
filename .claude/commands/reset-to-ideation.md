---
name: reset-to-ideation
description: Remove implementation, keep idea and mockups
---

# /reset-to-ideation

When user runs `/reset-to-ideation [ModuleName]`, invoke the module-lifecycle skill.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist
- Status can be anything (🚧 or ✅)

**Confirm operation:**
```
⚠️  This will remove ALL implementation files but preserve your ideas.

[ModuleName] will be reset to:
- ✅ creative-brief.md
- ✅ UI mockups (if created)
- ❌ architecture.md (removed)
- ❌ plan.md (removed)
- ❌ Source code (removed)
- ❌ Build artifacts (removed)

Continue? (yes/no): _
```

## Behavior

1. Verify module exists
2. List what will be removed
3. Back up entire source tree to `backups/[ModuleName]/pre-reset/`
4. Remove:
   - `modules/[ModuleName]/src/` (source code)
   - `modules/[ModuleName]/CMakeLists.txt`
   - `modules/[ModuleName]/build/` (build artifacts)
   - `.ideas/architecture.md`
   - `.ideas/plan.md`
   - All git history specific to this module (optional, controlled by user)
5. Keep:
   - `.ideas/creative-brief.md`
   - `.ideas/mockups/` (all UI designs)
   - `.ideas/improvements/`
6. Update MODULES.md: Current → 💡 Ideated
7. Save logs to `logs/[ModuleName]/reset_TIMESTAMP.log`

## Success Output

```
✓ [ModuleName] reset to ideation stage

Preserved:
- .ideas/creative-brief.md
- .ideas/mockups/ (all versions)

Removed:
- Source code
- Build artifacts
- Implementation contracts

Backup saved to:
backups/[ModuleName]/pre-reset/

To resume implementation:
1. Recreate mockup and finalize (if needed)
2. Run /plan [ModuleName]
3. Run /implement [ModuleName]
```

## Routes To

`module-lifecycle` skill
