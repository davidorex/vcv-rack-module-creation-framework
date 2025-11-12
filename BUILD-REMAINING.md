# VCV Rack Module Freedom System - Remaining Build Tasks

**Current Status:** Foundation complete (foundation-agent, shell-agent, core docs, critical patterns)

**Remaining Work:** Complete system infrastructure for working end-to-end workflow

---

## Completed (✅)

- ✅ `.claude/CLAUDE.md` - System documentation
- ✅ `README.md` - Quick start, overview
- ✅ `MODULES.md` - Module registry
- ✅ `troubleshooting/patterns/vcv-critical-patterns.md` - Required reading (11 patterns)
- ✅ `.claude/agents/foundation-agent.md` - Stage 2 implementation
- ✅ `.claude/agents/shell-agent.md` - Stage 3 implementation

---

## Priority 1: Remaining Subagents (CRITICAL)

### `.claude/agents/dsp-agent.md`
**Purpose:** Stage 4 - Implement audio processing in process() method
**Key adaptations from JUCE:**
- processBlock() → process(const ProcessArgs& args)
- Buffer-based → Per-sample processing
- APVTS parameter access → params[].getValue()
- Polyphony handling (getChannels(), setChannels())
- args.sampleTime instead of sampleRate
- Anti-aliasing (polyBLEP, oversampling)

**Implementation notes:**
- Read architecture.md for DSP design
- Implement process() with per-sample DSP
- Handle polyphony (up to 16 channels per cable)
- Apply voltage standards (±5V, 1V/oct pitch)
- Optimize for per-sample execution (no divisions/sqrt)
- Return JSON report

### `.claude/agents/gui-agent.md`
**Purpose:** Stage 5 - Finalize ModuleWidget component positioning
**Key adaptations from JUCE:**
- WebView integration → SVG panel (already done in Stage 3!)
- Parameter bindings → Already handled by helper.py mm2px positioning
- Custom widgets → NanoVG draw() overrides

**Implementation notes:**
- shell-agent already created panel and positioning
- gui-agent mainly validates and adds custom widgets if needed
- Custom displays (LED readouts, waveform views, etc.)
- Dark panel variant support (optional)
- Return JSON report

**SIMPLIFICATION:** This stage may be minimal or combined with Stage 3 for VCV Rack, since helper.py handles most GUI work.

### `.claude/agents/validator.md`
**Purpose:** Stage 6 - Create presets, test, generate CHANGELOG
**Key adaptations from JUCE:**
- .vstpreset → .vcvm presets (JSON format)
- pluginval → Manual test protocol
- System installation → VCV Rack plugins folder

**Implementation notes:**
- Create 3-5 factory presets (.vcvm JSON files)
- Generate CHANGELOG.md from version history
- Validate module loads in VCV Rack
- Test polyphony, CV modulation, sample rates
- Return JSON report

### `.claude/agents/troubleshooter.md`
**Purpose:** Investigate build failures and runtime errors
**Key adaptations from JUCE:**
- CMake errors → Makefile errors
- JUCE API issues → VCV Rack API issues
- RACK_DIR validation

**Implementation notes:**
- Parse make output for errors
- Check RACK_DIR environment variable
- Validate plugin.json format
- Check SVG panel issues
- Return investigation report with suggested fixes

---

## Priority 2: Core Skills (CRITICAL WORKFLOW)

### `.claude/skills/module-workflow/SKILL.md`
**Purpose:** Orchestrate Stages 2-6 via dispatcher pattern
**Adaptation:** Copy from plugin-workflow, rename all JUCE→VCV references

**Key changes:**
- plugin-workflow → module-workflow
- plugins/ → modules/
- Invoke VCV subagents (foundation, shell, dsp, gui, validator)
- PLUGINS.md → MODULES.md updates
- build-automation adapted for Makefile

### `.claude/skills/module-ideation/SKILL.md`
**Purpose:** Brainstorm module concepts, create creative-brief.md
**Adaptation:** Minimal from plugin-ideation

**Key changes:**
- Plugin → Module terminology
- Add HP width estimation (4-20 HP)
- Emphasize CV/gate/audio I/O (modular paradigm)
- Eurorack category selection

###`.claude/skills/module-planning/SKILL.md`
**Purpose:** Stages 0-1 (research DSP, create architecture.md + plan.md)
**Adaptation:** Minimal from plugin-planning

