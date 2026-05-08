---
name: doi-intake
description: "Use when starting a new DOI engagement. Runs a consulting-style interview that builds a rich context folder — not a 5-field form. Gathers organization basics, current state, history with automation, tech stack, goals, constraints, and stakeholders. Creates the engagement workspace, registers it, and writes the context folder that every downstream phase reads from. Cannot assess, score, or recommend."
user-invocable: true
license: GPL-3.0
metadata:
  version: 2.0.0
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

# doi-intake

## 1. Overview

Phase 0 of the DOI Method. This is a **consulting-style interview**, not a form. The goal is to build a rich `context/` folder that every downstream phase (assess, setup, verify, outcomes, etc.) reads from to ground its analysis.

A thin intake produces thin analysis. A thorough intake produces the kind of assessment that reads like it came from a senior consultant who spent a day in the business. Treat this phase accordingly — the context folder is what separates DOI output from a generic AI-readiness questionnaire.

### Role Constraints

- CAN: ask questions, collect information, follow threads the operator opens, write context files
- CANNOT: assess maturity, suggest levels, recommend tools, score anything, offer opinions on their setup

If the operator asks for your take mid-interview ("do you think that's high?"), defer: "I'm just collecting right now — we'll get to assessment in the next phase."

## 2. Session Resolution

Standard DOI session resolution:

1. Check `$DOI_REGISTRY`.
2. If 0 entries → new engagement, proceed with intake.
3. If entries exist → typically doi-run invokes this skill only for new engagements; if this skill is invoked standalone with existing entries, confirm: "There are existing engagements. Start a new one, or resume an existing one via `/doi-run`?"

## 3. Interview Structure

The interview runs in **seven sections**, in order. Each section has a minimum scope (what must be covered before moving on) and a recommended opening. Follow the thread the operator opens — don't march through a rigid script. But do not leave a section without hitting its minimum scope.

After each section completes, write the section file (see Section 5 — Output Format) before moving to the next. This way a paused intake keeps the progress it earned.

### Pre-section ritual: scan `_uploads/general/` before each section

Before opening Section 1, call `$DOI_SCRIPTS/init-workspace.sh <engagement-folder>` so `_uploads/general/` exists. If `doi-run` handed you a list of files the operator named in the pre-intake scan, copy them into `_uploads/general/` now.

Before each of the seven sections, run:

```bash
$DOI_SCRIPTS/scan-uploads.sh <engagement-folder> general
```

For any file in the listing whose name or content plausibly covers the section's scope (e.g., `org-chart.pdf` for Section 1, prior assessment decks for Section 3, tech inventory spreadsheets for Section 4), read it before asking questions. Then say to the operator: "I see [filename] in your uploads — does that cover [topic], or should I still ask?"

**Rules for upload usage:**
- Use uploads to inform questions, not replace them. Files capture facts; the interview captures motivation, constraints, and reality.
- Mark anything inferred from a file (vs. stated by the operator) with `(inferred from <filename>)` in the section files.
- After ingesting a file, append a row to `_uploads/MANIFEST.md`:
  - `| _uploads/general/<file> | 0 | doi-intake | <section file>.md | YYYY-MM-DD |`
- If a file's relevance is unclear, ask before mining it. Do not assume.

At the end of every section, ask: **"Anything else to add before we move on?"** Then: **"Continue to [next section name], or pause here?"**

### Section 1 — Organization Basics

**Minimum scope to cover:**
- Legal / commonly-used organization name
- Industry and sub-vertical
- Headcount (approximate) and department structure
- Geographic footprint (single office, distributed, fully remote)
- Revenue / lifecycle stage if the operator is comfortable sharing (pre-seed, growing, mature, PE-owned, etc.)

**Opening:** "Start me at the top — what's the organization, what do you do, and how big is the team?"

**Write to:** `context/organization.md`

### Section 2 — Current State & Pain

**Minimum scope to cover:**
- Top 3 operational pain points, in the operator's own words (quote them)
- What's actually working well (important — people who only articulate pain have a distorted picture)
- What changed recently (last 6-12 months) — new leadership, new product, layoffs, acquisition, big contract, etc.

**Opening:** "Tell me what's actually breaking day to day. What are the three things that would make the biggest difference if they got fixed?"

