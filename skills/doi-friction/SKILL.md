---
name: doi-friction
description: "Use when scoring friction on classified tasks using the Three C's framework (Consistency, Clarity, Capacity). Evaluates each task across 3 dimensions, calculates per-task friction scores, and rolls up to Role Friction Tax and Department Friction Tax. Cannot recommend or prioritize."
license: proprietary
metadata:
  version: 1.1.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
---

### Overview

Phase 6 of the DOI Method. Measurer — quantifies how much pain each task causes using DOI's **Three C's framework** (Consistency, Clarity, Capacity), then rolls up to role and department level. The Friction Tax is DOI's signature metric: "X% of your capacity is friction, not output." This phase makes invisible operational drag visible and measurable.

The Three C's are the *outcomes* DOI is building toward. They arrive in a chain — each one is a prerequisite for the next:

> "Without Consistency, you can't have real Clarity. If your data is messy, your dashboards are misleading. Without Clarity, you can't confidently identify bottlenecks and unlock Capacity. You'd be scaling blind."

When a task scores poorly on a C, it means the organization is losing ground on that outcome — and blocking every C downstream. A task that fails Consistency doesn't just create inconsistency; it actively prevents Clarity and Capacity from being achieved at the role and department level.

### Role Constraints

- CAN: Score Three C's dimensions, calculate weighted scores, produce rollups
- CANNOT: Recommend solutions, prioritize fixes, route bottlenecks, change automation stages

### Session Resolution

Standard DOI session resolution.

### Prerequisites

Call `~/.claude/scripts/doi/check-prerequisites.sh 6 <engagement-folder> <dept-slug> <role-slug>`
Required: Task files must exist in `roles/{role-slug}/tasks/`
Also read `outcome-map.md` for outcome alignment context when scoring Capacity.

### The Three C's Friction Dimensions

Score each 1-5:

| Dimension | What it measures | 1 (Low Friction) | 3 (Moderate) | 5 (High Friction) |
|---|---|---|---|---|
| **Consistency** | How reliably does this task produce the same result? Are errors, rework, and variation common? | Standardized, rarely varies, minimal errors | Occasional inconsistency, some rework needed | Frequent errors, high rework, different outcome every time |
| **Clarity** | How visible and understood is this task's status, ownership, and output? Can anyone see what's happening? | Clear ownership, real-time status visible, output trusted | Some ambiguity in ownership or status, output mostly reliable | Nobody knows the status, unclear who owns it, output questioned |
| **Capacity** | How much human time and effort does this task consume relative to its value? Does it block higher-value work? | Minimal time, proportional to value, doesn't block other work | Noticeable time sink, somewhat disproportionate | Major time drain, blocks strategic work, disproportionate to value |

### How the Three C's Connect to DOI Levels

| C | When It Manifests | What Enables It | What Blocks It |
|---|---|---|---|
| **Consistency** | Level 2 | Documenting processes + tools that enforce data standards | Ad-hoc processes, no documentation, tool fragmentation |
| **Clarity** | Level 3 | Unified data removes copy/paste; dashboards reflect reality | Inconsistent data (Consistency not yet achieved) |
| **Capacity** | Level 4+ (major gains) | Automation handles routine tasks; 5-10x gains on key workflows | Lack of Clarity — you can't automate what you can't see |

The chain is sequential. A task that scores 5/5 on Consistency is not just inconsistent — it is actively preventing Clarity from existing at the role level, which in turn prevents Capacity gains at the department level. Score the chain, not just the dimension.

**3 Cs × People → Process → Tools**

Each C also maps to the P→P→T layer where it breaks down:

| C | People failure | Process failure | Tools failure |
|---|---|---|---|
| **Consistency** | Team not following standard practices | No documented steps; variation by person | Systems don't enforce data standards |
| **Clarity** | Not everyone sees the same information | No regular reporting rituals | No real-time dashboards or alerts |
| **Capacity** | Focus on low-value work | Unnecessary steps still in the process | Routine tasks not yet automated |

Use this when scoring — a Consistency problem has a root cause in People, Process, or Tools. The score captures the pain; this table identifies where the fix belongs (which doi-route will classify).

