# 3rd Brain System Building Principles

This is the canonical, immutable doctrine the DOI consultant applies when scoping, sequencing, and constructing recommendations. It is the **constructive layer** that sits on top of DOI's diagnostic doctrine (People → Process → Tools, Three Cs, Foundation gates, 4-stage framework). DOI says *what is broken and what to recommend*; these principles say *how to scope and ship the recommendation*.

Phase skills that reference this file: `doi-roles` (Phase 5), `doi-route` (Phase 7), `doi-roadmap` (Phase 9), `doi-build` (Phase 10). The `doi-review` critic enforces compliance at the corresponding gates.

**This file is bundled with the plugin and is not editable per-engagement.** If an engagement's situation genuinely violates a principle, the violation is documented in the roadmap with an explicit rationale, but the principle is not rewritten.

---

## Principle 1 — Frontend-first for apps

When the recommendation is **build an application**, build the user-facing surface first. The frontend is the spec; the backend is the response to it.

**How DOI applies this:**
- `doi-route` Tools+Stage 2-3 interventions: artifact spec must lead with the user-facing surface (form, page, dashboard, prompt UI), not the data model.
- `doi-build` Phase 10: when generating an app artifact, scaffold the frontend before the backend, even if both are produced in the same session.

**Violation signal:** roadmap intervention specifies database schema or API contract before naming the screen the user opens.

---

## Principle 2 — Solo-agent-first for workflows

When the recommendation is **build a workflow or automation**, build the single-agent version first. Agent orchestration is a response to a measured limitation, not a starting point.

**How DOI applies this:**
- `doi-roles` Phase 5 microservice decomposition: even at Stage 3, default to **1 agent + N tools** before splitting into N agents.
- `doi-build` Phase 10: solo-agent artifact is the default deliverable for any workflow intervention. Multi-agent only on explicit override with measured single-agent failure cited.

**Violation signal:** Stage 3 intervention proposes 3+ separate agents without naming the bottleneck (latency/quality/cost) that forces decomposition.

---

## Principle 3 — Ship every week

If a Tier 1 intervention cannot ship in one week, it is not a Tier 1 intervention. Demote it to Tier 2 and split out a 1-week shippable subset that goes back into Tier 1.

**How DOI applies this:**
- `doi-roadmap` Phase 9: every Tier 1 intervention must declare a **1-week shippable subset** with a concrete demo definition.
- `doi-build` Phase 10: build artifacts in shippable order — the smallest thing the user can use end-to-end before the next thing.

**Violation signal:** Tier 1 intervention has no week-1 demo definition, or the week-1 demo is internal-only with no user touch.

---

## Principle 4 — Single agent until proven otherwise

One agent + role + tools is the default. Decompose only when a **measured** bottleneck — latency, quality, or cost — forces it. The complex build's only job is making the simple thing better at scale.

**How DOI applies this:**
- `doi-roles` Phase 5: microservice splits at Stage 3 must cite the measured bottleneck. Speculative decomposition is a methodology violation.
- `doi-build` Phase 10: default Stage 3 artifact = single agent with multiple tools. Multi-agent only on override.
- Stage 4 (AI Coworker, full autonomy): refused by default. Re-routes to "stabilize Stage 3 first, then earn Stage 4" unless the operator explicitly overrides with measured Stage 3 success.

**Violation signal:** intervention proposes >1 agent without a citation of a measured failure of the 1-agent design.

---

## Principle 5 — ICM and folders before infrastructure

Default state, handoffs, and orchestration to **folder structure + markdown files via ICM** — numbered stages, `CONTEXT.md` contracts, `_config/` for stable reference, `output/` for handoffs. Postgres + APIs + queues + orchestration frameworks earn their keep only when files measurably fail: concurrent writes from multiple users, aggregations across many records, scale beyond tens of thousands of rows.

**The fix is never "smaller Postgres schema." The fix is "no Postgres until files break."**

