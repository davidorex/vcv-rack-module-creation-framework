# VCV RACK MODULE FREEDOM SYSTEM - VCV Rack Module Development System

## System Components

- **Scripts**: `scripts/` - Build and installation automation
  - build-and-install.sh - Centralized build automation (7-phase pipeline: validate, build, install, verify)
  - verify-backup.sh - Backup integrity verification (Phase 7)
- **Skills**: `.claude/skills/` - Each skill follows Anthropic's pattern with `SKILL.md`, `references/`, and `assets/` subdirectories
  - module-workflow, module-ideation, module-improve (enhanced with regression testing), panel-mockup, context-resume, module-testing, module-lifecycle, build-automation, troubleshooting-docs, deep-research, design-sync, system-setup
- **Subagents**: `.claude/agents/` - foundation-agent, shell-agent, dsp-agent, gui-agent, validator, troubleshooter
- **Commands**: `.claude/commands/` - /setup, /dream, /implement, /improve, /continue, /test, /install-module, /uninstall, /show-vcv, /troubleshoot-vcv, /doc-fix, /research, /sync-design
- **Hooks**: `.claude/hooks/` - Validation gates (PostToolUse, SubagentStop, UserPromptSubmit, Stop, PreCompact, SessionStart)
- **Knowledge Base**: `troubleshooting/` - Dual-indexed (by-module + by-symptom) problem solutions

## Contracts (Single Source of Truth)

- `modules/[Name]/.ideas/` - creative-brief.md (vision), parameter-spec.md (parameters), architecture.md (DSP design), plan.md (implementation strategy)
- **State**: MODULES.md (all modules), .continue-here.md (active workflow)
- **Templates**: Contract templates stored in skill assets (`.claude/skills/*/assets/`)

## Key Principles

1. **Contracts are immutable during implementation** - All stages reference the same specs (zero drift)
2. **Dispatcher pattern** - Each subagent runs in fresh context (no accumulation)
3. **Discovery through play** - Features found via slash command autocomplete and decision menus
4. **Instructed routing** - Commands expand to prompts, Claude invokes skills
5. **Required Reading injection** - Critical patterns (`vcv-critical-patterns.md`) are mandatory reading for all subagents to prevent repeat mistakes

## Checkpoint Protocol (System-Wide)

At every significant completion point (stage complete, phase complete, files generated, contract created):

1. Auto-commit changes (if in workflow)
2. Update state files (.continue-here.md, MODULES.md)
3. ALWAYS present numbered decision menu:

✓ [Completion statement]

What's next?

1. [Primary action] (recommended)
2. [Secondary action]
3. [Discovery option] ← User discovers [feature]
4. [Alternative path]
5. Other

Choose (1-5): _

4. WAIT for user response - NEVER auto-proceed
5. Execute chosen action

This applies to:

- All workflow stages (0-6)
- All subagent completions
- Contract creation (creative-brief, panel mockups, parameter-spec)
- Any point where user needs to decide next action

Do NOT use AskUserQuestion tool for decision menus - use inline numbered lists as shown above.

## Subagent Invocation Protocol

Stages 2-5 use the dispatcher pattern:

- Stage 2 → You **must** invoke foundation-agent via Task tool
- Stage 3 → You **must** invoke shell-agent via Task tool
- Stage 4 → You **must** invoke dsp-agent via Task tool
- Stage 5 → You **must** invoke gui-agent via Task tool

The module-workflow skill orchestrates, it does **not** implement.

After subagent completes:

1. Read subagent's return message
2. Commit changes
3. Update .continue-here.md
4. Update MODULES.md
5. Present numbered decision menu
6. Wait for user response

This ensures consistent checkpoint behavior and clean separation of concerns.

## Workflow Entry Points

- First-time setup: `/setup` (validate and configure dependencies)
- New module: `/dream` → `/plan` → `/implement`
- Resume work: `/continue [ModuleName]`
- Modify existing: `/improve [ModuleName]`
- Test module: `/test [ModuleName]`

## Implementation Status

- ✓ Phase 0: Foundation & Contracts (complete)
- ✓ Phase 1: Discovery System (complete)
- ✓ Phase 2: Workflow Engine (complete)
- ✓ Phase 3: Implementation Subagents (complete)
- ✓ Phase 4: Build & Troubleshooting System (complete)
- ✓ Phase 5: Validation System (complete - hybrid validation operational)
- ✓ Phase 6: SVG Panel System (complete)
- ✓ Phase 7: Polish & Enhancement (complete - feedback loop operational)

