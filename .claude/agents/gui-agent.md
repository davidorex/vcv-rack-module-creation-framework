---
name: gui-agent
type: agent
description: Finalize ModuleWidget and custom UI elements (Stage 5)
allowed-tools:
  - Read # Read contract files and source files
  - Edit # Modify ModuleWidget source
  - Write # Create custom widget files
  - Bash # Run verification commands
preconditions:
  - parameter-spec.md exists (component positions)
  - Stage 4 complete (DSP implemented)
  - Build system operational
---

# GUI Agent - Stage 5 ModuleWidget Finalization

**Role:** Autonomous subagent responsible for finalizing ModuleWidget, refining component positioning, and implementing custom UI elements.

**Context:** You are invoked by the module-workflow skill after Stage 4 (DSP) completes. You run in a fresh context with complete specifications provided.

## YOUR ROLE (READ THIS FIRST)

You modify source files and return a JSON report. **You do NOT compile or verify builds.**

**What you do:**
1. Read contracts (parameter-spec.md, creative-brief.md, finalized panel mockups)
2. Refine ModuleWidget component positioning (if needed)
3. Implement custom widgets (displays, scopes, visualizers)
4. Add context menu items (advanced features)
5. Implement widget callbacks (buttons, displays)
6. Return JSON report with modified file list and status

**What you DON'T do:**
- ❌ Run make commands
- ❌ Run build scripts
- ❌ Check if builds succeed
- ❌ Test compilation
- ❌ Invoke builds yourself

**Build verification:** Handled by `module-workflow` → `build-automation` skill after you complete.

---

## Inputs (Contracts)

You will receive the following contract files:

1. **parameter-spec.md** - Component positions (mm coordinates), widget types
2. **creative-brief.md** - Module vision, HP width, visual aesthetic
3. **Finalized panel mockups** - `v[N]-panel.svg` from panel-mockup workflow

**Module location:** `modules/[ModuleName]/`

## Task

Finalize ModuleWidget implementation, refining component positioning and adding custom UI elements as needed.

## CRITICAL: Required Reading

**Before ANY implementation, read:**

`troubleshooting/patterns/vcv-critical-patterns.md`

This file contains non-negotiable VCV Rack patterns that prevent repeat mistakes. Verify your implementation matches these patterns BEFORE generating code.

**Key patterns for Stage 5:**
1. mm2px() for all coordinate conversions (millimeters → pixels)
2. Component positioning: Use createParamCentered/createInputCentered/etc for helper.py compatibility
3. Panel loading: createPanel(asset::plugin(pluginInstance, "res/[Module].svg"))
4. Custom widgets: Inherit from widget::Widget, override draw(const DrawArgs &args)
5. FramebufferWidget caching for static graphics (performance)

## Implementation Steps

### 1. Read Existing ModuleWidget

Read `modules/[ModuleName]/src/[ModuleName].cpp` to see current ModuleWidget state (from Stage 3):

**Example current state (Stage 3 helper.py output):**

```cpp
struct MyOscillatorWidget : ModuleWidget {
    MyOscillatorWidget(MyOscillator* module) {
        setModule(module);
        setPanel(createPanel(asset::plugin(pluginInstance, "res/MyOscillator.svg")));

        // Screws (standard positions)
        addChild(createWidget<ScrewSilver>(Vec(RACK_GRID_WIDTH, 0)));
        addChild(createWidget<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, 0)));
        addChild(createWidget<ScrewSilver>(Vec(RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));
        addChild(createWidget<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));

        // Components (from helper.py createmodule)
        addParam(createParamCentered<RoundBlackKnob>(mm2px(Vec(10.16, 25.4)), module, MyOscillator::FREQ_PARAM));
        addParam(createParamCentered<CKSS>(mm2px(Vec(10.16, 40.0)), module, MyOscillator::WAVE_SWITCH));
        addInput(createInputCentered<PJ301MPort>(mm2px(Vec(10.16, 55.0)), module, MyOscillator::FREQ_CV));
        addOutput(createOutputCentered<PJ301MPort>(mm2px(Vec(10.16, 80.0)), module, MyOscillator::AUDIO_OUT));
    }
};
```

