---
name: doi-outcomes
description: "Use when mapping role-level outcomes after verification. Captures solution-agnostic results, success signals, measurement status, and task-to-outcome alignment. Sits between Verify (Phase 3) and Roles (Phase 5) in the per-role loop. Cannot classify automation stages, score friction, or recommend solutions."
license: proprietary
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-08
---

### Overview

Phase 4 of the DOI Method. For each verified role, captures what results the role needs to produce, whether those results are defined and measured, and which verified tasks serve which results. This is the "does this work matter?" lens for the rest of the engagement.

Outcomes are framed as solution-agnostic results, not deliverables. "Leadership has timely pipeline visibility" not "I produce a weekly report." This framing prevents the downstream roadmap from anchoring to current solutions when a different approach might be better.

The existence of defined outcomes is the finding. Whether a role can articulate what results it produces, what "good" looks like, and whether it's measured — that IS the assessment. No deep value-chain analysis needed.

### Role Constraints

- CAN: Ask outcome questions, capture results, tag tasks to outcomes, identify outcome gaps, note unmeasured results
- CANNOT: Recommend eliminating tasks, classify automation stages, score friction, prescribe solutions

### Session Resolution

Standard DOI session resolution (check `~/.claude/.doi-registry.md` for active engagements, confirm engagement context — see `doi-intake/SKILL.md` Session Resolution section for the full pattern).

### Prerequisites

Call `~/.claude/scripts/doi/check-prerequisites.sh 4 <engagement-folder> <dept-slug> <role-slug>`

Required: `roles/{role-slug}/verified-role.md` must exist (Phase 3 complete for this role).

Also read: `departments/{dept-slug}/department.md` for department-level outcomes to ground the conversation.

### Process

#### Step 1: Ground in department outcomes.

Read `department.md` outcomes section. Present the department-level results to the facilitator: "The department's defined results are [X, Y, Z]. Now let's map how this role contributes."

If no department outcomes were captured in Phase 2, note it and proceed — role-level outcomes can stand on their own.

#### Step 2: Capture role-level results.

Use AskUserQuestion:

> "What results does this role need to produce for the people who depend on it? Not the tasks or reports — the actual results that matter."

For each result identified, use AskUserQuestion:

> "How would someone know that result is being achieved well?"

Then:

> "Is that result being measured today? If so, how?"

Capture: result statement (solution-agnostic), success signal, measurement status (Yes/No/Partially), measurement mechanism if it exists.

Connect each role outcome to department outcomes where applicable. Some role outcomes may not map to a department outcome — that's fine, note it.

If the facilitator frames outcomes as deliverables (e.g., "I produce a weekly report"), push for the result behind the deliverable: "What result does that report serve for the people who receive it?"

#### Step 3: Task-to-outcome tagging.

Read `verified-role.md` for the task list. For each verified task, use AskUserQuestion:

> "Which of these results does [task] contribute to?"

Tag each task:
- **Aligned** — directly contributes to one or more named results
- **Indirectly aligned** — enables another task that contributes to a result
- **Unaligned** — cannot be traced to any result

For unaligned tasks, do NOT recommend elimination. Simply record: "This task could not be mapped to a defined result during the assessment."

#### Step 4: Identify outcome gaps.

Compare department outcomes against role outcomes and task coverage. Flag:
- Department outcomes with no role-level result supporting them (for this role)
- Role outcomes with no task supporting them — results the role is responsible for but has no process to achieve

#### Step 5: Write output and update state.

Write `roles/{role-slug}/outcome-map.md`.
Call `~/.claude/scripts/doi/update-state.sh <folder> phase="Phase 4"`

### Output Format

`roles/{role-slug}/outcome-map.md`:

```markdown
---
role: [Role Name]
department: [Department Name]
results_identified: [count]
results_measured: [count with measurement mechanism]
results_partially_measured: [count partially measured]
results_unmeasured: [count with no measurement]
tasks_aligned: [count]
tasks_unaligned: [count]
outcome_gaps: [count]
mapped_date: [YYYY-MM-DD]
---

# Outcome Map — [Role Name]

## Department Context
[Reference department outcomes from department.md. Note which this role contributes to.]

## Role Results
| ID | Result | Success Signal | Measured? | Mechanism | Dept Outcome |
|---|---|---|---|---|---|
| R1 | [solution-agnostic result] | [how you'd know] | [Yes/No/Partially] | [how, if measured] | [DO# or —] |
| R2 | ... | ... | ... | ... | ... |

## Task-to-Result Alignment
| Task (from verified-role.md) | Alignment | Result(s) | Notes |
|---|---|---|---|
| [task name] | Aligned | R1 | [how it serves the result] |
| [task name] | Indirect | R2 | [which aligned task it enables] |
| [task name] | Unaligned | — | [could not be mapped to a defined result] |

## Outcome Gaps
| Result | Gap | Implication |
|---|---|---|
| R3 | No task supports this result | [what this means for the role/department] |
| DO2 | No role-level result maps to this department outcome | [this role may not be responsible, or the connection is unclear] |

## Assessment Notes
[If outcomes could not be identified: "The facilitator/role holder could not articulate
defined results for this role. The role operates on tasks and deliverables rather than
measured outcomes. This is a maturity signal that affects downstream prioritization."]

[If measurement is absent: "N of M results have no measurement mechanism. The role
produces results but cannot verify whether they are achieved well."]
```

### Constraints

- Outcome statements MUST be solution-agnostic — push back on deliverable-framed answers. "I produce a weekly report" -> "What result does that report serve?"
- Do NOT recommend eliminating unaligned tasks — state the finding, don't prescribe
- Do NOT classify automation stages — that's Phase 5
- Do NOT score friction — that's Phase 6
- If the facilitator cannot identify results for a role, record that as a finding and continue. The engagement is not blocked.
- Task tagging uses verified-role.md tasks, not materials — reality, not aspiration
- Connect role outcomes to department outcomes where possible, but don't force connections that aren't there
- Ask questions ONE AT A TIME using AskUserQuestion

### Common Mistakes

| Mistake | Fix |
|---|---|
| Accepting deliverables as outcomes | Push for results: "What result does that report serve?" |
| Prescribing elimination of unaligned tasks | State the finding plainly — don't recommend action |
| Blocking on missing outcomes | Record as finding, continue the engagement |
| Skipping measurement question | Always ask — unmeasured results are a key finding |
| Forcing department-to-role connections | Only connect where genuine. Gaps are findings, not errors. |
| Dumping all tasks for tagging at once | Walk through incrementally, confirm as you go |
