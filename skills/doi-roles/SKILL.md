---
name: doi-roles
description: "Use when analyzing a verified role — extracts tasks by frequency, classifies each into the 4-stage AI automation framework, maps LLM functions and KOODAR dimensions, and decomposes stage 2-4 tasks into microservices. Cannot score friction or recommend implementation order."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-04-07
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

### Overview

> **Voice:** Read `scripts/_config/voice.md` before drafting any user-facing output. Verification rule, vocabulary blocklist, Confusion Protocol all apply.

Phase 5 of the DOI Method. Analyst — extracts tasks from verified role profiles, classifies automation potential, and decomposes into implementable units. This is the technical core of DOI.

Before classifying tasks or decomposing microservices, this phase researches the operator's actual software capabilities — API docs, integration catalogs, automation features — so that workflow steps and microservice designs reference real, verified capabilities rather than assumptions.

### Role Constraints

- CAN: Research tool APIs/capabilities, extract tasks, classify automation stages, map LLM functions, apply KOODAR, decompose microservices
- CANNOT: Score friction (Phase 6), route bottlenecks (Phase 7), recommend implementation order (Phase 9)

### Build Doctrine — read before decomposing microservices

Before any Stage 2-4 microservice decomposition, read the canonical doctrine:

```text
$DOI_SCRIPTS/_config/3rd-brain-build-principles.md
```

Two principles bind this phase:

- **Principle 2 — Solo-agent-first for workflows.** The default Stage 3 design is **1 agent + N tools**, not N agents. Agent orchestration is a response to a measured limitation, never a starting point.
- **Principle 4 — Single agent until proven otherwise.** Decomposing into multiple microservices/agents requires a cited measured bottleneck (latency, quality, or cost). Speculative decomposition is a methodology violation.

**Decomposition rules with the doctrine applied:**

| Stage | Default | Decompose only when |
|---|---|---|
| 1 | 0 microservices (no AI) | Never — Stage 1 has no AI component |
| 2 | 1 microservice | Never — the task IS the microservice |
| 3 | **1 agent + multiple tools** (treated as 1 microservice with multiple capabilities) | A measured bottleneck forces splitting into 2-5 microservices. Cite the bottleneck in the microservice file. |
| 4 | **Refused by default.** Re-route to Stage 3 starting point. | Operator explicitly overrides with measured Stage 3 success. If overridden, decompose into 3-8+ microservices. |

If you split a Stage 3 task into >1 microservice, the microservice file MUST include a `## Decomposition Rationale` section citing the measured bottleneck. No bottleneck cited = single-microservice design.

This overrides the older "Stage 3 = 2-5 microservices" rule. Stage 3 = 1 by default; 2-5 only with cited justification.

### Session Resolution

Standard DOI session resolution.

### Prerequisites

Call `$DOI_SCRIPTS/check-prerequisites.sh 5 <engagement-folder> <dept-slug> <role-slug>`
Required: `roles/{role-slug}/verified-role.md` must exist.
Also read: `roles/{role-slug}/outcome-map.md` for outcome alignment data from Phase 4.

### The 4-Stage AI Framework

| Stage | Name | Autonomy | Description | Examples |
|---|---|---|---|---|
| 1 | Automated Workflow | None | Rule-based, no AI. Use Zapier, Make, CRM rules, conditional logic. | Auto-send email on form submit, sync contacts between CRM and email, auto-generate invoice on project complete |
| 2 | Agentic Tool | Low (Intern) | Single AI function. 1 input -> AI processing -> 1 output. | Draft email from bullet points, summarize meeting transcript, classify support tickets |
| 3 | Agentic Workflow | Medium (Specialist) | Multi-step AI with human checkpoints. Multiple tools coordinated. | Client onboarding: intake form -> research -> proposal draft -> human review -> send. Content pipeline: brief -> outline -> draft -> edit -> schedule |
| 4 | AI Coworker | High (Peer) | Full role autonomy. Owns responsibility area. Proactive operation. | Executive assistant: manages calendar + email + prep + follow-ups. Customer support manager: handles tickets, escalates, reports trends |

### 8 Core LLM Functions

| Function | What it does | Example |
|---|---|---|
| Execute | Trigger external actions or API calls | Run search, call webhook, use external tool |
| Extract | Pull specific data points from content | Get KPIs from a monthly report |
| Summarize | Condense content preserving key points | Summarize a 30-minute meeting |
| Analyze | Understand content, identify patterns, interpret meaning | What themes appeared most in these transcripts? |
| Generate | Create new original content | Write first draft of email campaign |
| Transform | Convert content to a new format or structure | Convert paragraph to executive bullet points |
| Edit | Improve existing content for quality, clarity, or tone | Make this draft more persuasive |
| Classify | Categorize into predefined labels | Sort support tickets by priority |