### 2. Verify Component Positioning

Check if helper.py-generated positions match parameter-spec.md:

**If positions match:** No changes needed, proceed to Step 3.

**If positions need refinement:**

```cpp
// Adjust positions to match finalized panel mockup
addParam(createParamCentered<RoundBlackKnob>(
    mm2px(Vec(10.16, 25.4)),  // Exact mm from parameter-spec.md
    module, MyOscillator::FREQ_PARAM));
```

**Common adjustments:**
- Fine-tuning alignment (±0.5mm)
- Changing widget types (RoundBlackKnob → Davies1900hBlackKnob)
- Adjusting screw positions for non-standard HP widths

### 3. Customize Widget Types (If Needed)

Replace default widgets with aesthetically appropriate types:

**Knob types:**
```cpp
// Standard black knobs
addParam(createParamCentered<RoundBlackKnob>(pos, module, id));        // 9mm diameter
addParam(createParamCentered<RoundSmallBlackKnob>(pos, module, id));  // 6mm diameter
addParam(createParamCentered<Trimpot>(pos, module, id));              // Trimmer (small)

// Vintage Davies knobs
addParam(createParamCentered<Davies1900hBlackKnob>(pos, module, id));
addParam(createParamCentered<Davies1900hWhiteKnob>(pos, module, id));

// Rogan knobs (Moog-style)
addParam(createParamCentered<Rogan6PSWhite>(pos, module, id));
addParam(createParamCentered<Rogan3PSBlue>(pos, module, id));

// Custom branded knobs (if using ui-template-library)
addParam(createParamCentered<MyBrandKnob>(pos, module, id));
```

**Switch types:**
```cpp
// Toggle switches
addParam(createParamCentered<CKSS>(pos, module, id));          // 2-position toggle
addParam(createParamCentered<CKSSThree>(pos, module, id));     // 3-position toggle

// Buttons
addParam(createParamCentered<CKD6>(pos, module, id));          // Momentary button
addParam(createParamCentered<TL1105>(pos, module, id));        // Small button

// Slide switches
addParam(createParamCentered<NKK>(pos, module, id));           // Sub-mini toggle
```

**Port types:**
```cpp
// Standard 3.5mm jacks
addInput(createInputCentered<PJ301MPort>(pos, module, id));    // Standard mono/poly
addOutput(createOutputCentered<PJ301MPort>(pos, module, id));

// Colored ports (Befaco style)
addInput(createInputCentered<BefacoInputPort>(pos, module, id));
addOutput(createOutputCentered<BefacoOutputPort>(pos, module, id));
```

**Light types:**
```cpp
// Single-color lights
addChild(createLightCentered<SmallLight<RedLight>>(pos, module, id));
addChild(createLightCentered<MediumLight<GreenLight>>(pos, module, id));
addChild(createLightCentered<LargeLight<BlueLight>>(pos, module, id));
addChild(createLightCentered<TinyLight<WhiteLight>>(pos, module, id));

// RGB lights (3 consecutive light IDs)
addChild(createLightCentered<MediumLight<RedGreenBlueLight>>(pos, module, id));

// Light rings around knobs
addParam(createParamCentered<RoundBlackKnob>(pos, module, paramId));
addChild(createLightCentered<MediumLight<RedLight>>(pos, module, lightId));  // Same position
```

### 4. Implement Custom Widgets (If Needed)

If the module needs custom displays, scopes, or visualizers, create custom widgets:

**Custom widget pattern:**

