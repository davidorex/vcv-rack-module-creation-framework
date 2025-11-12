# VCV Rack Critical Patterns - Required Reading

**Purpose:** Non-negotiable patterns that prevent repeat mistakes across all VCV Rack module development.

**Audience:** ALL subagents (foundation-agent, shell-agent, dsp-agent, gui-agent, validator) MUST internalize these patterns before implementation.

**Status:** Living document - updated when new critical patterns emerge.

---

## 1. Slug Immutability (ABSOLUTE RULE)

### Pattern
**Plugin and module slugs MUST NEVER CHANGE after first release.**

### Rationale
- Changing slugs breaks all user patches that reference the module
- VCV Rack identifies modules by plugin slug + module slug
- No migration path exists for renamed modules

### Implementation
```json
// plugin.json - THESE VALUES ARE PERMANENT
{
  "slug": "MyPlugin",        // ← NEVER CHANGE after v1.0.0
  "modules": [
    {
      "slug": "MyModule"     // ← NEVER CHANGE after v1.0.0
    }
  ]
}
```

### Validation
- Slugs use only: a-z, A-Z, 0-9, -, _
- Case-sensitive (MyModule ≠ mymodule)
- No spaces, no special characters
- Check slug validity BEFORE first release

### Recovery
**If slug was changed:**
- Cannot undo - breaking change shipped
- Document in CHANGELOG as breaking change
- Users must manually fix patches
- Avoid at all costs

---

## 2. Panel Dimensions (EXACT STANDARD)

### Pattern
**Height = 128.5mm (fixed), Width = HP × 5.08mm (exact)**

### Rationale
- Eurorack standard: 1 HP = 5.08mm, 3U = 128.5mm
- VCV Rack renders panels at exact dimensions
- Incorrect dimensions cause misalignment in patches

### Implementation
```xml
<!-- SVG panel dimensions -->
<svg
   width="[HP * 5.08]mm"
   height="128.5mm"
   viewBox="0 0 [HP * 5.08] 128.5">
```

```cpp
// ModuleWidget box size
setPanel(createPanel(asset::plugin(pluginInstance, "res/MyModule.svg")));
// Panel width auto-determined from SVG, but can be set explicitly:
// box.size.x = mm2px(HP * 5.08);
```

### Common HP Widths
- 4 HP = 20.32mm (minimal)
- 6 HP = 30.48mm (small)
- 8 HP = 40.64mm (medium)
- 10 HP = 50.80mm (standard)
- 12 HP = 60.96mm (large)
- 16 HP = 81.28mm (complex)
- 20 HP = 101.60mm (very complex)

### Validation
- Measure SVG width: `HP * 5.08 ± 0.01mm`
- Height: exactly 128.5mm
- No fractional HP (must be integer)

---

## 3. Voltage Standards (SIGNAL CONVENTION)

### Pattern
**Audio/CV: ±5V standard, Pitch CV: 1V/octave (C4 = 0V)**

### Rationale
- VCV Rack uses ±5V for most signals (±10V accepted but ±5V standard)
- 1V/oct enables predictable pitch tracking
- Consistency across modules enables patching compatibility

### Implementation
```cpp
// Audio input/output
float input = inputs[AUDIO_IN].getVoltage();  // Expect ±5V
outputs[AUDIO_OUT].setVoltage(output);        // Generate ±5V

// Pitch CV (1V/oct standard)
float pitch = params[PITCH_PARAM].getValue() + inputs[PITCH_CV].getVoltage();
float freq = dsp::FREQ_C4 * dsp::exp2_taylor5(pitch);  // 1V/oct → Hz

// Modulation CV (0-10V or ±5V)
float mod = clamp(inputs[MOD_CV].getVoltage(), 0.f, 10.f);  // If 0-10V range
float mod = clamp(inputs[MOD_CV].getVoltage(), -5.f, 5.f);  // If ±5V range
```

### Standards
- **Audio**: ±5V (peaks may exceed, but RMS around ±5V)
- **Pitch CV**: 1V/oct (0V = C4 = 261.63 Hz)
- **Gate/Trigger**: High = 10V, Low = 0V (or any >1V = high)
- **Modulation**: ±5V or 0-10V (document in manual)

### Validation
- Test with Audio-16 module (provides ±5V audio)
- Test pitch tracking with VCV VCO-1
- Check clipping behavior at ±10V