**How DOI applies this:**
- `doi-route` Phase 7: when classifying a Tools bottleneck, the default intervention is file-based ICM. Postgres/queues/orchestration frameworks only appear when the friction data shows concurrent writes, aggregation needs, or >10K-row scale.
- `doi-build` Phase 10: Stage 3 artifacts ship as ICM folder structures with `CONTEXT.md`, `_config/`, `output/`. The builder refuses to scaffold Postgres/queue infrastructure without an explicit override that names the file-failure mode.

**Violation signal:** intervention specifies a database, queue, or orchestrator (Airflow, Temporal, n8n at scale) without citing the file-failure mode that justifies it.

---

## Principle 6 — Start with what we have built (if it works)

If a real corpus exists (legacy DB, prior outputs, real client data), it is the spec and the starting point. If a working frontend exists, plug in a new backend before rebuilding it. If nothing exists, start as small as possible.

**Companion question:** Always ask "what can I remove?" not "what tool fixes this?" Minimize what you build to what is absolutely necessary.

**How DOI applies this:**
- `doi-route` Phase 7: extending an existing system always beats introducing a new one when both can address the bottleneck. Tag interventions as `extend-existing` vs. `new-system` and prefer the former.
- `doi-roadmap` Phase 9: new section **"Existing Systems to Extend"** — pulled from `verified-role.md` tools and `_uploads/`. Every Tier 1-2 intervention names which existing system it builds on (or explicitly justifies why a new one is needed).
- `doi-build` Phase 10: builder reads the verified tool list and integration research before scaffolding. New systems only when extending the existing one is genuinely impossible.

**Violation signal:** intervention introduces a new tool/system when an existing one in the verified tool list could address the bottleneck.

---

## Principle 7 — Demo before doc + the three architect questions

The plan justifies additions to a working thing — it never births a system from imagination. Before any component lands in a roadmap or a build, answer these three questions. If you cannot answer all three, the component is not ready.

### a. Where does state reside?

Name the **single component** that owns this data. Two owners = desync waiting to ship.

### b. Where is feedback?

Name the **log, metric, or error** that proves this component is working. No feedback = running blind.

### c. What breaks if this is deleted?

If the answer is "nothing user-facing," delete it now. If the answer is "I don't know," map the dependency graph before adding more.

**How DOI applies this:**
- `doi-roadmap` Phase 9: every Tier 1-2 intervention answers all three questions in its spec. Interventions missing answers are demoted or dropped.
- `doi-build` Phase 10: builder writes a `BUILD-NOTES.md` per artifact answering all three. Critic rejects artifacts that skip any of the three.

**Violation signal:** intervention or artifact lacks explicit answers to state owner, feedback signal, or deletion impact.

---

## Quick Reference — Where each principle binds

| Principle | doi-roles (5) | doi-route (7) | doi-roadmap (9) | doi-build (10) | Critic |
|---|---|---|---|---|---|
| 1. Frontend-first for apps | — | apps spec | apps spec | scaffold order | P9, P10 checks |
| 2. Solo-agent-first for workflows | decomposition default | — | — | default artifact | P5, P10 checks |
| 3. Ship every week | — | — | Tier 1 1-week subset | shippable order | P9 check |
| 4. Single agent until proven otherwise | decomposition justification | — | sequencing | refuses speculative multi-agent | P5, P10 checks |
| 5. ICM + folders before infrastructure | — | Tools default | "Existing Systems" section | refuses speculative infra | P7, P10 checks |
| 6. Start with what we have built | — | extend > new | "Existing Systems" section | reads verified tool list | P7, P9 checks |
| 7. Demo before doc + 3 questions | — | — | every Tier 1-2 spec | BUILD-NOTES.md per artifact | P9, P10 checks |

---

## Compliance is measured, not implied

Skills do not just *reference* this file. They are required to:
1. Read the relevant principles into context before producing output.
2. Mark each intervention/artifact with the principle(s) it satisfies in its output.
3. Flag deliberate violations with a written rationale (the critic will surface these for human review, but does not block them).

Undocumented violations are methodology violations. The critic flags them as critical.
