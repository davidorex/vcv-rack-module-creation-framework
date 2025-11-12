---
name: improve
description: Modify completed modules with versioning
---

# /improve

When user runs `/improve [ModuleName] [description?]`, invoke the module-improve skill.

## Preconditions

**Check MODULES.md status:**
- Module MUST exist
- Status MUST be ✅ Working OR 📦 Installed
- Status MUST NOT be 🚧 In Development

**If status is 🚧:**
Reject with message:
```
[ModuleName] is still in development (Stage [N]).
Complete the workflow first with /continue [ModuleName].
Cannot use /improve on in-progress modules.
```

**If status is 💡:**
Reject with message:
```
[ModuleName] is not implemented yet (Status: 💡 Ideated).
Use /implement [ModuleName] to build it first.
```

## Behavior

**Without module name:**
Present menu of completed modules (✅ or 📦 status).

**With module, no description:**
Ask what to improve:
```
What would you like to improve in [ModuleName]?

1. From existing brief ([feature].md found in improvements/)
2. Describe the change
```

**With vague description:**
Detect vagueness (lacks specific feature, action, or criteria).

Present choice:
```
Your request is vague. How should I proceed?

1. Brainstorm approaches first → creates improvement brief
2. Just implement something reasonable → Phase 0.5 investigation
```

**With specific description:**
Proceed directly to module-improve skill with Phase 0.5 investigation.

## Vagueness Detection

Request IS vague if it lacks:
- Specific feature name
- Specific action
- Acceptance criteria

Examples of VAGUE:
- "improve the filters"
- "better presets"
- "UI feels cramped"

Examples of SPECIFIC:
- "add resonance parameter to filter, range 0-1"
- "fix bypass parameter - not muting audio"
- "increase window height to 500px"

## Module-Improve Workflow

The module-improve skill executes:
1. **Phase 0.5:** Investigation (root cause analysis)
2. **Approval:** Wait for user confirmation
3. **Version selection:** Ask PATCH/MINOR/MAJOR
4. **Backup:** Copy to backups/[Module]/v[X.Y.Z]/
5. **Implementation:** Make code changes
6. **CHANGELOG:** Update with version and description
7. **Git commit:** Conventional format with version
8. **Git tag:** Tag release (v[X.Y.Z])
9. **Build:** Compile Release mode
10. **Install:** Deploy to system folders

## Output

Changes are production-ready:
- Versioned and backed up
- Built in Release mode
- Installed to system folders
- Documented in CHANGELOG
- Git history preserved
