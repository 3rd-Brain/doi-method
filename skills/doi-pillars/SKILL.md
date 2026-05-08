---
name: doi-pillars
description: "Use when scoring a department's foundational pillars (Talent Strategy, Workflow Optimization, Digital Architecture) and advanced pillars (Knowledge Management, AI Automation). Every score must cite evidence from prior phases. Includes gate check for advanced assessment eligibility."
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
Phase 8 of the DOI Method. Assessor — scores department maturity pillars grounded in REAL DATA from prior phases. Unlike traditional self-assessments, every score must cite specific evidence. If the data contradicts what the user might expect, score based on the data and explain why.

### Role Constraints
- CAN: Score pillars, cite evidence, validate tools against reality, apply gate checks
- CANNOT: Recommend interventions (Phase 9), build roadmaps (Phase 9), adjust prior phase data

### Session Resolution
Standard DOI session resolution.

### Prerequisites
Call `$DOI_SCRIPTS/check-prerequisites.sh 8 <engagement-folder> <dept-slug>`
Required: All role-summary.md files + gap-analysis.md must exist.

### Foundational Assessment — 3 Pillars (9 sub-dimensions, 1-5 each)

| Pillar | Sub-dimension | Score Informed By |
|---|---|---|
| **Talent Strategy** (People) | Team Structure | Role snapshots — are roles clearly defined? Digital-first? Outcome maps — are roles organized around defined results with success signals, or just task lists? Roles with 0 defined outcomes score lower. |
| | Skills Development | Verification — skills gaps found? Training happening? |
| | Training & Adoption | Verification — tool adoption comfort? Resistance? |
| **Workflow Optimization** (Process) | Process Mapping | Verification — how many processes were undocumented? Outcome maps — are processes connected to measured results, or documented as steps without a clear "what good looks like"? High unaligned-task ratios indicate process mapping without purpose. |
| | Automation Design | Bottleneck analysis — automation opportunities identified? |
| | Efficiency Optimization | Friction report — are bottlenecks being addressed? |
| **Digital Architecture** (Tools) | System Design | Department tools list — intentional stack or accidental accumulation? |
| | Data Infrastructure | Initial assessment data management scores + friction System dimension |
| | Tool Integration | Bottleneck analysis — how many tool-related friction tasks? |

### Pillar Contribution to the 3 Cs

Each pillar advances the 3 Cs in a specific way. Use this as your scoring lens — a low sub-dimension score means that C is not being delivered:

| Pillar | → Consistency | → Clarity | → Capacity |
|---|---|---|---|
| **Talent Strategy** | Teams follow standard practices | Clear understanding of roles and responsibilities | Skills to leverage digital tools effectively |
| **Workflow Optimization** | Standardized processes eliminate variation | Visible status of work in progress | Unnecessary steps eliminated |
| **Digital Architecture** | Standardized data across platforms | Single source of truth for reporting | Automated data transfers |

### Scoring Rules
- Score 1-5 per sub-dimension using the following interpretation:
  - **1** — Needs immediate attention before progress to higher levels is possible
  - **2** — Stable but needs implementation work to see real gains
  - **3** — Solid foundation but room for significant improvement
  - **4-5** — Well-developed, can support advanced digital operations
- EVERY score MUST cite specific evidence from prior phases
- If evidence contradicts a seemingly high score, score based on evidence and explain
- "The team seems capable" = NOT acceptable. "Role summaries show 3 clearly defined roles with distinct responsibilities, but verification found 4 undocumented cross-role tasks suggesting boundary blur" = acceptable
- Outcome maps from Phase 4 provide evidence for pillar scoring. Roles with defined, measured results indicate higher maturity. Roles operating on tasks without articulated results indicate lower maturity.

### Foundational Levels

The book defines foundational level by pillar development status, not just score:
- **Level 1:** None of the three foundational pillars fully developed
- **Level 2:** Basic development of one or two pillars
- **Level 3:** All three foundational pillars functioning effectively together

Score ranges align with this:
| Level | Score Range | Name | Pillar Status |
|---|---|---|---|
| 1 | 9-20 | Information Silos | No pillars developed |
| 2 | 21-34 | Integratable Cloud | 1-2 pillars in basic development |
| 3 | 35-45 | Unified Data Layer | All 3 pillars functioning together |

**All Three Pillars Are Required for Level 3.** Focusing on just one or two will leave gaps that undermine progress. A strong Digital Architecture score does not compensate for a weak Talent Strategy — the team still won't use the tools correctly.

### Advanced Gate Check

Before running advanced assessment:
- Call `$DOI_SCRIPTS/score-assessment.sh advanced-gate <level> <pillar1> <pillar2> <pillar3>`
- Foundational level MUST = 3
- EVERY pillar total MUST >= 7/15
- If gate fails → document why, do NOT proceed to advanced

**Why Level 3 is a hard prerequisite for Knowledge Management and AI Automation:**

1. **Garbage In, Garbage Out** — AI systems trained on inconsistent or inaccurate data produce unreliable results. Consistency at Level 3 is what creates the predictable data patterns AI requires to learn effectively.
2. **Process Confusion** — Automating undefined or variant processes leads to unpredictable outcomes. Workflow Optimization must be mapped and standardized before it can be enhanced with AI.
3. **Skills Gap** — Teams struggling with basic digital tools cannot effectively leverage advanced AI capabilities. Talent Strategy must reach digital proficiency before AI Automation is introduced.
4. **Unsustainable Wins** — Any initial success collapses when the weak foundation gives way. Premature AI deployment creates brittle automation that works until it doesn't, then fails at the worst possible time.

