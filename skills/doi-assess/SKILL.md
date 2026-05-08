---
name: doi-assess
description: "Use when conducting the 30-question digital operations maturity assessment. Walks the user through 5 categories of yes/no questions, applies hard cap gate rules, and determines maturity level 1-5. Cannot recommend or prescribe solutions."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
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

### Overview

Phase 1 of the DOI Method. Evaluates the entire organization's digital operations maturity (Level 1-5) using a 30-item yes/no checklist across 5 categories. This is the starting point for understanding where the organization stands.

Organizations at Level 1-2 are accumulating **Operational Debt** — the compounding cost of disconnected tools, inconsistent data, and undocumented processes. What worked at 5 people actively hinders at 20. Growth becomes painful rather than exciting. The assessment identifies where this debt is concentrated and what must be resolved before advancing.

### Role Constraints

- CAN: Ask questions, evaluate responses, apply scoring logic, determine maturity level
- CANNOT: Recommend solutions, prescribe tools, suggest what to fix, skip hard cap logic

### Session Resolution

Standard DOI session resolution — check registry, confirm engagement.

### The 30 Checklist Questions

Present these conversationally — explain each if the user seems unsure. DO NOT dump all 30 at once.

**Category 0: People & Team Structure** (6 questions)
| Key | Question |
|---|---|
| panel0_item0 | Is there a documented plan for digital skills training? |
| panel0_item1 | Are team members comfortable adopting new technology? |
| panel0_item2 | Are there designated owners for digital processes? |
| panel0_item3 | Do you have access to technical talent when needed? |
| panel0_item4 | Does digital operations have executive support? |
| panel0_item5 | Does an internal draftsman, architect, or equivalent role exist internally? |

**Category 1: Process Documentation** (6 questions)
| Key | Question |
|---|---|
| panel1_item0 | Are core business processes documented in writing, flowcharts, and/or checklists? |
| panel1_item1 | Is process documentation stored in a central location? |
| panel1_item2 | Does documentation include step-by-step instructions? |
| panel1_item3 | Are process exceptions and edge cases documented? |
| panel1_item4 | Is documentation regularly reviewed and updated? |
| panel1_item5 | Can new team members follow processes without extensive training? |

**Category 2: Technology Systems** (6 questions)
| Key | Question |
|---|---|
| panel2_item0 | Is core business software cloud-based? |
| panel2_item1 | Can different departments easily share data? |
| panel2_item2 | Are software licenses and access properly managed? |
| panel2_item3 | Can systems be accessed securely from anywhere? |
| panel2_item4 | Can key software tools connect to each other? |
| panel2_item5 | Is there a documented technology stack? |

**Category 3: Data Management** (6 questions)
| Key | Question |
|---|---|
| panel3_item0 | Is data entry automated where possible? |
| panel3_item1 | Is data validated automatically? |
| panel3_item2 | Can reports be generated automatically? |
| panel3_item3 | Does data flow automatically between systems? |
| panel3_item4 | Is data consistently formatted across systems? |
| panel3_item5 | Is there a single source of truth for key data? |

**Category 4: Automation Implementation** (6 questions)
| Key | Question |
|---|---|
| panel4_item0 | Are repetitive tasks automated? |
| panel4_item1 | Do workflows trigger automatically based on events? |
| panel4_item2 | Do team members spend minimal time on data entry? |
| panel4_item3 | Are errors from manual processes rare? |
| panel4_item4 | Are complex processes partially automated? |
| panel4_item5 | Are resources focused on high-value work? |

### Hard Cap Gate Rules

These are non-negotiable. If a gate item is "No", the level is capped regardless of total score.

| Item | Gate Effect |
|---|---|
| panel2_item0 (cloud-based software) | Capped at Level 1 |
| panel2_item4 (tools connect) | Capped at Level 1 |
| panel3_item0 (automated data entry) | Capped at Level 2 |
| panel3_item3 (data flows between systems) | Capped at Level 2 |
| panel3_item5 (single source of truth) | Capped at Level 2 |
| panel1_item0 (documented processes) | Capped at Level 3 |
| panel1_item2 (step-by-step instructions) | Capped at Level 3 |

### The 5 Maturity Levels

