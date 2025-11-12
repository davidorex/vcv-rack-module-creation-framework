# [ModuleName] - Implementation Plan

**Date:** [YYYY-MM-DD]
**Complexity Score:** [X.X] ([Simple/Medium/Complex])
**Strategy:** [Single-pass implementation | Phase-based implementation]
**HP Width:** [X] HP ([X * 5.08] mm)

---

## Complexity Factors

[Show the calculation breakdown]

**Formula:** `params + (ports / 8) + (HP / 4) + algorithms + features + polyphony`

- **Parameters:** [N] parameters ([N / 5] points, capped at 2.0) = [X.X]
  - [List parameters counted]
- **I/O Ports:** [N] ports ([N / 8] points, capped at 1.5) = [X.X]
  - [List ports: X inputs + Y outputs]
- **HP Width:** [X] HP ([HP / 4] points, capped at 1.0) = [X.X]
  - 4-8 HP = 0.5 points (simple)
  - 10-16 HP = 0.75 points (medium)
  - 18+ HP = 1.0 points (complex)
- **Algorithms:** [N] DSP components = [N]
  - [List DSP components counted]
- **Features:** [N] points
  - Polyphony support (+0.5 if fully polyphonic)
  - Oversampling/anti-aliasing (+0.5 per nonlinear component)
  - External feedback/CV routing (+0.5 per complex routing)
  - 1V/oct tracking (+0.5)
  - Custom UI widgets (+0.5 per widget)
  - [List features identified]
- **Total:** [X.X] (capped at 5.0)

**Complexity Thresholds:**
- **0-2.0:** Simple (single-pass implementation)
- **2.0-3.5:** Medium (consider phased implementation)
- **3.5-5.0:** Complex (phased implementation required)

**Example:**
```markdown
**Formula:** `params + (ports / 8) + (HP / 4) + algorithms + features + polyphony`

- **Parameters:** 7 parameters (7 / 5 = 1.4, capped at 2.0) = 1.4
  - TIME, FEEDBACK, MIX, TONE, WOW, FLUTTER, PING_PONG
- **I/O Ports:** 8 ports (8 / 8 = 1.0, capped at 1.5) = 1.0
  - 4 inputs (IN, TIME_CV, FEEDBACK_CV, EXT_FB) + 4 outputs (OUT_L, OUT_R, DRY, CLIP)
- **HP Width:** 10 HP (10 / 4 = 2.5, capped at 1.0) = 0.75
  - Medium width (10-16 HP range)
- **Algorithms:** 5 DSP components = 5.0
  - Delay line (interpolated)
  - Tone filter (state-variable)
  - Tape saturation (oversampled)
  - Wow/flutter LFOs (dual)
  - Ping-pong router
- **Features:** 2.0 points
  - Polyphony support (+0.5)
  - Oversampling for saturation (+0.5)
  - External feedback routing (+0.5)
  - 1V/oct tracking at max feedback (+0.5)
- **Total:** 1.4 + 1.0 + 0.75 + 5.0 + 2.0 = 10.15 → Capped at 5.0

**Complexity:** 5.0 (Complex - phased implementation required)
```

---

## Stages

- Stage 0: Ideation ✓
- Stage 1: Planning ✓
- Stage 2: Foundation ← Next
- Stage 3: Panel Design
- Stage 4: DSP [phased if complex]
- Stage 5: Assembly
- Stage 6: Validation

---

## Simple Implementation (Score ≤ 2.0)

[Use this format for simple modules - single-pass implementation]

### Estimated Duration

Total: ~[X] minutes

- Stage 2: 5 min (Foundation - plugin structure via helper.py createplugin)
- Stage 3: 15 min (Panel - SVG design with component layer)
- Stage 4: [X] min (DSP - single pass)
- Stage 5: [X] min (Assembly - createmodule, wire parameters/I/O)
- Stage 6: 10 min (Validation - test in Rack, check polyphony)

### Implementation Notes

