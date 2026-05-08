---
name: doi-scorecard
description: "Use after Phase 9 (doi-roadmap) to produce the engagement capstone — a one-page board-ready scorecard. Compresses 5 pillar scores to 1-5 ratings with one-sentence justifications, writes the verdict, finalizes the deployable Tier 1-2 list with quarterly assignments, and produces the remediation roadmap headlines. Cannot recommend, score from scratch, or override roadmap tier decisions."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-05-08
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

> **Voice:** Read `scripts/_config/voice.md` before drafting any client-facing output. Verification rule, vocabulary blocklist, Confusion Protocol all apply.

Engagement capstone. Sits between Phase 9 (doi-roadmap) and Phase 10 (doi-build). Reads everything the engagement has already produced, compresses it into a one-page board-ready artifact, and stops. No new analysis, no new scoring, no new recommendations.

The output exists for a single audience: a CFO or department head who has 90 seconds to defend the budget ask. They will not re-read the 200-page assessment. They will read this. If the verdict, the five pillar ratings, the deployable list with quarters, and the three-line remediation plan do not stand on their own, the engagement does not get funded. Reading time target: under 90 seconds. Two artifacts: `data/scorecard.json` (consumed by the HTML scorecard renderer) and `scorecard-summary.md` (printable sibling).

### Role Constraints

- CAN: Read prior-phase outputs, compress pillar scores from 0-15 to 1-5, write the scorecard JSON and the markdown summary, copy roadmap tier and quarter assignments, name the single largest constraint
- CANNOT: Score pillars from scratch (always uses Phase 8 output), add or remove interventions (uses Phase 9 roadmap as ground truth), soften the verdict to be polite (CONDITIONAL is the soft option; NO is real), invent dollar amounts or FTE counts not present in the roadmap

### Inputs

Read every file in this list before drafting. Each entry names what is pulled from it.

- `assessments/maturity-assessment.md` - maturity level (1-5) and any active hard-cap gate; level feeds the verdict ready_status, cap reason can override the constraint_line
- `departments/{dept}/assessments/foundational.md` - three foundational pillar scores (Talent Strategy, Workflow Optimization, Digital Architecture) on the 0-15 scale plus their evidence chains
- `departments/{dept}/assessments/advanced.md` - two advanced pillar scores (Knowledge Management, AI Automation) on the 0-15 scale; only present if the advanced gate passed in Phase 8, otherwise these ratings are omitted from the JSON
- `departments/{dept}/gap-analysis.md` - bottleneck and intervention catalog used to phrase justifications and value lines
- `roadmap.md` - Tier 1 and Tier 2 entries, slugs, names, value theses, 1-week shippable subsets, demo definitions, sequencing within tiers, dual-effort labels (`human_effort` / `doi_effort`) when present
- `context/goals.md` - the single primary goal forced at intake; copied verbatim into the markdown header
- `context/company-profile.md` - organization name; copied verbatim into the JSON and the markdown header
- `_uploads/MANIFEST.md` - provenance reference; any evidence quoted in a justification must trace back here

If any required input is missing, stop. Do not synthesize a stand-in. Tell the operator which file is missing and which phase produces it.

### Compression Rules

These rules are mechanical. No judgment calls beyond what is named here.

#### 1. Pillar 15-point score → 1-5 rating

| 0-15 score | 1-5 rating |
|---|---|
| 0-3 | 1 |
| 4-6 | 2 |
| 7-9 | 3 |
| 10-12 | 4 |
| 13-15 | 5 |

Apply to all five pillars. If `advanced.md` is absent (advanced gate failed in Phase 8), omit `knowledge_management` and `ai_automation` from the JSON ratings object - the schema requires only the three foundational pillars.

#### 2. Justification per pillar

One sentence. ≤ 200 characters. Cites one piece of evidence drawn from the Phase 8 evidence chain. The full chain stays in `foundational.md` / `advanced.md`; the scorecard quotes one anchor. Form: "<observation>; <gap>" or "<asset>; <missing capacity>". Example: "Two ops leads with prompt-design depth; no ML capacity."

