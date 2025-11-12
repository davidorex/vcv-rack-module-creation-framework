---
name: add-critical-pattern
description: Add current problem solution to critical patterns (fast path)
---

# /add-critical-pattern

When user runs `/add-critical-pattern`, add current problem/solution directly to vcv-critical-patterns.md.

## Preconditions

**Should have:**
- Just solved a significant problem
- Problem affects multiple modules or recurring across work
- Solution is well-understood
- Want to prevent future occurrences

## Behavior

The skill will:

1. **Ask for minimal details:**
   - Problem title (1 sentence)
   - Why it matters (impact)
   - Solution (1-2 paragraphs)
   - Prevention tips

2. **Add to critical patterns:**
   - File: `troubleshooting/patterns/vcv-critical-patterns.md`
   - Appends to existing pattern collection
   - Makes it mandatory reading for all subagents Stage 2+

3. **Document in git:**
   - Commit message: "docs(vcv-critical-patterns): add [pattern-name]"
   - Describes the pattern and why it's critical

## Fast Path vs Doc-Fix

**Use /add-critical-pattern when:**
- Problem is high-impact (affects many modules)
- Solution is proven and proven again
- Want to prevent future work from repeating same mistake
- Don't need extensive troubleshooting documentation

**Use /doc-fix when:**
- Problem is module-specific
- Want comprehensive troubleshooting guide
- Want detailed category-based organization
- Might want both (doc + promote)

## Critical Patterns

Patterns in vcv-critical-patterns.md are:
- Read by foundation-agent before Stage 2
- Read by shell-agent before Stage 3
- Read by dsp-agent before Stage 4
- Read by gui-agent before Stage 5
- Read by validator before Stage 6

Acts as enforced lessons learned system.

## Output

Pattern added to vcv-critical-patterns.md:
- Immediately effective for future work
- Git history captures reasoning
- Accessible reference for all subagents

## Routes To

`troubleshooting-docs` skill (critical-path mode)