**DSP Approach:**
[Describe straightforward implementation plan]

**Panel Approach:**
[Describe UI layout plan]

**Key Considerations:**
- [Any special notes for simple implementation]
- [Potential gotchas]

**Example:**
```markdown
### Estimated Duration

Total: ~45 minutes

- Stage 2: 5 min (Foundation)
- Stage 3: 15 min (Panel)
- Stage 4: 10 min (DSP)
- Stage 5: 10 min (Assembly)
- Stage 6: 5 min (Validation)

### Implementation Notes

**DSP Approach:**
- Single VCO core using rack::dsp sine oscillator
- Simple 1V/oct tracking (exp2_taylor5)
- No complex modulation or polyphony
- Straightforward parameter mapping

**Panel Approach:**
- 6 HP width (minimal)
- 3 knobs (FREQ, FINE, SHAPE)
- 2 inputs (V/OCT, FM)
- 1 output (OUT)
- Clean layout, centered components

**Key Considerations:**
- Use exp2_taylor5 for fast 1V/oct conversion
- Ensure V/OCT input is summed with FREQ param
- Test with keyboard/sequencer for accurate tracking
```

---

## Medium Implementation (Score 2.0-3.5)

[Use this format for medium modules - consider phased approach if >3.0]

### Estimated Duration

Total: ~[X] minutes to [Y] hours

- Stage 2: 5 min (Foundation)
- Stage 3: 20 min (Panel)
- Stage 4: [X] min (DSP - single pass or 2 phases)
- Stage 5: [X] min (Assembly)
- Stage 6: 15 min (Validation)

### Implementation Notes

**DSP Approach:**
[Describe moderate complexity implementation]

**Panel Approach:**
[Describe UI layout plan]

**Phasing Decision:**
- If score < 3.0: Single-pass DSP implementation (all at once)
- If score ≥ 3.0: Consider splitting into 2 phases (core + features)

**Example:**
```markdown
**Complexity:** 2.8 (Medium - single-pass acceptable, but could phase)

**DSP Approach:**
- Implement all DSP in single pass (delay line, filter, saturation)
- Start with core (delay read/write), then add filter, then saturation
- Test incrementally within single implementation session

**Panel Approach:**
- 10 HP width (standard)
- 6 knobs + 4 inputs + 2 outputs + 2 lights
- Logical grouping: delay controls (top), feedback controls (middle), output (bottom)

**Phasing Decision:**
- Single-pass implementation (score < 3.0)
- Implement all DSP components in one session (~40 min)
- Test after each component addition (incremental validation)
```

---

## Complex Implementation (Score ≥ 3.5)

[Use this format for complex modules - phased implementation required]

### Stage 4: DSP Phases

#### Phase 4.1: Core Processing

**Goal:** [Describe core audio path implementation]

**Components:**
- [List DSP components to implement in this phase]
- [Describe basic signal flow]

**Test Criteria:**
- [ ] Module loads in VCV Rack without crashes
- [ ] Audio passes through (input to output audible)
- [ ] [Component 1] parameter works correctly
- [ ] [Component 2] parameter works correctly
- [ ] No artifacts or discontinuities
- [ ] Polyphony propagates correctly (if applicable)

**Duration:** [X] min

**Example:**
```markdown
#### Phase 4.1: Core Delay Line

**Goal:** Implement basic delay buffer with time control and dry/wet mixing

**Components:**
- Delay buffer (DoubleRingBuffer) with write/read heads
- TIME parameter controls read position offset
- MIX parameter blends dry and wet signals
- Basic polyphony support (per-channel buffers)

**Test Criteria:**
- [ ] Module loads in VCV Rack without crashes
- [ ] Audio input appears at output (dry signal audible)
- [ ] TIME knob changes delay time audibly (10ms-1s range)
- [ ] MIX knob blends dry and wet (0% = dry only, 100% = wet only)
- [ ] No clicks or pops when changing TIME
- [ ] Polyphony works (16-channel test with VCV MERGE)

**Duration:** 25 min

**Notes:**
- Use cubic interpolation for smooth time changes
- Smooth TIME changes over 10ms to prevent clicks
- Allocate buffers lazily (only when channel active)
```

