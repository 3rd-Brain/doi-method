# Turn Claude Into A Top 1% AI Operations Consultant

**The Digital Operations Institute Method**

Most AI readiness tools give you a questionnaire and a score. The DOI Method gives you a structured engagement — maturity scoring, role verification, outcome mapping, task classification, friction analysis, and a sequenced implementation roadmap. The same methodology behind 50+ client engagements at [3rd Brain](https://3rdbrain.co), packaged as a Claude plugin.

Install it. Type `/doi-run`. Your assessment starts.

---

## What You Walk Away With

| Deliverable | What It Is |
|---|---|
| **Maturity Score** | Level 1-5 readiness rating with hard cap gate logic — no inflated scores |
| **Role Reality Check** | Verified gap between documented roles and actual day-to-day work |
| **Outcome Map** | Solution-agnostic results per role, tagged to every task |
| **Task Classification** | Every task rated on a 4-stage AI automation scale |
| **Friction Tax** | % of capacity lost to friction — by task, role, and department |
| **Bottleneck Routing** | People / Process / Tools classification for every high-friction task |
| **Pillar Assessment** | Evidence-backed foundational + advanced readiness scores |
| **Implementation Roadmap** | Tiered, sequenced plan with projected friction reduction |

This is not a report someone reads and shelves. Every output feeds the next phase, and the final roadmap is sequenced by impact — what to fix first, what to automate, and what to leave alone.

---

## Installation

### Claude Cowork (recommended)

Search for **DOI Method** in the Cowork plugin marketplace, or install from source:

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh
```

Installs as a self-contained plugin at `~/.claude/plugins/doi-method/`.

### Claude Code CLI

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh --legacy

```

Copies skills, agents, and scripts to your `~/.claude/` directories.
---

## Quick Start

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh
```

Open Claude Code and type:

```
/doi-run
```

Claude picks up the methodology and walks you through every phase.

---

## How to Use It

**Start a new engagement:** Type `/doi-run`. Claude asks for the organization name and goals, creates a workspace, and begins Phase 0.

**Resume an engagement:** Type `/doi-run` again. Claude finds the existing engagement and picks up where you left off.

**Run a single phase:** Each phase has its own command (`/doi-intake`, `/doi-assess`, `/doi-setup`, etc.) if you need to re-run or skip ahead.

**Pause or stop:** Say "pause" or "stop" at any point. State is saved. Come back tomorrow, next week — the engagement holds.

**Human gates:** After key phases, Claude presents its work and waits for your approval before moving on. You review, edit, or push back. Nothing advances without your sign-off.

---

## How It Works

DOI Method is a skill system — 10 phase-specific skills, an isolated critic agent, and 6 computation scripts, wired together by a single orchestrator. Each phase has one job. Output from one phase becomes input to the next.

```
Phase 0: Intake --> Phase 1: Assess --> [Critic] --> Gate
                                                       |
                    Phase 2: Setup (per department) <---+
                        |
         +--------------+-- Per Role Loop --------------+
         |              v                                |
         |  Phase 3: Verify --> [Critic] --> Gate        |
         |  Phase 4: Outcomes --> [Critic] --> Gate      |
         |  Phase 5: Roles --> [Critic] --> Gate         |
         |  Phase 6: Friction --> [Critic] --> Gate      |
         |              |                                |
         +--------------+--------------------------------+
                        v
         Phase 7: Route --> [Critic] --> Gate
         Phase 8: Pillars --> [Critic] --> Gate
         Phase 9: Roadmap --> [Critic] --> Gate --> Done
```

| Phase | Command | What Happens |
|---|---|---|
| 0 | `/doi-intake` | Gather organization context and goals |
| 1 | `/doi-assess` | 30-question maturity checklist — determines Level 1-5 |
| 2 | `/doi-setup` | Define departments, roles, and department-level outcomes |
| 3 | `/doi-verify` | Probe actual day-to-day work vs. what is documented |
| 4 | `/doi-outcomes` | Map what each role is supposed to produce, tag every task |
| 5 | `/doi-roles` | Classify every task on a 4-stage AI automation scale |
| 6 | `/doi-friction` | Score friction across the Three Cs — calculate Friction Tax |
| 7 | `/doi-route` | Classify bottlenecks: People, Process, or Tools |
| 8 | `/doi-pillars` | Score foundational + advanced operational readiness |
| 9 | `/doi-roadmap` | Build the tiered, sequenced implementation plan |

After each critical phase, an independent **critic agent** reviews the output in isolation — no access to the conversation, just the raw work. It flags methodology violations, scoring inconsistencies, and missing data before the next phase begins.

---

## Why This Is Different

**It is a methodology, not a questionnaire.** Most AI readiness tools ask you 20 questions and hand you a score. The DOI Method runs a full engagement — it verifies what your team actually does, maps what they are supposed to produce, classifies every task, measures friction, and builds a roadmap sequenced by impact.

**It assesses from the inside out.** No surface-level scans. The method works with your people, department by department, role by role. It catches the gap between how work is documented and how it actually happens.

**It has a critic.** After every critical phase, an independent reviewer tears the work apart in isolation — no conversation context, just the raw output. Methodology violations, scoring inconsistencies, and blind spots get flagged before anything moves forward.

**Built from 50+ client engagements.** This is not a framework designed in a vacuum. It is the methodology behind the [3rd Brain](https://3rdbrain.co) consulting practice, refined across real organizations over nearly four years.

---

## The Framework

**5 Maturity Levels** — from Information Silos (Level 1) to AI-Driven Automation (Level 5). Hard cap gate logic prevents inflated scoring — you cannot test into Level 3 if you are missing Level 2 fundamentals.

**4-Stage AI Automation Scale** — every task in the assessment gets classified: Stage 1 (Rule-Based Workflows) through Stage 4 (AI Coworkers with autonomous responsibility). This is how the roadmap knows what to recommend.

**The Three Cs** — Consistency, Clarity, Capacity. They arrive in sequence. You cannot unlock Capacity gains until Consistency and Clarity are in place. Friction is measured against all three.

**People > Process > Tools** — the sequencing principle behind every recommendation. Fix people gaps first, then process, then tools. The roadmap tiers follow this order because the reverse never works.

**Outcome Mapping** — Phase 4 surfaces what each role is actually supposed to produce, solution-agnostic. Tasks get tagged as aligned, indirectly aligned, or unaligned. Unaligned tasks are flagged before any automation is recommended — because automating the wrong work faster is not a win.

### Go Deeper

The full methodology, frameworks, and case thinking behind the DOI Method are documented in the [**Digital Operations Playbook**](https://digitalopsplaybook.com). If you want to understand the why behind every phase, start there.

---

## Made by 3rd Brain

DOI Method is designed, built, and maintained by [**3rd Brain**](https://3rdbrain.co) — a digital operations consultancy that builds AI-native operating systems for growing businesses.

## Uninstall

**Cowork plugin:** `rm -rf ~/.claude/plugins/doi-method`

**Legacy install:** `rm -rf ~/.claude/skills/doi-* ~/.claude/agents/doi-review ~/.claude/scripts/doi/`

---

*Licensed under GPL-3.0. Copyright 2026 3rd Brain DigiOps. All rights reserved.*