### KOODAR Framework

Military decision-making cycle applied to task scoping:

| Dimension | What to define | Stage 1-3 | Stage 4 |
|---|---|---|---|
| **Know** | Information sources needed | What data inputs | What data + context sources |
| **Observe** | Monitoring/pattern detection | N/A | What patterns to watch for |
| **Orient** | Environmental fit | N/A | How task fits broader context |
| **Decide** | Decision boundaries | Fixed rules | Judgment within parameters |
| **Act** | Concrete execution steps | Direct actions | Multi-step with coordination |
| **Review** | Output evaluation | Basic validation | Quality check + feedback loop |

### Process

1. Read `verified-role.md` AND `outcome-map.md` for the current role
2. **Tool/API Research** — before classifying anything, research the operator's actual software stack. See the Tool/API Research section below for full details. Save findings to `roles/{role-slug}/integration-research.md`.
3. **Task Extraction** — extract every distinct task into frequency categories:
   - Quarterly (3-month recurring)
   - Monthly (1-month recurring)
   - Weekly (1-week recurring)
   - Daily (every day)
   - Triggered (event-based — "when X happens, do Y")
   - Infinite (ongoing responsibilities with no clear frequency)
   - INCLUDE undocumented tasks discovered during verification
   - INCLUDE corrected versions of discrepant tasks (use the reality, not the materials)
   - EXCLUDE aspirational items (described but not happening)
4. Write `responsibilities.md` with the extracted task list by frequency
5. For EACH task, classify using integration-research.md to ground your decisions:
   - Stage (1-4) with reasoning and confidence score (0-1)
   - Effort Level: Low / Medium / High / Continuous
   - 8 Core LLM Functions (which apply and why)
   - KOODAR (6 dimensions — Observe/Orient = N/A for Stage 1-3)
   - Workflow Steps — reference REAL API endpoints, integrations, and tool features from tool-capabilities.md
   - Outcome Alignment — populated from outcome-map.md (aligned/indirect/unaligned)
6. Save each task as `tasks/{task-slug}.md` with full classification
7. For Stage 2-4 tasks, run Microservice Decomposition:
   - Stage 1: SKIP (no AI, no microservices)
   - Stage 2: 1 microservice (the task IS the microservice)
   - Stage 3: 2-5 microservices (break into coordinated AI tools)
   - Stage 4: 3-8+ microservices (comprehensive autonomous capabilities)
   - Each microservice must reference verified tool capabilities — no fictional API endpoints
   - **Skip for unaligned tasks** (outcome_alignment = unaligned from outcome-map.md). No point designing AI architecture for work that may not serve a defined result.
   - Save to `microservices/{task-slug}-microservices.md`
8. Present the extracted task list to the user. Use AskUserQuestion: "Here are the [N] tasks I extracted for [role name]. Is anything missing or wrong?" — this is their last chance to add tasks before classification begins.
9. Call `$DOI_SCRIPTS/aggregate-snapshot.sh <folder> <dept-slug> <role-slug>`
10. Call `$DOI_SCRIPTS/update-state.sh <folder> phase="Phase 5"`

### Tool/API Research Step (Detail for Step 2)

Read `department.md` for the tools list and `verified-role.md` for the verified tools table. For EACH tool the role actually uses:

**Check `_uploads/tool-exports/` first.** Before web search, scan for operator-provided artifacts:

```bash
$DOI_SCRIPTS/scan-uploads.sh <engagement-folder> tool-exports
```

Operator-provided exports (Zapier scenario JSON, Make blueprints, n8n workflow exports, CRM field schemas, integration screenshots, API doc PDFs, vendor SOW excerpts) are higher-trust than web search because they reflect the **operator's actual instance and configuration** — not the vendor's marketing surface. Mine these first; web search supplements the gaps. For each file ingested, append a row to `_uploads/MANIFEST.md`:

`| _uploads/tool-exports/<file> | 5 | doi-roles | integration-research.md (<tool>) | YYYY-MM-DD |`

**What to research:**

| Research Target | Where to Look | What You Need |
|---|---|---|
| API availability | Official docs, Composio catalog, Apify actors | Does this tool have an API? REST/GraphQL? Auth method? |
| Integration catalog | Tool's native integrations page, Zapier/Make app directories | What does this tool already connect to natively? |
| Automation features | Tool's automation/workflow docs | Built-in rules, triggers, scheduled actions? |
| Data export/import | Tool's data management docs | CSV, JSON, webhook, API bulk operations? |
| AI/LLM features | Tool's AI feature pages | Any built-in AI capabilities already? |
| Rate limits & pricing | API docs pricing page | Free tier? Per-call costs? Rate limits that affect automation? |