---

## 4. Component Color Codes (SVG STANDARD)

### Pattern
**Red = params, Green = inputs, Blue = outputs, Magenta = lights, Yellow = custom**

### Rationale
- helper.py auto-generates C++ from SVG component colors
- Consistent color coding enables automation
- Wrong colors cause misplaced components

### Implementation
```xml
<!-- SVG component layer (Inkscape) -->
<g id="components">
  <!-- Parameters (knobs, switches) -->
  <circle id="freq-knob" cx="10" cy="20" r="2" fill="#ff0000" />

  <!-- Input ports -->
  <circle id="audio-in" cx="10" cy="40" r="2" fill="#00ff00" />

  <!-- Output ports -->
  <circle id="audio-out" cx="10" cy="60" r="2" fill="#0000ff" />

  <!-- Lights -->
  <circle id="clip-light" cx="10" cy="80" r="1" fill="#ff00ff" />

  <!-- Custom widgets (optional) -->
  <rect id="display" x="5" y="90" width="10" height="5" fill="#ffff00" />
</g>
```

### Color Codes (Exact Hex)
- **Red**: `#ff0000` → Parameters
- **Green**: `#00ff00` → Inputs
- **Blue**: `#0000ff` → Outputs
- **Magenta**: `#ff00ff` → Lights
- **Yellow**: `#ffff00` → Custom widgets

### Validation
- Hide component layer before exporting final SVG
- Verify colors match exactly (case-insensitive but exact RGB)
- helper.py will error on wrong colors

---

## 5. Polyphony Handling (CABLE CHANNELS)

### Pattern
**Always call setChannels() after processing, use max(1, getChannels())**

### Rationale
- VCV Rack supports up to 16 channels per cable
- Modules must propagate polyphony correctly
- Missing setChannels() causes monophonic output even with poly input

### Implementation
```cpp
void process(const ProcessArgs& args) override {
    // Determine active channels (minimum 1 for monophonic)
    int channels = std::max(1, inputs[AUDIO_IN].getChannels());

    // Process each channel
    for (int c = 0; c < channels; c++) {
        float input = inputs[AUDIO_IN].getVoltage(c);
        float output = processSample(input);  // Your DSP here
        outputs[AUDIO_OUT].setVoltage(output, c);
    }

    // CRITICAL: Set output polyphony
    outputs[AUDIO_OUT].setChannels(channels);
}
```

### SIMD Optimization (Advanced)
```cpp
// Process 4 channels at once with float_4
int channels = std::max(1, inputs[AUDIO_IN].getChannels());
for (int c = 0; c < channels; c += 4) {
    float_4 input = inputs[AUDIO_IN].getPolyVoltageSimd<float_4>(c);
    float_4 output = processSampleSimd(input);  // SIMD DSP
    outputs[AUDIO_OUT].setVoltageSimd(output, c);
}
outputs[AUDIO_OUT].setChannels(channels);
```

### Validation
- Test with VCV MERGE module (creates polyphonic cables)
- Test with VCV SPLIT module (splits poly to mono)
- Verify all 16 channels process correctly

---

## 6. Per-Sample Processing (DSP PARADIGM)

### Pattern
**Avoid expensive operations (division, sqrt, exp, sin, cos) in process()**

### Rationale
- process() called at sample rate (44.1k-192k Hz)
- Expensive operations cause CPU spikes
- Use lookup tables, approximations, or pre-compute in prepareToPlay()

### Implementation
```cpp
// BAD: Division in hot path
void process(const ProcessArgs& args) override {
    float freq = 1.0f / period;  // ❌ Division every sample
    outputs[OUT].setVoltage(sin(phase));  // ❌ sin() every sample
}

// GOOD: Pre-compute or use approximations
void process(const ProcessArgs& args) override {
    float output = lookupTable[phaseInt];  // ✅ Table lookup (fast)
    outputs[OUT].setVoltage(output);
}

// GOOD: Use Rack DSP helpers (optimized)
void process(const ProcessArgs& args) override {
    float pitch = params[FREQ_PARAM].getValue();
    float freq = dsp::FREQ_C4 * dsp::exp2_taylor5(pitch);  // ✅ Fast approximation
}
```

