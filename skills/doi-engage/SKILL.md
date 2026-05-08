---
name: doi-engage
description: "Use when running the full DOI pipeline end-to-end after intake + routing. Chains doi-assess, doi-setup, doi-verify, doi-outcomes, doi-roles, doi-friction, doi-route, doi-pillars, and doi-roadmap with critic reviews, human gates, and state management. Invoked by doi-run for full-engagement paths, or directly if the operator wants to skip the consultant interview."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-23
---


### Environment Resolution

Before running any DOI script, resolve the shared DOI script directory and registry path once per session:

```bash
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "${CLAUDE_PLUGIN_ROOT}/scripts" ]; then
  export DOI_SCRIPTS="${CLAUDE_PLUGIN_ROOT}/scripts"
  export DOI_REGISTRY="${DOI_REGISTRY:-${CLAUDE_PLUGIN_DATA:-$PWD}/.doi-registry.md}"
elif [ -n "${CLAUDE_SKILL_DIR:-}" ] && [ -d "${CLAUDE_SKILL_DIR}/scripts/doi" ]; then
  export DOI_SCRIPTS="${CLAUDE_SKILL_DIR}/scripts/doi"
  export DOI_REGISTRY="${DOI_REGISTRY:-$PWD/.doi-registry.md}"
elif [ -d "$HOME/.claude/scripts/doi" ]; then
  export DOI_SCRIPTS="$HOME/.claude/scripts/doi"
  export DOI_REGISTRY="${DOI_REGISTRY:-$HOME/.claude/.doi-registry.md}"
else
  echo "ERROR: DOI Method scripts not found. Install the plugin, use ./install-doi.sh --legacy, or rebuild the Cowork .skill packages." >&2
  exit 1
fi
mkdir -p "$(dirname "$DOI_REGISTRY")"
```

# doi-engage

## 1. Overview

doi-engage is the pipeline executor for the Digital Operations Institute Method. It chains Phases 1-9 in sequence, triggers the `doi-review` critic agent after key phases, presents human gates between phases, and manages engagement state throughout the assessment lifecycle.

doi-engage never performs analysis itself. It only invokes phase skills and manages flow. Each phase skill is responsible for its own domain-specific work. doi-engage is responsible for sequencing, review orchestration, gate enforcement, and state persistence.

**Entry assumption:** doi-engage is invoked *after* intake has populated the engagement workspace. It expects:
- `company-profile.md` and `context/` folder present in the engagement folder
- `.doi-state.md` initialized with organization metadata
- Registry entry registered

If any of those are missing, stop and surface the gap — do not run intake from here. Intake belongs to `doi-intake`, routing belongs to `doi-run`.

When invoked, announce at start:

> "Running the full DOI pipeline for [organization]. Phases 1 through 9, with critic reviews and human gates between each."

## 2. Resume Check (Step 1 — Every Invocation)

Before advancing, check where the engagement stands:

1. Read `.doi-state.md` from the engagement folder.
2. Call `$DOI_SCRIPTS/check-prerequisites.sh` for the next incomplete phase to verify all required inputs exist.
3. If prerequisites are met, pick up at that phase.
4. If prerequisites are missing, explain the gap and stop — the operator or doi-run decides how to fix it.

## 3. Phase Sequencing

The pipeline follows this flow:

```text
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
Phase 9: doi-roadmap --> [CRITIC REVIEW] --> HUMAN GATE
  |
Phase 10: doi-build (optional, per-intervention loop)
  +--- For each Tier 1 intervention (default) -------+
  |  doi-build dispatches doi-builder subagent       |
  |  --> [CRITIC REVIEW (Phase 10)] --> HUMAN GATE   |
  |  --> Operator demos via SHIP-CHECKLIST           |
  |  --> Returns with feedback before next build     |
  +--------------------------------------------------+
  |
  --> COMPLETE
```

Then repeat Phases 2-9 (and optionally Phase 10) for the next department. When all departments are complete, generate the org-wide summary.

