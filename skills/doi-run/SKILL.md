---
name: doi-run
description: "Use when conducting a full DOI engagement — walks an organization through all assessment phases from intake through implementation roadmap. Orchestrates doi-intake, doi-assess, doi-setup, doi-verify, doi-outcomes, doi-roles, doi-friction, doi-route, doi-pillars, and doi-roadmap with critic reviews and human gates between each phase."
license: proprietary
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
---

# doi-run

## 1. Overview

DOI-run is the master conductor for the Digital Operations Intelligence Method. It chains all 10 phase skills in sequence, triggers the `doi-review` critic agent after key phases, presents human gates between phases, and manages engagement state throughout the entire assessment lifecycle.

DOI-run never performs analysis itself. It only invokes skills and manages flow. Each phase skill is responsible for its own domain-specific work. DOI-run is responsible for sequencing, review orchestration, gate enforcement, and state persistence.

When invoked, announce at start:

> "Using DOI Method to assess [organization] for AI/automation readiness."

## 2. Session Resolution (Step 1 — Every Invocation)

Before doing anything else, resolve the current session:

1. Check `~/.claude/.doi-registry.md` for existing engagements.
2. **If resuming:** Read `.doi-state.md` from the engagement folder, present a current progress summary, and pick up at the next incomplete phase.
3. **If new:** No matching engagement found — proceed to Phase 0 (doi-intake).
4. **If multiple engagements exist:** Show a numbered list of all engagements with their org name, current phase, and status. Ask which to continue.
5. **If exactly 1 engagement exists:** Confirm with the user: "Continue with [org]?"

## 3. Phase Sequencing

The full engagement follows this flow:

```
Phase 0: doi-intake
  |
Phase 1: doi-assess --> [CRITIC REVIEW] --> HUMAN GATE
  |
Phase 2: doi-setup (per department)
  |
  +--------------- Per Role Loop ----------------+
  |                                               |
  |  Phase 3: doi-verify --> [CRITIC] --> GATE    |
  |    |                                          |
  |  Phase 4: doi-outcomes --> [CRITIC] --> GATE  |
  |    |                                          |
  |  Phase 5: doi-roles --> [CRITIC] --> GATE     |
  |    |                                          |
  |  Phase 6: doi-friction --> [CRITIC] --> GATE  |
  |    |                                          |
  |  (next role or exit loop)                     |
  |                                               |
  +-----------------------------------------------+
  |
Phase 7: doi-route --> [CRITIC REVIEW] --> HUMAN GATE
  |
Phase 8: doi-pillars --> [CRITIC REVIEW] --> HUMAN GATE
  |
Phase 9: doi-roadmap --> [CRITIC REVIEW] --> HUMAN GATE --> COMPLETE
```

Then repeat Phases 2-9 for the next department. When all departments are complete, generate the org-wide summary.

## 4. Invoking Phase Skills

For each phase in the sequence:

1. **Invoke the skill by name** — call the corresponding skill (e.g., `/doi-intake`, `/doi-assess`, `/doi-setup`, etc.) with the appropriate engagement context.
2. **Check output** — after the skill completes, verify that its expected output files exist in the engagement workspace and are non-empty.
3. **Handle missing or incomplete output** — if expected output is missing or incomplete, do NOT advance to the next phase. Instead, surface the issue at the human gate so the operator can decide how to proceed.

## 5. Critic Review

After Phases 1, 3, 4, 5, 6, 7, 8, and 9, trigger an independent critic review:

1. Spawn the `doi-review` agent with:
   - The phase number
   - The phase output file path(s)
   - Engagement metadata (org name, department, role if applicable)
2. The critic runs in isolation — it has never seen the conversation and evaluates output on its own merits.
3. Save critic output to:
   - `reviews/phase{N}-review.md` for department-level phases
   - `reviews/phase{N}-{role-slug}-review.md` for per-role phases (3, 4, 5, 6)
4. Present the critic's summary at the subsequent human gate.

## 6. Human Gates

After every critic review, present this gate to the user:

```markdown
## Gate: Phase [N] Complete — [Phase Name]

### Critic Review Summary
- Quality: [PASS / PASS WITH ISSUES / NEEDS REVISION]
- Critical issues: [count]
- Minor issues: [count]

### Key Outputs
[2-3 bullet summary of what this phase produced]

### Your Options
1. **Approve** — proceed to Phase [N+1]
2. **Revise** — address critic issues, re-run this phase
3. **Pause** — save progress and come back later
4. **Stop** — end the engagement here
```

### Gate Rules

- **Silence does not equal approval.** The orchestrator must receive an explicit go-ahead before advancing.
- The following responses mean **proceed**: "Approve", "proceed", "go ahead", "looks good", "next".
- **"Pause"** triggers a call to `scripts/doi/update-state.sh` to set `status=paused`.
- **"Stop"** triggers a call to `scripts/doi/update-state.sh` to set `status=stopped`.
- If the critic returned **NEEDS REVISION**, recommend "Revise" to the user — but do not force it. The user has final say.