### Optimization Strategies
- **Lookup tables**: Pre-compute sin/cos/exp/log
- **Taylor series**: dsp::exp2_taylor5(), dsp::log2_taylor5()
- **Reciprocal multiplication**: `x * rcp` instead of `x / y` (pre-compute rcp = 1/y)
- **Integer math**: Use fixed-point for counters, phases
- **SIMD**: Process 4 channels at once with float_4

### Validation
- Profile with VCV Rack performance monitor (View → Frame rate)
- Aim for <1% CPU per module (simple modules)
- <5% CPU for complex modules (reverb, convolution)

---

## 7. JSON Serialization (STATE MANAGEMENT)

### Pattern
**Override dataToJson/dataFromJson for custom state (NOT for parameters)**

### Rationale
- Parameters are auto-saved by Rack (no manual code needed)
- Custom state (modes, buffers, sample data) needs manual serialization
- Large data (>100 KB) should use patch storage directory

### Implementation
```cpp
// Custom state (not parameters)
struct MyModule : Module {
    int customMode = 0;  // Not a parameter, needs manual save

    json_t* dataToJson() override {
        json_t* rootJ = json_object();
        json_object_set_new(rootJ, "customMode", json_integer(customMode));
        return rootJ;
    }

    void dataFromJson(json_t* rootJ) override {
        json_t* modeJ = json_object_get(rootJ, "customMode");
        if (modeJ) {
            customMode = json_integer_value(modeJ);
        }
    }
};
```

### Large Data (Samples, Wavetables)
```cpp
// Use patch storage directory for >100 KB
json_t* dataToJson() override {
    json_t* rootJ = json_object();

    // Save large data to file
    std::string dir = createPatchStorageDirectory();
    std::string path = dir + "/sample.wav";
    saveSampleToFile(path);

    // Store only metadata in JSON
    json_object_set_new(rootJ, "sampleLoaded", json_boolean(true));
    return rootJ;
}
```

### Validation
- Save patch, close Rack, reopen → state restored?
- Test with large state (>1 MB) → no lag on autosave?

---

## 8. Helper.py Workflow (SCAFFOLD AUTOMATION)

### Pattern
**Create SVG FIRST, then run createmodule (not reverse)**

### Rationale
- helper.py reads SVG component layer to generate C++ boilerplate
- Running createmodule without SVG creates empty file
- Correct order enables automation

### Implementation
```bash
# Stage 2: Create plugin structure
cd modules/
$RACK_DIR/helper.py createplugin MyPlugin

# Stage 3: Create SVG panel with component layer (Inkscape)
# ... design panel, add component layer with colored placeholders ...

# Stage 3: Generate module from SVG
cd MyPlugin/
$RACK_DIR/helper.py createmodule MyModule res/MyModule.svg src/MyModule.cpp
```

### helper.py createmodule Output
- Reads SVG component layer (red/green/blue/magenta shapes)
- Generates C++ enum for each component
- Generates addParam/addInput/addOutput calls with mm2px positions
- Creates boilerplate Module + ModuleWidget