**Phase 10 is opt-in.** After Phase 9 completes and the human gate is approved, ask the operator: "The roadmap is approved. Want me to proceed to Phase 10 (`doi-build`) and produce the artifacts for the Tier 1 interventions, or stop here with the roadmap as the deliverable?" If the operator wants to build, dispatch `doi-build`. If not, the engagement ends at Phase 9.

## 4. Invoking Phase Skills

For each phase in the sequence:

1. **Invoke the skill by name** — call the corresponding skill (e.g., `/doi-assess`, `/doi-setup`, etc.) with the appropriate engagement context.
2. **Check output** — after the skill completes, verify that its expected output files exist in the engagement workspace and are non-empty.
3. **Handle missing or incomplete output** — if expected output is missing or incomplete, do NOT advance to the next phase. Instead, surface the issue at the human gate so the operator can decide how to proceed.

## 5. Critic Review

After Phases 1, 3, 4, 5, 6, 7, 8, 9, and per-intervention in Phase 10, trigger an independent critic review:

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

### Human Gate Format

When pausing for human approval after this phase, present the gate using this structure (adapted from gstack's review/SKILL.md AskUserQuestion format):

- **D-number**: D-<phase>.<seq>, e.g. D-9.1 for the first decision in Phase 9. Lets the engagement reference past decisions consistently.
- **ELI10 paragraph**: one short paragraph explaining what's being decided in plain language. No jargon.
- **Stakes if we pick wrong**: one or two sentences on the cost of the wrong choice. Concrete (lost time, churn, rework) — not abstract ("could cause issues").
- **Recommendation**: which option you'd pick and one-sentence reason.
- **Options**: each with ≥2 pros and ≥1 con (≥40 chars each, no fluff). Options must be different in kind, not degree.
- **Net synthesis**: one sentence summarizing the tradeoff space.
- **Self-check before emitting**: have you cited specific evidence? Are the options actually different in kind, not degree? Did you load voice.md (no AI vocabulary, no em dashes, no "likely handled")?

## 7. State Management

State must be updated at two points: after every phase completion and after every human gate decision.

### After EVERY Phase Completes

Call the state update script:

```bash
$DOI_SCRIPTS/update-state.sh <engagement-folder> phase="Phase N" status=active
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

## 11. Constraints

- NEVER perform analysis — only invoke skills and manage state.
- NEVER skip critic review — it is automated, not optional.
- NEVER proceed past a human gate without explicit approval.
- NEVER combine phases — each runs independently as its own skill invocation.
- NEVER skip Phase 3 (doi-verify) — verification is what separates DOI from blind self-assessment.
- NEVER run intake from here — if `company-profile.md` or `.doi-state.md` are missing, stop and surface the gap.
- If a skill errors or produces incomplete output, do NOT advance. Present the issue at the human gate.
- State must be updated after EVERY phase and EVERY gate decision — no batching allowed.
- All file paths use the engagement folder as root — never hardcode absolute paths.
- Phase 2 (doi-setup) does NOT get a critic review — it is data collection, not analysis.

## 12. Quick Reference

| Phase | Skill | What It Does | Critic Review | Human Gate |
|---|---|---|---|---|
| 1 | doi-assess | Assesses organizational digital maturity level | Yes | Yes |
| 2 | doi-setup | Inventories roles, tools, workflows + department outcomes | No | No |
| 3 | doi-verify | Observes client systems + validates role data | Yes | Yes |
| 4 | doi-outcomes | Maps role-level results, success signals, task alignment | Yes | Yes |
| 5 | doi-roles | Researches tool APIs, classifies tasks (outcome-aware) | Yes | Yes |
| 6 | doi-friction | Scores friction via Three C's (outcome context) | Yes | Yes |
| 7 | doi-route | Routes bottlenecks (outcome-tagged) | Yes | Yes |
| 8 | doi-pillars | Scores maturity pillars (outcome coverage evidence) | Yes | Yes |
| 9 | doi-roadmap | Builds outcome-weighted implementation roadmap | Yes | Yes |
| 10 | doi-build | Produces working artifacts per intervention via doi-builder subagent (opt-in) | Yes (per intervention) | Yes (per intervention) |
