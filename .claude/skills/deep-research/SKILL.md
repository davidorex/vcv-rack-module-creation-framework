---
name: deep-research
description: Multi-agent parallel investigation for complex VCV Rack problems
model: claude-opus-4-1-20250805
allowed-tools:
  - Read # Local troubleshooting docs
  - Grep # Search docs
  - Task # Spawn parallel research subagents (Level 3)
  - WebSearch # Web research (Level 2-3)
preconditions:
  - Problem is non-trivial (quick lookup insufficient)
extended-thinking: false # Level 1-2, true for Level 3 (15k budget)
timeout: 3600 # 60 min max
---

# deep-research Skill

**Purpose:** Multi-level autonomous investigation for complex VCV Rack module development problems using graduated research depth protocol.

## Overview

This skill performs thorough research on technical problems by consulting multiple knowledge sources with automatic escalation based on confidence. Starts fast (5 min local lookup) and escalates as needed (up to 60 min parallel investigation).

**Why graduated protocol matters:**

Most problems have known solutions (Level 1: 5 min). Complex problems need deep research (Level 3: 60 min). Graduated protocol prevents over-researching simple problems while ensuring complex problems get thorough investigation.

**Key innovation:** Stops as soon as confident answer found. User controls depth via decision menus.

---

## Read-Only Protocol

**CRITICAL:** This skill is **read-only** and **advisory only**. It NEVER:

- Edits code files
- Runs builds
- Modifies contracts or configurations
- Implements solutions

**Workflow handoff:**

1. Research completes and presents findings with decision menu
2. User selects "Apply solution"
3. Output routing instruction: "User selected: Apply solution. Next step: Invoke module-improve skill."
4. Main conversation (orchestrator) sees routing instruction and invokes module-improve skill
5. module-improve reads research findings from conversation history
6. module-improve handles all implementation (with versioning, backups, testing)

**Note:** The routing instruction is a directive to the main conversation. When the orchestrator sees "Invoke module-improve skill", it will use the Skill tool to invoke module-improve. This is the standard handoff protocol.

**Why separation matters:**

- Research uses Opus + extended thinking (expensive)
- Implementation needs codebase context (different focus)
- Clear decision gate between "here are options" and "making changes"
- Research can't break anything (safe exploration)

---

## Entry Points

**Invoked by:**

- troubleshooter agent (Level 4 investigation)
- User manual: `/research [topic]`
- build-automation "Investigate" option
- Natural language: "research [topic]", "investigate [problem]"

**Entry parameters:**

- **Topic/question**: What to research
- **Context** (optional): Module name, stage, error message
- **Starting level** (optional): Skip to Level 2/3 if explicitly requested

---

## Level 1: Quick Check (5-10 min, Sonnet, no extended thinking)

**Goal:** Find solution in local knowledge base or basic Rack SDK docs

### Process

1. **Parse research topic/question**

   - Extract keywords
   - Identify VCV Rack components involved
   - Classify problem type (build, runtime, API usage, panel, CV, etc.)

2. **Search local troubleshooting docs:**

   ```bash
   # Search by keywords
   grep -r "[topic keywords]" troubleshooting/

   # Check relevant categories
   ls troubleshooting/[category]/

   # Search for module-specific or general issues
   ```

3. **Check Rack SDK documentation for direct answers:**

   - Query for relevant class/API
   - Check method signatures
   - Review basic usage examples
   - Look for known limitations

4. **Assess confidence:**

   - **HIGH:** Exact match in local docs OR clear API documentation
   - **MEDIUM:** Similar issue found but needs adaptation
   - **LOW:** No relevant matches or unclear documentation

5. **Decision point:**

   **If HIGH confidence:**

   ```
   ✓ Level 1 complete (found solution)

   Solution: [Brief description]
   Source: [Local doc or Rack SDK API]

   What's next?
   1. Apply solution (recommended)
   2. Review details - See full explanation
   3. Continue deeper - Escalate to Level 2 for more options
   4. Other
   ```

   **If MEDIUM/LOW confidence:**
   Auto-escalate to Level 2 with notification:

   ```
   Level 1: No confident solution found
   Escalating to Level 2 (moderate investigation)...
   ```

---

## Level 2: Moderate Investigation (15-30 min, Sonnet, no extended thinking)

**Goal:** Find authoritative answer through comprehensive documentation and community knowledge

### Process

1. **Rack SDK deep-dive:**

   - Full module documentation
   - Code examples and patterns
   - Related classes and methods
   - Best practices sections
   - Migration guides (if version-related)