### Validation
- SVG must have "components" layer
- Component IDs become C++ enum names
- Colors must be exact (#ff0000, #00ff00, etc.)

---

## 9. Thread Safety (MUTUALLY EXCLUSIVE)

### Pattern
**Module methods are mutually exclusive (no locks needed)**

### Rationale
- VCV Rack guarantees process(), dataToJson(), dataFromJson() never run simultaneously
- No need for mutexes in Module class
- Widget callbacks (buttons, knobs) DO need thread safety if accessing Module state

### Implementation
```cpp
// Module methods - thread-safe by design
struct MyModule : Module {
    float internalState = 0.f;

    void process(const ProcessArgs& args) override {
        internalState += 0.01f;  // ✅ No mutex needed
    }

    json_t* dataToJson() override {
        return json_real(internalState);  // ✅ No mutex needed
    }
};

// Widget callbacks - need synchronization if modifying Module
struct MyModuleWidget : ModuleWidget {
    void onButton() override {
        MyModule* module = dynamic_cast<MyModule*>(this->module);
        if (module) {
            // ⚠️ This runs in UI thread, process() runs in audio thread
            // Use atomic or APP->engine->setPaused(true) if modifying shared state
            module->internalState = 0.f;
        }
    }
};
```

### Safe Patterns
- **Module → Widget**: Use lights, outputs (read in widget draw())
- **Widget → Module**: Use params (thread-safe by design)
- **Complex state**: Use std::atomic or pause engine

### Validation
- No crashes under heavy UI interaction + audio processing
- No race conditions (use thread sanitizer if available)

---

## 10. Anti-Aliasing (NONLINEAR PROCESSING)

### Pattern
**Use polyBLEP for discontinuous waveforms, oversampling for nonlinear processes**

### Rationale
- Aliasing creates harsh, digital artifacts
- Discontinuities (saw, square waves) need bandlimiting
- Nonlinear processes (distortion, waveshaping) generate harmonics above Nyquist

### Implementation
```cpp
// PolyBLEP for sawtooth/square (discontinuous waveforms)
float polyBlepSaw(float phase, float phaseInc) {
    float value = 2.f * phase - 1.f;  // Naive saw
    value -= polyBlep(phase, phaseInc);  // Subtract discontinuity
    return value;
}

// Oversampling for nonlinear processes
#include <dsp/decimator.hpp>

struct Distortion : Module {
    dsp::Decimator<8, 8> decimator;  // 8x oversampling

    void process(const ProcessArgs& args) override {
        float input = inputs[IN].getVoltage();

        // Upsample 8x
        float upsampled[8];
        for (int i = 0; i < 8; i++) {
            upsampled[i] = input;  // Interpolate (simplified)
        }

        // Process at high sample rate (nonlinear)
        for (int i = 0; i < 8; i++) {
            upsampled[i] = std::tanh(upsampled[i] * 2.f);
        }

        // Downsample (anti-aliasing filter built-in)
        float output = decimator.process(upsampled);
        outputs[OUT].setVoltage(output);
    }
};
```

### When to Apply
- **PolyBLEP**: Saw, square, pulse waves (discontinuities)
- **Oversampling**: Distortion, saturation, waveshaping, soft clipping
- **Not needed**: Linear filters, reverb, delay, VCA, audio-rate FM of sine

### Validation
- Analyze spectrum (FFT) → no aliasing harmonics above Nyquist
- Listen at 44.1 kHz → no harsh digital artifacts

---

## 11. mm2px Coordinate System (LAYOUT)

### Pattern
**Use mm2px() for all component positioning (millimeters → pixels)**

### Rationale
- SVG uses millimeters, Rack uses pixels
- mm2px() converts correctly for all DPI settings
- Hard-coded pixel values break on high-DPI displays

### Implementation
```cpp
// GOOD: Use mm2px for positions
addParam(createParamCentered<RoundBlackKnob>(
    mm2px(Vec(10.16, 25.4)),  // ✅ Millimeters (from SVG)
    module, MyModule::FREQ_PARAM));

// BAD: Hard-coded pixels
addParam(createParamCentered<RoundBlackKnob>(
    Vec(38.4, 96.0),  // ❌ Pixels (breaks on scaling)
    module, MyModule::FREQ_PARAM));
```

### helper.py Output
- Automatically generates mm2px() calls
- Reads component positions from SVG (millimeters)
- Converts to pixel-based Vec in C++

### Validation
- Test at different zoom levels in VCV Rack
- Components align with panel graphics

---

## Summary Checklist (All Subagents)

Before implementation, verify:

- [ ] **Slugs**: Valid characters (a-zA-Z0-9_-), never change after release
- [ ] **Panel**: Height = 128.5mm, Width = HP × 5.08mm (exact)
- [ ] **Voltages**: ±5V audio/CV, 1V/oct pitch, 10V gate
- [ ] **Colors**: Red/green/blue/magenta for SVG components
- [ ] **Polyphony**: setChannels() after processing
- [ ] **Performance**: No expensive ops in process()
- [ ] **Serialization**: dataToJson/dataFromJson for custom state
- [ ] **Helper.py**: SVG first, then createmodule
- [ ] **Thread safety**: No locks in Module methods
- [ ] **Anti-aliasing**: PolyBLEP or oversampling for nonlinear
- [ ] **Coordinates**: mm2px() for all positions

---

## Updating This Document

When a new critical pattern emerges:

1. Add to this document with pattern/rationale/implementation/validation
2. Update all relevant subagents to reference new pattern
3. Add to system-setup validation checks
4. Document in troubleshooting knowledge base

**Last updated:** 2025-11-12
**Next review:** After first 5 modules complete
