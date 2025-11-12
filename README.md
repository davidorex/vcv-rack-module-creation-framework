# VCV Rack Module Freedom System

**AI-assisted VCV Rack module development through conversational creation**

Build professional VCV Rack modules by describing what you want. Claude Code orchestrates the entire workflow from ideation to distribution.

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

## What Is This?

An AI-powered workflow system for building VCV Rack modules through conversation. You describe your module idea, and Claude Code:

1. **Dreams** - Creates creative brief with vision, parameters, and use cases
2. **Plans** - Researches DSP algorithms and creates implementation strategy
3. **Implements** - Builds working module through 6 structured stages
4. **Tests** - Validates functionality and generates presets
5. **Deploys** - Installs to VCV Rack plugins folder
6. **Iterates** - Adds features and fixes bugs with version management

---

## System Architecture

### 7-Stage Workflow

**Stage 0-1: Planning**
- Research DSP algorithms, CV routing, modular synthesis patterns
- Create architecture.md (signal flow, algorithms) and plan.md (strategy)

**Stage 2-6: Implementation**
- **Stage 2 (Foundation)**: plugin.json, Makefile, Module skeleton
- **Stage 3 (Shell)**: config() parameters, SVG panel with placeholders
- **Stage 4 (DSP)**: process() implementation, polyphony, anti-aliasing
- **Stage 5 (GUI)**: ModuleWidget, component positioning, custom widgets
- **Stage 6 (Validation)**: .vcvm presets, manual testing, CHANGELOG

### Dispatcher Pattern

module-workflow skill orchestrates, specialized subagents implement:
- **foundation-agent** (Stage 2): plugin.json, Makefile, registration
- **shell-agent** (Stage 3): SVG panels, config() calls, helper.py
- **dsp-agent** (Stage 4): process(), polyphony, voltage standards
- **gui-agent** (Stage 5): ModuleWidget, mm2px positioning, NanoVG
- **validator** (Stage 6): Presets, testing protocol, CHANGELOG

### Contracts (Immutable During Implementation)

All stages reference:
- **creative-brief.md** - Vision, HP width, CV/audio I/O
- **parameter-spec.md** - All controls with ranges/positions
- **architecture.md** - DSP design, CV routing (Stage 0)
- **plan.md** - Implementation strategy (Stage 1)

---

## Key Features

**Conversational Development**
- Describe module in plain language
- System generates contracts, code, and documentation
- Checkpoint menus guide you through workflow

**SVG Panel Workflow**
- 2-phase mockup process (design iteration → scaffolding)
- helper.py automation (SVG → C++ boilerplate)
- Component color coding (red/green/blue/magenta)

**Version Management**
- Semantic versioning (MAJOR.MINOR.REVISION)
- Regression testing on every change
- CHANGELOG.md auto-generation

**Knowledge Accumulation**
- Dual-indexed troubleshooting database
- Required Reading patterns prevent repeat mistakes
- 3-level research protocol (Quick/Moderate/Deep)

**Quality Assurance**
- Manual test protocol (polyphony, CV, sample rates)
- Preset generation and validation
- Design-sync checks (panel ↔ brief consistency)

---

## Requirements

### Dependencies

**All Platforms:**
- C++11 compiler (g++ or clang++)
- Git
- Make (official VCV build system)
- Python 3 (for helper.py)

**Mac (via Homebrew):**
```bash
brew install git cmake autoconf automake libtool jq python zstd pkg-config
```

**Linux (Ubuntu 16.04+):**
```bash
apt-get install build-essential git gdb curl cmake libx11-dev libglu1-mesa-dev \
    libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev zlib1g-dev
```

**Windows (MSYS2 MinGW 64-bit):**
```bash
pacman -S git gcc gdb cmake autoconf automake libtool jq python zstd pkgconf
```

### VCV Rack SDK

Download platform-specific SDK from https://vcvrack.com/downloads/:
- Mac x64: `Rack-SDK-2.x.x-mac-x64.zip`
- Mac ARM64: `Rack-SDK-2.x.x-mac-arm64.zip`
- Linux x64: `Rack-SDK-2.x.x-lin-x64.zip`
- Windows x64: `Rack-SDK-2.x.x-win-x64.zip`

