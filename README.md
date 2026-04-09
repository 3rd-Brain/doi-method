# DOI Method

**Digital Operations Intelligence** — A multi-phase AI/automation readiness assessment methodology for Claude Code.

DOI walks organizations through a structured assessment: from initial maturity evaluation through role-level task analysis, friction measurement, bottleneck classification, and a tiered implementation roadmap. It's designed to be client-facing — the person being assessed drives the process with AI guidance.

## What It Does

1. **Assesses** organizational digital maturity (Level 1-5) with hard cap gates
2. **Verifies** that documented roles match actual day-to-day reality
3. **Maps** solution-agnostic business outcomes at the role level and tags tasks to those outcomes
4. **Classifies** every task by AI automation potential (4-stage framework)
5. **Measures** friction across the Three C's (Consistency, Clarity, Capacity) at task, role, and department levels (Friction Tax)
6. **Routes** bottlenecks through People → Process → Tools
7. **Produces** a tiered implementation roadmap with projected impact

## Quick Start

```bash
git clone https://github.com/3rd-Brain/doi-method.git
cd doi-method
./install-doi.sh
```

Then open Claude Code and type:

```
/doi-run
```

## Requirements

- Claude Code (Anthropic CLI)
- Claude Max or Team subscription
- macOS or Linux (Windows via WSL)

## The 10 Phases

| Phase | Skill | What It Does |
|---|---|---|
| 0 | `/doi-intake` | Gather organization context |
| 1 | `/doi-assess` | 30-question maturity checklist (Level 1-5) |
| 2 | `/doi-setup` | Set up departments, roles, gather materials + department outcomes |
| 3 | `/doi-verify` | Verify roles against actual day-to-day |
| 4 | `/doi-outcomes` | Map role-level results, success signals, task alignment |
| 5 | `/doi-roles` | Extract + classify tasks (4-stage AI framework, outcome-aware) |
| 6 | `/doi-friction` | Score friction (Three C's → Friction Tax) |
| 7 | `/doi-route` | Classify bottlenecks (People/Process/Tools, outcome-tagged) |
| 8 | `/doi-pillars` | Score foundational + advanced pillars |
| 9 | `/doi-roadmap` | Build outcome-weighted implementation roadmap |

Use `/doi-run` for the full orchestrated engagement, or invoke individual phases standalone.

## Components

- **11 skills** — orchestrator + 10 phase skills (including outcome mapping)
- **1 agent** — isolated critic (reviews every phase output)
- **6 scripts** — computation, scoring, state management

## Key Concepts

### The 5 Maturity Levels

| Level | Name | Description |
|---|---|---|
| 1 | Information Silos | Disconnected software, paper workflows, no real-time visibility |
| 2 | Integratable Cloud | Cloud-based tools adopted but not fully connected |
| 3 | Unified Data Layer | Integrated systems, single source of truth, automated data flows |
| 4 | Automated Workflow with Human-in-the-Loop | Deep automation for routine tasks, humans handle exceptions |
| 5 | AI-Driven Automation | AI handles complex decision-making, minimal manual oversight |

### The 4-Stage AI Framework

| Stage | Name | Autonomy |
|---|---|---|
| 1 | Automated Workflow | None (rule-based) |
| 2 | Agentic Tool | Low (single AI function) |
| 3 | Agentic Workflow | Medium (multi-step AI) |
| 4 | AI Coworker | High (full autonomy) |

### The Three C's

The outcomes DOI is building toward. They arrive in a chain — each is a prerequisite for the next:

| C | Manifests At | What Enables It |
|---|---|---|
| **Consistency** | Level 2 | Documented processes + tools that enforce data standards |
| **Clarity** | Level 3 | Unified data removes copy/paste; dashboards reflect reality |
| **Capacity** | Level 4+ | Automation handles routine tasks; 5-10x gains on key workflows |

> "Without Consistency, you can't have real Clarity. If your data is messy, your dashboards are misleading. Without Clarity, you can't confidently identify bottlenecks and unlock Capacity. You'd be scaling blind."

Phase 5 scores every task across these three dimensions. The Friction Tax is derived from those scores.

### Outcome Mapping

Phase 4 captures solution-agnostic results at the role level — what the role needs to produce for the people who depend on it, not the tasks or deliverables. Each outcome has a success signal ("how would you know it's working?") and measurement status.

Tasks are tagged to outcomes: aligned, indirectly aligned, or unaligned. This data flows through the rest of the engagement:
- Phase 5 skips microservice decomposition for unaligned tasks
- Phase 7 tags bottlenecks with the outcomes they block
- Phase 9 uses outcome alignment as a prioritization axis (20% weight)

The roadmap surfaces "Work That Lacks Defined Outcomes" before recommending what to automate, and "Outcome Gaps" after — results that matter but have no supporting process.

### Friction Tax

Percentage of operational capacity consumed by friction rather than productive output. Computed from Three C's scores at task → role → department levels.

### People → Process → Tools

DOI's core sequencing principle. Fix people gaps first, then process gaps, then tool gaps. Tools without process = automating chaos.

## Uninstall

```bash
rm -rf ~/.claude/skills/doi-*
rm -rf ~/.claude/agents/doi-review
rm -rf ~/.claude/scripts/doi/
```

## License

Proprietary. Copyright (c) 2026 3rd Brain DigiOps.