If a pillar's evidence chain references a person by name, generalize to role (e.g., "ops lead," "rev ops"). The scorecard is board-readable, not a personnel file.

#### 3. Verdict ready_status

| Condition | ready_status |
|---|---|
| Maturity ≥ Level 3 AND every foundational pillar ≥ 8/15 | YES |
| Maturity = Level 1 OR any pillar = 0/15 | NO |
| Anything else | CONDITIONAL |

NO is real. CONDITIONAL is the soft option. Do not write CONDITIONAL when the rules produce NO.

#### 4. Verdict summary_line

Format: `<N> deployable workflows, ~$<X>K committed, <Y> FTE for <Z> days`.

- `<N>` = count of Tier 1 + Tier 2 entries in the roadmap (the deployable list)
- `<X>K` = total budget envelope from the roadmap. If the roadmap does not carry a budget envelope, omit the cost clause entirely. Do not invent a number.
- `<Y> FTE` and `<Z> days` = sum across all Tier 1 + Tier 2 entries' `human_effort` lines. If `human_effort` is absent for any entry, omit the FTE/days clause and write "see roadmap for effort detail."

The summary_line is copy-from-source. The only operation is summing.

#### 5. Verdict constraint_line

Names the single largest blocker. Selection rule:

1. If maturity has an active hard-cap gate (Phase 1 `cap_reason` is set), the cap is the constraint. Phrase as "<cap reason> caps maturity at Level <N>."
2. Otherwise, the foundational pillar with the lowest 0-15 score is the constraint. Phrase as "<pillar name in plain English> is the single largest blocker." If two foundational pillars tie at the lowest score, name them both.

Do not list more than one constraint. The whole point is forcing a single focus.

#### 6. Deployable list

Copy Tier 1 and Tier 2 entries from the roadmap. Do not add. Do not remove. Do not reorder.

For each entry:

| Field | Source |
|---|---|
| `slug` | roadmap intervention slug, verbatim |
| `name` | roadmap intervention name, verbatim |
| `tier` | 1 or 2 (matches roadmap section) |
| `value_line` | one-line value thesis, ≤ 200 chars, drawn from the roadmap intervention block |
| `quarter` | Q1 / Q2 / Q3 / Q4. Pulled from the roadmap's sequencing relative to the engagement start. Tier 1 lands in the next 1-2 quarters with available capacity; Tier 2 follows. Real engagements rarely ship Tier 1 in the current quarter, so Q3-Q4 placement is normal when the engagement is mid-year. |
| `human_effort` | copy from roadmap if present, otherwise omit |
| `doi_effort` | copy from roadmap if present, otherwise omit |

Quarter assignment rule: read the roadmap's intervention sequence. Place each Tier 1 entry in the earliest realistic quarter given roadmap-stated dependencies and capacity. Tier 2 follows after the last Tier 1. The fixture (`tests/fixtures/sample-engagement/data/scorecard.json`) shows the expected pattern: Tier 1 → Q3 + Q3, Tier 2 → Q4 for a mid-year engagement. Do not force Q1 / Q2 if the roadmap's sequencing or capacity rules out current-quarter delivery.

Until Phase 6 of the implementation plan adds `human_effort` / `doi_effort` to every Tier 1-2 spec, those fields may be absent in the roadmap. Omit them from the JSON if absent. Do not fabricate effort numbers.

#### 7. Remediation Q1 / Q2 / Q3

Three lines, one per quarter. Format: `Q<N>: <what we are fixing or shipping> — owner: <role> — budget: $<amount or 'TBD'>`.

- Q1: pull from the roadmap "What Not to Do Yet" + the highest-priority foundation work (the constraint named in 5). This is the unglamorous remediation that has to happen first.
- Q2: name the Tier 1 deployables shipping in Q2 (per quarter assignments above), with the named owner role.
- Q3: name the Tier 2 deployables shipping in Q3, with the named owner role.

