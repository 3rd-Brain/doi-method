---
name: doi-route
description: "Use when classifying what causes friction in a department and routing to intervention types. Categorizes bottlenecks as People, Process, or Tools, then routes each by automation stage to determine the right intervention. Cannot build roadmaps or prescribe order."
license: proprietary
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
Phase 7 of the DOI Method. Diagnostician — classifies what's causing friction and routes to the right intervention type. This is where DOI's People → Process → Tools philosophy meets SONAR-style bottleneck analysis.

### Role Constraints
- CAN: Classify bottleneck types, route by automation stage, cross-reference maturity gates
- CANNOT: Build implementation timeline (Phase 9), prioritize interventions (Phase 9), change prior phase data

### Session Resolution
Standard DOI session resolution.

### Prerequisites
Call `$DOI_SCRIPTS/check-prerequisites.sh 7 <engagement-folder> <dept-slug>`
Required: All role-summary.md files complete for the department.
Also read all `outcome-map.md` files for the department to tag bottlenecks with blocked outcomes.

### Bottleneck Types

| Bottleneck | Symptoms | Example |
|---|---|---|
| **People** | Skills gap, no owner, wrong person doing it, training needed, resistance to change | "Marketing manager manually builds reports because nobody else knows how" |
| **Process** | No SOP, undocumented workflow, redundant steps, unnecessary handoffs, tribal knowledge | "Three people touch this because nobody defined who owns it" |
| **Tools** | Missing integration, wrong tool for the job, manual workaround for tool gap, data silos | "Exports from HubSpot because it doesn't connect to the reporting tool" |

A task can have MULTIPLE bottleneck types. List all that apply, primary first.

### Which C Each Bottleneck Blocks

Every bottleneck classification must be tagged with the C it is preventing. This connects the routing decision back to the 3C chain and makes the cost of inaction explicit:

| Bottleneck | Primary C blocked | Why |
|---|---|---|
| **People** (no standard practices) | Consistency | Variation comes from people, not tools — different people, different outcomes |
| **People** (unclear roles/ownership) | Clarity | Nobody knows who owns it, so nobody can see its status |
| **People** (low-value work focus) | Capacity | Skills not matched to work that needs human judgment |
| **Process** (no documentation, variation) | Consistency | Undocumented = ad-hoc = inconsistent every time |
| **Process** (no reporting rituals, invisible status) | Clarity | Work in progress is invisible without process structure |
| **Process** (unnecessary steps, redundant handoffs) | Capacity | Steps that exist by habit, not necessity, drain time |
| **Tools** (no data standards enforcement) | Consistency | Tools that allow free-form entry produce inconsistent data |
| **Tools** (no single source of truth, no dashboards) | Clarity | Siloed tools mean nobody sees the same picture |
| **Tools** (no automation, manual workarounds) | Capacity | Manual steps that should be automated consume human time |

Tag each routed task: "This is a [Bottleneck Type] bottleneck blocking [C]. Fixing it advances [C] toward Level [N]."

### Intervention Routing

Within each bottleneck type, the automation stage determines what kind of intervention is needed:

**People Bottleneck Interventions:**
| Stage | Intervention |
|---|---|
| 1 | Training on existing workflow tools |
| 2 | Upskill to use AI-assisted tools |
| 3 | Redesign role around AI workflow collaboration |
| 4 | Restructure team for AI-augmented operations |

**Process Bottleneck Interventions:**
| Stage | Intervention |
|---|---|
| 1 | Document + standardize → then automate with rules |
| 2 | Document + design AI tool handoff points |
| 3 | Map end-to-end process → design agentic workflow with human checkpoints |
| 4 | Redesign process for autonomous operation with exception handling |

**Tools Bottleneck Interventions:**
| Stage | Intervention |
|---|---|
| 1 | Integrate existing tools (Zapier, Make, native integrations) |
| 2 | Add single-function AI tool to stack |
| 3 | Build coordinated AI toolchain with orchestration layer |
| 4 | Deploy AI system with full tool access and decision authority |

