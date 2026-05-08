# Turn Claude Into An AI Operations Consultant

**The Digital Operations Institute Method**

Most AI readiness tools give you a questionnaire and a score. DOI gives you a consultant: conversational intake, role verification, outcome mapping, task classification, friction analysis, and a sequenced implementation roadmap.

Built from 50+ client engagements at [3rd Brain](https://3rdbrain.co), DOI is packaged for **Claude Code** and **Claude Cowork**.

## The Official Experience

DOI is now **plugin-first**.

That means the official install and usage story is:
- Install DOI as a plugin
- Run one command everywhere: `/doi-method:doi-run`

If you uploaded DOI as a plugin and saw `Unknown command: /doi-run`, nothing was wrong with the methodology itself. Plugin installs are namespaced, so the correct command is:

```text
/doi-method:doi-run
```

---

## What You Get

| Deliverable | What It Is |
|---|---|
| **Maturity Score** | Level 1-5 readiness rating with hard cap gate logic |
| **Role Reality Check** | Verified gap between documented roles and actual day-to-day work |
| **Outcome Map** | Solution-agnostic results per role, tagged to every task |
| **Task Classification** | Every task rated on a 4-stage AI automation scale |
| **Friction Tax** | % of capacity lost to friction by task, role, and department |
| **Bottleneck Routing** | People / Process / Tools diagnosis for high-friction work |
| **Pillar Assessment** | Evidence-backed foundational + advanced readiness scores |
| **Implementation Roadmap** | Tiered, sequenced plan with projected friction reduction, dual-effort labels (human consultant vs. DOI pipeline) |
| **Engagement Scorecard** | One-page board-ready HTML — verdict, 5 readiness ratings (1–5), deployable Tier 1–2 list with quarterly assignments, remediation roadmap. Renders live in the browser as phases complete; can be re-baked into a self-contained handoff file. |
| **Per-Intervention Playbook** | Operator-handoff runbook produced per Phase 10 artifact: trigger, inputs, step-by-step instructions with success criteria, decommission section answering the three architect questions |
| **Working Artifacts** *(opt-in)* | Phase 10 produces shippable Skills, ICM folders, integration configs, SOPs — built one per week against the 3rd Brain Build Principles |

This is not a report someone reads and shelves. Every output feeds the next phase. And Phase 10 turns the roadmap into things you can actually use.

---

## Install

### Claude Code

#### Marketplace install

```text
/plugin marketplace add 3rd-Brain/AI-Operations-Consultant
/plugin install doi-method@doi-method
```

Then run:

```text
/doi-method:doi-run
```

#### Local clone install

```bash
git clone https://github.com/3rd-Brain/AI-Operations-Consultant.git
cd AI-Operations-Consultant
./install-doi.sh
```

`./install-doi.sh` now defaults to the **plugin install** path.

Then run:

```text
/doi-method:doi-run
```

### Claude Cowork

Upload the repo as a custom plugin, then run:

```text
/doi-method:doi-run
```

This is the recommended Cowork path because it includes:
- the shared DOI scripts
- the reviewer agent used in the full pipeline
- the exact same entrypoint and behavior as plugin installs in Claude Code

---

## Quick Start

Open Claude and type:

```text
/doi-method:doi-run
```

The consultant will:
1. Detect whether this is a new engagement or a resume
2. Run a consulting-style intake
3. Ask what you want out of the engagement
4. Route you to the right path

You do **not** have to run the full pipeline every time.

After intake, DOI can route you to:
- **Full engagement**: all phases across departments and roles
- **Maturity score only**: 30-question assessment
- **Single-role deep dive**: verification, outcomes, tasks, friction
- **Pillars snapshot**: evidence-backed readiness scoring
- **Consultative routing**: describe the situation and let DOI choose the path

---

## How To Use It

**Start a new engagement:**

```text
/doi-method:doi-run
```

**Resume an engagement:**
Use the same command again. DOI checks saved state, shows where you left off, and continues.

**Skip the front-door consultant:**
Advanced users can call namespaced phase skills directly. Example:

```text
/doi-method:doi-engage
```

**Pause or stop:**
Say `pause` or `stop` during the flow. State is saved.

**Human gates:**
After key phases, DOI shows the work and waits for approval before moving on.

---

## How It Works

The `doi-run` skill is the consultant front door. In plugin installs, you invoke it as `/doi-method:doi-run`.

```text
/doi-method:doi-run
    |
    +--> doi-intake
    |        |
    |        v
    |    context/ folder + company-profile.md
    |        |
    |        v
    +--> Routing Interview
             |
     +-------+---------+------------+---------------+
     |                 |            |               |
     v                 v            v               v
 doi-engage       doi-assess    role loop      doi-pillars
 (full pipeline)  (score only)  (one role)     (pillars only)
     |
     v
 Phase 1: doi-assess   --> [Critic] --> Gate
 Phase 2: doi-setup
    |
    +---- Per Role Loop ----+
    |  Phase 3: doi-verify   --> [Critic] --> Gate
    |  Phase 4: doi-outcomes --> [Critic] --> Gate
    |  Phase 5: doi-roles    --> [Critic] --> Gate
    |  Phase 6: doi-friction --> [Critic] --> Gate
    +-----------------------+
    |
 Phase 7: doi-route    --> [Critic] --> Gate
 Phase 8: doi-pillars  --> [Critic] --> Gate
 Phase 9: doi-roadmap  --> [Critic] --> Gate
    |
 Phase 10: doi-build (opt-in)
    +-- per Tier 1 intervention --+
    |  doi-builder produces       |
    |  artifact in build/{slug}/  |
    |  --> [Critic] --> Gate      |
    |  --> Operator demos         |
    |  --> Comes back, next       |
    +-----------------------------+
    |
 --> Done
```

After each critical phase, an independent **critic agent** reviews the output in isolation before the next phase begins.

### Uploads — give the consultant your materials up-front

Every engagement workspace creates an `_uploads/` folder:

```text
<engagement>/
  _uploads/
    general/                  # org charts, P&Ls, decks, prior assessments
    tool-exports/             # CRM dumps, Zapier exports, integration screenshots, API docs
    {dept-slug}/              # department-scoped materials
      {role-slug}/            # role-scoped materials (job descriptions, SOPs, day-in-life docs)
    MANIFEST.md               # provenance ledger every phase appends to
```

Drop files in before, during, or between sessions. The relevant phases scan and ingest:

- `doi-intake` reads `_uploads/general/` to inform interview questions.
- `doi-setup` ingests `_uploads/{dept}/{role}/` into role materials.
- `doi-verify` checks `_uploads/` before asking for files when system access is blocked.
- `doi-roles` reads `_uploads/tool-exports/` before web search — operator-provided exports beat vendor marketing.

`MANIFEST.md` is the provenance trail. The critic uses it to verify no invented data.

### Live scorecard during the engagement

Every engagement workspace also creates a `scorecard.html` and a `data/` folder. Run `bash serve.sh` (or double-click `serve.cmd` on Windows) and open `localhost:8765/scorecard.html` — sections render "pending" until each phase JSON drops into `data/`. Hit refresh after each phase to see new content.

```text
<engagement>/
  scorecard.html              # Pre-built one-pager; reads ./data/*.json via fetch
  serve.sh / serve.cmd        # python -m http.server convenience
  data/
    _index.json               # phase status registry
    scorecard.json            # written by doi-scorecard (Phase 9 capstone)
```

When the engagement is done, run `doi-render` to produce a self-contained `scorecard-handoff.html` (data baked in, no server needed) for sharing with stakeholders or board members via email or Slack.

### 3rd Brain Build Principles

DOI's recommendations are constrained by a constructive doctrine in `scripts/_config/3rd-brain-build-principles.md`:

1. Frontend-first for apps
2. Solo-agent-first for workflows
3. Ship every week
4. Single agent until proven otherwise
5. ICM and folders before infrastructure
6. Start with what we have built
7. Demo before doc + the three architect questions (state owner, feedback signal, deletion impact)

Phases 5, 7, 9, and 10 enforce these. The critic flags violations.

### Phase 10 — Build (opt-in)

After the roadmap is approved, `doi-build` produces working artifacts per Tier 1 intervention:

- Tools+Stage 1 → ICM folder + connector config (Zapier/Make/n8n JSON)
- Tools+Stage 2 → single Claude Skill
- Tools+Stage 3 → ICM multi-stage folder, file-based by default
- Tools+Stage 4 → refused by default; re-routed to Stage 3 unless overridden with measured success
- Process bottleneck → SOP + checklist
- People bottleneck → training brief + role description

Each build ships in one week, gets demoed by the operator, and only then does the next one start. `build/{intervention-slug}/` carries the artifact + `BUILD-NOTES.md` (architect-question answers + principle compliance) + `SHIP-CHECKLIST.md` (concrete demo steps).

---

## Why This Is Different

**It is a consultant, not a questionnaire.** DOI starts with intake, then routes to the path that actually answers the user's question.

**It assesses from the inside out.** It works department by department and role by role, not from surface-level assumptions.

**It has a critic.** Critical outputs are reviewed independently before the engagement advances.

**The intake is real.** Phase 0 is a seven-section consulting interview that grounds every later phase.

**It is built from client work.** This methodology was refined through real consulting engagements, not invented in a vacuum.

---

## The Framework

**5 Maturity Levels**
From Information Silos (Level 1) to AI-Driven Automation (Level 5), with hard-cap gate logic to prevent inflated scoring.

**4-Stage AI Automation Scale**
Every task is classified from Stage 1 (Rule-Based Workflow) through Stage 4 (AI Coworker).

**The Three Cs**
Consistency, Clarity, Capacity. They arrive in sequence.

**People -> Process -> Tools**
The sequencing principle behind DOI's diagnosis and roadmap.

**Outcome Mapping**
DOI distinguishes work that serves a defined result from work that is merely habitual, unmeasured, or unaligned.

The deeper framework and case thinking behind DOI are documented in the [Digital Operations Playbook](https://digitalopsplaybook.com).

---

## Advanced And Legacy Installs

These paths still exist, but they are **not** the default public install story.

### Standalone Claude Code skills

If you explicitly want bare `/doi-run` instead of plugin mode:

```bash
./install-doi.sh --standalone
```

Then use:

```text
/doi-run
```

### Cowork `.skill` imports

If you explicitly want direct Cowork skill imports instead of a plugin upload:

1. Build or download the `.skill` files from `dist/cowork/`
2. Import them in Cowork
3. Use `/doi-run`

This is an advanced path and is less complete than the plugin install because it does not include the bundled reviewer agent.

Full install details live in [INSTALL.md](INSTALL.md).

---

## Uninstall

**Claude Code plugin:** `/plugin uninstall doi-method@doi-method`

**Claude Code standalone:** `rm -rf ~/.claude/skills/doi-* ~/.claude/agents/doi-review ~/.claude/scripts/doi/`

**Cowork plugin:** remove DOI from Customize -> Plugins

**Cowork skills:** remove each `doi-*` skill from Skills -> Manage

---

## Made by 3rd Brain

DOI Method is designed and maintained by [3rd Brain](https://3rdbrain.co), a digital operations consultancy building AI-native operating systems for growing businesses.

*Licensed under GPL-3.0. Copyright 2026 3rd Brain DigiOps.*