Owner = role, not person. Budget = roadmap-cited dollar value, otherwise `TBD`. Do not invent dollar amounts.

### Output

The skill produces three artifacts. All three are required for the phase to be marked complete.

#### 1. `data/scorecard.json`

Must validate against `scripts/_config/output-schemas/scorecard.json`. Run validation before declaring success:

```bash
python -c "
import json, jsonschema
schema = json.load(open('scripts/_config/output-schemas/scorecard.json'))
data = json.load(open('data/scorecard.json'))
jsonschema.validate(data, schema)
print('SCHEMA OK')
"
```

If validation fails, fix the JSON before proceeding. Do not ship a scorecard that fails its schema.

#### 2. `data/_index.json`

Update the `scorecard` field to `"complete"` and add `"scorecard": "complete"` to the `phases` map. The HTML scorecard renderer reads `_index.json` to find which engagement folders have a complete scorecard.

#### 3. `scorecard-summary.md`

Printable markdown sibling. Render the same data using this exact format:

```markdown
# DOI Engagement Scorecard — {{organization}}
**Primary goal:** {{primary_goal}}
**Generated:** {{generated_at}}

## Verdict
**{{ready_status}}** — {{summary_line}}

**Largest constraint:** {{constraint_line}}

## Readiness Ratings

| Pillar | Score | Justification |
|---|---|---|
| Talent Strategy | {{score}}/5 | {{justification}} |
| Workflow Optimization | {{score}}/5 | {{justification}} |
| Digital Architecture | {{score}}/5 | {{justification}} |
| Knowledge Management | {{score}}/5 | {{justification}} |
| AI Automation | {{score}}/5 | {{justification}} |

## Deployable Workflows

| Tier | Workflow | Value | Quarter | Effort (human / DOI) |
|---|---|---|---|---|
| T{{tier}} | {{name}} | {{value_line}} | {{quarter}} | {{human_effort}} → {{doi_effort}} |
[...one row per deployable]

## Remediation Roadmap

- {{q1}}
- {{q2}}
- {{q3}}
```

If the advanced gate failed in Phase 8 and Knowledge Management / AI Automation are absent from the JSON, omit those two table rows from the markdown. Do not write "N/A" or leave a blank score - drop the row.

If `human_effort` or `doi_effort` is absent for a deployable row, write "see roadmap" in the effort column. Do not invent effort numbers.

### Constraints

- CANNOT score pillars from scratch - always reads Phase 8 output (`foundational.md`, `advanced.md`)
- CANNOT add or remove interventions - reads Phase 9 roadmap as ground truth for the deployable list
- CANNOT soften the verdict - CONDITIONAL is the soft option; NO is real and is required when maturity = Level 1 or any pillar = 0/15
- CANNOT exceed 200 characters per justification or value_line (schema-enforced for justification, self-policed for value_line)
- CANNOT invent dollar amounts, FTE counts, day counts, or quarter assignments not present in the source phases. Omit the field and write "see roadmap" or `TBD` instead.
- CANNOT name a person in any field. Owners and evidence anchors use role names.
- CANNOT proceed if any required input is missing. Stop and tell the operator which phase produces the missing file.

### Critic checks (which checklists apply)

The `doi-review` critic loads `evidence.md`, `principles.md`, `scope-drift.md`, and `invented-data.md` for this phase - every claim in the scorecard must trace to a prior-phase file, every dollar figure must trace to the roadmap, and every constraint must trace to either a maturity cap or a Phase 8 pillar score. A `schema-conformance.md` checklist (added in Phase 3 of the implementation plan) will validate the JSON output against `scripts/_config/output-schemas/scorecard.json` and fail the phase if the JSON does not parse or does not match the schema. The schema check is the hardest gate: a scorecard that does not validate does not ship.
