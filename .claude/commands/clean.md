---
name: clean
description: Interactive menu for module cleanup (uninstall, reset, destroy)
---

# /clean

When user runs `/clean [ModuleName?]`, present interactive cleanup menu.

## Behavior

**Without argument:**
Present main cleanup menu:
```
Module cleanup options:

1. List installed modules
2. Uninstall module (keep source)
3. Reset to ideation stage
4. Completely destroy module
5. Clear all caches
```

**With module name:**
```bash
/clean [ModuleName]
```

Present module-specific menu:
```
[ModuleName] cleanup options:

1. Uninstall (remove from Rack, keep source)
2. Reset to ideation (remove implementation, keep idea/mockups)
3. Destroy (completely remove everything)
4. View current status
5. Cancel
```

## Menu Routes

Each option invokes module-lifecycle skill appropriately:
- Option 1 → Shows status
- Option 2 → Uninstall workflow
- Option 3 → Reset workflow
- Option 4 → Destroy workflow
- Option 5 → Cancel and exit

## Routes To

`module-lifecycle` skill with appropriate operation