---

#### Phase 4.2: Feedback and Routing

**Goal:** [Describe feedback system and signal routing]

**Components:**
- [List feedback/routing components]
- [Describe parameter connections]

**Test Criteria:**
- [ ] FEEDBACK parameter controls repeat amount
- [ ] Feedback loop is stable (no runaway at 100%)
- [ ] Self-oscillation works (if applicable)
- [ ] External feedback input works (if applicable)
- [ ] Routing switches work correctly (if applicable)

**Duration:** [X] min

**Example:**
```markdown
#### Phase 4.2: Feedback and Tone Filter

**Goal:** Implement feedback path with tone filtering and external feedback input

**Components:**
- FEEDBACK parameter (0-120%) controls feedback gain
- TONE filter (state-variable) in feedback path
- EXT_FB input (normalized to internal feedback)
- FEEDBACK_CV input for voltage control

**Test Criteria:**
- [ ] FEEDBACK knob controls repeat amount (0% = single delay, 100% = infinite)
- [ ] Feedback >100% creates self-oscillation (stable, no runaway)
- [ ] TONE knob filters feedback (negative = dark, positive = bright)
- [ ] EXT_FB input replaces internal feedback when patched
- [ ] FEEDBACK_CV modulates feedback amount (±5V = ±100%)
- [ ] No instability or runaway at extreme settings

**Duration:** 20 min

**Notes:**
- Use soft limiter at 120% feedback to prevent runaway
- TONE bypass zone (±0.5%) prevents accidental filtering at center
- EXT_FB normalizes to internal feedback (check isConnected())
```

---

#### Phase 4.3: Advanced Features

[Only include if complex features present]

**Goal:** [Describe advanced DSP features]

**Components:**
- [List advanced components (modulation, anti-aliasing, pitch tracking, etc.)]
- [Describe integration with core processing]

**Test Criteria:**
- [ ] [Feature 1] works as specified
- [ ] [Feature 2] integrates without artifacts
- [ ] Performance acceptable with all features active (<1% CPU per channel target)
- [ ] Edge cases handled correctly
- [ ] Polyphonic behavior correct (if applicable)

**Duration:** [X] min

**Example:**
```markdown
#### Phase 4.3: Wow/Flutter and Tape Saturation

**Goal:** Add vintage tape character (wow/flutter modulation and saturation)

**Components:**
- Dual LFOs (WOW = slow 0.1-0.5Hz, FLUTTER = fast 1-5Hz)
- Smooth random waveform (sample & hold + lowpass)
- Tape saturation (oversampled tanh) in feedback path
- 1V/oct tracking when FEEDBACK ≥ 90%

**Test Criteria:**
- [ ] WOW knob adds slow tape speed variation (0-2% depth)
- [ ] FLUTTER knob adds fast tape speed variation (0-1% depth)
- [ ] Wow/flutter modulation is smooth and organic (not stepped)
- [ ] Tape saturation audible at high feedback (soft clipping)
- [ ] 1V/oct tracking works at max feedback (keyboard/sequencer test)
- [ ] CPU usage acceptable (<1% per channel)

**Duration:** 30 min

**Notes:**
- Independent LFO phases per channel (polyphonic variation)
- Saturation uses 2x oversampling to prevent aliasing
- 1V/oct uses exp2_taylor5 for fast conversion
```

---

### Stage 5: Assembly

**Goal:** Generate C++ scaffold from SVG and wire parameters/I/O to DSP

**Components:**
- Run `helper.py createmodule` to generate boilerplate from SVG
- Wire parameters (params[X]) to DSP components
- Wire inputs/outputs (inputs[X], outputs[X]) to processing chain
- Add lights (if applicable) for visual feedback
- Implement polyphony (setChannels calls)

