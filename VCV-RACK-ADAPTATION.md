# VCV RACK ADAPTATION - Module Freedom System

**Parallel system for creating VCV Rack modules using the Plugin Freedom System approach**

---

## Executive Summary

VCV Rack module development maps remarkably well to JUCE plugin development, with clear parallels in architecture, workflow, and implementation stages. The Plugin Freedom System can be adapted to create a "Module Freedom System" for VCV Rack with minimal conceptual changes while accounting for platform-specific differences.

**Key Finding:** The 7-stage workflow (Dream → Plan → Foundation → Shell → DSP → GUI → Validation) translates directly to VCV Rack with adjusted implementation details.

---

## JUCE vs VCV Rack: Architecture Comparison

| Aspect | JUCE Plugins | VCV Rack Modules |
|--------|--------------|------------------|
| **Target Format** | VST3, AU, Standalone | VCV Rack Module (.dylib/.so/.dll) |
| **Build System** | CMake (juce_add_plugin) | Makefile (official) or CMake (community) |
| **SDK Distribution** | JUCE framework (source/modules) | Rack SDK (pre-compiled headers/libs) |
| **GUI Framework** | WebView (HTML/CSS/JS) or JUCE native | NanoVG + SVG panels |
| **Parameter System** | APVTS (AudioProcessorValueTreeState) | Module::params[] + JSON serialization |
| **DSP Entry Point** | processBlock() | process(const ProcessArgs &args) |
| **State Management** | APVTS + getStateInformation() | Automatic params + dataToJson() |
| **Panel Design** | WebView mockups | SVG panels with component placeholders |
| **Distribution** | User installation to system folders | VCV Library submission or manual install |
| **Voltage Standard** | ±1.0 float | ±5V (±10V accepted) |
| **Sample Rate** | DAW-provided (44.1k-192k typical) | Engine-controlled (default 44.1k) |

---

## Workflow Mapping: 7-Stage Parallel

### Stage 0: Research (DSP Architecture)
**JUCE:** Research audio processing algorithms, signal flow, JUCE API patterns
**VCV Rack:** Research modular synthesis concepts, CV routing, Rack API patterns

**Differences:**
- VCV uses CV (Control Voltage) paradigm instead of MIDI/automation
- Audio and control signals both use ±5V standard
- Polyphony handled per-cable (up to 16 channels per port)

**Contract Output:** `architecture.md` (same for both, but VCV version includes CV routing diagram)

---

### Stage 1: Planning (Implementation Strategy)
**JUCE:** Define complexity, phases, JUCE-specific considerations
**VCV Rack:** Define complexity, phases, Rack-specific considerations

**Differences:**
- VCV modules typically simpler (single-purpose, composable)
- Panel design is critical (Eurorack HP width, component spacing)
- Consider expander modules for complex features

**Contract Output:** `plan.md` (same structure for both)

---

### Stage 2: Foundation (Project Structure)
**JUCE:** Create CMakeLists.txt, PluginProcessor/Editor skeletons, JUCE dependencies
**VCV Rack:** Create plugin.json manifest, Module/ModuleWidget skeletons, Makefile/CMakeLists

**Parallels:**
- Both create project skeleton
- Both define metadata (plugin.json ≈ JUCE project settings in CMakeLists)
- Both set up build configuration

**VCV-Specific Files:**
```
plugins/[Name]/
├── plugin.json          # Manifest (slug, version, modules)
├── src/
│   ├── plugin.hpp       # Plugin-level declarations
│   ├── plugin.cpp       # Plugin registration
│   └── [Module].cpp     # Module implementation
├── res/
│   └── [Module].svg     # Panel design
└── Makefile             # Build config (RACK_DIR reference)
```

**Contract:** `creative-brief.md`, `parameter-spec.md`

---

### Stage 3: Shell (Parameter Definition)
**JUCE:** Create APVTS, define all parameters, state management
**VCV Rack:** Configure params/inputs/outputs/lights, define component placeholders

**Parallels:**
- Both enumerate all controls
- Both handle state persistence
- Both wire up parameter → DSP connections

**VCV-Specific Pattern:**
```cpp
// Module constructor
config(NUM_PARAMS, NUM_INPUTS, NUM_OUTPUTS, NUM_LIGHTS);
configParam(FREQ_PARAM, 0.f, 10.f, 5.f, "Frequency", " Hz");
configInput(AUDIO_IN, "Audio");
configOutput(AUDIO_OUT, "Audio");
configLight(CLIP_LIGHT, "Clipping indicator");
```

