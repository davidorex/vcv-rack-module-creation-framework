---
name: doc-fix
description: Document a recently solved problem for knowledge base
---

# /doc-fix

When user runs `/doc-fix`, invoke the troubleshooting-docs skill to capture problem solutions.

## Preconditions

**Should have:**
- Recently solved a problem
- Code changes or fixes in place
- Understanding of root cause
- Steps to reproduce problem (optional but helpful)

## Behavior

The troubleshooting-docs skill will:

1. **Ask for problem details:**
   - What was the problem?
   - What category? (build, runtime, GUI, DSP, parameters, etc.)
   - Steps to reproduce
   - Error messages/logs

2. **Ask for solution:**
   - What was the fix?
   - Why did it work?
   - Are there alternative approaches?
   - What to avoid?

3. **Create documentation:**
   - File: `troubleshooting/[CATEGORY]/[symptom].md`
   - Dual-indexed for fast lookup
   - Includes problem, cause, solution, prevention

4. **Offer to promote:**
   ```
   Solution documented at:
   troubleshooting/build/[issue].md

   Promote to critical patterns?

   VCV Rack critical patterns are mandatory reading for future work.
   Prevents repeat mistakes across all modules.

   1. Yes, promote to vcv-critical-patterns.md
   2. Keep in troubleshooting knowledge base only
   3. Cancel
   ```

## Critical Patterns

If promoted to critical patterns:
- Stored in: `troubleshooting/patterns/vcv-critical-patterns.md`
- All subagents must read before Stage 2+
- Prevents systematic errors across all modules

## Output

Documentation created:
- Indexed in troubleshooting knowledge base
- Searchable by symptom and category
- Git committed with descriptive message
- Tagged if critical pattern

## Routes To

`troubleshooting-docs` skill