2. **VCV Rack community forum search via WebSearch:**

   ```
   Query: "site:community.vcvrack.com [topic]"

   Look for:
   - Recent threads (last 2 years)
   - Accepted solutions
   - VCV team responses
   - Multiple user confirmations
   ```

3. **GitHub issue search:**

   ```
   Query: "site:github.com/VCVRack/Rack [topic]"

   Look for:
   - Closed issues with solutions
   - Pull requests addressing problem
   - Code examples in discussions
   - Version-specific fixes
   ```

4. **Synthesize findings:**

   - Compare multiple sources
   - Verify version compatibility (Rack SDK 2.x)
   - Assess solution quality (proper fix vs workaround)
   - Identify common recommendations

5. **Decision point:**

   **If HIGH/MEDIUM confidence:**

   ```
   ✓ Level 2 complete (found N solutions)

   Investigated sources:
   - Rack SDK docs: [Finding]
   - VCV Community: [N threads]
   - GitHub: [N issues]

   Solutions found:
   1. [Solution 1] (recommended)
   2. [Solution 2] (alternative)

   What's next?
   1. Apply recommended solution
   2. Review all options - Compare approaches
   3. Continue deeper - Escalate to Level 3 (parallel investigation)
   4. Other
   ```

   **If LOW confidence OR novel problem:**
   Auto-escalate to Level 3 with notification:

   ```
   Level 2: Complex problem detected (requires original implementation)
   Escalating to Level 3 (deep research with parallel investigation)...

   Switching to Opus model + extended thinking (may take up to 60 min)
   ```

---

## Level 3: Deep Research (30-60 min, Opus, extended thinking 15k budget)

**Goal:** Comprehensive investigation with parallel subagent research for novel/complex problems

### Process

1. **Switch to Opus model with extended thinking:**

   ```yaml
   extended_thinking: true
   thinking_budget: 15000
   timeout: 3600 # 60 min
   ```

2. **Identify research approaches:**

   Analyze problem and determine 2-3 investigation paths:

   **For DSP algorithm questions:**

   - Algorithm A investigation (e.g., anti-aliasing methods)
   - Algorithm B investigation (e.g., oversampling approach)
   - Commercial implementation research (industry standards)

   **For novel feature implementation:**

   - VCV Rack native approach (using built-in APIs)
   - External library approach (e.g., integration patterns)
   - Custom implementation approach (from scratch)

   **For performance optimization:**

   - Algorithm optimization (better complexity)
   - Caching/pre-computation (trade memory for CPU)
   - SIMD/parallel processing (vectorization)

3. **Spawn parallel research subagents:**

   Use Task tool to spawn 2-3 specialized research agents in fresh contexts:

   ```typescript
   // Example: CV scaling research for V/Oct tracking

   Task(
     (subagent_type = "general-purpose"),
     (description = "Research V/Oct standard"),
     (prompt = `
       Investigate 1V/octave CV standard for pitch tracking in VCV Rack.

       Research:
       1. Voltage-to-frequency conversion formula
       2. VCV Rack API support (dsp::FREQ_* constants?)
       3. Implementation complexity (1-5 scale)
       4. Common pitfalls and edge cases
       5. Reference implementations
       6. Code examples

       Return structured findings:
       {
         "approach": "V/Oct conversion",
         "rack_support": "description",
         "complexity": 2,
         "formula": "...",
         "pros": ["...", "..."],
         "cons": ["...", "..."],
         "references": ["...", "..."]
       }
     `)
   );

   Task(
     (subagent_type = "general-purpose"),
     (description = "Research exponential FM"),
     (prompt = `
       Investigate exponential frequency modulation for VCV Rack oscillators.

       Research:
       1. Linear vs exponential FM differences
       2. VCV Rack conventions (how much FM range?)
       3. Implementation complexity (1-5 scale)
       4. CPU performance characteristics
       5. Code examples or references

       Return structured findings:
       {
         "approach": "Exponential FM",
         "rack_conventions": "description",
         "complexity": 3,
         "typical_range": "...",
         "pros": ["...", "..."],
         "cons": ["...", "..."],
         "references": ["...", "..."]
       }
     `)
   );

   Task(
     (subagent_type = "general-purpose"),
     (description = "Research polyphony implementation"),
     (prompt = `
       Research polyphonic voice allocation for VCV Rack modules.

       Investigate:
       1. VCV Rack polyphony API (16 channels max)
       2. Voice allocation strategies
       3. Common patterns from existing modules
       4. Performance considerations

       Return structured findings:
       {
         "approach": "Polyphony",
         "max_channels": 16,
         "allocation_strategy": "...",
         "rack_patterns": "...",
         "references": ["...", "..."]
       }
     `)
   );
   ```

   **Each subagent:**

   - Runs in fresh context (no accumulated conversation)
   - Has focused research goal
   - Returns structured findings
   - Takes 10-20 minutes
   - Runs in parallel (3 agents = 20 min total, not 60 min)

