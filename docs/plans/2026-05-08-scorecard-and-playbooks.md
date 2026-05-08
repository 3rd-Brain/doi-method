# Scorecard, Playbooks, and Critic Discipline — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Land board-ready output formats (one-page scorecard HTML, per-intervention playbook markdown, structured JSON outputs) and tighter critic discipline (specialist checklists, plan completion audit, voice rules) on top of the existing DOI Method.

**Architecture:**
- Each phase emits both `.md` (existing, human-readable) AND `.json` (new, structured) — JSON schemas live in `scripts/_config/output-schemas/`.
- A pre-built `scorecard.html` (scaffolded at intake into the engagement folder) reads phase JSONs via `fetch` from a sibling `data/` folder and renders sections progressively as phases complete. Operators serve it via `python -m http.server` and refresh the browser to see updates.
- A new `doi-scorecard` skill (capstone after Phase 9) compresses pillar scores to 1–5 with one-sentence justifications, writes the verdict block, and emits the canonical `data/scorecard.json` that the HTML reads.
- A new `doi-render` skill produces a fully self-contained static HTML for client handoff (data baked in, no server needed).
- `doi-build` emits a per-intervention `playbook.md` using the operator-handoff template.
- `doi-review` is refactored: single agent (no parallel dispatch — Principle 4), but loads named checklist files per phase from `agents/doi-review/checklists/`, emits JSON findings with confidence 1–10, deduplicates by fingerprint, runs a Plan Completion Audit between phases.
- A shared `scripts/_config/voice.md` (verification rule, AI-vocabulary blocklist, Confusion Protocol) is referenced by every heavyweight phase skill.

**Tech Stack:**
- Markdown skill files with YAML frontmatter (existing)
- Bash scripts in `scripts/` for workspace scaffolding (existing pattern)
- JSON Schema (Draft 2020-12) for output schemas
- Plain HTML + vanilla JS (no framework) for `scorecard.html`
- `python -m http.server` (already present on consultant laptops) for local serving — no new runtime dependency

**Branch:** `feat/scorecard-and-playbooks` (already created off `feat/uploads-principles-build`)

**Out of scope (deliberately deferred):**
- Live reload / WebSocket reactivity. Manual browser refresh after phase completion is the correct ICM-aligned answer (Principle 5).
- Parallel critic subagent dispatch. Single critic with checklist folder is the Principle-4-aligned upgrade.
- Hooks-based PreToolUse gates from gstack `careful/` and `freeze/`. Couples plugin to harness; defer.
- 23-persona menagerie. Our 13 phases already cover the consulting roles.

**Reference document:** [`docs/research/gstack-grabs.md`](../research/gstack-grabs.md) — justifies the critic refactor and voice rules portions of this plan.

---

## Plan summary

| Phase | What ships | Verifiable demo | Estimated scope |
|---|---|---|---|
| 1 | Voice rules + critic checklist folder + Plan Completion Audit | Critic loads checklists; voice.md referenced from heavyweight phases | small |
| 2 | Schema + scorecard HTML + `doi-scorecard` skill on a fake engagement | Open `scorecard.html` against sample JSONs, see verdict + 5 ratings + interventions render | medium |
| 3 | All relevant phases emit JSON alongside MD; schema-conformance critic check | Run phases on a sample engagement, see JSON files validate | medium |
| 4 | `doi-intake` scaffolds `data/`, `scorecard.html`, `serve.cmd`/`serve.sh` at engagement creation | Fresh engagement folder has working scorecard skeleton | small |
| 5 | `playbook.md` template + `doi-build` updates + `doi-render` skill | A built intervention has playbook.md; static HTML renders for handoff | medium |
| 6 | AskUserQuestion decision-brief gates + dual-effort labels + README | Read-through of gates and roadmap matches new format | small |

Each phase ends in a clean commit. Each task within a phase is also a commit.

---

## Phase 1 — Foundation (zero-risk additions)

### Task 1.1: Commit the research report (already on disk, untracked)

**Files:**
- Track: `docs/research/gstack-grabs.md` (already exists, untracked)

**Step 1: Stage and commit**

```bash
git add docs/research/gstack-grabs.md
git commit -m "$(cat <<'EOF'
Add gstack research report justifying scorecard + critic work

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

**Step 2: Verify**

```bash
git log --oneline -1
git status
```

Expected: clean working tree, new commit at HEAD.

---

### Task 1.2: Create `scripts/_config/voice.md`

**Files:**
- Create: `scripts/_config/voice.md`

**Step 1: Write the file**

Content (full file):

```markdown
# DOI Voice Rules

Skills that write client-facing or critic-facing output read this file before drafting.

## Verification rule

Never say "likely handled" or "probably tested" — verify and cite, or flag as unknown.
"This looks fine" is not a finding. Either cite evidence it IS fine, or flag it as unverified.

If you claim "this pattern is safe" → cite the specific line proving safety.
If you claim "this is handled elsewhere" → read and cite the handling location.
If you claim "tests cover this" → name the test file and method.

## Voice rule

Lead with the point. Name files, functions, line numbers, commands, outputs, and real numbers. No em dashes (use hyphens with spaces, or restructure). No AI vocabulary:

- delve, crucial, robust, comprehensive, nuanced, multifaceted
- pivotal, landscape, tapestry, foster, intricate, vibrant
- fundamental, significant, underscore, showcase
- furthermore, moreover, additionally

Bad: "I've identified a potential issue in the authentication flow that may cause problems under certain conditions."

Good: "auth.ts:47 returns undefined when the session cookie expires. Users hit a white screen. Fix: add a null check and redirect to /login. Two lines."

## Confusion Protocol

For high-stakes ambiguity (data model, destructive scope, missing context), STOP. Name the ambiguity in one sentence, present 2–3 options with tradeoffs, and ask. Do not use for routine work — only when a wrong choice is hard to undo.

## Source

These rules are adapted from gstack's `review/SKILL.md` "Voice" and "Verification of claims" sections (see `docs/research/gstack-grabs.md` §3.3).
```

**Step 2: Commit**

```bash
git add scripts/_config/voice.md
git commit -m "$(cat <<'EOF'
Add shared voice rules (verification, vocabulary, confusion protocol)

Source: gstack review/SKILL.md, adapted in docs/research/gstack-grabs.md.
Referenced by heavyweight phase skills and by the critic.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 1.3: Reference `voice.md` from heavyweight phase skills

**Files (modify, single line each):**
- `skills/doi-roles/SKILL.md`
- `skills/doi-route/SKILL.md`
- `skills/doi-roadmap/SKILL.md`
- `skills/doi-build/SKILL.md`

**Step 1: Add the reference line to each skill**

Add immediately under the `## 1. Overview` heading in each file:

```markdown
> **Voice:** Read `scripts/_config/voice.md` before drafting any client-facing output. Verification rule, vocabulary blocklist, Confusion Protocol all apply.
```

**Step 2: Verify the line is present in all four files**

```bash
grep -l "scripts/_config/voice.md" skills/doi-roles/SKILL.md skills/doi-route/SKILL.md skills/doi-roadmap/SKILL.md skills/doi-build/SKILL.md
```

Expected: all four paths printed.