**Test Criteria:**
- [ ] All parameters appear in Rack and control DSP correctly
- [ ] All inputs/outputs work (audio, CV, gates)
- [ ] Lights respond to DSP state (if applicable)
- [ ] Polyphony propagates correctly (input channels = output channels)
- [ ] Right-click menu works (if applicable)

**Duration:** [X] min

**Example:**
```markdown
**Goal:** Wire SVG components to DSP implementation

**Components:**
- Generate scaffold: `$RACK_DIR/helper.py createmodule TapeDelay res/TapeDelay.svg src/TapeDelay.cpp`
- Wire 7 parameters (TIME, FEEDBACK, MIX, TONE, WOW, FLUTTER, PING_PONG)
- Wire 4 inputs (IN, TIME_CV, FEEDBACK_CV, EXT_FB)
- Wire 4 outputs (OUT_L, OUT_R, DRY, CLIP)
- Add CLIP light (brightness = saturation level)
- Implement `setChannels()` for all outputs

**Test Criteria:**
- [ ] All 7 knobs visible and functional
- [ ] All 4 inputs accept cables and modulate correctly
- [ ] All 4 outputs generate signals
- [ ] CLIP light brightness tracks saturation level
- [ ] Polyphony: 16-channel input → 16-channel output
- [ ] Module appears in VCV Library browser

**Duration:** 15 min

**Notes:**
- helper.py reads component layer (red/green/blue/magenta colors)
- Enum names match SVG component IDs (e.g., "time-knob" → TIME_PARAM)
- Position coordinates auto-generated with mm2px()
```

---

### Estimated Duration

Total: ~[X] hours

- Stage 2: 5 min (Foundation - createplugin)
- Stage 3: 25 min (Panel - SVG with component layer)
- Stage 4: [X] min (DSP - [N] phases)
  - Phase 4.1: [X] min (Core processing)
  - Phase 4.2: [X] min (Feedback/routing)
  - Phase 4.3: [X] min (Advanced features, if applicable)
- Stage 5: [X] min (Assembly - createmodule, wiring)
- Stage 6: 20 min (Validation - comprehensive testing)

**Example:**
```markdown
Total: ~2 hours

- Stage 2: 5 min (Foundation)
- Stage 3: 25 min (Panel - 10 HP design)
- Stage 4: 75 min (DSP - 3 phases)
  - Phase 4.1: 25 min (Core delay line)
  - Phase 4.2: 20 min (Feedback and tone filter)
  - Phase 4.3: 30 min (Wow/flutter and saturation)
- Stage 5: 15 min (Assembly)
- Stage 6: 20 min (Validation)
```

---

## Implementation Notes

[Add any notes that will help during implementation]

### Thread Safety

[Note parameter access patterns, concurrency, lock-free updates]

**Example:**
```markdown
- All Module methods (process, dataToJson, dataFromJson) are mutually exclusive (VCV Rack guarantee)
- No mutexes needed within Module class
- Parameter access is thread-safe (Rack handles synchronization)
- UI callbacks (ModuleWidget) run in separate thread:
  - Use params[X].getValue() for safe reads
  - Use params[X].setValue() for safe writes
- Large state changes (buffer resizes) require careful handling:
  - Allocate new buffer, swap atomically, or pause engine
```

### Performance

[Estimate CPU usage per component, identify hot paths]

**Example:**
```markdown
**CPU Budget:**
- Monophonic (1 channel): 1-2% CPU
  - Delay read/write: 0.5%
  - Cubic interpolation: 0.3%
  - Tone filter: 0.2%
  - Saturation (2x oversample): 0.5%
  - Mixing/routing: 0.2%
- 16-channel polyphonic: 8-12% CPU (scales linearly)

**Hot Paths:**
- Cubic interpolation (called per sample, per channel)
- Oversampled saturation (2x samples processed)
- Tone filter update (per sample, per channel)

**Optimization Opportunities:**
- SIMD (float_4) for 2-4x speedup on polyphonic
- Reduce interpolation quality if CPU-constrained
- Skip tone filter if TONE ≈ 0 (bypass mode)
- Skip saturation if FEEDBACK < 80%
```