**Key changes:**
- Modular synthesis research focus
- CV routing diagrams
- 1V/oct pitch CV standard
- Polyphony strategy

### `.claude/skills/panel-mockup/SKILL.md`
**Purpose:** 2-phase panel workflow (design iteration → scaffolding)
**Adaptation:** Major from ui-mockup

**Phase A (Design Iteration):**
1. Generate `v[N]-panel.yaml` (machine-readable spec)
2. Generate `v[N]-panel.svg` (Inkscape-compatible, component layer)
3. STOP - Present menu, iterate or finalize

**Phase B (Implementation Scaffolding, after approval):**
4. Copy finalized SVG to res/[Module].svg
5. Run helper.py createmodule (auto-generate C++)
6. Generate parameter-spec.md from finalized panel
7. Generate integration checklist

### `.claude/skills/module-improve/SKILL.md`
**Purpose:** Version management, fix bugs, add features
**Adaptation:** Minimal from plugin-improve

**Key changes:**
- plugin.json version field instead of CMakeLists.txt
- VCV-specific regression tests (polyphony, CV, sample rates)
- Backup before changes

### `.claude/skills/module-testing/SKILL.md`
**Purpose:** Automated validation suite
**Adaptation:** Major from plugin-testing

**VCV-specific tests:**
- Build verification (make succeeds)
- plugin.json validation (slug format, version)
- SVG panel validation (dimensions, component layer)
- Manual test protocol (polyphony, CV, 44.1k-192k Hz)

### `.claude/skills/module-lifecycle/SKILL.md`
**Purpose:** Install/uninstall/reset/destroy operations
**Adaptation:** Minimal from plugin-lifecycle

**Key changes:**
- System installation paths (~/Documents/Rack2/plugins-*)
- No DAW cache clearing (VCV Rack rescans automatically)
- Platform detection (mac-arm64, mac-x64, linux-x64, win-x64)

### `.claude/skills/build-automation/SKILL.md`
**Purpose:** Coordinate build process
**Adaptation:** Major from build-automation

**Key changes:**
- CMake → Makefile
- `make` instead of `cmake --build`
- RACK_DIR validation
- Platform-specific Rack plugins folder

### `.claude/skills/system-setup/SKILL.md`
**Purpose:** Validate dependencies (first-time setup)
**Adaptation:** Major from system-setup

**VCV-specific checks:**
- RACK_DIR environment variable set
- Rack SDK exists and valid (rack.hpp present)
- Make installed
- C++ compiler (g++/clang++)
- Python 3 (for helper.py)

### `.claude/skills/troubleshooting-docs/SKILL.md`
**Purpose:** Capture solutions to knowledge base
**Adaptation:** Minimal from troubleshooting-docs

**Key changes:**
- Dual-indexed by symptom (build-failures/, runtime-issues/, etc.)
- Option to promote to Required Reading (vcv-critical-patterns.md)

### `.claude/skills/deep-research/SKILL.md`
**Purpose:** 3-level problem investigation
**Adaptation:** None (target-agnostic, works as-is)

**3 levels:**
- Tier 1: Quick (single-agent, 1-2 min)
- Tier 2: Moderate (multi-agent parallel, 3-5 min)
- Tier 3: Deep (comprehensive, 5-10 min)

### `.claude/skills/design-sync/SKILL.md`
**Purpose:** Validate panel ↔ brief consistency
**Adaptation:** Minimal from design-sync

**Key changes:**
- WebView mockup → SVG panel
- Check HP width matches creative-brief.md
- Check parameter count matches parameter-spec.md

### `.claude/skills/context-resume/SKILL.md`
**Purpose:** Resume from .continue-here.md checkpoints
**Adaptation:** None (target-agnostic, works as-is)

---

## Priority 3: Commands (USER ENTRY POINTS)

All commands in `.claude/commands/*.md` expand to prompts that invoke skills.

### `/setup.md`
**Prompt:** "Run system-setup skill to validate VCV Rack SDK and dependencies"

### `/dream.md`
**Prompt:** "Run module-ideation skill for [Name]"

### `/plan.md`
**Prompt:** "Run module-planning skill for [Name] (Stages 0-1)"

### `/implement.md`
**Prompt:** "Run module-workflow skill for [Name] (Stages 2-6)"