### Process
1. Read `3c-report.md` + all `role-summary.md` files for the current department
2. Read all task files to access friction scores and context
3. For each HIGH-friction task (score >= 10/15): classify bottleneck type(s). When classifying each task, also note which result(s) the task serves (from outcome-map.md). Tag the bottleneck: "This is a [Bottleneck Type] bottleneck blocking [R# — result name]." Include in both the working classification AND the output.
4. For each MODERATE-friction task (score >= 6/15): classify bottleneck type(s). Same outcome tagging as step 3.
5. Low-friction tasks (< 6/15): skip — not worth routing
6. For each classified task, route to the intervention table based on bottleneck type + stage
7. Group results by bottleneck type, then by stage within each
8. Include Foundation Check: cross-reference maturity level from Phase 1
   - Stage 1-2 interventions: can begin immediately
   - Stage 3-4 interventions: BLOCKED until maturity reaches Level 3
9. Write `gap-analysis.md`
10. Call `$DOI_SCRIPTS/update-state.sh <folder> phase="Phase 7"`

### Output Format
`departments/{dept-slug}/gap-analysis.md`:

```markdown
---
department: [name]
assessed_date: [YYYY-MM-DD]
bottleneck_summary:
  people: [count]
  process: [count]
  tools: [count]
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

# Bottleneck Analysis — [Department Name]

## Summary
| Bottleneck Type | Tasks Affected | Primary Driver |
|---|---|---|
| Tools | [N] | [one-line description of the main pattern] |
| Process | [N] | [one-line description] |
| People | [N] | [one-line description] |

## DOI Principle: People → Process → Tools
Fix in this order. Tools without process = automating chaos. Process without people = documentation nobody follows.

## Detailed Routing

### Tools Bottlenecks ([N] tasks)

#### Stage 1 — Integrate Existing Tools ([N] tasks)
| Task | Role | Friction | Intervention | Result Blocked |
|---|---|---|---|---|
| [task name] | [role] | [score]/15 | [specific intervention — not generic] | [R# — result name, or "No defined result"] |

#### Stage 2 — Add AI Tool ([N] tasks)
[same table format]

#### Stage 3 — Build AI Workflow ([N] tasks)
[same table format]

### Process Bottlenecks ([N] tasks)
[same structure grouped by stage]

### People Bottlenecks ([N] tasks)
[same structure grouped by stage]

## Foundation Check
**Current Maturity: Level [N]**
[If Level < 3:]
Stage 3-4 interventions are blocked. Attempting advanced automation before Level 3 fails for four reasons:
1. **Garbage In, Garbage Out** — AI and automation built on inconsistent data produces unreliable results
2. **Process Confusion** — Automating undefined or variant processes creates unpredictable outcomes
3. **Skills Gap** — Teams not yet fluent with basic digital tools cannot leverage advanced automation
4. **Unsustainable Wins** — Any initial success collapses when the weak foundation gives way. Brittle automation fails at the worst possible time.

Before Stage 3-4 work can begin, the organization needs:
- [ ] [specific hard cap gate that must be cleared]
- [ ] [next gate]

Stage 1-2 interventions can begin immediately. These build the Consistency and Clarity foundation that Stage 3-4 requires.

[If Level >= 3:]
Foundation supports all intervention stages. Consistency and Clarity are established — Stage 3-4 work can proceed toward Capacity gains.
```

### Constraints
- Classify bottlenecks based on friction data AND verification findings — not assumptions
- A task can have multiple bottleneck types — list ALL that apply, primary first
- Respect People → Process → Tools order in the output structure
- Intervention descriptions must be SPECIFIC to the task ("Connect HubSpot to Google Sheets via Zapier" not "Integrate tools")
- Include the Foundation Check — always cross-reference maturity level
- Stage 3-4 interventions MUST be flagged as gated when maturity < Level 3
- Do NOT build the implementation timeline — that's Phase 9
- Do NOT prioritize interventions — that's Phase 9
- Do NOT change friction scores or automation stages from prior phases
- Bottleneck summary counts must match the detailed sections

### Common Mistakes
| Mistake | Fix |
|---|---|
| Generic interventions | Be specific: "Connect HubSpot to Sheets" not "Integrate tools" |
| Missing Foundation Check | Always cross-reference maturity level |
| Stage 3-4 not gated | Must be flagged as blocked when maturity < 3 |
| Single bottleneck per task | Check for multiple — most friction tasks have 2+ causes |
| Skipping moderate friction | Score >= 6 gets classified, not just >= 10 |