### Memory Usage

[Calculate buffer allocation, polyphonic scaling]

**Example:**
```markdown
**Per-Channel:**
- Delay buffer: 192,000 samples × 4 bytes = 768 KB (1s at 192kHz)
- Oversampling buffers: 8 KB
- Filter/LFO state: ~200 bytes
- **Total:** ~780 KB per channel

**Polyphonic Scaling:**
- 1 channel: 780 KB
- 8 channels: 6.2 MB
- 16 channels: 12.5 MB

**Notes:**
- 12.5 MB is acceptable on modern systems
- Consider lazy allocation (only allocate active channels)
- Alternative: Reduce max delay to 500ms (halve memory)
```

### Latency

[Calculate total processing latency]

**Example:**
```markdown
**Latency Sources:**
- Base delay: Variable (10ms-1s) - unavoidable, this is the effect
- Oversampling: ~8 samples (0.17ms at 48kHz) - negligible

**Total Latency:**
- ~8 samples from oversampling (constant, negligible)
- No compensation needed (VCV Rack has no plugin delay compensation)

**Notes:**
- DRY output has no latency (immediate passthrough)
- Users can manually compensate if needed
```

### Denormal Protection

[Note denormal handling strategy]

**Example:**
```markdown
- VCV Rack flushes denormals automatically (_MM_SET_FLUSH_ZERO_MODE)
- No manual denormal protection needed
- Add small DC offset (1e-10) to feedback path if CPU spikes observed
- rack::dsp filters handle denormals internally
```

### Anti-Aliasing

[Note anti-aliasing strategy]

**Example:**
```markdown
**Required For:**
- Tape saturation (nonlinear) → 2x oversampling with Decimator

**Not Required For:**
- Delay line (linear interpolation)
- Tone filter (linear)
- LFO modulation (slow, no harmonics above Nyquist)

**Implementation:**
- Use `rack::dsp::Decimator<2, 8>` for 2x oversampling
- Process saturation at 2x sample rate
- Downsample with brickwall filter (built into Decimator)
```

### Known Challenges

[List any anticipated difficulties and approaches]

1. **[Challenge Name]**
   - Description: [What makes this difficult]
   - Approach: [How to address it]
   - Reference: [Similar module or pattern]

**Example:**
```markdown
1. **Smooth Delay Time Modulation**
   - Description: Direct delay time changes cause pitch glitches and clicks
   - Approach: Use one-pole lowpass filter to smooth time changes over 10ms
   - Reference: VCV Delay uses similar smoothing

2. **Self-Oscillation Stability**
   - Description: Feedback >100% can runaway and clip internal buffer
   - Approach: Soft limiter at 120% feedback, allow controlled saturation
   - Reference: Echophon uses similar feedback limiting

3. **Polyphonic Memory Management**
   - Description: 16 channels × 1s delay = ~12 MB per module instance
   - Approach: Lazy allocation (only allocate active channels), acceptable on modern systems
   - Reference: Befaco Spring Reverb uses lazy allocation

4. **Wow/Flutter vs Pitch CV**
   - Description: Both modulate delay time, need to sum correctly without runaway
   - Approach: Apply wow/flutter as ±2% modulation after TIME CV, clamp total range
   - Reference: No direct reference, test incrementally

5. **Stereo Ping-Pong Timing**
   - Description: Need to alternate delays between L/R outputs with correct timing
   - Approach: Dual delay lines with crossover feedback routing (L → R, R → L)
   - Reference: Chronoblob2 uses dual delay lines
```

---

## References

[Link to contract files and related documentation]

- Creative brief: `modules/[ModuleName]/.ideas/creative-brief.md`
- Parameter spec: `modules/[ModuleName]/.ideas/parameter-spec.md`
- DSP architecture: `modules/[ModuleName]/.ideas/architecture.md`
- Panel mockup: `modules/[ModuleName]/.ideas/mockups/panel.svg`