Organizations that attempt AI Automation without Level 3 maturity don't just fail to gain — they accumulate Operational Debt that makes recovery harder.

### Advanced Assessment — 2 Pillars (6 sub-dimensions, 1-5 each)
Only if gate passes:

| Pillar | Sub-dimension | Score Informed By |
|---|---|---|
| **Knowledge Management** (Process) | Documentation | Verification — what % of processes were documented? |
| | Business Intelligence | Friction report — data-driven decisions happening? Outcome maps — what percentage of role results have active measurement mechanisms? Unmeasured results indicate BI gaps regardless of dashboard tooling. |
| | Process Standards | Verification — enforced standards or tribal knowledge? |
| **AI Automation** (Tools) | AI Tool Selection | Bottleneck analysis — intentional AI evaluation happening? |
| | System Deployment | Role snapshots — any Stage 3-4 tasks currently operational? |
| | Automation Enhancement | Bottleneck analysis — improving existing automations? |

### Tool Validation (Mandatory)
Cross-reference pillar scores against actual tool capabilities:
- If user scored Tool Integration 4/5 but bottleneck analysis found 9 tool-related friction tasks → flag discrepancy
- If user scored AI Tool Selection 3/5 but no Stage 3-4 tasks are operational → flag discrepancy
- Adjust scores based on observed reality, not self-report

### Pillar Progression by Level

Use this as the scoring reference — where a pillar sits on this table is what the score should reflect:

| Level | Talent Strategy | Workflow Optimization | Digital Architecture | Knowledge Management | AI Automation |
|---|---|---|---|---|---|
| 1 | Basic skills | Ad-hoc processes | Disconnected systems | Tribal knowledge | Minimal/None |
| 2 | Defined roles | Workflow documentation | Cloud-based tools | Workflow documentation | Minimal/None |
| 3 | Training program | Mapped processes to systems | Integrated systems | Centralized resources | Targeted use, prompt library |
| 4 | Digital proficiency | Automated data handling | Automated dashboards | Analytics insights | Process integration |
| 5 | Continuous learning | Optimized processes | Adaptive architecture | Intelligent reference | Comprehensive AI |

A sub-dimension score of 3 = the pillar is at Level 3 behavior. Score 2 = Level 2 behavior. This table is the evidence-to-score translation key.

### Process
1. Read ALL prior phase outputs: role-summary.md files, 3c-report.md, gap-analysis.md, maturity-assessment.md, and all `outcome-map.md` files
2. Score each foundational sub-dimension with evidence citations
3. Call `$DOI_SCRIPTS/score-assessment.sh foundational <9 scores>`
4. Check gate for advanced: call `$DOI_SCRIPTS/score-assessment.sh advanced-gate <level> <p1> <p2> <p3>`
5. If gate passes, score advanced sub-dimensions with evidence citations
6. Perform tool validation — compare claimed vs. observed
7. Write `assessments/foundational.md` (and `assessments/advanced.md` if eligible)
8. Call `$DOI_SCRIPTS/update-state.sh <folder> phase="Phase 8"`

### Output Format
`assessments/foundational.md`:

```markdown
---
department: [name]
foundational_level: [1-3]
foundational_score: [9-45]
pillar_totals:
  talent_strategy: [3-15]
  workflow_optimization: [3-15]
  digital_architecture: [3-15]
advanced_eligible: [true/false]
gate_failure: "[reason if not eligible]"
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

# Foundational Assessment — [Department Name]

## Pillar Scores

### Talent Strategy ([N]/15) — People
| Sub-dimension | Score | Evidence |
|---|---|---|
| Team Structure | [1-5] | [Specific citation from prior phases] |
| Skills Development | [1-5] | [Specific citation] |
| Training & Adoption | [1-5] | [Specific citation] |

### Workflow Optimization ([N]/15) — Process
| Sub-dimension | Score | Evidence |
|---|---|---|
| Process Mapping | [1-5] | [Specific citation] |
| Automation Design | [1-5] | [Specific citation] |
| Efficiency Optimization | [1-5] | [Specific citation] |

### Digital Architecture ([N]/15) — Tools
| Sub-dimension | Score | Evidence |
|---|---|---|
| System Design | [1-5] | [Specific citation] |
| Data Infrastructure | [1-5] | [Specific citation] |
| Tool Integration | [1-5] | [Specific citation] |

## Tool Validation
[Comparison of claimed capabilities vs. bottleneck reality. Flag any discrepancies.]

## Level Determination
**Score: [N]/45 → Level [N] ([Name])**

## Advanced Assessment Gate
[ELIGIBLE: proceed to advanced / NOT ELIGIBLE: explain what must improve]
```

### Constraints
- Every score MUST cite specific evidence — no vibes-based scoring
- Tool validation is mandatory — if scores and data conflict, trust the data
- Do NOT adjust prior phase outputs
- Do NOT recommend interventions — that's Phase 9
- Advanced assessment ONLY runs if gate passes — no exceptions
- Pillar totals must match sub-dimension sums (script verifies this)
- If the user pushes back on a low score, show the evidence — don't cave

### Common Mistakes
| Mistake | Fix |
|---|---|
| Scoring without evidence | "Role snapshots show X" not "the team seems Y" |
| Ignoring tool validation | Compare bottleneck findings against tool scores |
| Running advanced when gate fails | Check level AND all pillar totals first |
| Soft-scoring to please the client | Score based on data. Explain diplomatically. |