**Step 3: Commit**

```bash
git add skills/doi-roles/SKILL.md skills/doi-route/SKILL.md skills/doi-roadmap/SKILL.md skills/doi-build/SKILL.md
git commit -m "$(cat <<'EOF'
Reference shared voice.md from heavyweight phase skills

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 1.4: Create `agents/doi-review/checklists/` folder with foundational checklists

**Files:**
- Create: `agents/doi-review/checklists/evidence.md`
- Create: `agents/doi-review/checklists/principles.md`
- Create: `agents/doi-review/checklists/scope-drift.md`
- Create: `agents/doi-review/checklists/invented-data.md`
- Create: `agents/doi-review/checklists/plan-completion-audit.md`

**Each checklist file structure:**

```markdown
# Checklist: <name>

**Applies to phases:** <list, or "all">

**Owner question:** <one-sentence framing — what this checklist is asking of the output>

## Checks

- [ ] Check 1 — <one-line check> — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] Check 2 — ...

## Output format per finding

```json
{
  "phase": "<phase number>",
  "checklist": "<checklist name>",
  "check_id": "<id from list above>",
  "severity": "CRITICAL|MINOR",
  "finding": "<one-line description>",
  "evidence_cite": "<file:line or section reference>",
  "confidence": <integer 1-10>
}
```

## Severity guide

