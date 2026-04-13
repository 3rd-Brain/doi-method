---
name: doi-roadmap
description: "Use when building the final implementation roadmap for a department. Synthesizes all prior phases into a tiered, sequenced plan with projected friction reduction and maturity progression. This is the final deliverable of a DOI engagement."
license: proprietary
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
---

### Overview
Phase 9 of the DOI Method. Planner — the final deliverable. Synthesizes everything from prior phases into an actionable, sequenced implementation roadmap. Prioritizes interventions, sorts into tiers, sequences within tiers, and projects impact.

### Role Constraints
- CAN: Prioritize interventions, sequence implementation, project impact, produce the final deliverable
- CANNOT: Invent new analysis, change prior phase findings, introduce new data not from prior phases

### Session Resolution
Standard DOI session resolution.

### Prerequisites
Call `~/.claude/scripts/doi/check-prerequisites.sh 9 <engagement-folder> <dept-slug>`
Required: foundational.md + 3c-report.md + gap-analysis.md

### Required Inputs
Read ALL of these before starting:
- `company-profile.md` — primary goal and context
- `assessments/maturity-assessment.md` — maturity level + hard cap gates
- All `roles/*/role-summary.md` — task distribution + friction
- `3c-report.md` — department Friction Tax
- `gap-analysis.md` — routing + intervention types
- `assessments/foundational.md` (+ `advanced.md` if exists) — pillar scores
- All `roles/*/outcome-map.md` — outcome alignment and gaps

### Prioritization Framework
Score each intervention on 5 axes:

| Axis | Weight | What it measures |
|---|---|---|
| Friction Recovered | 35% | How much pain does this eliminate? (from friction scores) |
| Outcome Alignment | 20% | Does this advance a defined, measured result? |
| Implementation Complexity | 20% | How hard to build? (Stage 1 = easy, Stage 4 = hard) |
| Foundation Dependency | 15% | Does this require higher maturity? (gated or not) |
| Cascade Potential | 10% | Does fixing this unblock other improvements? |

**Outcome Alignment scoring:**
- Task aligned to a measured result: high
- Task aligned to an unmeasured result: medium
- Task indirectly aligned: low-medium
- Task unaligned: low

### Tier Classification
| Tier | Criteria | When to Start |
|---|---|---|
| **Tier 1: Quick Wins** | High friction recovered, low complexity, no foundation dependency | Immediately |
| **Tier 2: Strategic Investments** | High friction recovered, medium-high complexity, may need foundation work | After Tier 1 |
| **Tier 3: Future Capabilities** | Stage 3-4 interventions gated behind Level 3+ maturity | After Tier 2 + foundation built |

### Planning Principles

Ground every roadmap in these expectations. Cite them when setting scope.

**Timeline (Level 1 orgs):** 12-18 months to reach Level 3. Level 2 orgs: 6-12 months. Timeline depends on adoption speed, organization size, and whether foundational work happens before or alongside tool changes.

**Capacity Gains:**
| Stage | Expected Gain | When Achievable |
|---|---|---|
| Stage 2 (Agentic Tool) | 2-5x on targeted tasks | Immediately — low risk, rapid ROI |
| Stage 3 (Agentic Workflow) | 5-10x on key workflows | After Level 3 foundation is built |
| Stage 4 (AI Coworker) | 10-20x on core operations | After Stage 3 is stable and proven |

**Start with Stage 2 for rapid ROI.** Stage 2 wins build organizational confidence, prove value early, and generate the funding and buy-in needed for Stage 3-4 investment.

**Minimal Viable Workflow:** Build the simplest version that reliably works, then expand. A Stage 3 workflow with human checkpoints is not a compromise — it's the correct starting point. Fully autonomous Stage 4 should be earned, not assumed.

**Not every process needs Stage 4.** Most organizations' durable value comes from Stage 2-3. Reserve Stage 4 for high-volume, well-understood, low-risk processes. Forcing Stage 4 on judgment-heavy tasks creates brittle automation.

### Sequencing Rules
Within each tier, respect:
1. **People → Process → Tools** — DOI's core principle. Train people first, then document processes, then implement tools.
2. **Foundation gates** — can't automate Stage 3 without Level 3 maturity
3. **Dependencies** — can't integrate tools before documenting the process they support
4. **Quick wins first** — build momentum and prove value early

### Process
1. Read all prior phase outputs
2. Read all `outcome-map.md` files. Compile: (1) list of unaligned tasks with their friction and time data, (2) list of outcome gaps across all roles.
3. List every intervention from gap-analysis.md
4. Score each on the 5 prioritization axes
5. Sort into tiers
6. Sequence within tiers following the rules above
7. For each intervention, specify:
   - What to do (specific, actionable)
   - Which bottleneck it addresses (People/Process/Tools)
   - Which tasks it impacts (with friction scores)
   - Friction recovered (estimated reduction in friction points)
   - Prerequisites (what must be done first)
8. Calculate projected impact:
   - Current Friction Tax → Projected Friction Tax after Tier 1
   - Current maturity → Projected level after Tier 1 + Tier 2