4. **Main context synthesis (extended thinking):**

   After all subagents return, use extended thinking to synthesize:

   - **Aggregate findings** from all subagents
   - **Compare approaches:**
     - Pros/cons for each
     - Implementation complexity (1-5 scale)
     - CPU cost vs quality trade-offs
     - VCV Rack integration ease
   - **Recommend best fit:**
     - For this specific use case
     - Considering complexity budget
     - Balancing CPU and quality
   - **Implementation roadmap:**
     - Step-by-step approach
     - VCV Rack APIs to use
     - Potential pitfalls
     - Testing strategy

5. **Academic paper search (if applicable):**

   For DSP algorithms, search for authoritative papers:

   - "Digital Audio Signal Processing"
   - "Real-Time Audio Programming"
   - "Modular Synthesis Techniques"

6. **Generate comprehensive report:**

   Use structured format with populated values:

   ```json
   {
     "agent": "deep-research",
     "status": "success",
     "level": 3,
     "topic": "[research topic]",
     "findings": [
       {
         "solution": "[Approach 1]",
         "confidence": "high|medium|low",
         "description": "...",
         "pros": ["...", "..."],
         "cons": ["...", "..."],
         "implementation_complexity": 3,
         "references": ["...", "..."]
       },
       {
         "solution": "[Approach 2]",
         ...
       }
     ],
     "recommendation": 0,  // Index into findings
     "reasoning": "Why this approach is recommended...",
     "sources": [
       "Rack SDK: ...",
       "VCV Community: ...",
       "Paper: ...",
       "Subagent findings: ..."
     ],
     "time_spent_minutes": 45,
     "escalation_path": [1, 2, 3]
   }
   ```

7. **Present findings:**

   ```
   ✓ Level 3 complete (comprehensive investigation)

   Investigated N approaches:
   1. [Approach 1] - Complexity: 3/5, CPU: Low, Quality: High
   2. [Approach 2] - Complexity: 2/5, CPU: Medium, Quality: High
   3. [Approach 3] - Complexity: 4/5, CPU: Low, Quality: Very High

   Recommendation: [Approach 2]
   Reasoning: [Why this is the best fit]

   What's next?
   1. Apply recommended solution (recommended)
   2. Review all findings - See detailed comparison
   3. Try alternative approach - [Approach N name]
   4. Document findings - Save to troubleshooting/
   5. Other
   ```

---

## Report Generation

All levels return structured report. Format depends on level:

### Level 1 Report (Quick)

```markdown
## Research Report: [Topic]

**Level:** 1 (Quick Check)
**Time:** 5 minutes
**Confidence:** HIGH

**Source:** troubleshooting/[category]/[file].md

**Solution:**
[Direct answer from local docs or Rack SDK API]

**How to apply:**
[Step-by-step]

**Reference:** [Source file path or Rack SDK API link]
```

### Level 2 Report (Moderate)

```markdown
## Research Report: [Topic]

**Level:** 2 (Moderate Investigation)
**Time:** 18 minutes
**Confidence:** MEDIUM-HIGH

**Sources:**

- Rack SDK docs: [Finding]
- VCV Community: 3 threads reviewed
- GitHub: 2 issues reviewed

**Solutions:**

### Option 1: [Recommended]

**Approach:** ...
**Pros:** ...
**Cons:** ...
**Implementation:** ...

### Option 2: [Alternative]

**Approach:** ...
**Pros:** ...
**Cons:** ...
**Implementation:** ...

**Recommendation:** Option 1
**Reasoning:** [Why recommended]

**References:**

- [Source 1]
- [Source 2]
```

### Level 3 Report (Comprehensive)