**How to research:**

- Use web search to find official API documentation for each tool
- Check Composio (composio.dev) for pre-built tool connectors and action catalogs
- Check Apify (apify.com) for existing actors/scrapers for the tool
- Check the tool's own integration marketplace (e.g., HubSpot App Marketplace, Salesforce AppExchange)
- Check Zapier app directory for available triggers and actions
- Check Make (make.com) app directory for modules and supported operations
- Check n8n (n8n.io) community nodes for available integrations
- Check Pipedream (pipedream.com) app catalog for pre-built sources and actions

**Save findings to:** `roles/{role-slug}/integration-research.md`

```markdown
---
role: [Role Name]
tools_researched: [count]
researched_date: [YYYY-MM-DD]
---


### Environment Resolution

Before running any DOI script, resolve the plugin paths once per session:

```bash
# Resolve DOI plugin directory (Cowork install or legacy)
if [ -d "$HOME/.claude/plugins/doi-method/scripts" ]; then
  export DOI_SCRIPTS="$HOME/.claude/plugins/doi-method/scripts"
elif [ -d "$HOME/.claude/scripts/doi" ]; then
  export DOI_SCRIPTS="$HOME/.claude/scripts/doi"
else
  echo "ERROR: DOI Method scripts not found. Run the installer or install via Cowork."; exit 1
fi
export DOI_REGISTRY="$HOME/.claude/.doi-registry.md"
```

# Integration Research — [Role Name]

## [Tool Name] (e.g., HubSpot)
**API:** [Yes — REST API, OAuth2 / No API / Limited]
**Official Docs:** [URL]
**Rate Limits:** [e.g., 100 calls/10sec on free tier]

### Available Integrations
- Native: [list native integrations relevant to this role's tools]
- Zapier: [key triggers and actions available]
- Make: [key modules and operations]
- n8n: [community nodes if available]
- Pipedream: [sources and actions if available]
- Composio: [pre-built connectors if any]

### Automation Capabilities
- [Built-in workflows, triggers, scheduled actions]
- [What can be automated WITHOUT custom code]

### API Actions Relevant to This Role's Tasks
| Action | Endpoint/Method | Relevance to Task |
|---|---|---|
| Get contacts | GET /crm/v3/objects/contacts | Used in "Export HubSpot data" task |
| Create report | POST /analytics/v2/reports | Could automate "Weekly report" task |

### Limitations
- [What the API cannot do]
- [Actions that require enterprise tier]
- [Missing integrations between this tool and others in the stack]

## [Next Tool]
...
```

**Why this matters:** Without this step, workflow steps and microservice designs are based on assumptions about what tools can do. With it, every "Connect to HubSpot API" step references a real endpoint, every "Trigger Zapier automation" references a real integration, and every "Stage 1: use native integration" recommendation is verified to actually exist. integration-research.md is the single source of truth for tool capabilities throughout this phase.

### Task Output Format

`tasks/{task-slug}.md`:

```markdown
---
task: [task name]
frequency: [daily/weekly/monthly/quarterly/triggered/infinite]
stage: [1-4]
effort: [low/medium/high/continuous]
confidence: [0.0-1.0]
outcome_alignment: [aligned/indirect/unaligned]
---


### Environment Resolution

Before running any DOI script, resolve the plugin paths once per session:

```bash
# Resolve DOI plugin directory (Cowork install or legacy)
if [ -d "$HOME/.claude/plugins/doi-method/scripts" ]; then
  export DOI_SCRIPTS="$HOME/.claude/plugins/doi-method/scripts"
elif [ -d "$HOME/.claude/scripts/doi" ]; then
  export DOI_SCRIPTS="$HOME/.claude/scripts/doi"
else
  echo "ERROR: DOI Method scripts not found. Run the installer or install via Cowork."; exit 1
