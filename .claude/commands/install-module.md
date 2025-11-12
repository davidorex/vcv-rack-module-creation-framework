---
name: install-module
description: Install completed module to Rack folder for use
---

# /install-module

When user runs `/install-module [ModuleName]`, invoke the module-lifecycle skill.

## Preconditions

Before running this command:
- Module status must be ✅ Working (Stage 6 complete)
- Module must have successful Release build
- Widget validation must have passed
- Module must have been tested in Rack from build folder

If any precondition fails, block execution and guide user to complete Stage 6 first.

## Behavior

1. Verify module exists and status is ✅ Working
2. Build module in Release mode (optimized, production-ready)
3. Extract PLUGIN_NAME from CMakeLists.txt or manifest.json
4. Remove old versions from Rack plugins folder
5. Install to:
   - User folder: `~/.Rack2/plugins/[PluginName]/`
   - System folder: `/opt/Rack2/plugins/[PluginName]/` (if permitted)
6. Set proper permissions (755)
7. Update Rack plugin cache
8. Verify installation (check timestamps, file sizes)
9. Update MODULES.md: ✅ Working → 📦 Installed
10. Save logs to `logs/[ModuleName]/install_TIMESTAMP.log`

## Success Output

```
✓ [ModuleName] installed successfully

Installed location:
- ~/.Rack2/plugins/[PluginName]/plugin.so (X.X MB)
- ~/.Rack2/plugins/[PluginName]/plugin.json (manifest)

Cache status: Updated

Next steps:
1. Restart Rack (if running)
2. Module should appear in Rack's module browser
3. Test the module in a patch
4. Check audio routing and controls work correctly
```

## Routes To

`module-lifecycle` skill
