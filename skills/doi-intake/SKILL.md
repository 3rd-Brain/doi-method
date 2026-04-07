---
name: doi-intake
description: "Use when starting a new DOI engagement. Gathers organization context — name, industry, size, primary goal, and assessment trigger. Creates the engagement workspace and registers it. Cannot assess, score, or recommend."
license: proprietary
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
---

### Overview

Phase 0 of the DOI Method. Information collector — gathers organization context to ground all future analysis. Cannot assess, score, or recommend anything.

### Role Constraints

- CAN: Ask questions, collect information, create workspace files
- CANNOT: Assess maturity, suggest levels, recommend tools, score anything

### Session Resolution

Standard DOI session resolution:
1. Check `~/.claude/.doi-registry.md`
2. If 0 entries → new engagement, proceed with intake
3. If entries exist → this is handled by doi-run; if invoked standalone, confirm new engagement

### Process

1. Use AskUserQuestion: "What is the name of the organization we're assessing?"
2. Use AskUserQuestion: "What industry is [organization] in?"
3. Use AskUserQuestion: "How large is the organization? (approximate employee count and number of departments)"
4. Use AskUserQuestion: "What is the single most important goal for this assessment? Pick ONE — for example: reduce operational overhead, scale without headcount growth, improve service delivery speed."
   - If the user lists multiple, follow up with AskUserQuestion: "Those are all valid, but we need to rank everything against ONE primary goal. Which of those matters most right now?"
5. Use AskUserQuestion: "What prompted this assessment? (pain points, growth plans, curiosity, mandate from leadership — anything that triggered it)"
6. Confirm all details with the user before saving
7. Create engagement folder and call `~/.claude/scripts/doi/init-workspace.sh <folder>`
8. Write `company-profile.md` in the engagement root
9. Create `.doi-state.md` with initial state (phase: Phase 0, status: active)
10. Create or update `~/.claude/.doi-registry.md` with new entry

### Output Format

`company-profile.md`:
```markdown
# [Organization Name]

**Industry:** [industry]
**Size:** [X employees, Y departments]
**Primary Goal:** [single forced-choice goal]
**Assessment Trigger:** [what prompted the assessment]
**Date:** [YYYY-MM-DD]
```

`.doi-state.md`:
```yaml
---
organization: [name]
industry: [industry]
folder: [absolute path]
phase: Phase 0
current_department: 
current_role: 
maturity_level: 
status: active
started: [YYYY-MM-DD]
updated: [YYYY-MM-DD]
roles_completed: []
roles_remaining: []
departments_completed: []
departments_remaining: []
---
```

### Constraints

- Primary goal must be ONE forced choice — if the user lists multiple, ask them to pick the one that matters most
- Do NOT assess anything yet
- Do NOT suggest maturity levels or scores
- Do NOT make assumptions about departments or roles
- Confirm all gathered info before saving
- Use absolute paths for the engagement folder

### Common Mistakes

| Mistake | Fix |
|---|---|
| Accepting multiple goals | Force single choice — "Which ONE matters most right now?" |
| Skipping confirmation | Always present summary and ask "Does this look right?" |
| Using relative paths | Engagement folder must be absolute in state and registry |