```cpp
// Add near top of file (before ModuleWidget)
struct MyCustomDisplay : widget::Widget {
    MyOscillator* module;

    // Constructor
    MyCustomDisplay() {
        box.size = mm2px(Vec(30.0, 20.0));  // Width x height in mm
    }

    // Draw method (called every frame)
    void draw(const DrawArgs& args) override {
        // Access module state (null-check for Module Browser)
        if (!module) {
            return;
        }

        nvgSave(args.vg);  // Save NanoVG context

        // Example: Draw background
        nvgBeginPath(args.vg);
        nvgRect(args.vg, 0, 0, box.size.x, box.size.y);
        nvgFillColor(args.vg, nvgRGB(0x00, 0x00, 0x00));  // Black
        nvgFill(args.vg);

        // Example: Draw text
        nvgFontSize(args.vg, 12.0f);
        nvgFontFaceId(args.vg, APP->window->uiFont->handle);
        nvgFillColor(args.vg, nvgRGB(0xff, 0xff, 0xff));  // White
        nvgTextAlign(args.vg, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
        nvgText(args.vg, box.size.x / 2, box.size.y / 2, "Custom Display", NULL);

        // Example: Draw waveform (access module state)
        float phase = module->phase;
        float x = phase * box.size.x;
        float y = box.size.y / 2;
        nvgBeginPath(args.vg);
        nvgCircle(args.vg, x, y, 3.0f);
        nvgFillColor(args.vg, nvgRGB(0x00, 0xff, 0x00));  // Green
        nvgFill(args.vg);

        nvgRestore(args.vg);  // Restore NanoVG context

        Widget::draw(args);  // Draw children (if any)
    }
};

// In ModuleWidget constructor:
struct MyOscillatorWidget : ModuleWidget {
    MyOscillatorWidget(MyOscillator* module) {
        // ... standard setup ...

        // Add custom display
        MyCustomDisplay* display = createWidget<MyCustomDisplay>(mm2px(Vec(5.0, 10.0)));
        display->module = module;
        addChild(display);
    }
};
```

**Common custom widgets:**

1. **Frequency display:**
```cpp
struct FrequencyDisplay : widget::Widget {
    MyModule* module;

    void draw(const DrawArgs& args) override {
        if (!module) return;

        float freq = module->currentFrequency;  // Access module state
        char text[32];
        snprintf(text, sizeof(text), "%.2f Hz", freq);

        nvgFontSize(args.vg, 10.0f);
        nvgFillColor(args.vg, nvgRGB(0xff, 0xff, 0x00));
        nvgText(args.vg, 5, 15, text, NULL);
    }
};
```

2. **Waveform scope:**
```cpp
struct WaveformScope : widget::Widget {
    MyModule* module;
    std::vector<float> buffer;  // Circular buffer

    void draw(const DrawArgs& args) override {
        if (!module) return;

        nvgBeginPath(args.vg);
        for (size_t i = 0; i < buffer.size(); i++) {
            float x = (float)i / buffer.size() * box.size.x;
            float y = (1.f - (buffer[i] / 10.f + 0.5f)) * box.size.y;
            if (i == 0) {
                nvgMoveTo(args.vg, x, y);
            } else {
                nvgLineTo(args.vg, x, y);
            }
        }
        nvgStrokeColor(args.vg, nvgRGB(0x00, 0xff, 0x00));
        nvgStrokeWidth(args.vg, 1.5f);
        nvgStroke(args.vg);
    }
};
```

3. **Level meter:**
```cpp
struct LevelMeter : widget::Widget {
    MyModule* module;

    void draw(const DrawArgs& args) override {
        if (!module) return;

        float level = module->outputLevel;  // 0-1 range
        float height = level * box.size.y;

        // Background
        nvgBeginPath(args.vg);
        nvgRect(args.vg, 0, 0, box.size.x, box.size.y);
        nvgFillColor(args.vg, nvgRGB(0x20, 0x20, 0x20));
        nvgFill(args.vg);

        // Level bar
        nvgBeginPath(args.vg);
        nvgRect(args.vg, 0, box.size.y - height, box.size.x, height);
        nvgFillColor(args.vg, nvgRGB(0x00, 0xff, 0x00));
        nvgFill(args.vg);
    }
};
```

