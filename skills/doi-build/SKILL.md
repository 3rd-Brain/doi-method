---
name: doi-build
description: "Use when constructing operator-ready artifacts (Claude Skills/Agents, ICM folder structures, integration configs, SOPs) from an approved DOI roadmap. Phase 10 of the DOI Method. Reads the roadmap, picks Tier 1 interventions by default, dispatches doi-builder subagents per intervention, runs critic review on artifacts, gates per-intervention so the operator can ship and test before building the next one. Cannot invent interventions, change roadmap priorities, or build ungated Stage 3-4 work."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-05-07
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

# doi-build

## 1. Overview

> **Voice:** Read `scripts/_config/voice.md` before drafting any user-facing output. Verification rule, vocabulary blocklist, Confusion Protocol all apply.

Phase 10 of the DOI Method — the first phase that **produces working artifacts** for the operator's organization, not analysis documents. doi-build reads the approved `roadmap.md`, walks the operator through which interventions to build (default: Tier 1 only), dispatches a `doi-builder` subagent per intervention, runs critic review on each artifact, and gates per-intervention so the operator can actually ship and test before the next one is built.

**This is the phase that makes Principle 3 — Ship every week — real.** Each artifact is built to the **1-week shippable subset** declared in the roadmap, not the eventual full design. The operator demos it, uses it, learns from it, and only then does the next artifact get built.

doi-build itself is an orchestrator — it does NOT generate code. The `doi-builder` subagent generates artifacts; doi-build sequences, gates, and validates.

### Role Constraints

- CAN: Read the roadmap, ask the operator which interventions to build, dispatch builder subagents, validate artifacts, manage per-intervention gates
- CANNOT: Invent interventions not in the roadmap, change roadmap priorities, build Stage 3-4 work without an explicit override when maturity < Level 3, build Stage 4 work without measured Stage 3 success cited

### Session Resolution

Standard DOI session resolution.

## 2. Prerequisites

Call `$DOI_SCRIPTS/check-prerequisites.sh 10 <engagement-folder> <dept-slug>`

