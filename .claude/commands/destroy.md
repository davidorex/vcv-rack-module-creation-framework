---
name: destroy
description: Completely remove module (backup, then delete)
---

# /destroy

When user runs `/destroy [ModuleName]`, invoke the module-lifecycle skill.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist

**CRITICAL: Confirm destruction:**
```
⚠️  DESTRUCTIVE OPERATION - This cannot be undone!

Will completely remove [ModuleName]:
- ALL source code
- ALL ideas and mockups
- ALL build artifacts
- ALL documentation
- Module entry from MODULES.md

A backup will be saved to:
backups/[ModuleName]/complete-backup-TIMESTAMP/

But recovery requires manual restoration.

Type the module name to confirm: _
```

## Behavior

1. Verify module exists
2. Show what will be destroyed
3. Require explicit confirmation (type module name)
4. **BACKUP PHASE:**
   - Create complete backup: `backups/[ModuleName]/complete-backup-TIMESTAMP/`
   - Verify backup integrity (checksum validation)
   - Save backup manifest with file listing
5. **REMOVAL PHASE:**
   - Uninstall from Rack if installed
   - Delete `modules/[ModuleName]/` (entire directory)
   - Remove from MODULES.md
   - Remove from .continue-here.md (if active)
   - Remove all logs for this module (optional)
   - Clean git index (optional)
6. Save destruction log to `logs/[ModuleName]/destroyed_TIMESTAMP.log`

## Success Output

```
✓ [ModuleName] completely destroyed

Complete backup saved to:
backups/[ModuleName]/complete-backup-TIMESTAMP/

This backup contains:
- All source code
- All ideas and documentation
- Build artifacts
- Full git history

To recover:
1. Manual restore from backup directory
2. Or contact system administrator

Module removed from:
- MODULES.md
- .continue-here.md
- Build system
```

## What Cannot Be Recovered

Once destroyed:
- No automatic recovery (only from backup)
- Git history for this module can be permanently removed
- System dependencies are cleaned up

## Routes To

`module-lifecycle` skill