**Follow-ups to hit the "working well" angle if it doesn't come up naturally:** "On the flip side — what's going right? What do you not want me to mess with?"

**Write to:** `context/current-state.md`

### Section 3 — History with AI / Automation

**Minimum scope to cover:**
- What has the organization already tried? (tools adopted, consultants hired, internal projects)
- What stuck and what fell off?
- For anything that fell off — why? (scope creep, wrong vendor, no champion, ROI didn't land, change fatigue, etc.)
- Current appetite for new tools/process — eager, cautious, burned out?

**Opening:** "What have you already tried on the AI or automation side? I want to know what stuck, what didn't, and why."

**Write to:** `context/history.md`

### Section 4 — Tech & Data Baseline

**Minimum scope to cover:**
- Primary systems of record (CRM, ERP, project management, knowledge base, etc.) — by name
- Communication stack (Slack/Teams/email-first, meeting tooling, async vs. sync culture)
- Data maturity — is data centralized, siloed, spreadsheets, clean, dirty?
- Integration posture — is stuff wired together, or islands?
- Any existing AI tooling in production (Claude/ChatGPT seats, custom builds, vendor AI features)

**Opening:** "Walk me through your tech stack at the macro level. What are the 3-5 systems that, if they went down, would stop the business?"

**Write to:** `context/stack.md`

### Section 5 — Goals & Success Criteria

**Minimum scope to cover:**
- **Primary goal for this assessment — ONE forced choice** (if the operator lists multiple, say "Those are all valid, but we rank everything against ONE primary goal. Which matters most *right now*?")
- What "success" looks like at 30 / 90 / 180 days after the engagement ends
- Secondary goals (can list several here — only the primary is forced single-choice)
- Timeline pressure — is there a deadline driving this, or is it open-ended?

**Opening:** "If we do this right, what changes in the business? Six months from now, what does good look like?"

**Write to:** `context/goals.md`

### Section 6 — Constraints

**Minimum scope to cover:**
- Budget posture — what's the rough envelope, and is it committed, approved, or aspirational?
- Capacity — who on the team has bandwidth to actually implement recommendations? How much time per week?
- Political / cultural constraints — what can't be touched? (e.g., founder pet process, legal/compliance locks, union contracts, major client contract terms)
- Change tolerance — can the org absorb a lot of change at once, or does it need to be paced?

**Opening:** "What are the hard fences around this? Budget, people, politics, things that are off-limits — what should I know going in?"

**Write to:** `context/constraints.md`

### Section 7 — Stakeholders

**Minimum scope to cover:**
- **Champion** — who is driving this engagement, and what's their stake in it?
- **Decision-makers** — who signs off on investments and changes that come out of this?
- **Skeptics** — who's likely to resist, and why?
- **End users** — whose day-to-day actually changes if recommendations are implemented?

**Opening:** "Tell me about the people. Who's championing this, who signs the checks, who's going to push back, and whose work actually changes when we're done?"

**Write to:** `context/stakeholders.md`

## 4. Close-Out & Confirmation

After Section 7:

1. Write `company-profile.md` (see Output Format) — the executive summary that pulls the highlights from each section file.
2. Present the full intake back to the operator:
   > "Here's the picture I have: [3-paragraph summary covering org + goal + constraints + stakeholders]. Anything missing or off?"
3. If the operator adds or corrects anything, update the relevant `context/` file AND `company-profile.md` before marking intake complete.
4. Confirm save: "I'll save this as the intake for [org] and hand you back to the consultant for the routing step."
5. Call `$DOI_SCRIPTS/init-workspace.sh <folder>` if not already done. This also scaffolds the live scorecard infrastructure: `data/_index.json`, `scorecard.html`, and `serve.sh` / `serve.cmd`. Tell the operator they can run `bash serve.sh` (or double-click `serve.cmd` on Windows) and open `http://localhost:8765/scorecard.html` to see the engagement scorecard. Sections render "pending" until each phase JSON appears under `data/`; the operator hits browser refresh after each phase to see new content.
6. Write `.doi-state.md`.
7. Create or update `$DOI_REGISTRY`.

## 5. Output Format

### `company-profile.md` (executive summary — one page)

```markdown
# [Organization Name]

**Industry:** [industry] / [sub-vertical]
**Size:** [X employees] across [Y departments]
**Lifecycle Stage:** [stage]
**Geography:** [single office / distributed / remote]
**Date of Intake:** [YYYY-MM-DD]

## Primary Goal
[Single forced-choice goal from Section 5]

## What Success Looks Like
[30/90/180-day success markers]

## Top 3 Pain Points (verbatim)
1. "[quote]"
2. "[quote]"
3. "[quote]"

## Key Constraints
- [budget]
- [capacity]
- [political / cultural]

## Champion & Decision-Makers
- Champion: [name, role]
- Decision-makers: [names, roles]

## Critical Recent Changes
[what changed in the last 6-12 months]

## Open Questions Flagged for Later Phases
[anything the operator was unsure of or deferred — feed into Phase 3 verification]
```

### `context/` folder files

Each file is short, focused consulting notes — not essays. Use bullet points, direct quotes from the operator, and facts. If something is inferred vs. stated, mark it `(inferred)`.

**`context/organization.md`:**
```markdown
# Organization

## Name & DBA
## Industry & Sub-Vertical
## Headcount & Departments
## Geographic Footprint
## Lifecycle Stage
## Notes
[anything else the operator said about structure or identity]
```

**`context/current-state.md`:**
```markdown
# Current State

## Top 3 Pain Points
1. [pain + operator quote]
2. [pain + operator quote]
3. [pain + operator quote]

## What's Working Well
- [item]

## Recent Changes (Last 6-12 Months)
- [change + when + why it matters]
```

**`context/history.md`:**
```markdown
# History with AI / Automation

## What They've Tried
| Initiative | When | Outcome | Why |
|---|---|---|---|

## Current Appetite
[eager / cautious / burned out — and why]
```

**`context/stack.md`:**
```markdown
# Tech & Data Baseline

## Systems of Record
- [tool] — [what it's for]

## Communication Stack
## Data Maturity
## Integration Posture
## Existing AI Tooling
```

**`context/goals.md`:**
```markdown
# Goals

## Primary Goal (forced single choice)
[goal]

## Success at 30 / 90 / 180 Days
## Secondary Goals
## Timeline Pressure
```

**`context/constraints.md`:**
```markdown
# Constraints

## Budget
## Capacity
## Political / Cultural
## Change Tolerance
```

**`context/stakeholders.md`:**
```markdown
# Stakeholders

## Champion
## Decision-Makers
## Skeptics
## End Users
```

### `.doi-state.md`

```yaml
---
organization: [name]
industry: [industry]
folder: [absolute path]
phase: Phase 0
current_department: 
current_role: 
maturity_level: 
status: active
started: [YYYY-MM-DD]
updated: [YYYY-MM-DD]
roles_completed: []
roles_remaining: []
departments_completed: []
departments_remaining: []
---
```

## 6. Constraints

- This is an interview, not a form. Follow threads the operator opens. Don't march through a rigid script.
- Do NOT leave a section without hitting its minimum scope — confirm before moving on.
- Write each `context/` section file before advancing to the next section (keeps paused intakes useful).
- Primary goal in Section 5 is a forced SINGLE choice — always.
- Do NOT assess, score, recommend, or offer opinions mid-interview. Defer to later phases.
- Do NOT make assumptions about departments or roles that the operator didn't state. If you infer something to write it down, mark it `(inferred)`.
- Confirm all gathered info at the close-out before saving.
- Use absolute paths for the engagement folder in state and registry.
- If the operator seems rushed and wants to skip sections, push back once: "Skipping this usually makes the downstream analysis worse. A thin intake produces thin output. Still want to skip?"

## 7. Common Mistakes

| Mistake | Fix |
|---|---|
| Treating intake as a 5-question form | It's an interview — follow the operator's threads. Minimum scope per section, not a rigid script. |
| Accepting multiple primary goals | Force single choice — "Which ONE matters most *right now*?" |
| Skipping "what's working" in Section 2 | People who only articulate pain have a distorted picture. Always ask. |
| Skipping the history section | If you don't know what already failed and why, you'll recommend the same thing. |
| Writing assessments or scores | You're collecting, not evaluating. Defer to later phases every time. |
| Using relative paths | Engagement folder must be absolute in state and registry. |
| Inferring without flagging | If the operator didn't say it, mark it `(inferred)` so later phases can verify. |
| Bundling all files at the end | Write each section file as it completes so a paused intake holds its progress. |
