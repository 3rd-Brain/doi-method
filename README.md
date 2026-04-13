# DOI Method

**by [3rd Brain](https://3rdbrain.co)**

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-proprietary-red)
![Runs on Claude Code](https://img.shields.io/badge/runs%20on-Claude%20Code-blueviolet)

> A 10-phase AI readiness assessment methodology that runs inside Claude Code.

**No spreadsheets. No workshops. No guesswork.**

---

DOI (Digital Operations Institute) is a structured engagement methodology for assessing an organization's operations and building a concrete AI implementation roadmap — from maturity scoring through role verification, outcome mapping, friction analysis, and tiered recommendations.

Designed for consultants running AI readiness engagements with clients. Also works for operations teams assessing their own organization.

---

<!-- GRAPHIC: screenshot or short GIF of an active DOI engagement — phase prompt + structured output -->

---

## What the Client Walks Away With

| Output | Description |
|---|---|
| Maturity Score | Level 1–5 readiness rating with hard cap gate logic |
| Role Reality Check | Verified gap between documented roles and actual day-to-day work |
| Outcome Map | Solution-agnostic results per role, tagged to tasks |
| Task Classification | Every task rated on a 4-stage AI automation scale |
| Friction Tax | % of capacity lost to friction — by task, role, and department |
| Bottleneck Routing | People / Process / Tools classification for every high-friction task |
| Pillar Assessment | Evidence-backed foundational + advanced readiness scores |
| Implementation Roadmap | Tiered, sequenced plan with projected friction reduction |

---

## Quick Start

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh
```

Open Claude Code and run:

```
/doi-run
```

Claude guides you through every phase. Your client answers the questions.

### Requirements

- [Claude Code](https://claude.ai/code) — Anthropic's CLI
- Claude Max or Team subscription
- macOS or Linux (Windows via WSL)

---

## How It Works

DOI is a **skill system for Claude Code** — 10 phase-specific skills, an isolated critic agent, and 6 computation scripts, all wired together by a single orchestrator.

<!-- GRAPHIC: phase flow diagram (0 → 1 → 2 → ... → 9, with phase names) -->

| Phase | Command | What Happens |
|---|---|---|
| 0 | `/doi-intake` | Gather organization context and goals |
| 1 | `/doi-assess` | 30-question maturity checklist (Level 1–5) |
| 2 | `/doi-setup` | Set up departments, roles, gather materials |
| 3 | `/doi-verify` | Verify roles against actual day-to-day reality |
| 4 | `/doi-outcomes` | Map role-level results, success signals, task alignment |
| 5 | `/doi-roles` | Extract and classify tasks by AI automation potential |
| 6 | `/doi-friction` | Score friction across the Three C's → Friction Tax |
| 7 | `/doi-route` | Classify bottlenecks and route to intervention types |
| 8 | `/doi-pillars` | Score foundational and advanced readiness pillars |
| 9 | `/doi-roadmap` | Build the tiered implementation roadmap |

After each phase, the `/doi-review` critic agent checks the output before the next phase begins.

Individual phases can also be run standalone — useful for resuming mid-engagement or re-running a specific step.

---

## The Framework

**5 Maturity Levels** — from Information Silos (Level 1) to AI-Driven Automation (Level 5). Hard cap gate logic prevents inflated scoring.

**4-Stage AI Automation Scale** — from rule-based Automated Workflows (Stage 1) to full AI Coworkers with autonomous responsibility (Stage 4). Every task in the assessment gets classified here.

**The Three C's** — the outcomes DOI builds toward. They arrive in sequence: Consistency (Level 2) → Clarity (Level 3) → Capacity (Level 4+). Friction is measured against all three.

**People → Process → Tools** — DOI's sequencing principle. Fix people gaps first, then process, then tools. Bottleneck routing, pillar scoring, and roadmap tier sequencing all follow this order.

**Outcome Mapping** — Phase 4 surfaces what each role is actually supposed to produce, solution-agnostic. Tasks are tagged aligned, indirectly aligned, or unaligned. Unaligned tasks surface in the roadmap before any automation recommendations are made.

---

## Made by 3rd Brain

DOI Method is designed, built, and maintained by **[3rd Brain](https://3rdbrain.co)** — a digital operations consultancy that builds AI-native systems for growing businesses.

---

## Uninstall

```bash
rm -rf ~/.claude/skills/doi-*
rm -rf ~/.claude/agents/doi-review
rm -rf ~/.claude/scripts/doi/
```

---

*Proprietary. Copyright © 2026 3rd Brain DigiOps. All rights reserved.*
