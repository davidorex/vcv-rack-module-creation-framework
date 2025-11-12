# VCV RACK MODULE FREEDOM SYSTEM - Quick Reference

**What:** AI-assisted VCV Rack module builder via conversation
**How:** 7-stage workflow (Dream → Plan → Foundation → Shell → DSP → GUI → Validation)
**Orchestration:** module-workflow skill invokes specialized subagents via Task tool
**Entry points:** `/dream` → `/plan` → `/implement` → `/install-module` → `/improve`

---

## Architecture at a Glance

```
.claude/
├── skills/           # 13 capabilities (SKILL.md + references/ + assets/)
├── agents/           # 6 subagents (.md prompts: foundation, shell, dsp, gui, validator, troubleshooter)
├── commands/         # 18 slash commands (.md expansions)
└── hooks/            # 6 validation gates (.sh scripts)

modules/[Name]/
├── .ideas/           # Contracts (immutable during implementation)
│   ├── creative-brief.md       # Vision, HP width, CV/audio I/O
│   ├── parameter-spec.md       # All controls with positions (mm)
│   ├── architecture.md         # DSP design (Stage 0 output)
│   ├── plan.md                 # Strategy (Stage 1 output)
│   ├── panels/                 # SVG iterations (v1, v2, v3...)
│   └── .continue-here.md       # Resume checkpoint
├── src/              # C++ implementation
│   ├── plugin.{hpp,cpp}        # Plugin registration
│   └── [Module].cpp            # Module + ModuleWidget
├── res/              # Resources
│   └── [Module].svg            # Panel graphic (128.5mm × HP×5.08mm)
├── presets/          # Factory presets (.vcvm JSON)
├── plugin.json       # Manifest (slug, version, modules)
├── Makefile          # Build config (RACK_DIR reference)
├── CHANGELOG.md
└── LICENSE.txt

scripts/
├── build-and-install.sh        # 7-phase build pipeline (Makefile-based)
└── verify-backup.sh            # Backup integrity checks

troubleshooting/      # Knowledge base
├── build-failures/
├── runtime-issues/
├── gui-issues/
├── dsp-issues/
├── parameter-issues/
├── api-usage/
├── validation-problems/
└── patterns/
    └── vcv-critical-patterns.md  # REQUIRED READING (injected into all subagents)

MODULES.md            # Master registry (status, versions, timeline)
```

---

## Workflow Stages

### Stage 0-1: Planning (module-planning skill)
- **Stage 0**: Research → `architecture.md` (DSP design, CV routing, algorithms)
- **Stage 1**: Planning → `plan.md` (complexity, phased strategy, CPU budget)

### Stage 2-6: Implementation (module-workflow skill → subagents)
- **Stage 2**: Foundation → plugin.json, Makefile, Module skeleton (foundation-agent)
- **Stage 3**: Shell → SVG panel, config() parameters, helper.py (shell-agent)
- **Stage 4**: DSP → Audio/CV processing (dsp-agent, may be phased: 4.1, 4.2...)
- **Stage 5**: GUI → ModuleWidget finalization, custom widgets (gui-agent)
- **Stage 6**: Validation → Presets (.vcvm), manual testing, CHANGELOG (validator)

**Dispatcher Pattern:**
- module-workflow orchestrates, NEVER implements directly
- Each stage 2-5 MUST invoke subagent via Task tool
- After subagent: commit → update state → present menu → WAIT

---

## Key Commands

### Setup
```bash
/setup                    # Validate RACK_DIR and dependencies (first-time)
```

### Lifecycle
```bash
/dream [Name]             # Ideation → creative-brief.md
/plan [Name]              # Stages 0-1 → architecture + plan
/implement [Name]         # Stages 2-6 → Working module
/continue [Name]          # Resume from checkpoint
/improve [Name]           # Version management + regression tests
```

### Deployment
```bash
/install-module [Name]    # Deploy to ~/Documents/Rack2/plugins-*/
/uninstall [Name]         # Remove binaries (keep source)
/clean [Name]             # Interactive cleanup menu
/reset-to-ideation [Name] # Remove implementation, keep contracts
/destroy [Name]           # Complete removal (with backup)
```