**SVG Panel Creation:**
- Design panel in Inkscape (128.5mm height, width = 5.08mm × HP)
- Add component layer with colored placeholders:
  - Red (#ff0000) = Params
  - Green (#00ff00) = Inputs
  - Blue (#0000ff) = Outputs
  - Magenta (#ff00ff) = Lights
- Run `helper.py createmodule [Name] res/[Name].svg src/[Name].cpp`

**Contract:** `parameter-spec.md` (enhanced with CV input/output definitions)

---

### Stage 4: DSP (Audio Processing)
**JUCE:** Implement processBlock(), handle buffer processing
**VCV Rack:** Implement process(), handle per-sample processing

**Key Differences:**
- **JUCE:** Buffer-based (512 samples typical), optimize for throughput
- **VCV Rack:** Per-sample (process() called at sample rate), optimize per-frame

**VCV-Specific Pattern:**
```cpp
void process(const ProcessArgs &args) override {
    // args.sampleTime = 1 / sample_rate
    float input = inputs[AUDIO_IN].getVoltage();

    // DSP processing here
    float output = processSample(input);

    outputs[AUDIO_OUT].setVoltage(output);
}
```

**Polyphony Handling:**
```cpp
int channels = std::max(1, inputs[AUDIO_IN].getChannels());
for (int c = 0; c < channels; c++) {
    float v = inputs[AUDIO_IN].getVoltage(c);
    // Process per-channel
    outputs[AUDIO_OUT].setVoltage(processedValue, c);
}
outputs[AUDIO_OUT].setChannels(channels);
```

**Anti-Aliasing:**
- Required for nonlinear processes (distortion, waveshaping)
- Use minBLEP/polyBLEP for discontinuous waveforms
- VCV recommends biquad filters for IIR, FFT for long FIR

**Contract:** `architecture.md` (same DSP design, implementation differs)

---

### Stage 5: GUI (Visual Interface)
**JUCE:** WebView integration, HTML/CSS/JS, parameter bindings (relays/attachments)
**VCV Rack:** ModuleWidget setup, SVG panel loading, component instantiation

**Key Differences:**
- **JUCE:** Dynamic, web-based UI with custom styling
- **VCV Rack:** Fixed SVG panel with standard component widgets

**VCV-Specific Pattern:**
```cpp
struct MyModuleWidget : ModuleWidget {
    MyModuleWidget(MyModule* module) {
        setModule(module);
        setPanel(createPanel(asset::plugin(pluginInstance, "res/MyModule.svg")));

        // Add screws
        addChild(createWidget<ScrewSilver>(Vec(RACK_GRID_WIDTH, 0)));

        // Add params (from SVG component positions)
        addParam(createParamCentered<RoundBlackKnob>(mm2px(Vec(10.0, 20.0)), module, MyModule::FREQ_PARAM));

        // Add inputs
        addInput(createInputCentered<PJ301MPort>(mm2px(Vec(10.0, 40.0)), module, MyModule::AUDIO_IN));

        // Add outputs
        addOutput(createOutputCentered<PJ301MPort>(mm2px(Vec(10.0, 60.0)), module, MyModule::AUDIO_OUT));

        // Add lights
        addChild(createLightCentered<MediumLight<RedLight>>(mm2px(Vec(10.0, 80.0)), module, MyModule::CLIP_LIGHT));
    }
};
```

**Component Library:**
- Knobs: RoundBlackKnob, RoundSmallBlackKnob, Trimpot, Davies1900h
- Ports: PJ301MPort (standard 3.5mm jack)
- Switches: CKSS (toggle), CKD6 (momentary)
- Lights: SmallLight, MediumLight, LargeLight (various colors)

**Custom Widgets:**
- Inherit from `widget::Widget`
- Override `draw(const DrawArgs &args)` using NanoVG API
- Cache with `FramebufferWidget` if static

**Contract:** UI mockups adapted to SVG panel specifications

---

### Stage 6: Validation (Testing & Distribution)
**JUCE:** Presets, pluginval, CHANGELOG, system installation
**VCV Rack:** Presets (.vcvm), VCV Library submission, CHANGELOG

**Parallels:**
- Both create factory presets
- Both document changes
- Both validate functionality

**VCV-Specific Validation:**
- Manual testing in VCV Rack (no automated validator like pluginval)
- Test polyphony with polyphonic cables
- Test CV modulation of all parameters
- Test at different sample rates (44.1k, 48k, 96k, 192k)

**Preset Format (.vcvm):**
JSON format with module state:
```json
{
  "plugin": "MyPlugin",
  "model": "MyModule",
  "version": "2.0.0",
  "params": [
    {"value": 0.5},
    {"value": 0.75}
  ],
  "data": {
    // Custom JSON from dataToJson()
  }
}
```

**Distribution:**
1. **VCV Library (Open Source):**
   - Create issue in github.com/VCVRack/library with plugin slug
   - Post source URL, license, metadata
   - Increment version in plugin.json, post commit hash for updates
   - Library auto-builds for all platforms

2. **Manual Installation:**
   - `make dist` creates distributable in `dist/`
   - Users place in Rack's plugins folder:
     - Mac: `~/Documents/Rack2/plugins-mac-arm64/` (or x64)
     - Linux: `~/.Rack2/plugins-linux-x64/`
     - Windows: `%USERPROFILE%/Documents/Rack2/plugins-win-x64/`

**Contract:** CHANGELOG.md (same format for both)

---

## Dependencies & System Requirements

### Development Dependencies

**All Platforms:**
- C++11 compiler (g++ or clang++)
- Git
- Make (official) or CMake (community)
- Python 3 (for helper.py)

**Mac (via Homebrew):**
```bash
brew install git wget cmake autoconf automake libtool jq python zstd pkg-config
```

**Linux (Ubuntu 16.04+):**
```bash
apt-get install build-essential git gdb curl cmake libx11-dev libglu1-mesa-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev zlib1g-dev
```

**Windows (MSYS2 MinGW 64-bit):**
```bash
pacman -S git gcc gdb cmake autoconf automake libtool jq python zstd pkgconf
```

### Rack SDK Setup

**Environment Variable:**
```bash
export RACK_DIR=/path/to/Rack-SDK
# Add to ~/.bashrc or ~/.zshrc
```

**SDK Download:**
- Mac x64: `Rack-SDK-2.x.x-mac-x64.zip`
- Mac ARM64: `Rack-SDK-2.x.x-mac-arm64.zip`
- Linux x64: `Rack-SDK-2.x.x-lin-x64.zip`
- Windows x64: `Rack-SDK-2.x.x-win-x64.zip`

Available at: https://vcvrack.com/downloads/

### Runtime Dependencies (Built into SDK)
- NanoVG (vector graphics rendering)
- NanoSVG (SVG parsing)
- pffft (FFT library)
- RtAudio/RtMidi (audio/MIDI I/O, Rack-level only)
- Jansson (JSON parsing)

---

## Contract Adaptations

### creative-brief.md (Enhanced)
```markdown
# [Module Name] - Creative Brief

## Vision
[What does this module do? What problem does it solve?]

## Category
- [ ] Oscillator (VCO)
- [ ] Filter (VCF)
- [ ] Amplifier (VCA)
- [ ] Envelope Generator
- [ ] LFO
- [ ] Sequencer
- [ ] Effect
- [ ] Mixer
- [ ] Utility
- [ ] Other: ___

## Eurorack HP Width
[How many HP? Typical: 4-20 HP, 1 HP = 5.08mm]

## Inputs (CV/Audio)
| Input | Type | Range | Purpose |
|-------|------|-------|---------|
| IN | Audio | ±5V | Main audio input |
| FREQ | CV | 0-10V | Frequency modulation (1V/oct) |

## Outputs (CV/Audio)
| Output | Type | Range | Purpose |
|--------|------|-------|---------|
| OUT | Audio | ±5V | Main audio output |

## Parameters (Knobs/Switches)
[See parameter-spec.md]

## Sonic Character
[Describe the sound, feel, vibe]

## Use Cases
1. [Primary use case]
2. [Secondary use case]
3. [Creative use case]

## Inspirations
[Hardware modules, existing Rack modules, techniques]

## Expander Support
- [ ] No expander needed
- [ ] Left expander: [purpose]
- [ ] Right expander: [purpose]
```

### parameter-spec.md (Enhanced)
```markdown
# [Module Name] - Parameter Specification

**Generated from:** UI mockup v[N] finalization
**Eurorack HP Width:** [N] HP (width = [N × 5.08]mm)

## Panel Dimensions
- Height: 128.5mm (fixed)
- Width: [N × 5.08]mm ([N] HP)

## Parameters (Knobs)
| ID | Label | Type | Range | Default | Unit | Position (mm) |
|----|-------|------|-------|---------|------|---------------|
| FREQ_PARAM | Freq | Knob | 0-10 | 5 | V | (10.0, 20.0) |

## Inputs (Green Ports)
| ID | Label | Type | Voltage Range | Position (mm) |
|----|-------|------|---------------|---------------|
| AUDIO_IN | In | Audio | ±5V | (10.0, 40.0) |
| FREQ_CV | FM | CV | ±5V | (10.0, 50.0) |

## Outputs (Blue Ports)
| ID | Label | Type | Voltage Range | Position (mm) |
|----|-------|------|---------------|---------------|
| AUDIO_OUT | Out | Audio | ±5V | (10.0, 80.0) |

## Lights (Visual Feedback)
| ID | Label | Color | Purpose | Position (mm) |
|----|-------|-------|---------|---------------|
| CLIP_LIGHT | Clip | Red | Clipping indicator | (10.0, 100.0) |

## Switches/Buttons
| ID | Label | Type | States | Default | Position (mm) |
|----|-------|------|--------|---------|---------------|
| WAVE_SWITCH | Wave | Toggle | [Sine, Saw, Square] | 0 | (20.0, 30.0) |

## CV Modulation Matrix
| Parameter | CV Input | Attenuverter | Behavior |
|-----------|----------|--------------|----------|
| Freq | FREQ_CV | No | Additive (1V/oct standard) |

## Notes
- All positions in millimeters from top-left corner
- Colors: Params=red, Inputs=green, Outputs=blue, Lights=magenta
- Use PJ301MPort for all jacks (standard 3.5mm)
```

### architecture.md (Enhanced)
```markdown
# [Module Name] - DSP Architecture

## Signal Flow Diagram
```
AUDIO_IN ──> [Pre-Gain] ──> [DSP Core] ──> [Post-Gain] ──> AUDIO_OUT
                              ▲
                              │
                         FREQ_CV (1V/oct)
```

## DSP Algorithms
[Detailed algorithm descriptions]

## CV Processing
- **1V/oct standard:** Frequency CV uses exponential conversion (dsp::FREQ_C4 * dsp::exp2_taylor5(voltage))
- **Linear CV:** Use direct voltage scaling (0-10V = 0-100%)
- **Bipolar CV:** ±5V range for modulation

## Polyphony Strategy
- [ ] Monophonic (single channel)
- [ ] Polyphonic (up to 16 channels per cable)
- [ ] Polyphony handling: [describe]

## Anti-Aliasing
- [ ] Not required (linear processing)
- [ ] PolyBLEP (discontinuous waveforms)
- [ ] Oversampling + filtering
- [ ] Other: [describe]

## Performance Considerations
- Process called per-sample (optimize for low latency)
- Avoid expensive operations (divisions, transcendentals) in hot path
- Use lookup tables for nonlinear functions
- Consider SIMD optimization (float_4 for 4-channel batches)

## Sample Rate Handling
Target: 44.1k-192k Hz (VCV Rack engine rate)
Access via: `args.sampleTime` (1 / sample_rate)

## Thread Safety
Module methods (process, dataToJson, etc.) are mutually exclusive (no locks needed)

## Resources
- Julius O. Smith III books: https://ccrma.stanford.edu/~jos/
- VCV DSP guide: https://vcvrack.com/manual/DSP
```

---

## Build Pipeline Adaptation

### Current JUCE Pipeline (scripts/build-and-install.sh)
1. Pre-flight validation (CMakeLists.txt, JUCE, directories)
2. Parallel build (VST3 + AU + Standalone)
3. Extract PRODUCT_NAME
4. Remove old versions
5. Install new versions (~/Library/Audio/Plug-Ins/)
6. Clear DAW caches
7. Verification

### VCV Rack Pipeline (scripts/build-and-install-vcv.sh)
1. Pre-flight validation (plugin.json, RACK_DIR, Makefile)
2. Build plugin (`make clean && make`)
3. Extract plugin slug from plugin.json
4. Remove old version (from Rack2/plugins-*)
5. Install new version (copy to Rack2/plugins-*)
6. Verification (check .dylib/.so/.dll, size, report)

**VCV-Specific Build Commands:**
```bash
# Build plugin
make

# Create distributable package
make dist

# Install to Rack user folder (auto-detects platform)
make install

# Clean build artifacts
make clean

# Full rebuild
make clean && make
```

**Platform-Specific Plugin Folders:**
- Mac: `~/Documents/Rack2/plugins-mac-arm64/[PluginSlug]/`
- Linux: `~/.Rack2/plugins-linux-x64/[PluginSlug]/`
- Windows: `%USERPROFILE%/Documents/Rack2/plugins-win-x64/[PluginSlug]/`

---

## Subagent Adaptations

### foundation-agent (Stage 2)
**JUCE Focus:** CMakeLists.txt, PluginProcessor/Editor skeletons
**VCV Focus:** plugin.json, Module/ModuleWidget skeletons, Makefile

**VCV-Specific Knowledge:**
- plugin.json structure (slug rules, version format)
- Makefile RACK_DIR reference
- Module config() syntax
- Component placeholder color codes
- helper.py usage

**Required Reading (VCV):**
- Rack SDK slug naming rules (a-zA-Z0-9_- only, never change after release)
- HP width calculations (1 HP = 5.08mm)
- Module registration pattern (Model* model[Name] = createModel<>())

### shell-agent (Stage 3)
**JUCE Focus:** APVTS parameter tree
**VCV Focus:** config() calls, SVG panel with placeholders

**VCV-Specific Knowledge:**
- configParam() vs configInput/Output/Light()
- SVG component layer (Inkscape workflow)
- helper.py createmodule automation
- mm2px() coordinate conversion
- Component widget types (RoundBlackKnob, PJ301MPort, etc.)

**Required Reading (VCV):**
- Panel design specs (128.5mm height, 5.08mm width multiples)
- Component color codes (red/green/blue/magenta/yellow)
- Position naming conventions (SVG object properties)

### dsp-agent (Stage 4)
**JUCE Focus:** processBlock(), buffer-based processing
**VCV Focus:** process(), per-sample processing

**VCV-Specific Knowledge:**
- args.sampleTime usage
- Polyphony iteration (getChannels(), getVoltage(c), setVoltage(v, c))
- Voltage standards (±5V, 1V/oct for pitch)
- getPolyVoltageSimd<float_4>() for SIMD
- Anti-aliasing for modular (polyBLEP, oversampling)

**Required Reading (VCV):**
- Per-sample vs buffer optimization
- 1V/oct pitch CV standard (dsp::FREQ_C4 * dsp::exp2_taylor5())
- Polyphony best practices (setChannels() after processing)
- VCV DSP utilities (dsp::BiquadFilter, dsp::RCFilter, etc.)

### gui-agent (Stage 5)
**JUCE Focus:** WebView integration, HTML/CSS/JS, parameter bindings
**VCV Focus:** ModuleWidget setup, SVG panel, component instantiation

**VCV-Specific Knowledge:**
- setPanel() + createPanel()
- addParam/Input/Output/Child() positioning
- mm2px() coordinate system
- Component widget library (Befaco, Mutable, Fundamental)
- Custom widget drawing (NanoVG API)
- FramebufferWidget caching for static graphics

**Required Reading (VCV):**
- ModuleWidget structure pattern
- createParamCentered vs createParam (positioning)
- Custom widget draw() method (NanoVG context)
- Dark panel theming (ThemedScrew, dual SVG panels)

### validator (Stage 6)
**JUCE Focus:** Presets, pluginval, CHANGELOG
**VCV Focus:** Presets (.vcvm), manual testing, CHANGELOG

**VCV-Specific Knowledge:**
- .vcvm preset format (JSON with params + data)
- Manual test protocol (polyphony, CV, sample rates)
- VCV Library submission (github.com/VCVRack/library issue)
- Version bumping in plugin.json
- dist/ package structure

**Required Reading (VCV):**
- Preset JSON structure
- Library submission requirements (open-source licensing)
- Version format (MAJOR.MINOR.REVISION, match Rack major version)

---

## Skills Adaptation

### plugin-ideation → module-ideation
- Brainstorm modular synthesis concepts
- Consider Eurorack paradigm (CV, gate, trigger, audio)
- HP width estimation (4-20 HP typical)
- Expander module strategy for complex features

### plugin-planning → module-planning
- Research modular synthesis techniques
- Plan CV routing and polyphony
- Define HP width and panel layout constraints
- Complexity scoring (1-5, same scale)

### plugin-workflow → module-workflow
- Orchestrate Stages 2-6 (same dispatcher pattern)
- Invoke VCV-specific subagents
- Checkpoint protocol (commit → update state → menu → WAIT)

### ui-mockup → panel-mockup
**2-Phase Workflow (Adapted):**

**Phase A: Panel Iteration (Fast)**
1. Generate `v[N]-panel.yaml` (machine-readable spec)
2. Generate `v[N]-panel.svg` (Inkscape-compatible with component layer)
3. STOP - Present menu, iterate or finalize

**Phase B: Implementation Scaffolding (After Approval)**
4. Run `helper.py createmodule` (auto-generate C++)
5. Generate `v[N]-ModuleWidget.cpp` (boilerplate with component positions)
6. Generate `v[N]-integration-checklist.md` (steps)

### ui-template-library → panel-template-library
- Save visual aesthetics from finalized panels
- Apply to new modules (adapt to different HP widths)
- Library: `.claude/aesthetics-vcv/` (separate from JUCE aesthetics)

### plugin-improve → module-improve
- Same version management, regression testing
- Adapted for VCV-specific validation (manual testing protocol)

### plugin-testing → module-testing
**Automated tests:**
- Build verification (make succeeds)
- plugin.json validation (slug format, version format)
- SVG panel validation (dimensions, component layer)

**Manual test protocol:**
- Load in VCV Rack
- Test all parameters (knobs, switches)
- Test CV modulation (all inputs)
- Test polyphony (16-channel cables)
- Test at 44.1k, 48k, 96k, 192k sample rates
- Check lights respond correctly
- Verify no crashes, audio glitches, or CPU spikes

### system-setup → system-setup-vcv
**Validate dependencies:**
- C++ compiler (g++/clang++)
- Make or CMake
- Python 3
- RACK_DIR environment variable
- Rack SDK downloaded and accessible

**Guided setup:**
- Download Rack SDK for platform
- Set RACK_DIR in shell profile
- Verify with `$RACK_DIR/helper.py --help`

---

## Knowledge Base Adaptations

### troubleshooting/build-failures/
**VCV-Specific Issues:**
- `RACK_DIR not set` → Environment variable missing
- `Makefile:X: recipe failed` → Compiler errors, missing dependencies
- `undefined reference to rack::*` → SDK version mismatch
- `ld: library not found` → Missing platform libraries

### troubleshooting/runtime-issues/
**VCV-Specific Issues:**
- Module not appearing in browser → plugin.json error, slug mismatch
- Crashes on load → Constructor exception, uninitialized state
- Audio glitches → DSP optimization needed, process() too expensive
- CPU spikes → Remove division/transcendentals from hot path

### troubleshooting/gui-issues/
**VCV-Specific Issues:**
- SVG not loading → Path issue, SVG rendering errors
- Components misaligned → mm2px() conversion errors, wrong coordinates
- Panel rendering slow → Use FramebufferWidget for static elements
- Dark theme not working → Missing second SVG, ThemedScrew usage

### troubleshooting/vcv-critical-patterns.md (New)
**Required Reading for VCV Subagents:**

1. **Slug immutability:** Plugin/module slugs MUST NEVER change after release (breaks patches)
2. **Panel dimensions:** Height = 128.5mm (fixed), Width = HP × 5.08mm (exact)
3. **Voltage standards:** Audio ±5V, CV ±5V, 1V/oct for pitch
4. **Polyphony handling:** Always setChannels() after processing, use max(1, getChannels())
5. **Per-sample optimization:** Avoid expensive ops (division, sqrt, exp, sin) in process()
6. **Component colors:** Red=params, Green=inputs, Blue=outputs, Magenta=lights, Yellow=custom
7. **JSON serialization:** Override dataToJson/dataFromJson for custom state (not params)
8. **Thread safety:** Module methods are mutually exclusive (no locks needed)
9. **Helper.py workflow:** Create SVG first, then run createmodule (not reverse)
10. **Library submission:** Must be open-source, include LICENSE.txt, post in issue tracker

---

## State Management (Parallel)

### PLUGINS.md → MODULES.md
```markdown
# VCV Rack Modules Registry

| Module | Status | Version | HP | Category | Install Date |
|--------|--------|---------|----|-----------|----- ---------|
| MyOscillator | 📦 Installed | 2.1.0 | 10 | Oscillator | 2025-11-12 |
| MyFilter | ✅ Working | 1.0.0 | 8 | Filter | 2025-11-10 |
| MySequencer | 🚧 Stage 4 | - | 16 | Sequencer | - |

## Status Legend
- 💡 Ideated - Creative brief exists, no implementation
- 🚧 Stage N - In development (locked to module-workflow)
- ✅ Working - Stage 6 complete, not installed
- 📦 Installed - In VCV Rack plugins folder
- 🌐 Published - Submitted to VCV Library
- 🐛 Has Issues - Known problems (combines with other states)
```

### .continue-here.md (Same Structure)
```json
{
  "module_name": "MyOscillator",
  "current_stage": 4,
  "current_phase": "4.2",
  "next_action": "Implement anti-aliasing for saw wave",
  "last_updated": "2025-11-12T10:30:00Z",
  "notes": "Completed basic oscillator, need polyBLEP for saw/square"
}
```

---

## Commands Adaptation

### New/Modified Commands
- `/dream-vcv [Name]` - Ideate VCV Rack module
- `/plan-vcv [Name]` - Research + planning for VCV module
- `/implement-vcv [Name]` - Build through Stages 2-6 (VCV version)
- `/install-module [Name]` - Install to Rack plugins folder
- `/uninstall-module [Name]` - Remove from Rack plugins folder
- `/show-vcv [Name]` - Open VCV Rack and load module
- `/publish-module [Name]` - Generate VCV Library submission
- `/test-vcv [Name]` - Run VCV-specific validation suite

### Reusable Commands (No Changes)
- `/continue [Name]` - Resume from checkpoint (works for both)
- `/improve [Name]` - Version management + regression testing (adapted)
- `/doc-fix` - Document solved problems (both JUCE and VCV)
- `/research [topic]` - Deep investigation (works for both)

---

## Typical VCV Module Structure (Completed)

```
plugins/MyOscillator/
├── .ideas/
│   ├── creative-brief.md         # Vision, CV/audio I/O, HP width
│   ├── parameter-spec.md         # Params, inputs, outputs, lights, positions
│   ├── architecture.md           # DSP design, CV processing, polyphony
│   ├── plan.md                   # Implementation strategy
│   ├── panels/
│   │   ├── v2-panel.yaml         # Machine-readable spec
│   │   ├── v2-panel.svg          # Final panel (Inkscape, with component layer)
│   │   ├── v2-ModuleWidget.cpp   # Boilerplate C++
│   │   └── v2-integration-checklist.md
│   └── .continue-here.md         # Resume checkpoint
├── src/
│   ├── plugin.hpp                # Plugin-level declarations
│   ├── plugin.cpp                # Plugin registration (modelMyOscillator)
│   └── MyOscillator.cpp          # Module + ModuleWidget implementation
├── res/
│   ├── MyOscillator.svg          # Panel graphic (production)
│   └── MyOscillator-dark.svg     # Optional dark theme panel
├── presets/
│   ├── Default.vcvm              # Factory presets (JSON)
│   ├── Sine.vcvm
│   └── Sawtooth.vcvm
├── plugin.json                   # Manifest (slug, version, modules, metadata)
├── Makefile                      # Build config (RACK_DIR reference)
├── CHANGELOG.md                  # Version history
└── LICENSE.txt                   # License (required for VCV Library)
```

---

## Migration Path: Implementing Module Freedom System

### Phase 1: Infrastructure Setup
1. **Directory structure:**
   - Copy `.claude/` structure to `vcv-rack-system/`
   - Adapt skills (rename, update references)
   - Adapt subagents (VCV-specific knowledge)
   - Adapt commands (VCV-specific commands)

2. **Knowledge base:**
   - Create `troubleshooting-vcv/` (parallel to `troubleshooting/`)
   - Seed with `vcv-critical-patterns.md` (Required Reading)
   - Copy relevant DSP patterns (polyphony, anti-aliasing)

3. **Scripts:**
   - Create `scripts/build-and-install-vcv.sh` (7-phase pipeline)
   - Adapt for Makefile-based build (`make` instead of `cmake`)
   - Platform-specific Rack plugins folder detection

4. **State files:**
   - Create `MODULES.md` (registry)
   - Reuse `.continue-here.md` structure (same JSON format)

### Phase 2: Skill/Subagent Adaptation
1. **Foundation-agent-vcv:**
   - Generate plugin.json (helper.py createplugin)
   - Create Makefile with RACK_DIR reference
   - Generate plugin.hpp/cpp (registration boilerplate)

2. **Shell-agent-vcv:**
   - Generate SVG panel with component placeholders
   - Run helper.py createmodule (auto-generate Module skeleton)
   - Define config() calls (params, inputs, outputs, lights)

3. **DSP-agent-vcv:**
   - Implement process() (per-sample instead of buffer-based)
   - Handle polyphony (channel iteration)
   - Apply anti-aliasing (polyBLEP, oversampling)
   - Use args.sampleTime for sample-rate-dependent processing

4. **GUI-agent-vcv:**
   - Create ModuleWidget (setPanel, addParam, addInput, addOutput)
   - Position components (mm2px conversion)
   - Optional: Custom widgets (NanoVG drawing)

5. **Validator-vcv:**
   - Generate .vcvm presets (JSON format)
   - Run manual test protocol
   - Generate CHANGELOG.md
   - Prepare VCV Library submission (if open-source)

### Phase 3: Testing & Refinement
1. **Test module-workflow:**
   - Create simple module (VCO, VCA, utility)
   - Run through Stages 0-6
   - Verify checkpoint protocol

2. **Test panel-mockup:**
   - 2-phase workflow (iteration → scaffolding)
   - Verify helper.py automation
   - Test multiple HP widths

3. **Test module-improve:**
   - Fix bug, add feature
   - Verify regression testing
   - Check version bumping

### Phase 4: Documentation & Launch
1. **Create VCV-SYSTEM-OVERVIEW.md:**
   - Parallel to SYSTEM-OVERVIEW.md
   - Document VCV-specific workflow
   - Quick reference for VCV patterns

2. **Create vcv-templates/:**
   - Contract templates (creative-brief, parameter-spec, architecture, plan)
   - SVG panel template (Inkscape file with component layer)
   - Preset template (.vcvm JSON structure)

3. **Update hooks:**
   - Detect VCV projects (check for plugin.json)
   - Apply VCV-specific validation
   - Inject vcv-critical-patterns.md into VCV subagents

4. **Launch:**
   - `/setup-vcv` - Validate VCV dependencies
   - `/dream-vcv MyFirstModule` - Test end-to-end
   - Document lessons learned
   - Publish Module Freedom System

---

## Key Differences Summary

| Aspect | JUCE | VCV Rack |
|--------|------|----------|
| **Build Time** | Longer (CMake + compile) | Faster (Make + simple Makefile) |
| **GUI Complexity** | Higher (WebView, web skills) | Lower (SVG + standard widgets) |
| **DSP Paradigm** | Buffer-based (throughput) | Per-sample (latency) |
| **Parameter System** | APVTS (complex, type-safe) | config() + JSON (simple, flexible) |
| **Distribution** | User installs to system folders | VCV Library or manual install |
| **Learning Curve** | Steeper (JUCE API, CMake, WebView) | Gentler (simpler API, Make, SVG) |
| **Creative Control** | Full UI customization | Limited to SVG panel + standard widgets |
| **Audio Paradigm** | DAW-integrated plugin | Modular patchbay environment |

**Recommendation:** Start with VCV Rack for simpler implementation, faster iteration, and lower barrier to entry. JUCE for commercial-grade plugins with custom UIs.

---

## Resources

### Official VCV Rack Documentation
- **Manual:** https://vcvrack.com/manual/
- **API Reference:** https://vcvrack.com/docs-v2/
- **Library:** https://library.vcvrack.com/
- **GitHub:** https://github.com/VCVRack/Rack
- **SDK Downloads:** https://vcvrack.com/downloads/

### Learning Resources
- **Julius O. Smith III - DSP Books:** https://ccrma.stanford.edu/~jos/
- **Vadim Zavalishin - VA Filter Design:** Native Instruments white paper
- **VCV Community Forum:** https://community.vcvrack.com/
- **O'Reilly Book:** "Developing Virtual Synthesizers with VCV Rack"

### Example Plugins (Open Source)
- **Fundamental:** https://github.com/VCVRack/Fundamental (official)
- **Befaco:** https://github.com/VCVRack/Befaco
- **Mutable Instruments:** https://github.com/VCVRack/AudibleInstruments
- **Bogaudio:** https://github.com/bogaudio/BogaudioModules
- **Valley:** https://github.com/ValleyAudio/ValleyRackFree

---

## Conclusion

The Plugin Freedom System's 7-stage workflow, dispatcher pattern, contract system, and checkpoint protocol translate seamlessly to VCV Rack module development. The core architecture—Dream → Plan → Foundation → Shell → DSP → GUI → Validation—remains identical, with only implementation details changing.

**Key insight:** Both JUCE and VCV Rack are targets for the same high-level workflow. The "Freedom System" is target-agnostic at the orchestration level, with specialized subagents handling platform-specific implementation.

**Next steps:**
1. Implement `module-workflow` skill (VCV orchestrator)
2. Create VCV-specific subagents (foundation, shell, dsp, gui, validator)
3. Adapt build pipeline (`scripts/build-and-install-vcv.sh`)
4. Seed knowledge base (`troubleshooting-vcv/`, `vcv-critical-patterns.md`)
5. Test with simple module (VCA or utility)
6. Launch Module Freedom System

**Estimated effort:** 2-3 weeks to adapt system, test, and document (given existing JUCE implementation).