| Level | Name | Software | Documentation | Data Management |
|---|---|---|---|---|
| 1 | Information Silos | Disconnected or analog tools that cannot be fully integrated | Processes exist only in employees' heads; maybe some checklists | No data management processes; scattered databases |
| 2 | Integratable Cloud | Cloud-based tools capable of integration, but not yet connected | Basic documentation emerging; high-level processes mapped | CRM, ERP, accounting tools chosen — data not cleaned |
| 3 | Unified Data Layer | Integrated cloud tools with single points of truth | Systems map documentation for workflows; clear org structure | Key ops data auto-cleaned on input/transfer; single source of truth |
| 4 | Automated Workflow with Human-in-the-Loop | Integrated tools with automated processes, human oversight | Detailed process maps and workflow documentation | Data cleaned regularly; 100% vital data clarity |
| 5 | AI-Driven Automation | AI-integrated tools using business-specific models; as automated as safely possible | Comprehensive documentation including edge cases for AI training | Data management fully automated for all possible processes |

### The 3 Cs — Chain Reaction

The 3 Cs are the *results* of leveling up. They arrive in sequence — you cannot skip:

> "Without Consistency, you can't have real Clarity. If your data is messy, your dashboards are misleading. Without Clarity, you can't confidently identify bottlenecks and unlock Capacity. You'd be scaling blind."

| C | Manifests at | What triggers it |
|---|---|---|
| **Consistency** | Level 2 | Documenting processes + selecting tools that enforce data standards |
| **Clarity** | Level 3 | Unified data removes copy/paste; real-time dashboards become accurate |
| **Capacity** | Level 4+ | Automation handles routine tasks; 5-10x gains only after Clarity is real |

### Process

1. Read `company-profile.md` from engagement folder for context
2. Walk user through 30 questions category by category. Use AskUserQuestion for each question — this keeps the flow structured and makes it clear when input is needed. If the user's answer is ambiguous (e.g., "kind of", "sometimes", "it depends"), use AskUserQuestion to clarify: "For scoring I need a yes or no — which is closer to your reality?"
3. Track all responses
4. Write responses to a temporary file for the scoring script
5. Call `$DOI_SCRIPTS/score-assessment.sh initial <engagement-folder> <responses-file>`
6. Read the script output for computed scores, level, and cap information
7. Write `assessments/maturity-assessment.md` with full analysis
8. Include per-category breakdown and plain-language explanation
9. If capped, explain clearly WHAT is blocking progress and WHY it matters
10. Call `$DOI_SCRIPTS/update-state.sh <folder> phase="Phase 1" maturity_level=<level>`

### Output Format

`assessments/maturity-assessment.md`:
```markdown
---
total_score: [0-30]
maturity_level: [1-5]
level_name: [name]
capped: [true/false]
cap_reason: "[reason if capped]"
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

# Initial Assessment — [Organization Name]

## Scores
| Category | Score | Max |
|---|---|---|
| People & Team Structure | [N] | 6 |
| Process Documentation | [N] | 6 |
| Technology Systems | [N] | 6 |
| Data Management | [N] | 6 |
| Automation Implementation | [N] | 6 |
| **Total** | **[N]** | **30** |

## Hard Cap Gate
[If capped: explain what gates failed and what must change]
[If not capped: "No hard caps applied — score determines level directly."]

## Category Analysis
[For each category: 2-3 sentences on what's working and what's missing, in plain language]

## What This Means
[Plain language — connect the level to the organization's stated primary goal from company-profile.md AND to where the org sits in the 3C chain.]

[Level 1-2: Name the Operational Debt. "You're at Level [N], which means [X]. Your team is accumulating Operational Debt — [specific pain from their category scores]. You're in the Consistency phase: before you can have real visibility (Clarity), your processes and data standards need to be uniform. Without that, any dashboard you build will mislead you."]

[Level 3: "You've achieved Consistency. You're now in the Clarity phase — unified data means your reporting can finally be trusted. The next unlock is Capacity, but major gains there require automation at Level 4."]

[Level 4-5: "You're in the Capacity phase. Automation is compounding — teams are achieving 5-10x gains on key workflows. Focus is shifting from 'doing the work' to 'designing the systems that do the work.'"]

[If Level 1-2 and org is asking about AI: Explicitly cite the three failure modes — Garbage In/Garbage Out, Process Confusion, Skills Gap. "Implementing AI now means building on an unstable foundation. The companies that succeed with AI don't just have better algorithms — they have better data, clearer processes, and more digitally fluent teams."]

[Always close by connecting to the primary goal from company-profile.md: "For your goal of [Y], this matters because [Z]."]
```

### Constraints

- Ask questions conversationally — explain each if the user seems unsure
- Do NOT dump all 30 questions at once — go category by category
- Do NOT recommend solutions in this phase
- Do NOT skip hard cap logic — the script handles it, trust its output
- Plain language throughout — this is client-facing, not a consultant report
- If the user is uncertain about a question, help them think through it but don't answer for them
- The "What This Means" section must reference the primary goal from company-profile.md