### Quality
```bash
/test [Name]              # Run validation suite
/show-vcv [Name]          # Open VCV Rack and load module
/sync-design [Name]       # Validate panel ↔ brief
/research [topic]         # Deep investigation
/doc-fix                  # Document solved problems
```

---

## Subagents (Specialized Implementers)

All in `.claude/agents/`:

| Subagent | Stage | Role |
|----------|-------|------|
| **foundation-agent** | 2 | plugin.json, Makefile, Module skeleton, helper.py setup |
| **shell-agent** | 3 | SVG panel with component placeholders, config() calls, helper.py createmodule |
| **dsp-agent** | 4 | process() implementation, polyphony, voltage standards, anti-aliasing |
| **gui-agent** | 5 | ModuleWidget finalization, custom NanoVG widgets, dark theme |
| **validator** | 6 | .vcvm presets, manual test protocol, CHANGELOG generation |
| **troubleshooter** | - | Build failure investigation, error diagnosis, RACK_DIR validation |

**All subagents receive:**
- Contracts (creative-brief, architecture, plan, parameter-spec)
- Required Reading (vcv-critical-patterns.md)

---

## Skills (High-Level Capabilities)

All in `.claude/skills/*/SKILL.md`:

### Core Workflow
- **module-ideation** - Brainstorm concepts, create creative briefs (HP width, CV I/O)
- **module-planning** - Stages 0-1 (research modular synthesis + planning)
- **module-workflow** - Stages 2-6 orchestration (dispatcher pattern)
- **context-resume** - Resume from checkpoints (.continue-here.md)

### Enhancement
- **module-improve** - Version management via plugin.json, regression testing
- **module-testing** - Automated validation (build, manifest, panel, manual protocol)
- **panel-mockup** - 2-phase SVG panel workflow (design iteration → scaffolding)

### Infrastructure
- **build-automation** - Build coordination (Makefile wrapper, RACK_DIR validation)
- **module-lifecycle** - Install/uninstall/reset/destroy operations
- **system-setup** - Dependency validation (RACK_DIR, Make, SDK)

### Quality
- **deep-research** - 3-level problem investigation (Quick/Moderate/Deep)
- **troubleshooting-docs** - Capture solutions to knowledge base
- **design-sync** - Validate panel ↔ brief consistency (drift detection)

---

## Contracts (Single Source of Truth)

**Location:** `modules/[Name]/.ideas/`

