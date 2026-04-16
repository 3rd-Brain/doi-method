---
name: doi-setup
description: "Use when setting up departments and roles for assessment. Identifies departments, gathers tools and team info, creates role directories, and collects source materials (job descriptions, SOPs, docs). Cannot analyze or score anything."
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
---


### Environment Resolution

Before running any DOI script, resolve the plugin paths once per session:

```bash
# Resolve DOI plugin directory (Cowork install or legacy)
if [ -d "$HOME/.claude/plugins/doi-method/scripts" ]; then
  export DOI_SCRIPTS="$HOME/.claude/plugins/doi-method/scripts"
elif [ -d "$HOME/.claude/scripts/doi" ]; then
  export DOI_SCRIPTS="$HOME/.claude/scripts/doi"
else
  echo "ERROR: DOI Method scripts not found. Run the installer or install via Cowork."; exit 1
fi
export DOI_REGISTRY="$HOME/.claude/.doi-registry.md"
```

### Overview

Phase 2 of the DOI Method. Organizer — collects organizational structure and source materials. Sets up the workspace for department and role assessment. This phase has NO critic review (it's data collection, not analysis).

### Role Constraints

- CAN: Ask questions, collect information, accept file content, create workspace structure
- CANNOT: Analyze tasks, classify automation stages, score anything, recommend anything

### Session Resolution

Standard DOI session resolution — check registry, confirm engagement.

### Prerequisites

Call `$DOI_SCRIPTS/check-prerequisites.sh 2 <engagement-folder>`
Required: `assessments/maturity-assessment.md` must exist.

### Process

#### Department Setup

1. Read `company-profile.md` and `maturity-assessment.md` for context
2. Use AskUserQuestion: "What departments make up your organization?" (If company-profile.md mentioned a count, reference it: "You mentioned [N] departments earlier — what are they?")
3. For each department, use AskUserQuestion to gather:
   - "What is [department]'s primary function?"
   - "How many people are on the [department] team?"
   - "What tools and software does [department] use? (CRM, project management, communication, file storage — list everything)"
4. Use AskUserQuestion: "What results does [department] need to deliver to the business? Not the tasks or reports — the actual results that matter if they stopped happening."
5. For each result identified, use AskUserQuestion: "How would someone know that result is being achieved well?"
6. Create `departments/{dept-slug}/department.md`
7. Call `$DOI_SCRIPTS/init-workspace.sh <folder> <dept-slug>`
8. Use AskUserQuestion: "Which department would you like to assess first?"
9. Update `.doi-state.md` with departments_remaining and current_department

#### Role Identification

1. For the selected department, use AskUserQuestion: "What roles exist in [department]?"
2. For each role:
   - Create `departments/{dept-slug}/roles/{role-slug}/`
   - Call `$DOI_SCRIPTS/init-workspace.sh <folder> <dept-slug> <role-slug>`
3. Update `.doi-state.md` with roles_remaining

#### Materials Gathering

For each role, gather source materials. Accept ANY of:
- **Pasted text** — job descriptions, process docs, daily task lists
- **Verbal descriptions** — "Tell me what this person does day to day"
- **File content** — if the user provides file content or references documents

Save all materials to `roles/{role-slug}/materials.md` with source headers:
```markdown
--- Job Description (job_description) ---
[content]

--- Daily Operations SOP (sop) ---
[content]

--- Verbal Description (verbal) ---
[captured conversation]
```

Also save individual files to `departments/{dept-slug}/source-docs/` for reference.

#### Org Chart

After all departments and their roles have been collected, generate `org-chart.md` in the engagement root:

```markdown
# Org Chart — [Organization Name]

**Generated:** [YYYY-MM-DD]
**Departments:** [count]
**Total Roles:** [count]

## [Department Name]
*Function: [primary function] | Team Size: [N]*

| Role | Slug | Materials |
|---|---|---|
| [Role Name] | `[role-slug]` | [Yes / Verbal only] |

## [Next Department]
...

## Assessment Scope
**Departments in scope:** [list]
**Total roles to assess:** [count]
```

This file is the navigation map for the entire engagement — every subsequent phase references it to know what to assess.

### Output Format

`department.md`:
```markdown
# [Department Name]

**Function:** [primary purpose]
**Team Size:** [number]
**Tools:** [comma-separated list]
**Date:** [YYYY-MM-DD]

## Department Outcomes
| ID | Result | Success Signal |
|---|---|---|
| DO1 | [solution-agnostic result statement] | [how you'd know it's working] |
| DO2 | ... | ... |

*If no outcomes can be articulated, record: "No department-level outcomes could be articulated during setup. This is a maturity signal — the department operates on tasks and deliverables rather than defined results."*
```

### Constraints

- Do NOT start analyzing tasks or classifying stages — that's Phase 5
- Do NOT score anything
- Accept materials in whatever format the user can provide — be flexible
- If verbal description only, capture faithfully as-is in the user's words
- One department at a time — complete all roles before moving to the next department
- Slugify names for folders: "Marketing Manager" → `marketing-manager`
- If the user doesn't have formal job descriptions, that's fine — verbal descriptions work
- Always confirm: "I have materials for [role]. Anything else to add before we move on?"
- After all roles have materials, present summary: "Here's what I have for [department]: [N] roles with materials. Ready to proceed to verification?"

### Common Mistakes

| Mistake | Fix |
|---|---|
| Demanding formal documents | Accept ANY format — verbal, pasted text, bullet lists |
| Starting to analyze tasks | Stop — analysis is Phase 5, after verification and outcome mapping |
| Combining departments | One department at a time |
| Missing materials confirmation | Always ask "Anything else to add?" before moving on |
| Not creating department.json status | Write department.md with tools and team info |