## Phase 7 Components (Polish & Enhancement)

### Skills

- **system-setup** (`.claude/skills/system-setup/`) - Dependency validation and environment configuration
- **module-lifecycle** (`.claude/skills/module-lifecycle/`) - Installation/uninstallation management
- **design-sync** (`.claude/skills/design-sync/`) - Mockup ↔ brief validation, drift detection
- **deep-research** (`.claude/skills/deep-research/`) - Multi-level problem investigation (3-level graduated protocol)
- **troubleshooting-docs** (`.claude/skills/troubleshooting-docs/`) - Knowledge base capture with dual-indexing
- **module-improve** (`.claude/skills/module-improve/`) - Version management with regression testing (enhanced)

### Commands

**Setup:**

- `/setup` - Validate and configure system dependencies (first-time setup)

**Lifecycle:**

- `/dream` - Ideate new module concept
- `/implement [Name]` - Build module through 7-stage workflow
- `/continue [Name]` - Resume paused workflow
- `/improve [Name]` - Fix bugs or add features (with regression testing)
- `/reconcile [Name]` - Reconcile state between planning and implementation

**Deployment:**

- `/install-module [Name]` - Install to VCV Rack plugins folder
- `/uninstall [Name]` - Remove binaries (keep source)
- `/reset-to-ideation [Name]` - Remove implementation, keep idea/mockups
- `/destroy [Name]` - Completely remove everything (with backup)

**Quality:**

- `/test [Name]` - Run validation suite
- `/sync-design [Name]` - Validate panel ↔ brief consistency
- `/research [topic]` - Deep investigation (3-level protocol)
- `/doc-fix` - Document solved problems (with option to promote to Required Reading)
- `/add-critical-pattern` - Directly add current problem to Required Reading (fast path)

### Knowledge Base

- `troubleshooting/build-failures/` - Build and compilation errors
- `troubleshooting/runtime-issues/` - Crashes, exceptions, performance issues
- `troubleshooting/gui-issues/` - SVG panel and rendering problems
- `troubleshooting/api-usage/` - VCV Rack API misuse and patterns
- `troubleshooting/dsp-issues/` - Audio processing problems
- `troubleshooting/parameter-issues/` - Parameter config and state management
- `troubleshooting/validation-problems/` - Testing failures
- `troubleshooting/patterns/` - Common patterns and solutions
- `troubleshooting/patterns/vcv-critical-patterns.md` - **REQUIRED READING** for all subagents (Stages 2-5)

### Scripts

- `scripts/build-and-install.sh` - Build automation (Makefile-based)
- `scripts/verify-backup.sh` - Backup integrity verification

## Feedback Loop

The complete improvement cycle:

```
Build → Test → Find Issue → Research → Improve → Document → Validate → Deploy
    ↑                                                                      ↓
    └──────────────────────────────────────────────────────────────────────┘
```

- **deep-research** finds solutions (3-level graduated protocol: Quick → Moderate → Deep)
- **module-improve** applies changes (with regression testing and backup verification)
- **troubleshooting-docs** captures knowledge (dual-indexed for fast lookup)
- **design-sync** prevents drift (validates contracts before implementation)
- **module-lifecycle** manages deployment (install/uninstall with Rack rescan)

## VCV Rack Specific Notes

### Build System
- Uses Makefile (not CMake) - official VCV Rack build system
- Requires RACK_DIR environment variable pointing to Rack SDK
- Build commands: `make`, `make dist`, `make install`
- Platform-specific: Mac (arm64/x64), Linux (x64), Windows (x64)

### Panel Design
- SVG panels: 128.5mm height (fixed), width = HP × 5.08mm
- Component placeholders: Red=params, Green=inputs, Blue=outputs, Magenta=lights
- helper.py automation: `$RACK_DIR/helper.py createmodule [Name] res/[Name].svg src/[Name].cpp`

### Module Structure
- plugin.json - Manifest (slug, version, modules array)
- src/[Module].cpp - Module + ModuleWidget implementation
- res/[Module].svg - Panel graphic
- Presets/*.vcvm - Factory presets (JSON format)

### DSP Considerations
- Per-sample processing (not buffer-based like JUCE)
- process(const ProcessArgs &args) called at sample rate
- Voltage standards: ±5V audio/CV, 1V/oct for pitch
- Polyphony: up to 16 channels per cable

### Distribution
- VCV Library (open-source): Submit to github.com/VCVRack/library
- Manual install: Copy to ~/Documents/Rack2/plugins-[platform]-[arch]/
- Auto-builds for all platforms via VCV Library system