## 7. State Management

State must be updated at two points: after every phase completion and after every human gate decision.

### After EVERY Phase Completes

Call the state update script:

```bash
~/.claude/scripts/doi/update-state.sh <engagement-folder> phase="Phase N" status=active
```

The registry is updated automatically by the script.

### After EVERY Human Gate Decision

| Decision | Action |
|---|---|
| **Approve** | Advance to the next phase |
| **Pause** | `update-state.sh <engagement-folder> status=paused` |
| **Stop** | `update-state.sh <engagement-folder> status=stopped` |
| **Revise** | Keep the same phase, note the revision count in state |

## 8. Per-Role Loop Management

During Phases 3-6, state tracks the current position within the role loop:

```yaml
current_department: marketing
current_role: content-specialist
roles_completed:
  - marketing-manager
roles_remaining:
  - content-specialist
  - analytics-coordinator
```

When a role completes all of Phases 3, 4, 5, and 6:

1. Update state: move the role from `roles_remaining` to `roles_completed`.
2. If `roles_remaining` is empty, exit the loop and proceed to Phase 7.
3. If roles remain, prompt the user: "Moving to the next role: [name]. Ready?"

## 9. Department Loop Management

After Phase 9 completes for a department:

1. Update state: move the department from `departments_remaining` to `departments_completed`.
2. If departments remain, prompt: "Department complete. Next: [name]. Ready to set up?"
3. If no departments remain, generate the org-wide summary.

## 10. Org-Wide Summary

When all departments are complete, produce `summary.md` in the engagement root directory:

```markdown
---
organization: [name]
departments_assessed: [count]
overall_maturity: [lowest department level]
overall_friction_tax: [weighted average]
generated: [date]
---

# DOI Assessment Summary — [Organization]

## Organization Maturity: Level [N] ([Name])

## Department Overview
| Department | Maturity | Friction Tax | Top Bottleneck | Quick Wins |
|---|---|---|---|---|

## Cross-Department Patterns
[Patterns appearing across multiple departments]

## Recommended Starting Point
[Which department to tackle first and why]

## Foundation Priorities (Org-Wide)
[Hard cap gates that must be cleared before any department can advance]
```

## 11. Resumption Logic

When doi-run is invoked and the registry contains active or paused engagements:

1. Read the registry at `~/.claude/.doi-registry.md`.
2. If exactly 1 engagement exists: "Welcome back. Working on [Org], currently at [Phase]. Continue?"
3. If more than 1 exists: show a numbered list, ask which to continue.
4. Read `.doi-state.md` for the selected engagement.
5. Call `~/.claude/scripts/doi/check-prerequisites.sh` for the next phase to verify all required inputs exist.
6. If prerequisites are met, pick up at the next phase.
7. If prerequisites are missing, explain what is needed and resume from the current phase so the gap can be addressed.

## 12. Constraints

- NEVER perform analysis — only invoke skills and manage state.
- NEVER skip critic review — it is automated, not optional.
- NEVER proceed past a human gate without explicit approval.
- NEVER combine phases — each runs independently as its own skill invocation.
- NEVER skip Phase 3 (doi-verify) — verification is what separates DOI from blind self-assessment.
- If a skill errors or produces incomplete output, do NOT advance. Present the issue at the human gate.
- State must be updated after EVERY phase and EVERY gate decision — no batching allowed.
- All file paths use the engagement folder as root — never hardcode absolute paths.
- Phase 2 (doi-setup) does NOT get a critic review — it is data collection, not analysis.

## 13. Quick Reference

| Phase | Skill | What It Does | Critic Review | Human Gate |
|---|---|---|---|---|
| 0 | doi-intake | Collects org info, creates engagement workspace | No | No |
| 1 | doi-assess | Assesses organizational digital maturity level | Yes | Yes |
| 2 | doi-setup | Inventories roles, tools, workflows + department outcomes | No | No |
| 3 | doi-verify | Observes client systems + validates role data | Yes | Yes |
| 4 | doi-outcomes | Maps role-level results, success signals, task alignment | Yes | Yes |
| 5 | doi-roles | Researches tool APIs, classifies tasks (outcome-aware) | Yes | Yes |
| 6 | doi-friction | Scores friction via Three C's (outcome context) | Yes | Yes |
| 7 | doi-route | Routes bottlenecks (outcome-tagged) | Yes | Yes |
| 8 | doi-pillars | Scores maturity pillars (outcome coverage evidence) | Yes | Yes |
| 9 | doi-roadmap | Builds outcome-weighted implementation roadmap | Yes | Yes |