```markdown
## Research Report: [Topic]

**Level:** 3 (Deep Research)
**Time:** 45 minutes
**Confidence:** HIGH
**Model:** Opus + Extended Thinking

**Investigation approach:**

- Spawned 3 parallel research subagents
- Investigated 3 distinct approaches
- Synthesized findings with extended thinking

**Findings:**

### Approach 1: [Name]

**Description:** ...
**VCV Rack support:** [API/pattern details]
**Complexity:** 2/5
**CPU cost:** Medium
**Quality:** High
**Pros:**

- Works for all cases
- VCV Rack native API
  **Cons:**
- Higher CPU than alternatives
  **References:**
- Rack SDK documentation
- Subagent findings

### Approach 2: [Name]

**Description:** ...
[Same structure]

### Approach 3: [Name]

**Description:** ...
[Same structure]

**Recommendation:** Approach 1
**Reasoning:**
[Detailed explanation of why this approach is best for the use case]

**Implementation Roadmap:**

1. [Step 1 with Rack API details]
2. [Step 2 with code pattern]
3. [Step 3 with integration notes]
4. [Step 4 with testing approach]

**Sources:**

- Rack SDK: [specific API documentation]
- Paper/Reference: [if applicable]
- VCV Community: [relevant threads]
- Subagent research: 3 parallel investigations

**Testing strategy:**

- [Test 1 description]
- [Test 2 description]
- [Validation approach]
```

---

## Decision Menus

After each level, present decision menu (user controls depth):

### After Level 1

```
What's next?
1. Apply solution (recommended) - [One-line description]
2. Review details - See full explanation
3. Continue deeper - Escalate to Level 2 for more options
4. Other
```

**Handle responses:**

- **Option 1 ("Apply solution"):**
  Output: "User selected: Apply solution. Next step: Invoke module-improve skill."
  The orchestrator will see this directive and invoke module-improve, which reads research findings from history and skips investigation phase.
- **Option 2:** Display full report, then re-present menu
- **Option 3:** Escalate to Level 2
- **Option 4:** Ask what they'd like to do

**IMPORTANT:** This skill is **read-only**. Never edit code, run builds, or modify files. All implementation happens through module-improve skill after research completes.

### After Level 2

```
What's next?
1. Apply recommended solution - [Solution name]
2. Review all options - Compare N approaches
3. Continue deeper - Escalate to Level 3 (may take up to 60 min)
4. Other
```

**Handle responses:**

- **Option 1 ("Apply recommended solution"):**
  Output: "User selected: Apply recommended solution. Next step: Invoke module-improve skill."
- **Option 2:** Display detailed comparison, then re-present menu
- **Option 3:** Escalate to Level 3
- **Option 4:** Ask what they'd like to do

### After Level 3

```
What's next?
1. Apply recommended solution (recommended) - [Solution name]
2. Review all findings - See detailed comparison
3. Try alternative approach - [Alternative name]
4. Document findings - Save to troubleshooting/ knowledge base
5. Other
```

**Handle responses:**

- **Option 1 ("Apply recommended solution"):**
  Output: "User selected: Apply recommended solution. Next step: Invoke module-improve skill."
- **Option 2:** Display comprehensive report with all approaches, then re-present menu
- **Option 3:** User wants to try different approach - update recommendation, then output: "Next step: Invoke module-improve skill with alternative approach."
- **Option 4:** Invoke troubleshooting-docs skill to capture findings in knowledge base
- **Option 5:** Ask what they'd like to do

---

## Integration with troubleshooter

**troubleshooter Level 4:**

When troubleshooter agent exhausts Levels 0-3, it invokes deep-research:

```markdown
## troubleshooter - Level 4

If Levels 0-3 insufficient, escalate to deep-research skill:

"I need to investigate this more deeply. Invoking deep-research skill..."

[Invoke deep-research with problem context]

deep-research handles:

- Graduated research protocol (Levels 1-3)
- Parallel investigation (Level 3)
- Extended thinking budget
- Returns structured report with recommendations
```

**Integration flow:**

1. troubleshooter detects complex problem (Level 3 insufficient)
2. Invokes deep-research skill
3. deep-research starts at Level 1 (may escalate)
4. Returns structured report to troubleshooter
5. troubleshooter presents findings to user

---

## Integration with troubleshooting-docs

After successful application of Level 2-3 findings:

**Auto-suggest documentation:**

```
✓ Solution applied successfully

This was a complex problem (Level N research). Document for future reference?

1. Yes - Create troubleshooting doc (recommended)
2. No - Skip documentation
3. Other
```

If user chooses "Yes":

- Invoke troubleshooting-docs skill
- Pass research report + solution as context
- Creates categorized documentation
- Future Level 1 searches will find it instantly

**The feedback loop:**

