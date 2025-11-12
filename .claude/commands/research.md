---
name: research
description: Deep investigation for complex VCV Rack problems
---

# /research

When user runs `/research [topic]`, invoke the deep-research skill for systematic problem investigation.

## Behavior

**Without topic:**
```
Deep research on what?

Provide a topic (required):
/research [topic]

Examples:
/research "Rack SDK build errors"
/research "Widget event handling"
/research "DSP audio routing"
```

**With topic:**
```bash
/research [topic]
```

Invoke deep-research skill.

## Research Protocol (3-Level Graduated)

The skill uses a 3-level protocol:

**Level 1: Quick Investigation (5-10 min)**
- Search existing documentation
- Check troubleshooting knowledge base
- Look at recent commits
- Search conversation history

**If Level 1 finds solution:**
- Report solution with links
- Offer to document in knowledge base

**If Level 1 inconclusive:**
Proceed to Level 2

**Level 2: Moderate Investigation (15-30 min)**
- Review Rack SDK documentation
- Check Rack plugin examples
- Analyze error messages deeply
- Test hypotheses locally

**If Level 2 finds solution:**
- Report with detailed explanation
- Offer to document with examples

**If Level 2 inconclusive:**
Proceed to Level 3

**Level 3: Deep Investigation (30-120 min)**
- Examine source code directly
- Trace execution paths
- Build minimal reproduction
- Consult Rack community resources
- Propose novel solutions

## Output

Research report with:
- Problem statement
- Investigation level reached
- Findings and evidence
- Proposed solutions (ranked by viability)
- Links to relevant resources
- Recommendation for next steps
- Offer to document solution

## Integration

After research completes, offer:
```
Would you like to:
1. Document this solution to knowledge base
2. Promote to critical patterns (fast-path for future work)
3. Close research
```

## Routes To

`deep-research` skill