1. **creative-brief.md** - Vision, HP width (4-20 HP), CV/audio I/O, voltage ranges
2. **parameter-spec.md** - All controls with positions (mm), voltage ranges, component colors
3. **architecture.md** - DSP design, CV routing, signal flow, polyphony strategy (Stage 0)
4. **plan.md** - Implementation strategy, complexity score, CPU budget (Stage 1)
5. **panels/** - SVG iterations with component placeholders

**Immutable during implementation** - All stages reference same specs.

---

## State Management

### Status States (MODULES.md)
- **💡 Ideated** - Creative brief exists, no implementation
- **🚧 Stage N** - In development (locks to workflow, blocks improve)
- **✅ Working** - Stage 6 complete, not installed
- **📦 Installed** - Deployed to Rack plugins folder
- **🌐 Published** - Submitted to VCV Library
- **🐛 Has Issues** - Known problems (combines with other states)

### Checkpoint Protocol (System-Wide)
After EVERY significant completion:
1. Auto-commit changes (if in workflow)
2. Update state files (.continue-here.md, MODULES.md)
3. Present numbered decision menu (NEVER auto-proceed)
4. WAIT for user response
5. Execute chosen action

---

## SVG Panel System

### 2-Phase Panel Workflow (panel-mockup skill)

**Phase A: Design Iteration (Fast)**
1. Generate `v[N]-panel.yaml` (machine-readable spec: HP width, components, positions)
2. Generate `v[N]-panel.svg` (Inkscape-compatible with component layer)
3. STOP - Present menu, iterate or finalize

**Phase B: Implementation Scaffolding (After Approval)**
4. Copy finalized SVG to `res/[Module].svg`
5. Run `helper.py createmodule` (auto-generates C++ enums, config() calls, widget positioning)
6. Generate `parameter-spec.md` from finalized panel
7. Generate integration checklist

### Panel Specifications
- **Height:** 128.5mm (fixed, Eurorack standard)
- **Width:** HP × 5.08mm (1 HP = 5.08mm, typical 4-20 HP)
- **Component colors:** Red (#ff0000) = params, Green (#00ff00) = inputs, Blue (#0000ff) = outputs, Magenta (#ff00ff) = lights
- **Coordinate system:** Millimeters from top-left corner, converted with mm2px()

---

## Build Pipeline

**Script:** `scripts/build-and-install.sh`

### 7 Phases:
1. **Pre-flight validation** - Check RACK_DIR, plugin.json, Makefile, compiler
2. **Build module** - Run `make clean && make`
3. **Extract metadata** - Read plugin slug from plugin.json
4. **Remove old version** - Clear previous installation from Rack plugins folder
5. **Install new version** - Copy to `~/Documents/Rack2/plugins-[platform]-[arch]/`
6. **Clear cache** - Trigger Rack rescan (automatic on launch)
7. **Verification** - Check installation, size, report

**Platforms:** mac-arm64, mac-x64, linux-x64, win-x64

**Flags:** `--uninstall`, `--build-only`, `--clean`, `--verify`

---

## Knowledge Base

**Location:** `troubleshooting/`

### By Symptom:
- `build-failures/` - Makefile errors, compiler issues, RACK_DIR problems
- `runtime-issues/` - Crashes, exceptions, CPU spikes
- `gui-issues/` - SVG panel problems, widget rendering
- `dsp-issues/` - Audio processing bugs, aliasing, polyphony
- `parameter-issues/` - config() errors, state management
- `api-usage/` - VCV Rack API misuse, 1.x → 2.x migration
- `validation-problems/` - Manual test failures, preset issues

### Required Reading (Injected Into All Subagents)
**File:** `troubleshooting/patterns/vcv-critical-patterns.md`

**11 non-negotiable patterns:**
1. **Slug immutability** - NEVER change after release (breaks patches)
2. **Panel dimensions** - Height = 128.5mm, Width = HP × 5.08mm (exact)
3. **Voltage standards** - ±5V audio/CV, 1V/oct pitch, 0-10V gates
4. **Component colors** - Red/green/blue/magenta (exact hex codes)
5. **Polyphony handling** - Always setChannels() after processing
6. **Per-sample optimization** - Avoid expensive ops in process()
7. **JSON serialization** - dataToJson/dataFromJson for custom state only
8. **Helper.py workflow** - SVG first, then createmodule (not reverse)
9. **Thread safety** - Module methods mutually exclusive (no locks needed)
10. **Anti-aliasing** - PolyBLEP for discontinuous, oversampling for nonlinear
11. **mm2px coordinates** - Use mm2px() for all positions (not hard-coded pixels)

---

## Key Patterns

### Dispatcher Pattern
- Orchestrator (module-workflow) invokes subagents via Task tool
- Subagents run in fresh context, return JSON report
- Orchestrator commits, updates state, presents menu

### Contract Immutability
- All stages reference same contracts (creative-brief, parameter-spec, architecture, plan)
- Zero drift during implementation
- design-sync skill validates consistency

### Phased Implementation (Complex Modules)
- Complexity ≥3 → Multi-phase stages (4.1, 4.2, 4.3... or 5.1, 5.2, 5.3...)
- Checkpoint after EACH phase
- plan.md defines phase breakdown

### Graduated Research (deep-research skill)
**3 levels:**
- **Quick** (Tier 1) - Single-agent, 1-2 min, local docs + Rack SDK
- **Moderate** (Tier 2) - Multi-agent parallel, 3-5 min, Community forum + GitHub issues
- **Deep** (Tier 3) - Comprehensive, 5-10 min, VCV Library analysis + expert modules

### Regression Testing (module-improve)
On every improvement:
1. Create backup (git commit + tag)
2. Implement changes
3. Run module-testing skill (build, manifest, panel, manual protocol)
4. Verify no regressions (polyphony, CV, sample rates)
5. Bump version in plugin.json (semantic versioning)
6. Update CHANGELOG.md

---

## VCV Rack Specifics

### Voltage Standards
- **Audio:** ±5V (peaks may exceed, but RMS ~±5V)
- **CV:** ±5V or 0-10V (document in manual)
- **Pitch CV:** 1V/octave (0V = C4 = 261.63 Hz, formula: `FREQ_C4 * exp2_taylor5(pitch_cv)`)
- **Gate/Trigger:** High = 10V (or >1V), Low = 0V

### Polyphony
- Up to 16 channels per cable
- `getChannels()` returns active channel count
- `getVoltage(c)` reads channel c
- `setVoltage(v, c)` writes channel c
- `setChannels(n)` MUST be called after processing
- SIMD optimization with `float_4` (process 4 channels at once)

### DSP Paradigm
- **Per-sample processing** - process() called at sample rate (44.1k-192k Hz)
- **args.sampleTime** - Time between samples (1 / sample_rate)
- **Optimize hot path** - No division, sqrt, exp, sin, cos in process()
- **Use lookup tables** - Pre-compute expensive functions
- **Rack DSP helpers** - exp2_taylor5(), log2_taylor5() (fast approximations)

### Panel Design
- **Fixed height:** 128.5mm (Eurorack 3U)
- **Variable width:** HP × 5.08mm (1 HP = 5.08mm)
- **Common HP widths:** 4, 6, 8, 10, 12, 16, 20 HP
- **Component spacing:** Thumb-width between knobs/ports (ergonomics)
- **Label readability:** Text readable at 100% zoom on non-high-DPI

### Build System
- **Makefile-based** - Official VCV Rack build system (not CMake)
- **RACK_DIR required** - Environment variable pointing to Rack SDK
- **Build commands:** `make` (build), `make dist` (package), `make install` (deploy)
- **Output:** `dist/[Module]-[version]-[platform].vcvplugin` archive

### Distribution
- **VCV Library (Open Source):** Submit to github.com/VCVRack/library (auto-builds for all platforms)
- **Manual Install:** Copy to `~/Documents/Rack2/plugins-[platform]-[arch]/`
- **Version format:** MAJOR.MINOR.REVISION (major version matches Rack version, e.g., 2.x.x for Rack 2)

---

## Modules in Repository

### Example: Completed Module Structure
```
modules/MyOscillator/
├── .ideas/
│   ├── creative-brief.md         # HP width: 10, Category: Oscillator
│   ├── parameter-spec.md         # Freq knob (mm), CV inputs (mm), outputs (mm)
│   ├── architecture.md           # Wavetable oscillator, 1V/oct tracking
│   ├── plan.md                   # Complexity: 2 (single-pass)
│   ├── panels/
│   │   └── v2-panel.svg          # 50.8mm × 128.5mm, component layer
│   └── .continue-here.md
├── src/
│   ├── plugin.{hpp,cpp}
│   └── MyOscillator.cpp          # Module + ModuleWidget (872 lines)
├── res/
│   └── MyOscillator.svg          # Panel graphic
├── presets/
│   ├── Default.vcvm
│   ├── Sine.vcvm
│   └── Saw.vcvm
├── plugin.json                   # slug: "MyOscillator", version: "1.0.0"
├── Makefile                      # RACK_DIR reference
├── CHANGELOG.md
└── LICENSE.txt
```

---

## Quick Start

```bash
# First-time setup
/setup

# Create new module
/dream MyOscillator          # Ideation → creative-brief.md
/plan MyOscillator           # Research + planning → architecture.md + plan.md
/implement MyOscillator      # Build through stages 2-6

# Deploy
/install-module MyOscillator # Install to VCV Rack plugins folder
/show-vcv MyOscillator       # Open in VCV Rack for testing

# Improve
/improve MyOscillator        # Fix bugs, add features (with versioning)
/test MyOscillator           # Run validation suite
```

---

## Success Criteria

**Module is complete when:**
- All stages (0-6) finished
- Module compiles (`make` succeeds)
- Audio/CV processing functional
- SVG panel renders correctly with all components
- Parameters configured with config() calls
- Polyphony works (up to 16 channels)
- Voltage standards followed (±5V, 1V/oct)
- Factory presets created (3-5 minimum, .vcvm format)
- CHANGELOG.md generated
- Status = ✅ Working (or 📦 Installed after deployment)

---

## System Principles

1. **Contracts are immutable during implementation** - All stages reference same specs
2. **Dispatcher pattern** - Subagents in fresh context, orchestrator commits
3. **Discovery through play** - Slash commands + decision menus
4. **Checkpoint protocol** - NEVER auto-proceed, always menu + WAIT
5. **Required Reading injection** - vcv-critical-patterns.md prevents repeat mistakes
6. **Helper.py automation** - SVG component layer → C++ code generation

---

## Comparison to JUCE Plugin Freedom System

| Aspect | VCV Rack Modules | JUCE Plugins |
|--------|------------------|--------------|
| **Build System** | Makefile | CMake |
| **Environment Var** | RACK_DIR | JUCE_DIR |
| **GUI Framework** | SVG + NanoVG | WebView (HTML/CSS/JS) |
| **Parameters** | config() + JSON | APVTS (AudioProcessorValueTreeState) |
| **DSP Paradigm** | Per-sample (process()) | Buffer-based (processBlock()) |
| **Voltage Range** | ±5V audio/CV, 1V/oct pitch | ±1.0 float |
| **Distribution** | VCV Library or manual | System plugin folders |
| **Formats** | .vcvplugin archive | VST3, AU, Standalone bundles |
| **Panel Design** | 128.5mm × HP×5.08mm (fixed) | Variable (600×400 typical) |
| **Preset Format** | .vcvm (JSON) | .vstpreset (binary) |
| **Validation** | Manual test protocol | pluginval (automated) |

**Both systems share:**
- 7-stage workflow (Dream → Plan → Foundation → Shell → DSP → GUI → Validation)
- Dispatcher pattern (orchestrator → subagents)
- Contract immutability (creative-brief, parameter-spec, architecture, plan)
- Checkpoint protocol (commit → update → menu → WAIT)
- Required Reading injection (critical patterns)
- Knowledge base accumulation (troubleshooting docs)
- Version management with regression testing

---

## Resources

**Official Documentation:**
- **Manual:** https://vcvrack.com/manual/
- **API Reference:** https://vcvrack.com/docs-v2/
- **Library:** https://library.vcvrack.com/
- **SDK Downloads:** https://vcvrack.com/downloads/

**Learning:**
- **Julius O. Smith DSP Books:** https://ccrma.stanford.edu/~jos/
- **VCV Community Forum:** https://community.vcvrack.com/
- **Rack GitHub:** https://github.com/VCVRack/Rack

**Example Modules (Open Source):**
- **Fundamental:** https://github.com/VCVRack/Fundamental (official)
- **Befaco:** https://github.com/VCVRack/Befaco
- **Mutable Instruments:** https://github.com/VCVRack/AudibleInstruments
- **Bogaudio:** https://github.com/bogaudio/BogaudioModules

---

## For More Detail

See expanded documentation:
- `.claude/CLAUDE.md` - Full system documentation
- `.claude/skills/*/SKILL.md` - Individual skill definitions
- `.claude/agents/*.md` - Subagent prompts
- `troubleshooting/patterns/vcv-critical-patterns.md` - Critical patterns
- `BUILD-REMAINING.md` - Implementation roadmap (if present)
