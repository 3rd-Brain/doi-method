# DOI Method

**Digital Operations Intelligence** — A multi-phase AI/automation readiness assessment methodology for Claude Code.

DOI walks organizations through a structured assessment: from initial maturity evaluation through role-level task analysis, friction measurement, bottleneck classification, and a tiered implementation roadmap. It's designed to be client-facing — the person being assessed drives the process with AI guidance.

## What It Does

1. **Assesses** organizational digital maturity (Level 1-5) with hard cap gates
2. **Verifies** that documented roles match actual day-to-day reality
3. **Classifies** every task by AI automation potential (4-stage framework)
4. **Measures** friction at task, role, and department levels (Friction Tax)
5. **Routes** bottlenecks through People → Process → Tools
6. **Produces** a tiered implementation roadmap with projected impact

## Quick Start

```bash
git clone <repo-url>
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

## The 9 Phases

| Phase | Skill | What It Does |
|---|---|---|
| 0 | `/doi-intake` | Gather organization context |
| 1 | `/doi-assess` | 30-question maturity checklist (Level 1-5) |
| 2 | `/doi-setup` | Set up departments, roles, gather materials |
| 3 | `/doi-verify` | Verify roles against actual day-to-day |
| 4 | `/doi-roles` | Extract + classify tasks (4-stage AI framework) |
| 5 | `/doi-friction` | Score friction (Three C's → Friction Tax) |
| 6 | `/doi-route` | Classify bottlenecks (People/Process/Tools) |
| 7 | `/doi-pillars` | Score foundational + advanced pillars |
| 8 | `/doi-roadmap` | Build tiered implementation roadmap |

Use `/doi-run` for the full orchestrated engagement, or invoke individual phases standalone.

## Components

- **10 skills** — orchestrator + 9 phase skills
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

### Friction Tax

Percentage of operational capacity consumed by friction rather than productive output. Measured at task → role → department levels.

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