1. Level 3 research solves complex problem (45 min)
2. Document solution → troubleshooting/
3. Similar problem occurs → Level 1 finds it (5 min)
4. Knowledge compounds, research gets faster over time

---

## Success Criteria

Research is successful when:

- ✅ Appropriate level reached (no over-research)
- ✅ Confidence level clearly stated
- ✅ Solution(s) provided with pros/cons
- ✅ Implementation steps included
- ✅ References cited
- ✅ User controls depth via decision menus

**Level-specific:**

**Level 1:**

- ✅ Local docs or Rack SDK checked
- ✅ HIGH confidence OR escalated

**Level 2:**

- ✅ SDK docs, community, GitHub searched
- ✅ Multiple sources compared
- ✅ MEDIUM-HIGH confidence OR escalated

**Level 3:**

- ✅ Parallel subagents spawned (2-3)
- ✅ Extended thinking used for synthesis
- ✅ Comprehensive report generated
- ✅ Clear recommendation with rationale

---

## Error Handling

**Timeout (>60 min):**

```
⚠️ Research timeout (60 min limit)

Returning best findings based on investigation so far:
[Partial findings]

What's next?
1. Use current findings - Proceed with partial answer
2. Retry with extended timeout - Continue research (80 min)
3. Other
```

**No solution found:**

```
Research exhausted (Level 3 complete, no definitive solution)

Attempted:
✓ Local troubleshooting docs (0 matches)
✓ Rack SDK documentation (API exists but undocumented)
✓ VCV Community + GitHub (no clear consensus)
✓ Parallel investigation (3 approaches, all have significant drawbacks)

Recommendations:
1. Post to VCV Community with detailed investigation
2. Try experimental approach: [Suggestion]
3. Consider alternative feature: [Workaround]

I can help formulate community post if needed.
```

**Subagent failure (Level 3):**

```
⚠️ Subagent [N] failed to complete research

Proceeding with findings from other subagents (N-1 completed)...
```

Continue with available findings, note partial investigation in report.

**WebSearch unavailable:**
Level 2 proceeds with SDK docs only:

```
⚠️ Web search unavailable

Proceeding with Rack SDK documentation only.
Results may be incomplete for community knowledge.
```

---

## Notes for Claude

**When executing this skill:**

1. Always start at Level 1 (never skip directly to Level 3)
2. Stop as soon as HIGH confidence achieved (don't over-research)
3. Switch to Opus + extended thinking at Level 3 (architecture requirement)
4. Spawn parallel subagents at Level 3 (2-3 concurrent, not serial)
5. Use relative confidence (HIGH/MEDIUM/LOW based on sources)
6. Present decision menus (user controls escalation)
7. Integration with troubleshooting-docs (capture complex solutions)
8. Timeout at 60 min (return best findings)

**Common pitfalls:**

- Skipping Level 1 local docs check (always fastest path)
- Serial subagent invocation at Level 3 (use parallel Task calls)
- Using Sonnet for Level 3 (must switch to Opus)
- Forgetting extended thinking at Level 3 (critical for synthesis)
- Over-researching simple problems (stop at HIGH confidence)
- Not presenting decision menus (user should control depth)

---

## Performance Budgets

**Level 1:**

- Time: 5-10 min
- Extended thinking: No
- Success rate: 40% of problems (known solutions)

**Level 2:**

- Time: 15-30 min
- Extended thinking: No
- Success rate: 40% of problems (documented solutions)

**Level 3:**

- Time: 30-60 min
- Extended thinking: Yes (15k budget)
- Success rate: 20% of problems (novel/complex)

**Overall:**

- Average resolution time: 15 min (weighted by success rates)
- 80% of problems solved at Level 1-2 (fast)
- 20% require Level 3 (deep research justified)

---

## VCV Rack Specific Research Areas

**Common research topics:**

1. **CV Standards:**
   - 1V/octave pitch tracking
   - 0-10V modulation range
   - Polyphonic voltage conventions

2. **DSP Patterns:**
   - Anti-aliasing for oscillators
   - Oversampling techniques
   - Exponential vs linear response

3. **Rack SDK APIs:**
   - Module lifecycle (process, onReset, etc.)
   - Port configuration (configParam, configInput)
   - Widget registration patterns

4. **Panel Design:**
   - SVG constraints and best practices
   - Component positioning conventions
   - helper.py usage patterns

5. **Performance:**
   - CPU optimization strategies
   - SIMD vectorization
   - Memory allocation patterns

6. **Build System:**
   - Rack SDK Makefile integration
   - CMake configuration
   - Cross-platform compatibility
