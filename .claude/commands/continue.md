---
name: continue
description: Resume paused workflow from checkpoint
---

# /continue

When user runs `/continue [ModuleName?]`, invoke the context-resume skill to pick up from last checkpoint.

## Preconditions

**Check .continue-here.md exists:**
- File MUST exist
- MUST contain: stage, module_name, last_action, checkpoint_time

**If .continue-here.md missing:**
```
No active workflow checkpoint found.

Available modules:
- [ModuleName] (Stage [N])
- [ModuleName] (Stage [N])

Use:
- /implement [ModuleName] - Start implementation
- /improve [ModuleName] - Make changes to completed module
```

## Behavior

**Without argument:**
Read .continue-here.md and resume that module at that stage:
```bash
/continue
```

Equivalent to `/continue [ModuleName]` where ModuleName is from .continue-here.md.

**With module name:**
```bash
/continue [ModuleName]
```

Find checkpoint in .continue-here.md for that module.

If checkpoint not found:
```
No checkpoint found for [ModuleName].

Check MODULES.md status or use:
- /implement [ModuleName] - Start implementation
- /improve [ModuleName] - Make changes to completed module
```

## Context Recovery

The skill will:
1. Read .continue-here.md
2. Restore module context
3. Show what stage was paused
4. Show last action completed
5. Resume from next action

## Workflow Integration

Resume paused work:
1. User pauses during `/implement` → checkpoint saved
2. User runs `/continue [ModuleName]`
3. Workflow resumes from exact point paused
4. No lost context, no repeated work

## Output

Context fully restored with:
- Current stage clearly shown
- Previous actions reviewed
- Ready to continue implementation