9. Write Foundation Progress Tracker (hard cap gates with current/projected status)
10. Write "What Not to Do Yet" section
11. Write `roadmap.md` in the department directory
12. Call `~/.claude/scripts/doi/update-state.sh <folder> phase="Phase 9"`

### Output Format
`roadmap.md`:

```markdown
---
organization: [name]
department: [name]
current_level: [1-5]
current_friction_tax: [N]%
projected_friction_after_tier1: [N]%
projected_level_after_tier2: [N]
generated: [YYYY-MM-DD]
---

# Implementation Roadmap — [Department Name]

## Where You Are
- **Maturity Level:** [N] ([Name])
- **Department Friction Tax:** [N]%
- **Primary Goal:** [from company-profile.md]
- **Biggest Pain:** [highest friction dimension and what it means]

## Work That Lacks Defined Outcomes
*These tasks consume operational capacity but could not be traced to a defined business result during the assessment. This is not a recommendation to eliminate — there may be context the assessment didn't capture. The organization should evaluate whether to continue, redefine, or stop this work before investing in automation.*

| Task | Role | Hours/Week | Friction | Current Status |
|---|---|---|---|---|
| [task name] | [role] | [estimated time] | [score]/15 | [what happens with it now] |

**Total unaligned capacity:** ~[N] hours/week across [M] roles

## Tier 1: Quick Wins
*High impact, low complexity, start immediately. No foundation work required.*

**Projected Friction Tax after Tier 1: [N]%** ([current]% → [projected]%, recovering [N] percentage points)

### 1. [Intervention Name] ([Bottleneck Type], Stage [N])
- **Bottleneck:** [type] — [one-line description of what's wrong]
- **Tasks impacted:** [task names with friction scores]
- **Friction recovered:** ~[N] points weighted
- **Prerequisites:** [None / specific prior interventions]
- **What to do:** [Specific, actionable steps — not vague]

### 2. [Next intervention]
...

## Tier 2: Strategic Investments
*Medium-high complexity, builds foundation for Level 3. Start after Tier 1.*

**Projected Level after Tier 2: [N] ([Name])**

[Same format as Tier 1]

## Tier 3: Future Capabilities
*Requires Level 3 foundation. Plan now, execute after Tier 2.*

[Same format — each intervention notes the foundation requirement]

## Outcome Gaps
*Results identified as important but with no supporting task or process. Future capability planning should address these gaps.*

| Result | Department/Role | Gap | Implication |
|---|---|---|---|
| [result name] | [source] | No task supports this result | [what's at risk] |

## People → Process → Tools Sequence
Within each tier, follow this order:
1. **People:** [specific people interventions from the tier]
2. **Process:** [specific process interventions]
3. **Tools:** [specific tool interventions]

## Foundation Progress Tracker
| Hard Cap Gate | Current | After Tier 1 | After Tier 2 |
|---|---|---|---|
| Cloud-based software (panel2_item0) | [Yes/No] | [projected] | [projected] |
| Tools connect (panel2_item4) | [Yes/No] | [projected] | [projected] |
| Automated data entry (panel3_item0) | [Yes/No] | [projected] | [projected] |
| Data flows between systems (panel3_item3) | [Yes/No] | [projected] | [projected] |
| Single source of truth (panel3_item5) | [Yes/No] | [projected] | [projected] |
| Documented processes (panel1_item0) | [Yes/No] | [projected] | [projected] |
| Step-by-step instructions (panel1_item2) | [Yes/No] | [projected] | [projected] |

## What Not to Do Yet
[Specific premature investments to avoid, with reasons]
- Do NOT [specific action] — [why: foundation not ready / dependency not met / will waste resources]
- Do NOT [next item]
```

### Constraints
- Every intervention MUST trace back to bottleneck analysis + friction data
- Do NOT invent interventions not grounded in prior phases
- Priority order respects People → Process → Tools
- Stage 3-4 interventions MUST be in Tier 3 with explicit gates when maturity < 3
- "What Not to Do Yet" is mandatory — prevents premature investment
- Projected numbers should be grounded in the friction data (not wild guesses)
- The roadmap must explicitly connect to the primary goal from company-profile.md
- Present as a plan, not a mandate — the human gate allows the user to adjust priorities
- Intervention descriptions must be specific and actionable — "Set up HubSpot → Google Sheets Zapier integration for weekly report automation" not "Improve tool integration"
- Every Tier 1-2 intervention must reference which result it advances. If an intervention addresses an unaligned task, note it serves operational efficiency rather than a defined outcome.

### Common Mistakes
| Mistake | Fix |
|---|---|
| Vague interventions | Be specific: what tool, what integration, what process |
| Stage 3-4 in Tier 1 | Gated items go in Tier 3 when maturity < 3 |
| No "What Not to Do Yet" | Always include — prevents premature investment |
| Ignoring People → Process → Tools | Sequence within tiers must follow this order |
| Interventions from thin air | Every item must trace to bottleneck analysis |
| Missing foundation tracker | Always include the hard cap gate progression table |