### 5. Optimize Custom Widgets with FramebufferWidget

For static graphics (don't change every frame), use FramebufferWidget caching:

```cpp
struct MyStaticDisplay : widget::FramebufferWidget {
    MyModule* module;

    MyStaticDisplay() {
        box.size = mm2px(Vec(30.0, 20.0));
    }

    void drawLayer(const DrawArgs& args, int layer) override {
        if (layer == 1) {
            // Static content (cached)
            nvgBeginPath(args.vg);
            nvgRect(args.vg, 0, 0, box.size.x, box.size.y);
            nvgFillColor(args.vg, nvgRGB(0x20, 0x20, 0x20));
            nvgFill(args.vg);

            nvgFontSize(args.vg, 12.0f);
            nvgFillColor(args.vg, nvgRGB(0xff, 0xff, 0xff));
            nvgText(args.vg, 10, 10, "Static Label", NULL);
        }

        FramebufferWidget::drawLayer(args, layer);
    }
};
```

**Benefits:**
- Reduces CPU usage (static content only rendered once)
- Use for backgrounds, labels, grids, non-changing graphics
- Don't use for animations, dynamic content

### 6. Add Context Menu Items (Advanced Features)

Implement custom context menu for advanced features:

```cpp
struct MyOscillatorWidget : ModuleWidget {
    // ... constructor ...

    void appendContextMenu(Menu* menu) override {
        MyOscillator* module = dynamic_cast<MyOscillator*>(this->module);
        if (!module) return;

        menu->addChild(new MenuSeparator);

        // Boolean option (checkbox)
        menu->addChild(createBoolMenuItem("Anti-aliasing", "",
            [=]() { return module->antiAliasingEnabled; },
            [=](bool enabled) { module->antiAliasingEnabled = enabled; }
        ));

        // Submenu (multiple options)
        struct OversamplingItem : MenuItem {
            MyOscillator* module;
            int factor;

            void onAction(const event::Action& e) override {
                module->oversamplingFactor = factor;
            }

            void step() override {
                rightText = (module->oversamplingFactor == factor) ? "✔" : "";
                MenuItem::step();
            }
        };

        MenuItem* oversamplingMenu = createSubmenuItem("Oversampling", "",
            [=](Menu* menu) {
                menu->addChild(construct<OversamplingItem>(&MenuItem::text, "1x", &OversamplingItem::module, module, &OversamplingItem::factor, 1));
                menu->addChild(construct<OversamplingItem>(&MenuItem::text, "2x", &OversamplingItem::module, module, &OversamplingItem::factor, 2));
                menu->addChild(construct<OversamplingItem>(&MenuItem::text, "4x", &OversamplingItem::module, module, &OversamplingItem::factor, 4));
                menu->addChild(construct<OversamplingItem>(&MenuItem::text, "8x", &OversamplingItem::module, module, &OversamplingItem::factor, 8));
            }
        );
        menu->addChild(oversamplingMenu);

        // Action item (triggers behavior)
        menu->addChild(createMenuItem("Reset phase", "",
            [=]() { module->phase = 0.f; }
        ));
    }
};
```

**Common context menu patterns:**
- Enable/disable features (anti-aliasing, oversampling)
- Select algorithms (filter types, waveform modes)
- Configuration options (sample rate, polyphony mode)
- Reset/initialize actions

**State persistence:**
Menu options stored in Module must be serialized:

```cpp
// In Module class
json_t* dataToJson() override {
    json_t* rootJ = json_object();
    json_object_set_new(rootJ, "antiAliasing", json_boolean(antiAliasingEnabled));
    json_object_set_new(rootJ, "oversampling", json_integer(oversamplingFactor));
    return rootJ;
}

void dataFromJson(json_t* rootJ) override {
    json_t* aaJ = json_object_get(rootJ, "antiAliasing");
    if (aaJ) antiAliasingEnabled = json_boolean_value(aaJ);

    json_t* osJ = json_object_get(rootJ, "oversampling");
    if (osJ) oversamplingFactor = json_integer_value(osJ);
}
```

### 7. Implement Dark Theme Support (Optional)

VCV Rack supports light/dark panel themes:

**Create dark theme SVG:**
- Duplicate `res/[Module].svg` → `res/[Module]-dark.svg`
- Adjust colors for dark background (lighter text, inverted graphics)

**Load theme-aware panel:**

```cpp
struct MyOscillatorWidget : ModuleWidget {
    MyOscillatorWidget(MyOscillator* module) {
        setModule(module);

        // Theme-aware panel loading
        setPanel(createPanel(
            asset::plugin(pluginInstance, "res/MyOscillator.svg"),
            asset::plugin(pluginInstance, "res/MyOscillator-dark.svg")
        ));

        // Use themed screws
        addChild(createWidget<ThemedScrew>(Vec(RACK_GRID_WIDTH, 0)));
        // ... rest of widget ...
    }
};
```

**If dark theme not needed:** Use single-panel approach (Stage 3 default).

### 8. Add Tooltips (Optional)

Override onHover for custom tooltips:

```cpp
struct MyCustomWidget : widget::Widget {
    void onHover(const event::Hover& e) override {
        e.consume(this);  // Prevent tooltip from parent
    }

    void onEnter(const event::Enter& e) override {
        // Custom tooltip
        ui::Tooltip* tooltip = new ui::Tooltip;
        tooltip->text = "Custom widget description";
        APP->scene->addChild(tooltip);
    }
};
```

**Note:** Standard params/inputs/outputs auto-generate tooltips from config() calls.

### 9. Self-Validation

Verify implementation:

1. **Component positioning:**
   - ✅ All components positioned with mm2px()
   - ✅ Positions match parameter-spec.md (±0.5mm tolerance)
   - ✅ Widget types appropriate for aesthetic
   - ✅ Screws positioned correctly (4 corners)

2. **Custom widgets:**
   - ✅ Inherit from widget::Widget or FramebufferWidget
   - ✅ Override draw() or drawLayer()
   - ✅ Null-check module pointer (for Module Browser)
   - ✅ Use NanoVG correctly (nvgSave/Restore)

3. **Context menu:**
   - ✅ appendContextMenu() overridden (if custom menu needed)
   - ✅ Menu items properly constructed
   - ✅ State serialized in dataToJson/dataFromJson()

4. **Performance:**
   - ✅ Static graphics use FramebufferWidget
   - ✅ Custom draw() methods optimized (no expensive operations)
   - ✅ No frame-by-frame redraws for static content

5. **Dark theme (if implemented):**
   - ✅ Dark SVG exists (res/[Module]-dark.svg)
   - ✅ setPanel() uses dual-SVG approach
   - ✅ ThemedScrew used instead of ScrewSilver

**If any checks fail:** Set status="failure", document issue in report

**Note:** Build verification is handled by module-workflow via build-automation skill after gui-agent completes.

### 10. Return Report

Generate JSON report in this exact format:

```json
{
  "agent": "gui-agent",
  "status": "success",
  "outputs": {
    "module_name": "[ModuleName]",
    "source_file_updated": "src/[ModuleName].cpp",
    "widget_finalized": true,
    "custom_widgets_added": ["FrequencyDisplay", "WaveformScope"],
    "context_menu_implemented": true,
    "dark_theme_support": false,
    "positioning_adjustments": "None (helper.py positions accurate)"
  },
  "issues": [],
  "ready_for_next_stage": true
}
```

**If GUI implementation fails:**

```json
{
  "agent": "gui-agent",
  "status": "failure",
  "outputs": {
    "module_name": "[ModuleName]",
    "error_type": "implementation_error",
    "error_message": "[Specific error message]"
  },
  "issues": [
    "Failed to implement: [specific widget]",
    "Reason: [specific reason]",
    "Suggestion: [how to resolve]"
  ],
  "ready_for_next_stage": false
}
```

**If parameter-spec missing:**

```json
{
  "agent": "gui-agent",
  "status": "failure",
  "outputs": {
    "error_type": "contract_error",
    "error_message": "parameter-spec.md missing"
  },
  "issues": [
    "BLOCKING ERROR: parameter-spec.md not found",
    "Required for: Component positions, widget types",
    "Resolution: Complete Stage 3 (panel mockup finalization) to generate parameter-spec.md"
  ],
  "ready_for_next_stage": false
}
```

**Note:** Build verification happens after this agent completes, managed by module-workflow via build-automation skill.

## Contract Enforcement

**BLOCK if missing:**

- parameter-spec.md (cannot position components without coordinates)

**Error message format:**

```json
{
  "agent": "gui-agent",
  "status": "failure",
  "outputs": {},
  "issues": [
    "Contract violation: parameter-spec.md not found",
    "Required for: Component positioning (mm coordinates)",
    "Stage 5 cannot proceed without complete contracts from Stage 3"
  ],
  "ready_for_next_stage": false
}
```

## Success Criteria

**gui-agent succeeds when:**

1. ModuleWidget finalized with all components positioned correctly
2. Widget types appropriate for module aesthetic
3. Custom widgets implemented (if needed) with proper NanoVG usage
4. Context menu implemented (if advanced features needed)
5. Dark theme support added (if specified)
6. Performance optimizations applied (FramebufferWidget for static content)
7. JSON report generated with correct format

**gui-agent fails when:**

- Any contract missing (parameter-spec.md)
- Component positions incorrect (don't match parameter-spec.md)
- Custom widgets crash (missing null-checks, NanoVG errors)
- Context menu state not serialized (lost on patch reload)
- Performance issues (expensive draw() operations)

**Build verification (Stage 5 completion) handled by:**

- module-workflow invokes build-automation skill after gui-agent completes
- build-automation runs make and handles any build failures

## Notes

- **Most work done in Stage 3** - helper.py auto-generates ModuleWidget boilerplate
- **Stage 5 is refinement** - Custom widgets, context menu, aesthetics
- **Optional stage** - If helper.py output is sufficient, Stage 5 may be minimal
- **Visual testing** - Load in VCV Rack to verify alignment, aesthetics

## VCV Rack Specifics

### NanoVG API Reference

**Basic shapes:**
```cpp
// Rectangle
nvgBeginPath(args.vg);
nvgRect(args.vg, x, y, width, height);
nvgFillColor(args.vg, nvgRGB(r, g, b));
nvgFill(args.vg);

// Circle
nvgBeginPath(args.vg);
nvgCircle(args.vg, cx, cy, radius);
nvgFillColor(args.vg, nvgRGBA(r, g, b, a));
nvgFill(args.vg);

// Line
nvgBeginPath(args.vg);
nvgMoveTo(args.vg, x1, y1);
nvgLineTo(args.vg, x2, y2);
nvgStrokeColor(args.vg, nvgRGB(r, g, b));
nvgStrokeWidth(args.vg, width);
nvgStroke(args.vg);
```

**Text:**
```cpp
nvgFontSize(args.vg, 12.0f);
nvgFontFaceId(args.vg, APP->window->uiFont->handle);
nvgFillColor(args.vg, nvgRGB(0xff, 0xff, 0xff));
nvgTextAlign(args.vg, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
nvgText(args.vg, x, y, "Text", NULL);
```

**Gradients:**
```cpp
NVGpaint gradient = nvgLinearGradient(args.vg, x1, y1, x2, y2,
    nvgRGB(r1, g1, b1), nvgRGB(r2, g2, b2));
nvgFillPaint(args.vg, gradient);
nvgFill(args.vg);
```

**Transforms:**
```cpp
nvgSave(args.vg);
nvgTranslate(args.vg, dx, dy);
nvgRotate(args.vg, angle);
nvgScale(args.vg, sx, sy);
// ... draw transformed content ...
nvgRestore(args.vg);
```

### Widget Coordinate System

- Origin: Top-left corner of widget (0, 0)
- Positive x: Right
- Positive y: Down
- box.size: Widget dimensions (Vec with x, y)

```cpp
void draw(const DrawArgs& args) override {
    // Center of widget
    float cx = box.size.x / 2;
    float cy = box.size.y / 2;

    // Bottom-right corner
    float right = box.size.x;
    float bottom = box.size.y;
}
```

### Common Widget Patterns

**Animated indicator:**
```cpp
struct AnimatedLight : widget::Widget {
    MyModule* module;
    float hue = 0.f;  // 0-360 degrees

    void draw(const DrawArgs& args) override {
        if (!module) return;

        // Animate hue
        hue += 1.f;
        if (hue >= 360.f) hue = 0.f;

        // HSV to RGB
        float h = hue / 60.f;
        float c = 1.f;  // Full saturation/value
        float x = c * (1.f - std::abs(std::fmod(h, 2.f) - 1.f));
        float r = 0, g = 0, b = 0;
        if (h < 1) { r = c; g = x; }
        else if (h < 2) { r = x; g = c; }
        else if (h < 3) { g = c; b = x; }
        else if (h < 4) { g = x; b = c; }
        else if (h < 5) { r = x; b = c; }
        else { r = c; b = x; }

        nvgBeginPath(args.vg);
        nvgCircle(args.vg, box.size.x / 2, box.size.y / 2, 5.f);
        nvgFillColor(args.vg, nvgRGBf(r, g, b));
        nvgFill(args.vg);
    }
};
```

**Waveform scope (circular buffer):**
```cpp
struct Scope : widget::FramebufferWidget {
    MyModule* module;
    static constexpr int BUFFER_SIZE = 256;

    void drawLayer(const DrawArgs& args, int layer) override {
        if (layer != 1) return;
        if (!module) return;

        nvgBeginPath(args.vg);
        for (int i = 0; i < BUFFER_SIZE; i++) {
            float x = (float)i / BUFFER_SIZE * box.size.x;
            float value = module->buffer[(module->bufferIndex + i) % BUFFER_SIZE];
            float y = (1.f - (value / 10.f + 0.5f)) * box.size.y;  // ±5V → screen
            if (i == 0) {
                nvgMoveTo(args.vg, x, y);
            } else {
                nvgLineTo(args.vg, x, y);
            }
        }
        nvgStrokeColor(args.vg, nvgRGB(0x00, 0xff, 0x00));
        nvgStrokeWidth(args.vg, 1.5f);
        nvgStroke(args.vg);

        FramebufferWidget::drawLayer(args, layer);
    }
};
```

**Interactive button (trigger on click):**
```cpp
struct TriggerButton : widget::OpaqueWidget {
    MyModule* module;

    TriggerButton() {
        box.size = mm2px(Vec(10.0, 10.0));
    }

    void onButton(const event::Button& e) override {
        if (e.action == GLFW_PRESS && e.button == GLFW_MOUSE_BUTTON_LEFT) {
            if (module) {
                module->triggerEvent();  // Call module method
            }
            e.consume(this);
        }
    }

    void draw(const DrawArgs& args) override {
        nvgBeginPath(args.vg);
        nvgRect(args.vg, 0, 0, box.size.x, box.size.y);
        nvgFillColor(args.vg, nvgRGB(0x80, 0x80, 0x80));
        nvgFill(args.vg);
    }
};
```

## Next Stage

After Stage 5 succeeds, module-workflow will invoke validator for Stage 6 (presets, testing, CHANGELOG, distribution).
