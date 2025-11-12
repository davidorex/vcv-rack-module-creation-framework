---
name: uninstall
description: Remove module from Rack folder (keep source)
---

# /uninstall

When user runs `/uninstall [ModuleName]`, invoke the module-lifecycle skill for uninstallation.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist
- Status SHOULD be 📦 Installed (but works for any state)

**If module not installed:**
```
[ModuleName] is not currently installed (Status: [Current]).

Source code remains in place - uninstall is not needed.
```

## Behavior

1. Verify module exists
2. Locate installed module in Rack folder
3. Remove module files:
   - ~/.Rack2/plugins/[PluginName]/ (entire directory)
4. Clear Rack plugin cache
5. Update MODULES.md: 📦 Installed → ✅ Working
6. Save logs to `logs/[ModuleName]/uninstall_TIMESTAMP.log`

## Success Output

```
✓ [ModuleName] uninstalled successfully

Removed from:
- ~/.Rack2/plugins/[PluginName]/

Source code remains in place at:
- modules/[ModuleName]/

To reinstall later:
/install-module [ModuleName]
```

## What This Does NOT Do

- Does NOT delete source code
- Does NOT affect .ideas/ or documentation
- Does NOT affect git history
- Source remains completely intact

## Routes To

`module-lifecycle` skill
