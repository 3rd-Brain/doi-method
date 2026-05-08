# gstack → DOI Method: Research Report

**Source:** [github.com/garrytan/gstack](https://github.com/garrytan/gstack) — Garry Tan's Claude Code setup, ~91k stars, 23 opinionated tools framed as CEO / Designer / Eng Manager / Release Manager / Doc Engineer / QA.

**Question:** What from gstack should DOI Method steal, what should we deliberately not, and what specifically changes in our prompts/skills?

**Date:** 2026-05-08

---

## 1. Our system, mapped

- **13 phase skills** in `skills/`: `doi-intake`, `doi-assess`, `doi-setup`, `doi-verify`, `doi-outcomes`, `doi-roles`, `doi-friction`, `doi-route`, `doi-pillars`, `doi-roadmap`, `doi-build`, `doi-engage` (full pipeline), `doi-run` (orchestrator front door)
- **2 agents** in `agents/`: `doi-builder` (produces Phase 10 artifacts), `doi-review` (single critic that reviews phase outputs in isolation, fresh context, no conversation memory)
- **Constructive doctrine** in [scripts/_config/3rd-brain-build-principles.md](../../scripts/_config/3rd-brain-build-principles.md) — 7 principles enforced at phases 5/7/9/10 by the critic
- **Workflow shape:** phase output → critic in isolation → human gate → next phase
- **Engagement workspace** has `_uploads/{general,tool-exports,{dept}/{role}}/` plus `MANIFEST.md` provenance ledger
- **Phase 10 cadence:** ONE artifact per week, demoed by operator before next starts

## 2. gstack, mapped

- ~50 top-level "skill" folders, each with `SKILL.md` (and often `SKILL.md.tmpl`)
- Specialist subagents under `review/specialists/` (`testing.md`, `security.md`, `red-team.md`, `maintainability.md`, `performance.md`, `data-migration.md`, `api-contract.md`)
- Dual-voice (Claude + Codex CLI) orchestration in `autoplan/`
- Harness-level gates via `careful/` + `freeze/` PreToolUse hooks
- Doctrine in `ETHOS.md` (parallels our build principles file but lives separately from enforcement)
- `bin/` filled with telemetry, sync, MCP scaffolding
- Backend infrastructure: Supabase, GBrain (vector DB), 22MB prompt-injection classifier, 721MB DeBERTa ensemble for sidebar agent defense
- Garry optimizes for a software factory; DOI optimizes for a consulting engagement

---

## 3. What to pull in (highest leverage)

### 3.1 Replace the single `doi-review` critic with a specialist-checklist fan-in — but keep one critic agent

Source: [review/SKILL.md](https://github.com/garrytan/gstack/blob/main/review/SKILL.md) Steps 4.5–4.6, [review/specialists/](https://github.com/garrytan/gstack/tree/main/review/specialists).

Garry routes a diff through up to 7 named specialists in parallel, each a one-page checklist emitting **structured JSON findings**, deduped by `path:line:category` fingerprint, with **confidence 1–10** per finding. Identical findings from two specialists get a confidence boost (+1, capped at 10) and a `MULTI-SPECIALIST CONFIRMED` tag. There's a hit-rate gate — specialists with 0 findings in 10+ dispatches get auto-skipped, except `[NEVER_GATE]` ones (security, data-migration).

We do **not** copy the parallel subagent dispatch — that violates Principle 4 (single agent until proven otherwise). We give our **single** `doi-review` agent a folder of checklists it loads per phase:

```
agents/doi-review/checklists/
  evidence.md                  # every score cites prior-phase evidence
  principles.md                # 3rd-brain-build-principles compliance
  scope-drift.md               # phase output stays in phase contract
  invented-data.md             # nothing not in MANIFEST.md
  friction-math.md             # phase 6 only — Three Cs arithmetic
  roadmap-tier-discipline.md   # phase 9 only — Tier 1 = 1-week shippable
  build-three-questions.md     # phase 10 only — state owner, feedback signal, deletion impact
```

Each finding emits as JSON: `{phase, checklist, severity, finding, evidence_cite, confidence}`. Dedupe by fingerprint. Surface MULTI-CHECKLIST-CONFIRMED findings first. **Single biggest quality lift available.**

### 3.2 Plan Completion Audit between phases

Source: [review/SKILL.md](https://github.com/garrytan/gstack/blob/main/review/SKILL.md) Step 1.5.

After each phase output, before the human gate, the critic extracts every actionable from the *prior* phase's output and classifies against the new output as **DONE / PARTIAL / NOT DONE / CHANGED**, with a forced WHY for each PARTIAL/NOT DONE: *Scope cut / Context exhaustion / Misunderstood / Blocked / Forgotten*.

Best defense against silent decay across a 12-phase pipeline. Goes into `agents/doi-review/AGENT.md` as a required step.

### 3.3 Steal three pieces of language verbatim

Land in a shared snippet at `scripts/_config/voice.md`, referenced with a one-line `Read scripts/_config/voice.md before drafting output.` from the heavyweight phase skills (`doi-roles`, `doi-route`, `doi-roadmap`, `doi-build`) and from `doi-review`.

**Verification rule** (review/SKILL.md Step 5):
> Never say "likely handled" or "probably tested" — verify and cite, or flag as unknown. "This looks fine" is not a finding. Either cite evidence it IS fine, or flag it as unverified.

**Voice rule** (review/SKILL.md "Voice"):
> Lead with the point. Name files, functions, line numbers. No em dashes. No AI vocabulary: delve, crucial, robust, comprehensive, nuanced, multifaceted, pivotal, landscape, tapestry, foster, intricate, vibrant, fundamental, significant, underscore, showcase, furthermore, moreover, additionally.

**Confusion Protocol**:
> For high-stakes ambiguity (data model, destructive scope, missing context), STOP. Name it in one sentence, present 2–3 options with tradeoffs, ask. Do not use for routine work.

### 3.4 Upgrade human gates to the AskUserQuestion decision-brief format

Today our gates between phases are free-form prose. Garry's format:

- **D-number** (decision id, lets the engagement reference past decisions)
- **ELI10 paragraph** of what's being decided
- **Stakes if we pick wrong**
- **Recommendation + reason**
- ≥2 pros, ≥1 con per option (≥40 chars each)
- **Net synthesis** sentence
- Self-check before emitting

Drop-in upgrade — no architectural change. Apply to gates in `doi-engage`, `doi-route`, `doi-roadmap`, `doi-build`.

### 3.5 Borrow two ETHOS framings

**Dual-effort labels** on every option in client-facing output:
> `(human consultant: ~2 weeks / DOI pipeline: ~1 hour)`

Makes the AI compression visible at decision time. Goes into `doi-roadmap` and `doi-build` artifact specs.

**Three Layers of Knowledge** (ETHOS §2): tried-and-true / new-and-popular / first-principles. Maps onto our `doi-route` Tools-bottleneck classification — a cleaner explanation for why we extend existing systems over introducing new ones (Principle 6).

---

## 4. What we already do better — do not regress

| Stance | gstack | DOI |
|---|---|---|
| Multi-agent posture | 7-specialist parallel fan-out on every diff > 50 lines | Single critic by Principle 4 — keep |
| Infrastructure | Supabase, MCP servers, 721MB ML ensemble, telemetry, GBrain vector DB | ICM + folders only — keep |
| State location | scattered: `~/.gstack/`, `.gstack/`, `~/.claude/skills/gstack/`, `.claude/skills/gstack/`, `~/.gstack-artifacts-remote.txt` | one `_uploads/MANIFEST.md` ledger — keep |
| Stage-4 autonomy | needs prompt-injection classifiers + Haiku transcript checker because untrusted sidebar agent runs web pages | refused by default; the entire defense stack disappears if you don't grant Stage-4 in the first place — keep |
| Doctrine binding | ETHOS.md exists but lives separately from skill enforcement | principles file bound to phases 5/7/9/10 + critic — keep |
| Demo-before-doc | `/document-release` is auto-generated post-hoc docs (opposite stance) | Principle 7 + 3 architect questions — keep |

## 5. Deliberately do not copy

- **800-line auto-generated SKILL preambles** (telemetry, GBrain detection, artifact-sync, voice rules, jargon glossing, checkpoint mode, routing injection). Violates demo-before-doc. Our SKILL bodies stay lean.
- **Codex + Claude dual-voice in every phase** ([autoplan/SKILL.md](https://github.com/garrytan/gstack/blob/main/autoplan/SKILL.md)). Requires the OpenAI Codex CLI installed, auth probe, 12-minute timeout wrappers, degradation matrices for `[codex-unavailable]` / `[single-model]` / `[subagent-only]`. Speculative multi-agent — violates Principle 4.
- **Hooks-based gates** ([careful/SKILL.md](https://github.com/garrytan/gstack/blob/main/careful/SKILL.md), [freeze/SKILL.md](https://github.com/garrytan/gstack/blob/main/freeze/SKILL.md)). Tempting for "no Stage 4 by default" enforcement, but couples the plugin to harness PreToolUse. Critic-only enforcement is correct.
- **23-persona menagerie** (CEO, Designer, Eng Manager, Release Manager, Doc Engineer, QA, SRE…). Our 13 phases already map the consulting roles. Adding personas doubles surface for marginal gain.
- **"Boil the Lake" maximalism applied to consulting**. Building 100% test coverage for code is a real lake; building "100% complete pillar scoring" on a client engagement is gold-plating. Principle 3 (ship every week, ONE artifact) is the correct frame. Borrow the language for completeness *within an artifact*, not for ever-expanding scope.
- **Telemetry, analytics jsonl, learnings sync to private GitHub repos, MCP server registration, Supabase backend** — every one violates Principle 5 (ICM + folders before infrastructure).

---

## 6. Top 3 highest-leverage grabs

1. **Specialist-checklist file pattern + structured-JSON findings + Fix-First batching for `doi-review`** (§3.1). Replace the single critic body with 5–7 named per-phase checklists emitting JSON, with confidence 1–10, deduped by fingerprint, and a single batched ASK gate at the end instead of free-form prose.
2. **Plan Completion Audit between phases** (§3.2). The single biggest defense against silent quality decay across the 12-phase pipeline.
3. **Decision-brief AskUserQuestion format + voice/verification rules** (§3.3 + §3.4). Steal verbatim. Sharper than what's in our skills today and fully principle-compatible.

---

## 7. Concrete change-points in our repo

If we act on this, the smallest set of edits is:

| # | File | Change |
|---|---|---|
| 1 | [agents/doi-review/AGENT.md](../../agents/doi-review/AGENT.md) | Add structured-JSON finding format, confidence 1–10, fingerprint dedup, Plan Completion Audit step. Reference `checklists/` folder it loads per phase. |
| 2 | `agents/doi-review/checklists/` *(new)* | Create `evidence.md`, `principles.md`, `scope-drift.md`, `invented-data.md`, `friction-math.md`, `roadmap-tier-discipline.md`, `build-three-questions.md`. |
| 3 | `scripts/_config/voice.md` *(new)* | Verification rule + voice blocklist + Confusion Protocol. |
| 4 | All heavyweight phase SKILLs (`doi-roles`, `doi-route`, `doi-roadmap`, `doi-build`) | Add one-line `Read scripts/_config/voice.md before drafting output.` |
| 5 | `skills/doi-engage/SKILL.md`, `skills/doi-roadmap/SKILL.md`, `skills/doi-build/SKILL.md` | Replace freeform gate prose with AskUserQuestion decision-brief format (D-number, ELI10, stakes, recommendation, ≥2 pros / ≥1 con per option, net synthesis). |
| 6 | `skills/doi-roadmap/SKILL.md` | Add dual-effort labels `(human consultant: X / DOI pipeline: Y)` to every Tier 1–2 spec. |

---

## 8. Reference paths in gstack

- [ETHOS.md](https://github.com/garrytan/gstack/blob/main/ETHOS.md) — doctrine file, parallel to our `3rd-brain-build-principles.md`
- [review/SKILL.md](https://github.com/garrytan/gstack/blob/main/review/SKILL.md) — the source of items 3.1, 3.2, 3.3
- [review/checklist.md](https://github.com/garrytan/gstack/blob/main/review/checklist.md) — Fix-First Heuristic, AUTO-FIX vs ASK
- [review/specialists/](https://github.com/garrytan/gstack/tree/main/review/specialists) — checklist file structure to model
- [autoplan/SKILL.md](https://github.com/garrytan/gstack/blob/main/autoplan/SKILL.md) — dual-voice (do not copy, but study the consensus-table shape)
- [careful/SKILL.md](https://github.com/garrytan/gstack/blob/main/careful/SKILL.md), [freeze/SKILL.md](https://github.com/garrytan/gstack/blob/main/freeze/SKILL.md) — hooks pattern (do not copy)
- [learn/SKILL.md](https://github.com/garrytan/gstack/blob/main/learn/SKILL.md) — learnings manager (relevant for our `_uploads` MANIFEST evolution)
- [agents/openai.yaml](https://github.com/garrytan/gstack/blob/main/agents/openai.yaml) — 5-line interface manifest