[Link to similar modules for reference]

- [ModuleName1] - [What to reference from this module]
- [ModuleName2] - [What to reference from this module]

**Example:**
```markdown
**Contract Files:**
- Creative brief: `modules/TapeDelay/.ideas/creative-brief.md`
- Parameter spec: `modules/TapeDelay/.ideas/parameter-spec.md`
- DSP architecture: `modules/TapeDelay/.ideas/architecture.md`
- Panel mockup: `modules/TapeDelay/.ideas/mockups/panel.svg`

**Reference Modules:**
- VCV Delay - Basic delay line structure, polyphony handling
- Chronoblob2 - External feedback input, dual delay lines for ping-pong
- Echophon - Self-oscillation, 1V/oct tracking
- Befaco Spring Reverb - Polyphonic processing, SIMD optimization
- Vult Tangents - Oversampled saturation, anti-aliasing
```

---

## Validation Plan

### Functional Tests

[What to test for correctness]

**Example:**
```markdown
- [ ] Module loads without crashes
- [ ] All parameters appear and function
- [ ] All inputs accept cables and modulate correctly
- [ ] All outputs generate expected signals
- [ ] Delay time range (10ms-1s) is correct
- [ ] Feedback range (0-120%) is correct
- [ ] Self-oscillation stable at 100% feedback
- [ ] External feedback input works (replaces internal)
- [ ] Ping-pong mode alternates L/R correctly
- [ ] 1V/oct tracking works at max feedback
- [ ] Polyphony: 1-16 channels process correctly
- [ ] CLIP light tracks saturation level
```

### Performance Tests

[What to test for efficiency]

**Example:**
```markdown
- [ ] Monophonic: <2% CPU at 48kHz
- [ ] 16-channel polyphonic: <12% CPU at 48kHz
- [ ] No audio dropouts under heavy modulation
- [ ] Memory usage acceptable (<15 MB for 16 channels)
- [ ] No CPU spikes when changing parameters
```

### Edge Case Tests

[What to test for robustness]

**Example:**
```markdown
- [ ] No clicks when changing TIME rapidly
- [ ] No runaway at >100% feedback
- [ ] No artifacts when switching PING_PONG mode
- [ ] No crashes when disconnecting cables during playback
- [ ] Polyphony change (1 → 16 channels) works smoothly
- [ ] Works correctly at 44.1kHz, 48kHz, 96kHz, 192kHz
```

### Sonic Tests

[What to test for sound quality]

**Example:**
```markdown
- [ ] Delay sounds clean (no digital artifacts)
- [ ] Pitch-shifting is smooth when TIME is modulated
- [ ] Wow/flutter adds organic movement (not excessive)
- [ ] Tape saturation sounds warm (not harsh)
- [ ] Tone filter affects feedback only (not initial signal)
- [ ] Self-oscillation is musical (tracks 1V/oct)
```

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| [YYYY-MM-DD] | 1.0 | Initial implementation plan | [Author] |

**Example:**
```markdown
| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-12 | 1.0 | Initial implementation plan | Claude |
| 2025-11-13 | 1.1 | Split DSP into 3 phases (was 2) | User |
```

---

## Contract Status

**Status:** [Draft | Approved | Immutable]

**Approval Date:** [YYYY-MM-DD or "Pending"]

**Implementation Stage:** [0 = Ideation | 1 = Planning | 2+ = Implementation locked]

**Notes:**
- **Draft**: Still planning, strategy may change
- **Approved**: Ready for implementation, changes require discussion
- **Immutable**: Implementation started, changes forbidden (would break contract)

**Example:**
```markdown
**Status:** Immutable

**Approval Date:** 2025-11-12

**Implementation Stage:** 2 (Foundation stage - contract locked)

**Notes:**
Plan locked after Stage 1 completion. No changes allowed during Stages 2-5 implementation. Complexity score and phasing strategy are fixed.
```