Required:
- `roadmap.md` must exist for the department (Phase 9 complete)
- `assessments/foundational.md` must exist (for Stage 3-4 gate enforcement)
- The roadmap must have passed its critic + human gate (do NOT build a roadmap that hasn't been approved)

Also reads:
- `company-profile.md` — primary goal context
- `assessments/maturity-assessment.md` — maturity level for Stage gate enforcement
- All `roles/*/verified-role.md`, `outcome-map.md`, `tasks/*.md`, `microservices/*.md` — every artifact-building subagent gets the relevant slice
- `_uploads/tool-exports/` and `roles/*/integration-research.md` — for real API/integration grounding
- `$DOI_SCRIPTS/_config/3rd-brain-build-principles.md` — the doctrine the builder must satisfy

## 3. Process

### Step 1: Read the roadmap and present the build menu

Read `roadmap.md`. Pull every Tier 1 intervention. For each, capture:
- Intervention name
- Bottleneck type (People / Process / Tools)
- Stage (1-4)
- 1-week shippable subset (Principle 3 declaration)
- The three architect questions (state / feedback / deletion impact)
- Build doctrine compliance flags
- Result advanced (R# or "operational efficiency only")
- Existing system extended (or "new — justification: ...")

Present to the operator:

> "You have **[N]** Tier 1 interventions in the roadmap. By default I'll build them in roadmap order, one at a time, with a gate after each so you can ship and test before I build the next.
>
> Ready to start with **[first intervention name]**? Or do you want to:
> - **Pick a different starting intervention** (any Tier 1)
> - **Build a Tier 2 intervention** (will require explicit override — Tier 2 is Strategic Investment, not Quick Win)
> - **Build a Tier 3 intervention** (BLOCKED if maturity < Level 3 — will only proceed with override)
> - **Skip ahead** — show me the full Tier 1 list and let me pick"

If the operator overrides into Tier 2 or Tier 3, capture the override reason in `build/OVERRIDES.md` before proceeding. The override is logged for the critic.

### Step 2: Per-intervention build loop

For each selected intervention, in order:

#### 2a. Pre-build doctrine gate

Before dispatching the builder, verify the roadmap intervention satisfies the build doctrine:

| Check | Required for build to proceed |
|---|---|
| 1-week shippable subset declared | Yes — if absent, abort and surface to operator |
| Demo definition with user touch | Yes — if internal-only or vague, abort |
| All three architect questions answered | Yes — if any missing, abort |
| Existing system tag (extend-existing / new-system) | Yes — if missing, abort |
| Stage 3 with >1 microservice | Microservice files must cite measured bottleneck |
| Stage 4 | Refused unless override + measured Stage 3 success cited |

If any check fails, do NOT dispatch. Tell the operator: "**[intervention]** is missing **[X]** in the roadmap. The roadmap should be revised before this gets built. Want me to (a) skip this intervention, (b) pause Phase 10 so you can revise the roadmap, or (c) override and build anyway with the gap documented?"

#### 2b. Match intervention → builder template

| Intervention shape | Builder produces |
|---|---|
| Tools + Stage 1 | ICM folder + `CONTEXT.md` + numbered stage SOPs + connector config (Zapier/Make/n8n JSON, drawn from `integration-research.md`) |
| Tools + Stage 2 | Single Claude Skill (`SKILL.md` with prompt, tool list, KOODAR), or single function script |
| Tools + Stage 3 | ICM multi-stage folder with `CONTEXT.md` contracts per stage, `_config/`, `output/` handoffs. **File-based by default** (Principle 5). Postgres/queues only if intervention is tagged `infrastructure-justified` with file-failure mode cited. |
| Tools + Stage 4 | **Refused by default.** Re-routes to Stage 3 starting point. Builds only on operator override + measured Stage 3 success citation. |
| Process + any stage | Markdown SOP in ICM folder + checklist file. No code. |
| People + any stage | Training brief / role description doc. No automation. |

#### 2c. Dispatch the builder subagent

Spawn the `doi-builder` agent (defined in `agents/doi-builder/AGENT.md`). The contract:

**Inputs (passed to the subagent):**
- The intervention spec block (verbatim from the roadmap)
- The matched builder template name
- Engagement metadata: organization, department, role(s) involved
- Relevant context files: `verified-role.md`, `outcome-map.md`, `tasks/{slug}.md` for the affected tasks, `integration-research.md`
- Doctrine file: `$DOI_SCRIPTS/_config/3rd-brain-build-principles.md`
- Output directory: `<engagement-folder>/build/{intervention-slug}/`

**Required outputs from the subagent:**
- Artifact files in `build/{intervention-slug}/` (specific files per template)
- `build/{intervention-slug}/BUILD-NOTES.md` — answers all three architect questions, lists which principles the artifact satisfies, flags any deliberate violations with rationale
- `build/{intervention-slug}/SHIP-CHECKLIST.md` — concrete steps the operator runs to demo the 1-week shippable subset

If the subagent reports it cannot satisfy a principle (e.g., "Stage 3 task genuinely needs Postgres for aggregation across 50K rows"), it does NOT build silently — it reports the conflict back, doi-build surfaces it to the operator, the operator decides whether to override.

#### 2d. Critic review

After artifacts land, spawn `doi-review` with:
- Phase number: 10
- Intervention slug
- All files in `build/{intervention-slug}/`
- The original roadmap intervention spec (so the critic can validate the artifact matches the spec)

Save critic output to `reviews/phase10-{intervention-slug}-review.md`.

#### 2e. Per-intervention human gate

Present:

```markdown
## Gate: Phase 10 — [intervention name] built

### What was produced
- Artifact files in `build/{intervention-slug}/`
- BUILD-NOTES.md (architect questions answered)
- SHIP-CHECKLIST.md (1-week demo steps)

### Critic review
- Quality: [PASS / PASS WITH ISSUES / NEEDS REVISION]
- Critical issues: [count]
- Doctrine violations: [count, listed]

### Your options
1. **Ship it** — run the SHIP-CHECKLIST, demo it, come back with feedback. The next intervention waits until you do.
2. **Revise** — builder addresses critic issues, regenerates the artifact, gate runs again.
3. **Skip** — abandon this intervention, move to the next one. Reason captured in OVERRIDES.md.
4. **Pause** — stop Phase 10 here, save state, come back later.
```

**Default to "ship it" — the whole point of weekly shipping is breaking the analysis-build-analysis loop.** If the operator says "ship it," update state with the intervention as `built`, but do NOT immediately build the next one. Wait for the operator to come back with feedback from running the demo. Phase 10 is the ONLY phase that explicitly slows down between steps.

### Step 3: Iteration after demo

When the operator returns after running the SHIP-CHECKLIST:

1. Capture demo feedback in `build/{intervention-slug}/DEMO-FEEDBACK.md` (worked / didn't / surprises / what to change)
2. If the operator wants changes, dispatch the builder again with the feedback as additional input. New artifact replaces old; critic + gate run again.
3. If the operator is satisfied, mark the intervention `shipped` in state and ask: "Ready to build the next intervention: **[next name]**?"

### Step 4: Engagement complete

When all selected interventions are built and shipped (or skipped), update state to `phase=Phase 10` `status=complete` and present the engagement summary:

```markdown
# Engagement Complete — [Organization] / [Department]

## What shipped
| Intervention | Bottleneck | Stage | Build Folder | Status |
|---|---|---|---|---|

## What was skipped
| Intervention | Reason |
|---|---|

## What remains in the roadmap (not built this engagement)
| Tier | Intervention | Why deferred |
|---|---|---|

## Friction Tax progression (claimed, not measured)
- Pre-engagement: [N]%
- Projected after Tier 1: [N]%
- Operator should re-measure friction at the next checkpoint to validate the claim.
```

## 4. Artifact Output Layout

```
build/
├── OVERRIDES.md                       # Override log (Tier 2/3 builds, doctrine-violation builds)
├── {intervention-slug}/
│   ├── BUILD-NOTES.md                 # Architect questions, principle compliance
│   ├── SHIP-CHECKLIST.md              # 1-week demo steps
│   ├── playbook.md                    # Operator-handoff runbook (rendered from scripts/_templates/playbook.md)
│   ├── DEMO-FEEDBACK.md               # (added after operator demos)
│   └── [template-specific files]      # SKILL.md, CONTEXT.md, _config/, output/, .json configs, .py scripts, etc.
├── {next-intervention-slug}/
│   └── ...
```

`build/` is parallel to `output/`. `output/` is analysis (documents). `build/` is deliverables (working artifacts).

### Playbook output (per intervention)

For every Tools+Stage 1, Tools+Stage 2, Process bottleneck, and Tools+Stage 3 (single-agent default) intervention, also produce `build/{intervention-slug}/playbook.md` using the template at `scripts/_templates/playbook.md`. The playbook is the operator-handoff runbook — actionable enough that Claude Code, Zapier, or a junior operator can execute without supervision.

Fill every `{{placeholder}}` token. Leaving placeholders unfilled is a Principle 7 violation: deliveries should be operator-ready, not skeleton-shaped. The Decommission section's three architect questions (state owner, feedback signal, deletion impact) must answer concretely — not "see BUILD-NOTES" or "TBD".

For Tools+Stage 4 interventions: refused by default. If override is granted (with measured Stage 3 success cited per Principle 4), the playbook MUST cite that override in the Background Context.

### Order-swap decisions

When the operator wants to swap build order (build a different Tier 1 next, pivot to a Tier 2, etc.), DOI is genuinely ambivalent — the roadmap doesn't pick for the operator. Present these moments using the decision-brief format in `scripts/_config/decision-brief.md`. Phase-end review gates (after each artifact ships) are NOT decisions — those are "here's what was built, demo it and tell me what to build next."

## 5. Constraints

- NEVER build an intervention not present in the approved roadmap.
- NEVER build a Tier 2 or Tier 3 intervention without explicit operator override + reason captured in `OVERRIDES.md`.
- NEVER build Stage 3-4 work when maturity < Level 3 without explicit operator override.
- NEVER build Stage 4 (AI Coworker) without measured Stage 3 success cited. Default = refuse, re-route to Stage 3.
- NEVER build the next intervention without an explicit operator decision after the previous gate. The whole point is weekly shipping with feedback.
- NEVER skip the BUILD-NOTES.md or SHIP-CHECKLIST.md — these enforce Principles 7 and 3.
- NEVER scaffold Postgres / queues / orchestrator infrastructure without `infrastructure-justified` tag + file-failure mode cited (Principle 5).
- NEVER introduce a new tool when the verified tool list contains one that addresses the bottleneck (Principle 6) — extend-existing is the default.
- If a builder subagent reports it cannot satisfy a principle, surface it to the operator. Do NOT build silently with the violation.
- State must be updated after every intervention build AND every gate decision.
- All file paths use the engagement folder as root.

## 6. Common Mistakes

| Mistake | Fix |
|---|---|
| Building all Tier 1 interventions in one batch | Build one at a time, gate after each, wait for demo feedback before the next |
| Skipping the doctrine gate (2a) | The roadmap is the contract — if it's missing 1-week subset / architect answers, the artifact will be born broken. Send it back to roadmap revision instead. |
| Builder generates Postgres scaffolding for a single-user workflow | Principle 5 violation. Re-dispatch with `files-default` enforced. |
| Builder produces 4-agent architecture when 1 agent + tools would do | Principle 4 violation. Re-dispatch with single-agent default. |
| Building Stage 4 because the operator wants to skip Stage 3 | Refuse. Re-route to Stage 3. Document the operator's request in OVERRIDES.md if they override. |
| Skipping critic on a "small" artifact | Critic runs on every artifact. No exceptions. |
| Treating BUILD-NOTES.md as optional | It's the artifact's contract with the doctrine. Without it, the artifact is unverifiable. |

## 7. Quick Reference

| Step | Tool | Purpose |
|---|---|---|
| 1. Read roadmap | Read tool | Pull Tier 1 interventions and their declarations |
| 2a. Pre-build gate | Skill logic | Verify roadmap satisfies doctrine before dispatching |
| 2b. Match template | Skill logic | Bottleneck + Stage → builder template |
| 2c. Dispatch builder | Agent (doi-builder) | Generate artifacts in `build/{slug}/` |
| 2d. Critic review | Agent (doi-review, Phase 10) | Validate artifact against doctrine + spec |
| 2e. Human gate | Skill logic | Ship / Revise / Skip / Pause |
| 3. Demo feedback | Skill logic | Capture what happened when operator ran SHIP-CHECKLIST |
| 4. Engagement summary | Skill logic | Final deliverable summary, state → complete |