Set environment variable:
```bash
export RACK_DIR=/path/to/Rack-SDK
# Add to ~/.bashrc or ~/.zshrc
```

---

## Typical Module Structure

```
modules/MyOscillator/
├── .ideas/                         # Contracts
│   ├── creative-brief.md
│   ├── parameter-spec.md
│   ├── architecture.md
│   ├── plan.md
│   ├── panels/
│   │   ├── v2-panel.yaml
│   │   ├── v2-panel.svg           # Final panel (Inkscape)
│   │   └── v2-ModuleWidget.cpp    # Boilerplate C++
│   └── .continue-here.md
├── src/
│   ├── plugin.hpp                  # Plugin-level declarations
│   ├── plugin.cpp                  # Module registration
│   └── MyOscillator.cpp            # Module + ModuleWidget
├── res/
│   └── MyOscillator.svg            # Panel graphic
├── presets/
│   ├── Default.vcvm
│   └── Sine.vcvm
├── plugin.json                     # Manifest (slug, version, modules)
├── Makefile                        # Build config (RACK_DIR)
├── CHANGELOG.md
└── LICENSE.txt
```

---

## VCV Rack Specifics

### Voltage Standards
- Audio: ±5V
- CV: ±5V (0-10V also common)
- Pitch: 1V/octave (C4 = 0V)

### Panel Dimensions
- Height: 128.5mm (fixed)
- Width: HP × 5.08mm (Eurorack standard, 1 HP = 5.08mm)

### Component Placeholders (SVG)
- **Red (#ff0000)**: Parameters (knobs, switches)
- **Green (#00ff00)**: Input ports
- **Blue (#0000ff)**: Output ports
- **Magenta (#ff00ff)**: Lights

### Build Commands
```bash
make                    # Build module
make dist               # Create distributable package
make install            # Install to Rack user folder
make clean              # Clean build artifacts
```

### Installation Locations
- Mac: `~/Documents/Rack2/plugins-mac-arm64/[PluginSlug]/`
- Linux: `~/.Rack2/plugins-linux-x64/[PluginSlug]/`
- Windows: `%USERPROFILE%/Documents/Rack2/plugins-win-x64/[PluginSlug]/`

---

## Commands Reference

### Setup
- `/setup` - Validate dependencies (RACK_DIR, Make, SDK)

### Lifecycle
- `/dream [Name]` - Ideation
- `/plan [Name]` - Research + planning
- `/implement [Name]` - Build through stages 2-6
- `/continue [Name]` - Resume from checkpoint
- `/improve [Name]` - Fix bugs, add features

### Deployment
- `/install-module [Name]` - Install to Rack plugins folder
- `/uninstall [Name]` - Remove binaries (keep source)
- `/clean [Name]` - Interactive cleanup menu
- `/destroy [Name]` - Complete removal (with backup)

### Quality
- `/test [Name]` - Run validation suite
- `/show-vcv [Name]` - Open VCV Rack and load module
- `/sync-design [Name]` - Validate panel ↔ brief
- `/research [topic]` - Deep investigation
- `/doc-fix` - Document solved problems

---

## Resources

**Official Documentation:**
- Manual: https://vcvrack.com/manual/
- API Reference: https://vcvrack.com/docs-v2/
- Library: https://library.vcvrack.com/

**Learning:**
- Julius O. Smith DSP Books: https://ccrma.stanford.edu/~jos/
- VCV Community Forum: https://community.vcvrack.com/

**Example Modules:**
- Fundamental: https://github.com/VCVRack/Fundamental
- Befaco: https://github.com/VCVRack/Befaco
- Bogaudio: https://github.com/bogaudio/BogaudioModules

---

## System Principles

1. **Contracts are immutable during implementation**
2. **Dispatcher pattern** - Subagents in fresh context
3. **Discovery through play** - Slash commands + menus
4. **Checkpoint protocol** - NEVER auto-proceed, always WAIT
5. **Required Reading injection** - vcv-critical-patterns.md

---

## License

[To be determined - same as original Plugin Freedom System]

---

## Acknowledgments

Adapted from the Plugin Freedom System for JUCE plugins.
VCV Rack by Andrew Belt and contributors.