### `/continue.md`
**Prompt:** "Run context-resume skill for [Name]"

### `/improve.md`
**Prompt:** "Run module-improve skill for [Name]"

### `/test.md`
**Prompt:** "Run module-testing skill for [Name]"

### `/install-module.md`
**Prompt:** "Run module-lifecycle skill with action=install for [Name]"

### `/uninstall.md`
**Prompt:** "Run module-lifecycle skill with action=uninstall for [Name]"

### `/clean.md`
**Prompt:** "Run module-lifecycle skill with action=menu for [Name] (interactive cleanup)"

### `/reset-to-ideation.md`
**Prompt:** "Run module-lifecycle skill with action=reset for [Name]"

### `/destroy.md`
**Prompt:** "Run module-lifecycle skill with action=destroy for [Name] (with backup)"

### `/show-vcv.md`
**Prompt:** "Open VCV Rack and load [Name] module for visual inspection"
**Implementation:** `open -a "VCV Rack 2" && echo "Module: [Name]"`

### `/sync-design.md`
**Prompt:** "Run design-sync skill for [Name]"

### `/research.md`
**Prompt:** "Run deep-research skill with topic=[topic] and tier=[Quick/Moderate/Deep]"

### `/doc-fix.md`
**Prompt:** "Run troubleshooting-docs skill to capture recently solved problem"

### `/add-critical-pattern.md`
**Prompt:** "Add current problem to vcv-critical-patterns.md (Required Reading fast path)"

### `/reconcile.md`
**Prompt:** "Reconcile state drift between planning and implementation for [Name]"

---

## Priority 4: Scripts (BUILD AUTOMATION)

### `scripts/build-and-install.sh`
**Purpose:** 7-phase build pipeline for VCV Rack modules
**Adaptation:** Major from JUCE version

**Phases:**
1. Pre-flight validation (plugin.json, RACK_DIR, Makefile)
2. Build module (`make clean && make`)
3. Extract plugin slug from plugin.json
4. Remove old version from Rack plugins folder
5. Install new version (copy to Rack2/plugins-*)
6. Verification (check .dylib/.so/.dll, size, report)
7. (No DAW cache clearing for VCV Rack)

**Platform detection:**
- Mac: Check uname -m for arm64 vs x86_64 → plugins-mac-arm64 vs plugins-mac-x64
- Linux: plugins-linux-x64
- Windows: plugins-win-x64 (via MSYS2)

**Flags:**
- `--dry-run` - Show commands without executing
- `--no-install` - Build only
- `--verbose` - Detailed output
- `--reconfigure` - Delete build/ and regenerate (if using CMake alternative)

**RACK_DIR validation:**
```bash
if [ -z "$RACK_DIR" ]; then
    echo "ERROR: RACK_DIR not set"
    exit 1
fi

if [ ! -f "$RACK_DIR/include/rack.hpp" ]; then
    echo "ERROR: Invalid Rack SDK: $RACK_DIR"
    exit 1
fi
```

### `scripts/verify-backup.sh`
**Purpose:** Backup integrity verification (Phase 7 of module-lifecycle)
**Adaptation:** Minimal from JUCE version

**Checks:**
- Backup directory exists
- Source files present (plugin.json, src/, res/)
- Binary present if installed (check Rack plugins folder)
- Git tag exists (for version tracking)

---

## Priority 5: Hooks (VALIDATION GATES)

All hooks in `.claude/hooks/*.sh` validate actions and enforce contracts.

### `.claude/hooks/PostToolUse.sh`
**Purpose:** After tool execution (detect subagent returns)
**Adaptation:** Minimal

**VCV-specific checks:**
- Detect JSON report from VCV subagents
- Extract status field (success/failure)
- Trigger checkpoint protocol if subagent completes

### `.claude/hooks/SubagentStop.sh`
**Purpose:** After subagent completes (enforce checkpoint)
**Adaptation:** None (target-agnostic)

**Actions:**
- Ensure orchestrator commits changes
- Update .continue-here.md
- Update MODULES.md
- Present numbered decision menu
- Block auto-proceed

### `.claude/hooks/UserPromptSubmit.sh`
**Purpose:** Before user prompt (validate context)
**Adaptation:** Minimal

**VCV-specific checks:**
- If in modules/ directory, check for .ideas/ contracts
- Validate RACK_DIR if setup-related command
- Warn if plugin.json has invalid slug format