- CRITICAL: <what makes it critical for this checklist>
- MINOR: <what makes it minor>
```

**Specific contents (write each file with these exact checks):**

**`evidence.md`** — checks: every score in the output cites prior-phase evidence (a file path + section, or a `_uploads/MANIFEST.md` row). Used by phases 5, 6, 7, 8, 9.

**`principles.md`** — checks compliance against `scripts/_config/3rd-brain-build-principles.md`:
- P1 (frontend-first): app interventions lead with user-facing surface
- P2/P4 (solo-agent / single-agent default): Stage 3 decompositions cite measured bottleneck
- P3 (ship every week): Tier 1 has 1-week shippable subset + demo definition
- P5 (ICM before infra): Tools interventions tagged `files-default` or `infrastructure-justified` (with file-failure mode cited)
- P6 (start with what's built): interventions tagged `extend-existing` or `new-system` (with justification)
- P7 (3 architect questions): every Tier 1–2 spec answers state owner / feedback signal / deletion impact

**`scope-drift.md`** — checks: phase output stays within the phase's scope contract (e.g., `doi-verify` doesn't classify or score; `doi-friction` doesn't recommend). Each phase has a "CANNOT" list in its SKILL.md — this checklist enforces it.

**`invented-data.md`** — checks: every instance-specific fact (vendor field name, API endpoint, error rate, integration capability) traces to a `_uploads/MANIFEST.md` row, an `integration-research.md` web-search citation, or a verified-tool entry. Untraceable instance-specific facts = CRITICAL.

**`plan-completion-audit.md`** — special: applied between phases, not within a phase. Takes the *prior* phase's actionable items and the *current* phase's output, classifies each item as `DONE / PARTIAL / NOT_DONE / CHANGED`. For each PARTIAL/NOT_DONE, forces a WHY: `scope_cut | context_exhaustion | misunderstood | blocked | forgotten`. Emits one finding per item that is NOT_DONE without a `scope_cut` justification.

**Step 1: Write all five files using the template above and the specific contents listed.**

**Step 2: Verify each file is parseable as markdown and has the required sections**

```bash
for f in agents/doi-review/checklists/*.md; do
  echo "=== $f ==="
  grep -E "^## Checks|^## Output format|^## Severity" "$f" || echo "MISSING SECTIONS in $f"
done
```

Expected: each file shows all three section headings.

**Step 3: Commit**

```bash
git add agents/doi-review/checklists/
git commit -m "$(cat <<'EOF'
Add doi-review checklist folder with five foundational checklists

evidence, principles, scope-drift, invented-data, plan-completion-audit.
Critic loads these per phase to emit structured JSON findings.

Source: gstack review/specialists/ pattern, adapted single-agent
(see docs/research/gstack-grabs.md §3.1).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 1.5: Refactor `agents/doi-review/AGENT.md` to use the checklist folder + JSON findings + Plan Completion Audit

**Files:**
- Modify: `agents/doi-review/AGENT.md`

**Step 1: Update sections in order**

Modifications (do not rewrite entire file — preserve phase-specific check lists in §3 as fallback content; the new flow loads checklists *in addition to* those):

1. **§2 "How You Are Invoked"** — add a paragraph:

   > For phases 1, 5–10, you load the relevant files from `agents/doi-review/checklists/` based on the phase number (every phase loads `evidence.md`, `principles.md`, `scope-drift.md`, `invented-data.md`; the orchestrator may also pass the prior phase output and the prior phase's actionable list, in which case you also load `plan-completion-audit.md`).

2. **§4 "Review Output Format"** — replace the current freeform markdown report with:

   - Top-level: a JSON array of findings (one object per finding, schema in checklist files)
   - After the JSON: a markdown summary in the existing format (RECOMMENDATION, WHAT WAS DONE WELL, etc.) — kept for human readability
   - Add deduplication rule: findings are deduplicated by fingerprint `phase:check_id:evidence_cite`. Identical findings flagged by two checklists get `multi_checklist_confirmed: true` and confidence `min(10, max(c1, c2) + 1)`.
   - Add confidence display rule: 9–10 normal, 5–6 with caveat "Medium confidence, verify", 3–4 in appendix only, 1–2 suppressed unless severity is CRITICAL.

3. **§5 "Scoring Criteria"** — add: PASS WITH ISSUES is now also returned when all CRITICAL findings have confidence < 7 (i.e., critic isn't sure enough to block).

4. **New §7 "Plan Completion Audit"** — insert before §6 "Constraints":

   > When the orchestrator provides the prior phase output AND a list of actionable items extracted from it, run `plan-completion-audit.md`. For each item, classify as DONE / PARTIAL / NOT_DONE / CHANGED against the current phase output. For each NOT_DONE without a `scope_cut` justification, emit a CRITICAL finding. This step prevents silent quality decay across the 12-phase pipeline.

**Step 2: Verify the file still parses as a valid skill — frontmatter intact, sections present**

```bash
head -12 agents/doi-review/AGENT.md
grep -E "^## " agents/doi-review/AGENT.md
```

Expected: frontmatter unchanged, sections 1-7 (was 1-6) present, "Plan Completion Audit" heading visible.

**Step 3: Commit**

```bash
git add agents/doi-review/AGENT.md
git commit -m "$(cat <<'EOF'
Refactor doi-review to use checklist folder + JSON findings + plan audit

- Loads agents/doi-review/checklists/ per phase
- Emits structured JSON findings deduplicated by fingerprint
- Confidence 1-10 per finding with display rules
- New §7: Plan Completion Audit between phases

Single agent maintained (Principle 4 — no parallel subagent dispatch).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 2 — End-to-end scorecard demo (smallest first useful slice)

This phase produces a working scorecard.html that renders against fixture data. Existing phase skills are NOT touched yet — that's Phase 3.

### Task 2.1: Define `scripts/_config/output-schemas/scorecard.json` (JSON Schema)

**Files:**
- Create: `scripts/_config/output-schemas/scorecard.json`

**Step 1: Write the schema**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "doi-method/scorecard.json",
  "title": "DOI Engagement Scorecard",
  "type": "object",
  "required": ["organization", "generated_at", "verdict", "ratings", "deployable", "remediation"],
  "properties": {
    "organization": { "type": "string" },
    "primary_goal": { "type": "string" },
    "generated_at": { "type": "string", "format": "date" },
    "verdict": {
      "type": "object",
      "required": ["ready_status", "summary_line", "constraint_line"],
      "properties": {
        "ready_status": { "enum": ["YES", "NO", "CONDITIONAL"] },
        "summary_line": { "type": "string", "description": "Deployment count, cost envelope, FTE commitment" },
        "constraint_line": { "type": "string", "description": "Single largest constraint identified" }
      }
    },
    "ratings": {
      "type": "object",
      "required": ["talent_strategy", "workflow_optimization", "digital_architecture"],
      "properties": {
        "talent_strategy": { "$ref": "#/$defs/rating" },
        "workflow_optimization": { "$ref": "#/$defs/rating" },
        "digital_architecture": { "$ref": "#/$defs/rating" },
        "knowledge_management": { "$ref": "#/$defs/rating" },
        "ai_automation": { "$ref": "#/$defs/rating" }
      }
    },
    "deployable": {
      "type": "array",
      "description": "Tier 1 + Tier 2 interventions",
      "items": {
        "type": "object",
        "required": ["slug", "name", "tier", "value_line", "quarter"],
        "properties": {
          "slug": { "type": "string" },
          "name": { "type": "string" },
          "tier": { "enum": [1, 2] },
          "value_line": { "type": "string", "description": "One-line value thesis" },
          "quarter": { "type": "string", "pattern": "^Q[1-4]$" },
          "human_effort": { "type": "string", "description": "e.g. '2 weeks'" },
          "doi_effort": { "type": "string", "description": "e.g. '1 hour'" }
        }
      }
    },
    "remediation": {
      "type": "object",
      "description": "One-sentence-per-quarter remediation roadmap headlines",
      "required": ["q1", "q2", "q3"],
      "properties": {
        "q1": { "type": "string" },
        "q2": { "type": "string" },
        "q3": { "type": "string" }
      }
    }
  },
  "$defs": {
    "rating": {
      "type": "object",
      "required": ["score", "justification"],
      "properties": {
        "score": { "type": "integer", "minimum": 1, "maximum": 5 },
        "justification": { "type": "string", "maxLength": 200 }
      }
    }
  }
}
```

**Step 2: Validate the schema is itself valid JSON Schema (using Python's jsonschema if installed, or just JSON parse)**

```bash
python -c "import json; json.load(open('scripts/_config/output-schemas/scorecard.json'))"
```

Expected: no output (success).

**Step 3: Commit**

```bash
git add scripts/_config/output-schemas/scorecard.json
git commit -m "$(cat <<'EOF'
Add scorecard.json schema (Move 7 board-ready format)

Required sections: verdict, 3-5 pillar ratings (1-5), deployable list,
remediation roadmap. Includes optional human_effort/doi_effort fields
for dual-effort labels.

Source: thecraftofai.com/read/750k-readiness-audit Move 7.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2.2: Create fixture engagement with sample data

**Files:**
- Create: `tests/fixtures/sample-engagement/data/scorecard.json`
- Create: `tests/fixtures/sample-engagement/data/_index.json`

**Step 1: Write fixture `_index.json`**

```json
{
  "organization": "Acme Widgets",
  "phases": {
    "1_assess": "complete",
    "8_pillars": "complete",
    "9_roadmap": "complete",
    "10_build": "in_progress"
  },
  "scorecard": "complete"
}
```

**Step 2: Write fixture `scorecard.json` with realistic content**

```json
{
  "organization": "Acme Widgets",
  "primary_goal": "Reduce sales-ops friction so AEs can spend more time selling",
  "generated_at": "2026-05-08",
  "verdict": {
    "ready_status": "CONDITIONAL",
    "summary_line": "3 deployable workflows, ~$45K committed, 0.5 FTE for 90 days",
    "constraint_line": "CRM data quality is the single largest blocker"
  },
  "ratings": {
    "talent_strategy": { "score": 3, "justification": "Two ops leads with prompt-design depth; no ML capacity" },
    "workflow_optimization": { "score": 2, "justification": "Sales pipeline documented but handoffs are tribal" },
    "digital_architecture": { "score": 2, "justification": "HubSpot + Sheets only; no integration layer" },
    "knowledge_management": { "score": 1, "justification": "No central knowledge base; SOPs live in Slack" },
    "ai_automation": { "score": 2, "justification": "ChatGPT seats exist; nothing in production workflow" }
  },
  "deployable": [
    {
      "slug": "lead-enrichment-skill",
      "name": "Lead enrichment Claude Skill",
      "tier": 1,
      "value_line": "Removes ~6 hrs/week of AE manual research per rep",
      "quarter": "Q3",
      "human_effort": "2 weeks of consultant + AE time",
      "doi_effort": "1 day to scaffold + 1 week to demo"
    },
    {
      "slug": "pipeline-hygiene-icm",
      "name": "Pipeline hygiene ICM folder",
      "tier": 1,
      "value_line": "Replaces tribal Slack handoffs with file-based stages",
      "quarter": "Q3",
      "human_effort": "3 weeks",
      "doi_effort": "2 days"
    },
    {
      "slug": "renewal-followup-automation",
      "name": "Renewal followup automation (Zapier)",
      "tier": 2,
      "value_line": "Captures the 12% of renewals currently dropped",
      "quarter": "Q4",
      "human_effort": "1 week",
      "doi_effort": "4 hours"
    }
  ],
  "remediation": {
    "q1": "Q1 (current): Stand up CRM data hygiene SOP — owner: ops lead — budget: $0",
    "q2": "Q2: Ship lead-enrichment skill + pipeline ICM — owner: ops lead — budget: $30K",
    "q3": "Q3: Renewal followup automation + measured Stage 3 review — owner: rev ops — budget: $15K"
  }
}
```

**Step 3: Validate fixture against schema**

```bash
python -c "
import json
from jsonschema import validate
schema = json.load(open('scripts/_config/output-schemas/scorecard.json'))
data = json.load(open('tests/fixtures/sample-engagement/data/scorecard.json'))
validate(instance=data, schema=schema)
print('OK')
"
```

Expected: `OK`. If `jsonschema` isn't installed, document the equivalent online validator URL in the commit message and skip — schema correctness will be re-verified in Phase 3 when real outputs flow through.

**Step 4: Commit**

```bash
git add tests/fixtures/sample-engagement/
git commit -m "$(cat <<'EOF'
Add sample-engagement fixture with realistic scorecard JSON

Used by scorecard.html template development and by the doi-scorecard
skill verification flow.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2.3: Build `scripts/_templates/scorecard.html`

**Files:**
- Create: `scripts/_templates/scorecard.html`

**Architecture:**
- Single self-contained HTML file (no external CSS/JS dependencies)
- On `DOMContentLoaded`, fetches `./data/_index.json` first
- If `_index.json.scorecard === "complete"`, fetches `./data/scorecard.json` and renders
- Otherwise renders "Scorecard pending — Phase 9 not yet complete" placeholder
- Layout matches Move 7 spec: fits one printed page at 11pt; sections in this order: Verdict / Readiness Ratings / Deployable / Remediation
- Uses `@media print` CSS to enforce one-page printout

**Step 1: Write the template file**

Full file content (write this verbatim — JS is intentionally vanilla, no build step):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>DOI Scorecard</title>
<style>
  :root {
    --fg: #111;
    --muted: #666;
    --line: #ddd;
    --critical: #b00020;
    --ok: #1a7f37;
    --warn: #b95000;
  }
  * { box-sizing: border-box; }
  body {
    font: 11pt/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
    color: var(--fg);
    max-width: 8.5in;
    margin: 0 auto;
    padding: 0.5in;
  }
  h1 { font-size: 14pt; margin: 0 0 4pt; }
  h2 { font-size: 11pt; margin: 14pt 0 4pt; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--line); padding-bottom: 2pt; }
  .meta { color: var(--muted); font-size: 9pt; margin-bottom: 12pt; }
  .verdict { font-weight: 600; }
  .verdict .status-YES { color: var(--ok); }
  .verdict .status-NO { color: var(--critical); }
  .verdict .status-CONDITIONAL { color: var(--warn); }
  table { width: 100%; border-collapse: collapse; margin: 6pt 0; }
  th, td { text-align: left; padding: 3pt 6pt 3pt 0; border-bottom: 1px solid var(--line); vertical-align: top; }
  th { font-weight: 600; font-size: 9pt; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); }
  td.score { font-weight: 600; width: 2em; }
  td.tier { width: 3em; }
  td.quarter { width: 3em; }
  .effort { color: var(--muted); font-size: 9pt; }
  .pending { color: var(--muted); font-style: italic; padding: 24pt 0; text-align: center; }
  @media print {
    body { padding: 0.5in; }
    h2 { page-break-after: avoid; }
  }
</style>
</head>
<body>
<header>
  <h1 id="org">Loading...</h1>
  <div class="meta"><span id="goal"></span> &middot; Generated <span id="date"></span></div>
</header>

<section id="verdict-section" hidden>
  <h2>Verdict</h2>
  <p class="verdict">
    <span class="status" id="ready-status"></span> &mdash; <span id="summary-line"></span>
  </p>
  <p><strong>Largest constraint:</strong> <span id="constraint-line"></span></p>
</section>

<section id="ratings-section" hidden>
  <h2>Readiness Ratings</h2>
  <table>
    <thead><tr><th>Pillar</th><th>Score</th><th>Justification</th></tr></thead>
    <tbody id="ratings-body"></tbody>
  </table>
</section>

<section id="deployable-section" hidden>
  <h2>Deployable Workflows</h2>
  <table>
    <thead><tr><th>Tier</th><th>Workflow</th><th>Value</th><th>Quarter</th><th>Effort (human / DOI)</th></tr></thead>
    <tbody id="deployable-body"></tbody>
  </table>
</section>

<section id="remediation-section" hidden>
  <h2>Remediation Roadmap</h2>
  <ul id="remediation-list"></ul>
</section>

<section id="pending" hidden>
  <p class="pending">Scorecard pending — earlier phases must complete first.</p>
</section>

<script>
const PILLAR_LABELS = {
  talent_strategy: "Talent Strategy",
  workflow_optimization: "Workflow Optimization",
  digital_architecture: "Digital Architecture",
  knowledge_management: "Knowledge Management",
  ai_automation: "AI Automation"
};

async function load() {
  const idx = await fetch("./data/_index.json").then(r => r.json()).catch(() => null);
  if (!idx || idx.scorecard !== "complete") {
    document.getElementById("pending").hidden = false;
    document.getElementById("org").textContent = idx?.organization || "DOI Engagement";
    return;
  }
  const data = await fetch("./data/scorecard.json").then(r => r.json());
  render(data);
}

function render(d) {
  document.getElementById("org").textContent = d.organization;
  document.getElementById("goal").textContent = d.primary_goal || "";
  document.getElementById("date").textContent = d.generated_at;

  // Verdict
  const v = d.verdict;
  const statusEl = document.getElementById("ready-status");
  statusEl.textContent = v.ready_status;
  statusEl.className = "status status-" + v.ready_status;
  document.getElementById("summary-line").textContent = v.summary_line;
  document.getElementById("constraint-line").textContent = v.constraint_line;
  document.getElementById("verdict-section").hidden = false;

  // Ratings
  const ratingsBody = document.getElementById("ratings-body");
  for (const [key, label] of Object.entries(PILLAR_LABELS)) {
    const r = d.ratings[key];
    if (!r) continue;
    const tr = document.createElement("tr");
    tr.innerHTML = `<td>${label}</td><td class="score">${r.score}/5</td><td>${escapeHtml(r.justification)}</td>`;
    ratingsBody.appendChild(tr);
  }
  document.getElementById("ratings-section").hidden = false;

  // Deployable
  const dBody = document.getElementById("deployable-body");
  for (const w of d.deployable) {
    const tr = document.createElement("tr");
    const effort = (w.human_effort || w.doi_effort)
      ? `<span class="effort">${escapeHtml(w.human_effort || "?")} &rarr; ${escapeHtml(w.doi_effort || "?")}</span>`
      : "";
    tr.innerHTML = `<td class="tier">T${w.tier}</td><td>${escapeHtml(w.name)}</td><td>${escapeHtml(w.value_line)}</td><td class="quarter">${w.quarter}</td><td>${effort}</td>`;
    dBody.appendChild(tr);
  }
  document.getElementById("deployable-section").hidden = false;

  // Remediation
  const rList = document.getElementById("remediation-list");
  ["q1","q2","q3"].forEach(q => {
    if (!d.remediation[q]) return;
    const li = document.createElement("li");
    li.textContent = d.remediation[q];
    rList.appendChild(li);
  });
  document.getElementById("remediation-section").hidden = false;
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

load();
</script>
</body>
</html>
```

**Step 2: Verify it renders against the fixture**

```bash
cp scripts/_templates/scorecard.html tests/fixtures/sample-engagement/scorecard.html
cd tests/fixtures/sample-engagement
python -m http.server 8765 &
SERVER_PID=$!
sleep 1
curl -s http://localhost:8765/scorecard.html | head -20
kill $SERVER_PID
cd -
```

Expected: HTML head visible. Then manually open `http://localhost:8765/scorecard.html` in a browser and confirm:
- Header shows "Acme Widgets · Reduce sales-ops friction..."
- Verdict shows CONDITIONAL in orange
- Five pillar ratings in a table
- Three deployable rows with effort columns
- Three remediation list items

If layout is broken or sections don't render, fix template before commit.

**Step 3: Remove the test copy and commit the template only**

```bash
rm tests/fixtures/sample-engagement/scorecard.html
git add scripts/_templates/scorecard.html
git commit -m "$(cat <<'EOF'
Add scorecard.html template (Move 7 one-pager)

Pre-built shell that fetches ./data/_index.json + ./data/scorecard.json
and progressively renders sections as phases complete. Print CSS
enforces one-page output. Vanilla JS, no build step.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2.4: Create `skills/doi-scorecard/SKILL.md`

**Files:**
- Create: `skills/doi-scorecard/SKILL.md`

**Step 1: Write the skill**

Sections (write each with full prose in DOI voice — drafting guidance below):

**Frontmatter:**
```yaml
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
```

**Body sections:**

1. **`## 1. Overview`** — what this is (the capstone), where it fits (after Phase 9, before Phase 10), what it produces (`data/scorecard.json` for HTML rendering, `roadmap-summary.md` as a printable markdown sibling). Include the voice reference: `> **Voice:** Read scripts/_config/voice.md before drafting.`

2. **`## 2. Inputs`** — list which prior phase files this skill reads:
   - `assessments/maturity-assessment.md` (verdict ready_status hint)
   - `departments/{dept}/assessments/foundational.md` (and `advanced.md` if present) — pillar scores
   - `departments/{dept}/gap-analysis.md` — interventions
   - `roadmap.md` — tier assignments + 1-week shippable subsets + dual-effort labels
   - `context/goals.md` — primary goal
   - `_uploads/MANIFEST.md` — provenance reference

3. **`## 3. Compression Rules`** — the actual judgment rules:
   - Pillar 15-point score → 1–5 rating: `1: 0-3, 2: 4-6, 3: 7-9, 4: 10-12, 5: 13-15`
   - Justification: ONE sentence, ≤ 200 chars, must cite one piece of evidence (e.g., "Two ops leads with prompt-design depth; no ML capacity")
   - Verdict ready_status: `YES` if maturity ≥ Level 3 AND all foundational pillars ≥ 8/15; `NO` if maturity = Level 1 OR any pillar = 0; otherwise `CONDITIONAL`
   - Verdict summary_line: pull from roadmap Tier 1 count + budget envelope + FTE estimate
   - Verdict constraint_line: identify the single largest blocker — usually the lowest-scoring pillar, but can be the maturity hard-cap if active
   - Deployable list: copy Tier 1 + Tier 2 from roadmap, each with one-line value thesis and quarter assignment (Q1 = current, Q2/Q3 follow); pull `human_effort` and `doi_effort` if present in the roadmap (Phase 6 of this plan)
   - Remediation Q1/Q2/Q3: one sentence each, sequenced from roadmap "What Not to Do Yet" + Tier 1 + Tier 2

4. **`## 4. Output`** — produces:
   - `data/scorecard.json` (validates against `scripts/_config/output-schemas/scorecard.json`)
   - `data/_index.json` updated to set `scorecard: "complete"`
   - `scorecard-summary.md` — markdown printout of the same data, for clients who can't open HTML

5. **`## 5. Constraints`** — CANNOT:
   - Score pillars from scratch (always reads Phase 8 output)
   - Add or remove interventions (reads Phase 9 roadmap as ground truth)
   - Soften the verdict (CONDITIONAL is the soft option; NO is real)
   - Exceed 200 chars per justification or one-line value thesis

6. **`## 6. Critic checks (which checklists apply)`** — `evidence.md`, `principles.md`, `scope-drift.md`, `invented-data.md`. Schema-conformance is added in Phase 3 of this plan.

**Step 2: Verify frontmatter parses**

```bash
python -c "
import yaml, sys
with open('skills/doi-scorecard/SKILL.md') as f:
    content = f.read()
parts = content.split('---', 2)
fm = yaml.safe_load(parts[1])
assert fm['name'] == 'doi-scorecard'
assert 'description' in fm
print('OK')
"
```

Expected: `OK`.

**Step 3: Run the skill against the fixture (manual test)**

The fixture already has a populated `scorecard.json` from Task 2.2. To verify the skill *would* produce the same output:
- Read the skill body
- Walk through the Compression Rules against fictional Phase 8/9 outputs in head
- Sanity-check that the rules in §3 produce the fixture content

If the rules don't reproduce the fixture, adjust Compression Rules until they do. (Cheaper than building real prior-phase fixtures right now.)

**Step 4: Commit**

```bash
git add skills/doi-scorecard/SKILL.md
git commit -m "$(cat <<'EOF'
Add doi-scorecard skill (engagement capstone after Phase 9)

Compresses pillar scores to 1-5 ratings, writes verdict with
ready_status, finalizes Tier 1-2 deployable list, and produces
quarterly remediation roadmap. Output: data/scorecard.json
(HTML-rendered) + scorecard-summary.md (printable).

Source: thecraftofai.com Move 7, adapted to DOI's pillar/tier model.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2.5: Phase 2 integration verification

**Step 1: Manually walk the demo**

```bash
cp scripts/_templates/scorecard.html tests/fixtures/sample-engagement/scorecard.html
cd tests/fixtures/sample-engagement
python -m http.server 8765 &
SERVER_PID=$!
sleep 1
echo "Open http://localhost:8765/scorecard.html in browser"
echo "Press Enter when verified, then I'll clean up"
read
kill $SERVER_PID
rm scorecard.html
cd -
```

Expected (browser): full scorecard renders with fixture data — all four sections visible, print preview shows one page.

**Step 2: If anything is wrong, fix in `scripts/_templates/scorecard.html` and amend the previous commit if not yet pushed; otherwise create a fixup commit.**

**No new commit if everything works** — Phase 2 is complete with the existing commits.

---

## Phase 3 — Wire phases to emit JSON alongside markdown

This is the largest phase. Each phase skill is updated to write a sibling JSON file. The critic gains a schema-conformance check.

### Task 3.1: Define remaining schemas

**Files (create all):**
- `scripts/_config/output-schemas/assess.json` — maturity level, total score, category scores, hard cap reasons
- `scripts/_config/output-schemas/pillars-foundational.json` — three foundational pillars with sub-dimension scores + evidence cites
- `scripts/_config/output-schemas/pillars-advanced.json` — same structure, two pillars
- `scripts/_config/output-schemas/route.json` — bottleneck classification per high-friction task with intervention type + tags
- `scripts/_config/output-schemas/roadmap.json` — Tier 1/2/3 interventions with shippable subset, demo definition, principle compliance, dual-effort labels
- `scripts/_config/output-schemas/build.json` — per-intervention manifest

**Step 1: Write each schema following the same pattern as `scorecard.json` — required fields enumerated, each with type + constraints, $defs reused for common shapes (rating, intervention, pillar).**

For each schema, study the corresponding phase output format in its SKILL.md and translate to JSON Schema. Common cross-schema $defs to factor:
- `rating` — `{score: 0-15, justification: string<=200, evidence_cite: string}`
- `intervention` — `{slug, name, tier, bottleneck_type, stage, friction_score, principle_compliance, ...}`
- `evidence_cite` — `{file: string, section: string?, line: int?}`

**Step 2: Validate each schema parses as JSON**

```bash
for f in scripts/_config/output-schemas/*.json; do
  python -c "import json; json.load(open('$f'))" && echo "OK: $f"
done
```

Expected: 6+ OK lines.

**Step 3: Commit (one commit, all schemas)**

```bash
git add scripts/_config/output-schemas/
git commit -m "$(cat <<'EOF'
Add JSON schemas for assess/pillars/route/roadmap/build phase outputs

Each phase will emit a sibling .json validating against its schema,
so the scorecard HTML and downstream tooling can read structured data.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3.2: Update `skills/doi-assess/SKILL.md` to emit JSON

**Files:**
- Modify: `skills/doi-assess/SKILL.md`

**Step 1: Add a "JSON output" subsection under "Output Format"**

Insert after the existing markdown output description:

```markdown
### JSON output (companion file)

After writing `assessments/maturity-assessment.md`, also write `data/phase-1-assess.json` matching the schema at `scripts/_config/output-schemas/assess.json`. Fields:

- `level`: integer 1-5
- `total_score`: integer 0-30
- `category_scores`: object with five integer fields (panel0_yes ... panel4_yes)
- `cap_reason`: string or null (matches the cap_reason in markdown frontmatter)
- `generated_at`: today's date

After writing the JSON, update `data/_index.json`:

```bash
$DOI_SCRIPTS/update-index.sh "1_assess" "complete"
```
```

**Step 2: Add the same line referencing voice.md if not already present (Task 1.3 only added it to roles/route/roadmap/build).**

Skip if already present. Otherwise add to top of "Overview" section.

**Step 3: Commit**

```bash
git add skills/doi-assess/SKILL.md
git commit -m "$(cat <<'EOF'
doi-assess: emit data/phase-1-assess.json alongside markdown

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3.3: Update `skills/doi-pillars/SKILL.md` to emit JSON

**Files:**
- Modify: `skills/doi-pillars/SKILL.md`

**Step 1: Add JSON output subsection**

Two outputs: `data/phase-8-pillars-foundational.json` and (if advanced gate passes) `data/phase-8-pillars-advanced.json`.

Schema fields per pillar: `score (0-15)`, `sub_dimensions: [{name, score, evidence_cite}]`, `justification`. Each evidence_cite must point to a file in prior phases or `_uploads/MANIFEST.md`.

**Step 2: Add `update-index.sh` call after JSON write.**

**Step 3: Commit**

```bash
git add skills/doi-pillars/SKILL.md
git commit -m "doi-pillars: emit foundational/advanced JSON alongside markdown

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 3.4: Update `skills/doi-route/SKILL.md` to emit JSON

Same pattern. Schema fields per intervention entry: `task_slug, friction_score, bottleneck_type (people|process|tools), tags ([extend-existing|new-system, files-default|infrastructure-justified]), intervention_summary, stage`.

Commit after.

---

### Task 3.5: Update `skills/doi-roadmap/SKILL.md` to emit JSON

Same pattern. Schema includes Tier 1-3 interventions, each with `1-week shippable subset` text, `demo_definition` text, `principle_compliance: {p1, p2_p4, p3, p5, p6, p7}`, optional `human_effort` and `doi_effort` (added properly in Phase 6 — leave the fields nullable here).

Commit after.

---

### Task 3.6: Add `agents/doi-review/checklists/schema-conformance.md`

**Files:**
- Create: `agents/doi-review/checklists/schema-conformance.md`

**Step 1: Write the checklist**

```markdown
# Checklist: Schema Conformance

**Applies to phases:** 1, 8, 7 (route), 9, 10

**Owner question:** Does the phase JSON validate against its schema?

## Checks

- [ ] sc-1 — `data/phase-N-*.json` exists for the completed phase — emits CRITICAL finding if missing
- [ ] sc-2 — JSON parses as valid JSON — emits CRITICAL if parse fails (with parser error in finding)
- [ ] sc-3 — JSON validates against `scripts/_config/output-schemas/<name>.json` — emits CRITICAL with specific schema error path
- [ ] sc-4 — `data/_index.json` reflects the phase as `complete` — emits MINOR if missing/stale

## How the critic runs this

```bash
python -c "
import json
from jsonschema import validate, ValidationError
schema = json.load(open('scripts/_config/output-schemas/<name>.json'))
data = json.load(open('<engagement>/data/phase-N-<name>.json'))
validate(instance=data, schema=schema)
"
```

If `jsonschema` is unavailable, the critic emits a MINOR finding noting the dependency missing AND falls back to a structural check (required keys present at the top level).

## Severity guide

- CRITICAL: missing JSON, invalid JSON, schema validation fails
- MINOR: index file stale, optional fields missing, jsonschema unavailable
```

**Step 2: Update `agents/doi-review/AGENT.md` §2 ("How You Are Invoked")** to add `schema-conformance.md` to the per-phase checklist load list for phases 1, 7, 8, 9, 10.

**Step 3: Commit**

```bash
git add agents/doi-review/checklists/schema-conformance.md agents/doi-review/AGENT.md
git commit -m "$(cat <<'EOF'
Add schema-conformance critic checklist for JSON outputs

Critic now validates each phase's data/*.json against its schema in
scripts/_config/output-schemas/ and emits structured findings for
missing/invalid/non-conforming JSON.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3.7: Update `scripts/update-state.sh` (or create `scripts/update-index.sh`) to maintain `data/_index.json`

**Files:**
- Create: `scripts/update-index.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage: update-index.sh <engagement-folder> <phase-key> <status>
# Example: update-index.sh ./engagements/acme "1_assess" "complete"

ENGAGEMENT="$1"
PHASE_KEY="$2"
STATUS="$3"
INDEX="$ENGAGEMENT/data/_index.json"

mkdir -p "$ENGAGEMENT/data"

if [ ! -f "$INDEX" ]; then
  ORG_NAME="$(basename "$ENGAGEMENT")"
  cat > "$INDEX" <<EOF
{
  "organization": "$ORG_NAME",
  "phases": {},
  "scorecard": "pending"
}
EOF
fi

python - "$INDEX" "$PHASE_KEY" "$STATUS" <<'PY'
import json, sys
path, key, status = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    data = json.load(f)
data.setdefault("phases", {})[key] = status
if key == "scorecard":
    data["scorecard"] = status
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY
```

**Step 2: Make executable + verify**

```bash
chmod +x scripts/update-index.sh
mkdir -p /tmp/test-engagement
scripts/update-index.sh /tmp/test-engagement "1_assess" "complete"
cat /tmp/test-engagement/data/_index.json
rm -rf /tmp/test-engagement
```

Expected: `_index.json` shows `"phases": {"1_assess": "complete"}, "scorecard": "pending"`.

**Step 3: Commit**

```bash
git add scripts/update-index.sh
git commit -m "$(cat <<'EOF'
Add update-index.sh — maintains data/_index.json status across phases

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 4 — Workspace scaffolding at intake

### Task 4.1: Update `scripts/init-workspace.sh` to scaffold the scorecard

**Files:**
- Modify: `scripts/init-workspace.sh`

**Step 1: Read the current script and find the section that creates `_uploads/`**

```bash
grep -n "_uploads\|mkdir" scripts/init-workspace.sh
```

**Step 2: After the `_uploads/` creation block, append:**

```bash
# Scaffold scorecard infrastructure
mkdir -p "$ENGAGEMENT_FOLDER/data"
cp "$DOI_SCRIPTS/_templates/scorecard.html" "$ENGAGEMENT_FOLDER/scorecard.html"
"$DOI_SCRIPTS/update-index.sh" "$ENGAGEMENT_FOLDER" "0_intake" "in_progress"

# Convenience serve scripts
cat > "$ENGAGEMENT_FOLDER/serve.sh" <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
python3 -m http.server 8765
EOF
chmod +x "$ENGAGEMENT_FOLDER/serve.sh"

cat > "$ENGAGEMENT_FOLDER/serve.cmd" <<'EOF'
@echo off
cd /d "%~dp0"
python -m http.server 8765
EOF
```

Note path adjustment: `_templates/scorecard.html` lives at `scripts/_templates/scorecard.html`, so `$DOI_SCRIPTS/_templates/scorecard.html` is the correct copy source.

**Step 3: Verify on a fresh fake engagement**

```bash
mkdir -p /tmp/test-init
DOI_SCRIPTS=$(pwd)/scripts ./scripts/init-workspace.sh /tmp/test-init/acme
ls -la /tmp/test-init/acme/
ls /tmp/test-init/acme/data/
cat /tmp/test-init/acme/data/_index.json
```

Expected: `_uploads/`, `data/`, `scorecard.html`, `serve.sh`, `serve.cmd` all present. `_index.json` shows `0_intake: in_progress`.

**Step 4: Cleanup + commit**

```bash
rm -rf /tmp/test-init
git add scripts/init-workspace.sh
git commit -m "$(cat <<'EOF'
init-workspace.sh: scaffold data/, scorecard.html, serve scripts at intake

Operators get a working scorecard skeleton from the moment a new
engagement folder is created. Sections render "pending" until each
phase JSON appears in data/.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4.2: Update `skills/doi-intake/SKILL.md` to mention the scaffolded outputs

**Files:**
- Modify: `skills/doi-intake/SKILL.md`

**Step 1: In §4 Close-Out, after the existing "Call init-workspace.sh" line, add a paragraph noting that the scaffolder now also creates `data/`, `scorecard.html`, and `serve.sh`/`serve.cmd`. Operators can `bash serve.sh` (or double-click `serve.cmd` on Windows) to view the scorecard at `localhost:8765/scorecard.html` — sections will say "pending" until phases complete.**

**Step 2: Commit**

```bash
git add skills/doi-intake/SKILL.md
git commit -m "doi-intake: document scorecard scaffolding in close-out

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Phase 5 — Playbook + render + build update

### Task 5.1: Create `scripts/_templates/playbook.md`

**Files:**
- Create: `scripts/_templates/playbook.md`

**Step 1: Write the file (verbatim from runonamp template, with DOI conventions filled in for placeholder text)**

```markdown
# Playbook: {{intervention_name}}
**Version:** v1
**Intervention slug:** {{intervention_slug}}
**Generated by:** doi-build (Phase 10)
**Date:** {{date}}

## Inputs

**Background Context:**
{{background — pull from roadmap intervention spec, why this exists, what result it serves}}

**Start When (Trigger):**
{{trigger — when does this playbook actually run? on a schedule? on an inbound event? on operator request?}}

**Gather Items (Inputs):**
{{inputs — what data, files, credentials, prior outputs does this playbook need before step 1?}}

**Deliverables (Outputs):**
{{outputs — what concrete artifacts/state changes does running this playbook produce?}}

---

## Step 1: {{step_1_name}}

**When:** {{when_step_1_runs}}

**Instructions:**
{{step_1_instructions — actionable enough for Claude Code, Zapier, or a junior operator to execute without supervision}}

**Success Criteria:**
{{step_1_success}}

**Example:**
{{step_1_example — concrete sample input → output}}

**Response Format:**
{{step_1_response_format — what does this step return to the next step?}}

**(Optional) Configuration Notes:**
{{step_1_config_notes}}

---

## Step 2: {{step_2_name}}

[same shape as Step 1]

---

[Continue for as many steps as the intervention requires]

---

## Decommission

**What breaks if this playbook is deleted?**
{{deletion_impact — Principle 7c}}

**Where is feedback / how do we know it's working?**
{{feedback_signal — Principle 7b}}

**Where does this playbook's state live?**
{{state_owner — Principle 7a}}
```

**Step 2: Commit**

```bash
git add scripts/_templates/playbook.md
git commit -m "$(cat <<'EOF'
Add playbook.md template (operator-handoff runbook format)

Adopted from runonamp Quick Start Template. Per-intervention
playbook produced by doi-build alongside BUILD-NOTES.md and
SHIP-CHECKLIST.md. Includes the three architect questions in the
Decommission section.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 5.2: Update `skills/doi-build/SKILL.md` to emit `playbook.md` per intervention

**Files:**
- Modify: `skills/doi-build/SKILL.md`

**Step 1: Add a "Playbook output" subsection under whatever section enumerates the build outputs**

```markdown
### Playbook output

For every Tools+Stage 1, Tools+Stage 2, Process bottleneck, and Tools+Stage 3 (single-agent default) intervention, also produce `build/{intervention-slug}/playbook.md` using the template at `scripts/_templates/playbook.md`. Fill every `{{placeholder}}` — leaving placeholders unfilled is a Principle 7 violation (deliveries should be operator-ready, not skeleton-shaped).

Tools+Stage 4 intervention: refused by default. If override is granted, the playbook MUST cite the measured Stage 3 success that justifies promotion.
```

**Step 2: Update `agents/doi-review/AGENT.md` §3 Phase 10 checks to add:**

```
14. Does `build/{intervention-slug}/playbook.md` exist? Missing = CRITICAL.
15. Are all `{{placeholder}}` tokens replaced in the playbook? Unfilled placeholders = CRITICAL.
16. Does the Decommission section answer all three architect questions concretely (not "TBD" or "see BUILD-NOTES")? Vague answers = CRITICAL.
```

**Step 3: Commit**

```bash
git add skills/doi-build/SKILL.md agents/doi-review/AGENT.md
git commit -m "$(cat <<'EOF'
doi-build: produce playbook.md per intervention; add critic checks

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 5.3: Create `skills/doi-render/SKILL.md` (static HTML rebake for handoff)

**Files:**
- Create: `skills/doi-render/SKILL.md`

**Step 1: Write the skill**

The skill takes the engagement folder, reads all `data/*.json`, and produces a single self-contained `scorecard-handoff.html` with all data inlined as a `const DATA = {...}` block instead of `fetch()` calls. Same template, two render modes.

Sections:
- **Overview**: when to use (client handoff, post-engagement archive, no-server environments)
- **Inputs**: engagement folder path
- **Process**:
  1. Read `data/_index.json` and every `data/*.json`
  2. Read `scripts/_templates/scorecard.html`
  3. Replace the `<script>...load();</script>` block with an inline `<script>const DATA = {scorecard: {...}, index: {...}}; render(DATA.scorecard);</script>` block
  4. Write to `scorecard-handoff.html` in the engagement root
- **Output**: `scorecard-handoff.html` (single file, can be emailed/Slacked, opens directly without a server)
- **Constraints**: must produce identical visual output to the live HTML; render code is the same `render()` function — only the load path differs

**Step 2: Commit**

```bash
git add skills/doi-render/SKILL.md
git commit -m "$(cat <<'EOF'
Add doi-render skill — bake static scorecard HTML for client handoff

Same template + render code as the live scorecard, but data inlined
so the file works without python -m http.server. For email/Slack
handoff and post-engagement archive.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 6 — Polish

### Task 6.1: Add AskUserQuestion decision-brief format to phase gates

**Files:**
- Modify: `skills/doi-engage/SKILL.md`
- Modify: `skills/doi-route/SKILL.md`
- Modify: `skills/doi-roadmap/SKILL.md`
- Modify: `skills/doi-build/SKILL.md`

**Step 1: Add a new subsection "Human Gate Format" to each, with this content:**

```markdown
### Human Gate Format

When pausing for human approval after this phase, present the gate using this structure (adapted from gstack's review/SKILL.md AskUserQuestion format):

- **D-number**: D-<phase>.<seq>, e.g. D-9.1 for the first decision in Phase 9
- **ELI10 paragraph**: one short paragraph explaining what's being decided in plain language
- **Stakes if we pick wrong**: one or two sentences on the cost of the wrong choice
- **Recommendation**: which option you'd pick and one-sentence reason
- **Options**: each with ≥2 pros and ≥1 con (≥40 chars each, no fluff)
- **Net synthesis**: one sentence summarizing the tradeoff space
- **Self-check before emitting**: have you cited specific evidence? Are the options actually different in kind, not degree?
```

**Step 2: Commit**

```bash
git add skills/doi-engage/SKILL.md skills/doi-route/SKILL.md skills/doi-roadmap/SKILL.md skills/doi-build/SKILL.md
git commit -m "$(cat <<'EOF'
Add Human Gate Format (decision-brief) to engage/route/roadmap/build

Source: gstack review/SKILL.md (see docs/research/gstack-grabs.md §3.4).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 6.2: Add dual-effort labels to roadmap

**Files:**
- Modify: `skills/doi-roadmap/SKILL.md`
- Modify: `scripts/_config/output-schemas/roadmap.json` (already has nullable fields from Task 3.5 — change to required for Tier 1-2 interventions)

**Step 1: In `doi-roadmap/SKILL.md`, add to the intervention spec format:**

```markdown
**Effort labels:** every Tier 1 and Tier 2 intervention MUST include both:
- `human_effort:` time a human consultant alone would need (e.g., "2 weeks")
- `doi_effort:` time using the DOI pipeline (e.g., "1 day to scaffold + 1 week demo")

These appear on the scorecard as the "Effort (human / DOI)" column. They make the AI compression visible at decision time.
```

**Step 2: Update `roadmap.json` schema so `human_effort` and `doi_effort` are required for Tier 1-2 entries (use `oneOf` or `if/then` based on tier).**

**Step 3: Commit**

```bash
git add skills/doi-roadmap/SKILL.md scripts/_config/output-schemas/roadmap.json
git commit -m "$(cat <<'EOF'
doi-roadmap: require human_effort + doi_effort labels on Tier 1-2

Source: gstack ETHOS.md "Effort both-scales" framing (see
docs/research/gstack-grabs.md §3.5).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 6.3: Update `README.md` with the new outputs

**Files:**
- Modify: `README.md`

**Step 1: In the "What You Get" table, add rows:**

| **Engagement Scorecard** | One-page board-ready HTML — verdict / 5 ratings / deployable list / quarterly remediation |
| **Per-Intervention Playbook** | Operator-handoff runbook with trigger, inputs, step-by-step, success criteria, decommission |

**Step 2: In "How It Works", under "Uploads — give the consultant your materials up-front", add a new subsection "Live scorecard during the engagement":**

> Every engagement workspace also creates a `scorecard.html` and a `data/` folder. Run `bash serve.sh` (or double-click `serve.cmd` on Windows) and open `localhost:8765/scorecard.html` — sections render as each phase completes. Hit refresh after a phase finishes to see new data.

**Step 3: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
README: document scorecard, playbook, and live scorecard view

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 6.4: Final integration test on a sample engagement

**Step 1: Walk a synthetic engagement end-to-end against the sample fixture**

```bash
# Use the sample-engagement fixture as a stand-in for a real one
cd tests/fixtures/sample-engagement
bash ../../../scripts/init-workspace.sh /tmp/integration-test/acme

# Manually drop fixture JSONs into the new engagement
cp data/* /tmp/integration-test/acme/data/

# Serve and open
cd /tmp/integration-test/acme
python -m http.server 8770 &
SERVER_PID=$!
sleep 1
echo "Open http://localhost:8770/scorecard.html"
echo "Verify: org name, verdict, 5 ratings, 3 deployable rows, 3 remediation entries"
read
kill $SERVER_PID
cd -
rm -rf /tmp/integration-test
```

**Step 2: If anything is wrong, fix the relevant skill or template and create a fixup commit.**

**Step 3: No new commit needed if the test passes** — Phase 6 is complete with the previous commits.

---

## Acceptance criteria (whole plan)

The plan is complete when:

1. `feat/scorecard-and-playbooks` branch contains all commits from Phases 1-6.
2. A fresh engagement created via `init-workspace.sh` has `data/`, `scorecard.html`, `serve.sh`, `serve.cmd` scaffolded.
3. Running `python -m http.server` in the engagement folder and opening `scorecard.html` renders "pending" placeholders before any phase runs and progressively renders sections as phase JSONs appear.
4. `doi-scorecard` skill produces `data/scorecard.json` that validates against `scripts/_config/output-schemas/scorecard.json`.
5. `doi-build` produces `playbook.md` per intervention with all template placeholders filled.
6. `doi-render` produces a self-contained `scorecard-handoff.html` that renders identically without a server.
7. `agents/doi-review/AGENT.md` loads checklists from `agents/doi-review/checklists/`, emits structured JSON findings, runs Plan Completion Audit between phases.
8. `scripts/_config/voice.md` referenced from at least four heavyweight phase skills.
9. `README.md` documents the new outputs.
10. All commits sign with the Claude Opus 4.7 trailer; no commits skip hooks or amend prior commits unless explicitly fixing a broken state.

---

## Notes for the executor

- **Each task is one commit.** If a task takes more than 30 minutes of work, split it.
- **Run the verification step before committing.** "Looks right" is not verification.
- **If a step's expected output doesn't match, stop and diagnose.** Do not proceed past a failed verification.
- **Voice rules apply to your own writing in skill files.** No em dashes, no AI vocabulary blocklist words, lead with the point.
- **The research report (`docs/research/gstack-grabs.md`) is the why.** When a task seems arbitrary, re-read it.
- **Skill body prose drafting:** use existing `skills/doi-roadmap/SKILL.md` and `skills/doi-build/SKILL.md` as voice references — match their cadence.
- **You may discover that an existing phase output already contains all the data needed for a new JSON schema.** If so, the JSON emission task is a serialization-only change, not a re-analysis. Document this in the commit message.
- **You may also discover that a JSON schema requires data the existing phase doesn't produce.** Stop, surface the gap to the user, and decide whether to: (a) extend the phase to produce it, (b) make the field optional in the schema, or (c) drop the field. Don't invent data.