### Friction Severity Classification

- **3-5:** Low friction — works fine, not a priority
- **6-9:** Moderate friction — noticeable drag on the role
- **10-12:** High friction — significant pain, priority candidate
- **13-15:** Critical friction — actively damaging operations

### Frequency Weights for Rollup

Used to weight friction by how often the pain occurs:

| Frequency | Weight | Rationale |
|---|---|---|
| Daily | 20 | Happens every working day |
| Weekly | 4 | Happens every week |
| Monthly | 1 | Baseline weight |
| Quarterly | 0.25 | Infrequent |
| Triggered | 2 | Unpredictable but recurring |
| Infinite | 10 | Always ongoing |

### Process

1. Read all `tasks/{task-slug}.md` files for the current role
2. Read `verified-role.md` for time estimates and context
3. For EACH task, score across the Three C's:
   - **Consistency:** Does this task produce reliable, standardized results? Based on verification — did the user mention errors, rework, variation, inconsistent outputs?
   - **Clarity:** Is ownership clear? Can anyone check the status? Is the output trusted? Based on verification — handoffs, ambiguous ownership, shadow work
   - **Capacity:** How much time does this consume relative to value? Use time estimates from verification. Does it block higher-value work? Reference outcome alignment from outcome-map.md when assessing value. An unaligned task consuming significant time is a capacity problem regardless of friction score — note this in the rationale. Example: "Capacity: 4/5 — consumes ~5 hrs/week and is not mapped to any defined business result (outcome_alignment: unaligned), making the time investment disproportionate to demonstrable value."
4. For each score, provide a specific rationale (not just a number)
5. Append friction section to each `tasks/{task-slug}.md`
6. Call `~/.claude/scripts/doi/calculate-friction.sh role <folder> <dept-slug> <role-slug>`
7. After ALL roles in the department are friction-scored, call `~/.claude/scripts/doi/calculate-friction.sh department <folder> <dept-slug>`
8. Call `~/.claude/scripts/doi/update-state.sh <folder> phase="Phase 6"`

### Per-Task Friction Output

Appended to existing `tasks/{task-slug}.md`:

```markdown
## Friction Score (Three C's)

| Dimension | Score | Rationale |
|---|---|---|
| Consistency | [1-5] | [specific reason — errors, rework, variation from verification data] |
| Clarity | [1-5] | [specific reason — ownership, visibility, trust in output] |
| Capacity | [1-5] | [specific reason — time consumed, value ratio, blocked work] |
| **Total** | **[N]/15** | **[Severity: Low/Moderate/High/Critical]** |
```

### Constraints

- Score based on VERIFIED task data — do not guess or assume
- Use time estimates from verified-role.md to inform Capacity dimension
- Consistency MUST account for error frequency AND task frequency (a daily task with errors = 5, a quarterly task with rare errors = 1)
- Clarity score must reflect what verification revealed about ownership and handoffs
- Every dimension needs a SPECIFIC rationale — not just a number
- Do NOT recommend solutions or prioritize fixes — that's Phase 7 and 9
- Do NOT change automation stage classifications from Phase 5
- Friction Tax is COMPUTED by the script — present the script's numbers, don't estimate
- Present the Friction Tax in plain language: "42% means 42 cents of every dollar of effort in this role is friction, not productive output"
- If a task has no friction data from verification (no time estimate, no error mentions), use AskUserQuestion to gather it: "I need a bit more info on [task name] to score it accurately. How consistent are the results, and how much time does it take?"

### Common Mistakes

| Mistake | Fix |
|---|---|
| Scoring without rationale | Every C needs a "because [specific reason]" |
| Capacity score ignoring verification | Reference the actual hours the user reported |
| Flat consistency scores | A daily error-prone task is 5, a monthly clean task is 1 |
| Guessing clarity issues | Use verification data — were ownership and handoffs clear? |
| Estimating Friction Tax | Let the script compute it — present computed numbers only |
| Scoring all tasks at once | Present scores to user incrementally, confirm they make sense |