### `.claude/hooks/Stop.sh`
**Purpose:** Before conversation ends (save state)
**Adaptation:** None (target-agnostic)

### `.claude/hooks/PreCompact.sh`
**Purpose:** Before context compaction (preserve critical data)
**Adaptation:** None (target-agnostic)

### `.claude/hooks/SessionStart.sh`
**Purpose:** On session start (load context, validate environment)
**Adaptation:** Major

**VCV-specific checks:**
- Check RACK_DIR set
- Validate Rack SDK if RACK_DIR present
- Display VCV system status (modules, versions)
- Show recent module activity

---

## Priority 6: Contract Templates

### `.claude/skills/module-ideation/assets/creative-brief-template.md`
**Adaptation:** Major from plugin version

**VCV-specific fields:**
- HP width (4-20 HP, 1 HP = 5.08mm)
- Eurorack category (Oscillator, Filter, VCA, etc.)
- CV/audio inputs and outputs
- Voltage ranges (±5V, 1V/oct, 0-10V)
- Modular synthesis use cases

### `.claude/skills/module-planning/assets/architecture-template.md`
**Adaptation:** Minimal

**VCV-specific sections:**
- CV routing diagram
- 1V/oct pitch CV handling
- Polyphony strategy (monophonic vs polyphonic)
- Voltage standards per input/output

### `.claude/skills/module-planning/assets/plan-template.md`
**Adaptation:** Minimal

**VCV-specific considerations:**
- Per-sample DSP optimization
- Anti-aliasing requirements
- Polyphony complexity
- Panel layout complexity (HP width, component density)

### `.claude/skills/panel-mockup/assets/parameter-spec-template.md`
**Adaptation:** Major from JUCE version

**VCV-specific fields:**
- Component positions in millimeters (from SVG)
- Component colors (red/green/blue/magenta)
- Voltage ranges for CV inputs/outputs
- 1V/oct standard for pitch CV

---

## Priority 7: Documentation

### `vcv-rack-module-freedom-system/SYSTEM-OVERVIEW.md`
**Purpose:** Quick reference architecture map (parallel to JUCE version)
**Content:**
- 7-stage workflow for VCV Rack
- Dispatcher pattern (module-workflow → subagents)
- Contracts system (creative-brief, parameter-spec, architecture, plan)
- SVG panel workflow (helper.py automation)
- Build pipeline (Makefile-based)
- Knowledge base structure
- VCV-specific patterns (slug immutability, panel dimensions, etc.)

---

## Estimated Remaining Files

**Subagents:** 3 files (dsp, gui, validator) + 1 troubleshooter = **4 files**
**Skills:** 12 files (workflow, ideation, planning, mockup, improve, testing, lifecycle, build, setup, docs, research, sync) = **12 files**
**Commands:** 15 files (setup, dream, plan, implement, continue, improve, test, install, uninstall, clean, reset, destroy, show-vcv, sync-design, research, doc-fix, add-critical-pattern, reconcile) = **18 files**
**Scripts:** 2 files (build-and-install.sh, verify-backup.sh) = **2 files**
**Hooks:** 6 files (PostToolUse, SubagentStop, UserPromptSubmit, Stop, PreCompact, SessionStart) = **6 files**
**Templates:** 4 files (creative-brief, architecture, plan, parameter-spec) = **4 files**
**Docs:** 1 file (SYSTEM-OVERVIEW.md) = **1 file**

**TOTAL:** ~47 files remaining

---

## Suggested Build Order

1. **dsp-agent, gui-agent, validator** (complete subagent set)
2. **module-workflow skill** (orchestrator - critical path)
3. **build-and-install.sh script** (build pipeline)
4. **module-ideation, module-planning skills** (Stages 0-1)
5. **Commands** (/dream, /plan, /implement minimum)
6. **Test with simple module** (utility or VCA)
7. **Complete remaining skills and commands**
8. **Hooks for validation**
9. **Templates for contracts**
10. **SYSTEM-OVERVIEW.md documentation**

---

## Next Action

Continue systematic build of remaining files, starting with critical path:
1. dsp-agent.md
2. gui-agent.md
3. validator.md
4. module-workflow/SKILL.md
5. build-and-install.sh

Then test with minimal workflow before completing remaining infrastructure.