fi
export DOI_REGISTRY="$HOME/.claude/.doi-registry.md"
```

# [Task Name]

**Stage [N] — [Stage Name]** ([autonomy level])
**Effort:** [level]
**Confidence:** [X]%

## Reasoning
[Why this stage classification — specific to this task's characteristics]

## Workflow Steps
1. [Concrete, AI-executable step]
2. [Next step]
...

## Core LLM Functions
| Function | Applies | Why |
|---|---|---|
| Execute | [Yes/No] | [reason if yes] |
| Extract | [Yes/No] | [reason if yes] |
| Summarize | [Yes/No] | [reason if yes] |
| Analyze | [Yes/No] | [reason if yes] |
| Generate | [Yes/No] | [reason if yes] |
| Transform | [Yes/No] | [reason if yes] |
| Edit | [Yes/No] | [reason if yes] |
| Classify | [Yes/No] | [reason if yes] |

## KOODAR
| Dimension | This Task |
|---|---|
| Know | [information sources needed] |
| Observe | [N/A for Stage 1-3, or monitoring pattern for Stage 4] |
| Orient | [N/A for Stage 1-3, or environmental context for Stage 4] |
| Decide | [decision boundaries] |
| Act | [execution summary] |
| Review | [evaluation method] |

## Outcome Alignment
**Alignment:** [Aligned/Indirect/Unaligned]
**Result(s):** [R# — result name, or "No defined result mapped"]
```

### Microservice Output Format

`microservices/{task-slug}-microservices.md`:

```markdown
---
task: [parent task name]
task_stage: [2-4]
microservice_count: [N]
---


### Environment Resolution

Before running any DOI script, resolve the plugin paths once per session:

```bash
# Resolve DOI plugin directory (Cowork install or legacy)
if [ -d "$HOME/.claude/plugins/doi-method/scripts" ]; then
  export DOI_SCRIPTS="$HOME/.claude/plugins/doi-method/scripts"
elif [ -d "$HOME/.claude/scripts/doi" ]; then
  export DOI_SCRIPTS="$HOME/.claude/scripts/doi"
else
  echo "ERROR: DOI Method scripts not found. Run the installer or install via Cowork."; exit 1
fi
export DOI_REGISTRY="$HOME/.claude/.doi-registry.md"
```

# Microservices — [Task Name]

## 1. [Microservice Name]
**Description:** [what it does]
**Order:** 1 of [N]
**Workflow Steps:**
1. [step]
2. [step]

**Core LLM Functions:**
| Function | Applies |
|---|---|
| Execute | [Yes/No] |
| Extract | [Yes/No] |
| Summarize | [Yes/No] |
| Analyze | [Yes/No] |
| Generate | [Yes/No] |
| Transform | [Yes/No] |
| Edit | [Yes/No] |
| Classify | [Yes/No] |

## 2. [Next Microservice]
...
```

### Constraints

- ALWAYS research tool APIs before classifying — do NOT assume what a tool can do
- Only extract tasks from the VERIFIED profile — do NOT invent tasks. Take what the user described face-value. 8 responsibilities should not become 20+ tasks.
- Include undocumented tasks from verification (Invisible Work section)
- Exclude aspirational items (they're not real tasks)
- Use the REALITY column from discrepancies, not the materials column
- Stage classification MUST include reasoning and confidence for every task
- KOODAR Observe/Orient = N/A for Stage 1-3 (these require the environmental awareness and proactive monitoring that only Stage 4 AI Coworkers have)
- Workflow steps must reference REAL API endpoints and integrations from integration-research.md — not generic "connect to API"
- Microservice counts MUST follow stage rules: Stage 1=0, Stage 2=1, Stage 3=2-5, Stage 4=3-8+
- If integration-research.md shows a limitation (no API, enterprise-only feature, missing integration), the stage classification and workflow must account for it
- Skip microservice decomposition for unaligned tasks — do not invest API research or microservice design in work that cannot be traced to a defined result.
- Do NOT score friction — that's Phase 6
- Do NOT recommend implementation order — that's Phase 9
- Task slugs: lowercase, hyphens, derived from task name

### Common Mistakes

| Mistake | Fix |
|---|---|
| Skipping tool research | Always run Tool/API Research before classifying tasks |
| Assuming API exists | Check official docs — many tools have no API or limited free-tier access |
| Fictional API endpoints | Every endpoint in workflow steps must come from tool-capabilities.md |
| Inventing tasks not in verification | Every task must trace to verified-role.md |
| Inflating task count | 8 responsibilities ≠ 20+ tasks. Extract what exists — don't decompose into sub-tasks during this phase |
| Missing undocumented tasks | Cross-reference verified-role.md "Undocumented Tasks" section |
| Human-centric workflow steps | Write AI-executable steps referencing real tool capabilities |
| KOODAR Observe/Orient on Stage 1-3 | Must be N/A — only Stage 4 (AI Coworker) has proactive environmental awareness |
| Stage 1 microservice decomposition | Skip — Stage 1 has no AI component |
| Generic reasoning | Be specific to this task: "Single input, single output, no judgment" |
| Decomposing unaligned tasks | Skip microservices for tasks with outcome_alignment = unaligned |
