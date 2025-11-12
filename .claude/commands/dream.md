---
name: dream
description: Explore module ideas without implementing
---

# /dream

When user runs `/dream [concept?]`, invoke the module-ideation skill.

## Behavior

**Without argument:**
Present interactive menu:
```
What would you like to explore?

1. New module idea
2. Improve existing module
3. Create UI mockup
4. Create aesthetic template
5. Research problem
```

Route based on selection:
- Option 1 → module-ideation skill (new module mode)
- Option 2 → module-ideation skill (improvement mode)
- Option 3 → ui-mockup skill
- Option 4 → aesthetic-dreaming skill
- Option 5 → deep-research skill

**With module name:**
```bash
/dream [ModuleName]
```

Check if module exists in MODULES.md:
- If exists: Present module-specific menu (improvement, mockup, research)
- If new: Route to module-ideation skill for creative brief

## Preconditions

None - brainstorming is always available.

## Output

All /dream operations create documentation:
- Creative briefs: `modules/[Name]/.ideas/creative-brief.md`
- Improvement proposals: `modules/[Name]/.ideas/improvements/[feature].md`
- UI mockups: `modules/[Name]/.ideas/mockups/v[N]-*`
- Aesthetic templates: `.claude/aesthetics/[aesthetic-id]/aesthetic.md`
- Research findings: Documentation with solutions

Nothing is implemented - this is purely exploratory.
