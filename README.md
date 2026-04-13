# DOI Method

**by [3rd Brain](https://3rdbrain.co)**

> *Digital Operations Intelligence — a structured engagement methodology for assessing and implementing AI automation inside organizations.*

---

DOI walks your clients through a complete AI readiness engagement — from initial maturity scoring through role-level task analysis, outcome mapping, friction measurement, and a tiered implementation roadmap. It runs entirely inside Claude Code, guided by AI, driven by the client.

No spreadsheets. No workshops. No guesswork.

---

## What It Delivers

| Phase | What Happens |
|---|---|
| Maturity Assessment | Score the organization on 30 criteria across 5 maturity levels |
| Role Verification | Uncover what roles actually do vs. what's on paper |
| Outcome Mapping | Define what each role is supposed to produce — solution-agnostic |
| Task Classification | Classify every task by AI automation potential (4 stages) |
| Friction Scoring | Measure Consistency, Clarity, and Capacity friction at task → department level |
| Bottleneck Routing | Classify causes (People / Process / Tools) and route to interventions |
| Pillar Assessment | Score foundational and advanced readiness pillars with evidence |
| Implementation Roadmap | Tiered, sequenced plan with projected friction reduction and outcome impact |

---

## Quick Start

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh
```

Open Claude Code and start a new engagement:

```
/doi-run
```

### Requirements

- [Claude Code](https://claude.ai/code) (Anthropic CLI)
- Claude Max or Team subscription
- macOS or Linux (Windows via WSL)

---

## How It Works

DOI is a **skill system for Claude Code** — a set of phase-specific prompts, scoring scripts, and an isolated critic agent that together run a structured client engagement.

```
/doi-run              ← Full orchestrated engagement (recommended)

/doi-intake           ← Phase 0: Gather org context
/doi-assess           ← Phase 1: 30-question maturity checklist
/doi-setup            ← Phase 2: Department + role setup
/doi-verify           ← Phase 3: Role verification
/doi-outcomes         ← Phase 4: Outcome mapping
/doi-roles            ← Phase 5: Task extraction + classification
/doi-friction         ← Phase 6: Friction scoring (Three C's → Friction Tax)
/doi-route            ← Phase 7: Bottleneck classification
/doi-pillars          ← Phase 8: Foundational + advanced pillar scoring
/doi-roadmap          ← Phase 9: Implementation roadmap
```

Each phase produces structured output files. The `/doi-review` critic agent reviews every phase before proceeding.

---

## The Framework

### 5 Maturity Levels

| Level | Name | What It Looks Like |
|---|---|---|
| 1 | Information Silos | Disconnected software, paper workflows, no real-time visibility |
| 2 | Integratable Cloud | Cloud tools adopted but not connected or standardized |
| 3 | Unified Data Layer | Integrated systems, single source of truth, automated data flows |
| 4 | Automated Workflow | Deep automation for routine tasks; humans handle exceptions |
| 5 | AI-Driven Automation | AI handles complex decisions; minimal manual oversight |

### 4-Stage AI Automation Framework

| Stage | Name | Autonomy | Description |
|---|---|---|---|
| 1 | Automated Workflow | None | Rule-based. Zapier, Make, CRM logic. No AI. |
| 2 | Agentic Tool | Low | Single AI function: one input → AI → one output |
| 3 | Agentic Workflow | Medium | Multi-step AI with human checkpoints |
| 4 | AI Coworker | High | Full role ownership. Proactive. Minimal oversight. |

### The Three C's

The outcomes DOI is building toward. They arrive in sequence — each is a prerequisite for the next:

| C | Manifests At | What Produces It |
|---|---|---|
| **Consistency** | Level 2 | Documented processes + tools that enforce data standards |
| **Clarity** | Level 3 | Unified data removes copy/paste; dashboards reflect reality |
| **Capacity** | Level 4+ | Automation handles routine tasks; 5-10x gains on key workflows |

> "Without Consistency, you can't have real Clarity. If your data is messy, your dashboards are misleading. Without Clarity, you can't confidently identify bottlenecks and unlock Capacity. You'd be scaling blind."

### Outcome Mapping

Phase 4 captures what each role is supposed to *produce* — not tasks, not deliverables, but actual results. Every task is then tagged: aligned, indirectly aligned, or unaligned to those results.

This flows through the rest of the engagement: unaligned tasks are surfaced in the roadmap under *Work That Lacks Defined Outcomes*; bottlenecks are tagged with the outcomes they block; roadmap prioritization weights outcome alignment at 20%.

### Friction Tax

The percentage of operational capacity consumed by friction instead of productive output. Computed from Three C's scores at task → role → department levels. The roadmap projects how much friction each intervention recovers.

### People → Process → Tools

DOI's sequencing principle. Fix people gaps first, then process, then tools. Tools without process = automating chaos. This order is enforced across bottleneck routing, pillar scoring, and roadmap tier sequencing.

---

## Components

- **11 skills** — orchestrator + 10 phase skills
- **1 agent** — isolated critic that reviews each phase output
- **6 scripts** — scoring, computation, state management, prerequisite checking

---

## Made by 3rd Brain

DOI Method is designed, built, and maintained by **[3rd Brain](https://3rdbrain.co)** — a digital operations consultancy that builds AI-native systems for growing businesses.

If you're using this for client engagements or want to license it commercially, reach out at **hello@3rdbrain.co**.

---

## Uninstall

```bash
rm -rf ~/.claude/skills/doi-*
rm -rf ~/.claude/agents/doi-review
rm -rf ~/.claude/scripts/doi/
```

---

*Proprietary. Copyright © 2026 3rd Brain DigiOps. All rights reserved.*
