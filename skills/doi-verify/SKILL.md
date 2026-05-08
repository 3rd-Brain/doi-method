---
name: doi-verify
description: "Use when verifying a role's documented responsibilities against their actual day-to-day work. Probes for discrepancies, discovers undocumented tasks, flags aspirational items, and captures time estimates. Cannot classify, score, or recommend."
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

Phase 3 of the DOI Method. Investigator — probes the gap between what materials say a role does and what the person actually does day-to-day. This is what separates DOI from blind self-assessment. People describe their roles aspirationally, not operationally. A marketing manager says "I develop campaign strategy" when they actually spend 3 hours a day copy-pasting data between spreadsheets.

This phase uses TWO verification methods:
1. **Direct System Observation** — connect to the operator's actual tools (Slack, CRM, PM tools, email, calendars) to observe real usage patterns, data structures, and workflows before asking questions
2. **Conversational Probing** — ask the operator targeted questions to fill gaps the systems can't reveal (motivations, frustrations, workarounds, tribal knowledge)

### Role Constraints

- CAN: Connect to operator systems, observe real usage data, ask probing questions, document discrepancies, capture time estimates, identify undocumented work
- CANNOT: Classify tasks by automation stage, score friction, recommend solutions, suggest tools

### Session Resolution

Standard DOI session resolution — check registry, confirm engagement, identify current department and role.

### Prerequisites

Call `$DOI_SCRIPTS/check-prerequisites.sh 3 <engagement-folder> <dept-slug> <role-slug>`
Required: `roles/{role-slug}/materials.md` must exist.

### Process

#### Step 1: Direct System Observation

Before asking the user a single question, observe their actual systems. Read `department.md` for the tools list, then connect to every available system:

**What to access and what to look for:**

| System Type | What to Observe | What It Reveals |
|---|---|---|
| **Slack / Teams** | Channel activity, message frequency, who talks to whom, recurring threads, bot integrations | Real communication patterns, handoffs, bottlenecks, informal processes |
| **CRM (HubSpot, Salesforce, etc.)** | Record counts, field usage, last-modified dates, pipeline stages, automation rules already in place | Data quality, actual vs. theoretical workflows, adoption depth |
| **Project Management (Asana, Monday, ClickUp, etc.)** | Task counts by assignee, overdue rates, recurring tasks, status distribution, template usage | Real workload distribution, process adherence, manual vs. automated task creation |
| **Calendar (Google, Outlook)** | Meeting frequency, recurring events, meeting-to-focus-time ratio | Time allocation reality, meeting overhead |
| **Email** | Volume, common recipients, recurring threads, auto-forwards/rules | Communication patterns, manual notification workflows |
| **File Storage (Google Drive, SharePoint, Dropbox)** | Folder structure, sharing patterns, naming conventions, recent activity | Documentation practices, collaboration patterns, data organization |
| **Spreadsheets** | Shared sheets with formulas, pivot tables, manual data entry patterns | Shadow IT — spreadsheets being used as databases or workflow tools |
| **Automation tools (Zapier, Make)** | Active zaps/scenarios, error rates, run history | Existing automation maturity, what's already been attempted |

**For each system, produce a System Observation Note:**

```markdown
### [Tool Name] — Observation Summary
**Access:** [Connected / Read-only / No access — explain why]
**Data quality:** [Clean / Mixed / Poor]
**Key findings:**
- [specific observation with data point]
- [specific observation]
**Discrepancies with materials:**
- [what materials claim vs. what the system shows]
**Hidden patterns:**
- [anything not mentioned in materials but visible in usage data]
```

Save all system observations to `roles/{role-slug}/tool-audit.md` before proceeding to conversational verification.

#### Step 2: Conversational Probing

Now that you have system data, your questions are sharper. You're not asking "what do you do?" — you're asking "I see X in your system, can you explain why?"

1. Present back what the materials say this person does — organized by apparent frequency
2. Present key findings from system observation — "I noticed [X] in your [tool]. Tell me about that."
3. Use AskUserQuestion for each probing question, ONE AT A TIME. Tailor based on what you observed:
   - "The job description says you [X]. But your CRM shows [Y]. Which is accurate?"
   - "I see you have 47 overdue tasks in Asana — is that normal, or is something broken?"
   - "Your Slack shows you posting in #support daily, but that's not in your job description. What's happening there?"
   - "There's a spreadsheet that gets updated every Monday with data from HubSpot. Is that you? Walk me through it."
   - "Your calendar shows 18 hours of meetings per week. Is that typical?"
   - "I see 3 Zapier automations connected to your CRM, but 2 have error rates above 20%. Are you aware?"
   - "What tasks eat your time that I wouldn't see in any of these systems?"
   - "What do you do manually that feels like it should be automated?"
4. For each discrepancy found:
   - Document what the materials say vs. what system data shows vs. what the user reports
   - Be specific with quantities ("2 hours/week" not "a lot of time")
   - Note when system data confirms or contradicts the user's account
5. For undocumented tasks (invisible work):
   - Probe deeper: "Tell me more about that spreadsheet export — what exactly do you do, step by step?"
   - Capture: what the task is, how often, how long, what tools involved
6. For aspirational items (described but not happening):
   - Note them explicitly — these reveal intent vs. reality gaps
   - Cross-reference with system data: "Materials say A/B testing on all campaigns, but I see no test variants in HubSpot"
7. Build time allocation table from user estimates AND system data
8. Write `verified-role.md`
9. Call `$DOI_SCRIPTS/update-state.sh <folder> phase="Phase 3"`

#### Step 3: When System Access Is Limited

If access to some or all systems is unavailable, follow this fallback chain:

**Fallback 1: Check `_uploads/`, then ask for more**

Before asking the operator for files, scan the engagement's upload tree for relevant artifacts that may already be there:

```bash
# Role-scoped exports for the role being verified
$DOI_SCRIPTS/scan-uploads.sh <engagement-folder> <dept-slug> <role-slug>

# Tool-wide exports (CRM dumps, integration screenshots, Zapier exports)
$DOI_SCRIPTS/scan-uploads.sh <engagement-folder> tool-exports
```

For each file relevant to the inaccessible system, read it and treat it as a supplementary observation source. Append a row to `_uploads/MANIFEST.md`:

`| <file> | 3 | doi-verify | tool-audit.md (<tool name>) | YYYY-MM-DD |`

Only **after** mining `_uploads/`, ask the operator for additional files for whatever gaps remain. Use AskUserQuestion:

> "I wasn't able to connect to [Tool Name] directly. I checked your uploads and found [N files / nothing relevant]. Do you have any other files that show how you use it — exports, reports, screenshots, dashboards? Drop them in `_uploads/{dept-slug}/{role-slug}/` or `_uploads/tool-exports/` and I'll re-scan, or we can skip and I'll ask you about it directly."

If the user provides additional files:
- Move/copy them into the appropriate `_uploads/` bucket and re-run the scan so the manifest stays accurate
- Mine the files for the same data points you'd look for in the live system (activity patterns, record counts, field usage, process flows)
- Use findings to inform your conversational probing in Step 2

**Fallback 2: Mine existing materials**

Before going fully conversational, re-read `materials.md` — the SOPs, job descriptions, and docs collected in Phase 2 are already there. Extract everything you can about this role's actual work patterns, tools used, and processes described. This gives you a baseline to probe against rather than asking cold.

**Fallback 3: Conversational-only**

If no files provided and no materials cover the gap, proceed with conversational probing for those areas. Your questions will be less targeted, so probe more thoroughly.

**Always flag gaps in the output:**
- "System observation: [tool] — No access. Supplementary files provided: [yes/no]"
- The critic will note limited access but it does not block progress

### Output Format

`roles/{role-slug}/verified-role.md`:

```markdown
---
role: [Role Name]
verified: true
verified_date: [YYYY-MM-DD]
discrepancies_found: [count]
undocumented_tasks: [count]
aspirational_items: [count]
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

# Verified Role Profile — [Role Name]

## System Observations Summary
[Which systems were accessed, key findings, data quality notes]
| System | Access | Data Quality | Key Finding |
|---|---|---|---|
| [tool name] | [Connected/Read-only/No access] | [Clean/Mixed/Poor] | [one-line finding] |

## Confirmed Responsibilities
[Tasks that matched between materials, system data, AND user's actual day-to-day]

## Discrepancies
| Materials Say | System Shows | User Reports |
|---|---|---|
| "[quoted from materials]" | [what the actual system data reveals] | [what user reports — specific, quantified] |

## Undocumented Tasks (Invisible Work)
[For each: what, how often, how long, what tools, why it exists]
- [Task description] (~[time]/[frequency])
  - Tools: [list]
  - Detail: [step by step if captured]

## Aspirational Items (Described But Not Happening)
[Items in the materials that the user says aren't actually occurring]
- "[quoted from materials]" — [why it's not happening]

## Verified Tools (Actually Used)
| Tool | Described | Actually Used | Usage Frequency | Primary Use |
|---|---|---|---|---|

## Time Allocation (User-Reported)
| Activity | Hours/Week | % of Role |
|---|---|---|
| [activity] | [hours] | [%] |
| **Total** | **[hours]** | **100%** |
```

### Verification Question Patterns

These patterns help probe without leading:

**For confirming responsibilities:**
- "Walk me through how you actually handle [X]"
- "When was the last time you did [Y]?"
- "How does [Z] actually work in practice?"

**For discovering invisible work:**
- "What do you spend time on that isn't in your job description?"
- "What repetitive tasks do you wish someone would take off your plate?"
- "Walk me through your first hour of a typical day"
- "What makes you stay late or feel behind?"

**For time accuracy:**
- "If I watched you do [X], how long would it take start to finish?"
- "How many times per week/month do you do this?"
- "Does anyone else help with this, or is it entirely on you?"

**For tool reality:**
- "Which of these tools do you actually open every day?"
- "Are there tools you're supposed to use but work around instead?"
- "Where do you use spreadsheets as a workaround?"

### Constraints

- Always observe systems BEFORE asking questions — data-informed questions are sharper
- Ask ONE question at a time — do not dump a survey
- When system data contradicts user claims, present the data respectfully: "I see X in your system — help me understand"
- Do NOT classify tasks by automation stage — that's Phase 4
- Do NOT score friction — that's Phase 5
- Do NOT suggest solutions or tools
- If the user reveals invisible work, probe deeper — don't move on too quickly
- Capture time estimates even if rough — "about 2 hours" is fine, "a while" is not
- Flag the gap between strategic work and operational work without editorializing
- If zero discrepancies found, flag it in the output — this is suspicious and the critic will check
- Time allocation should add up to approximately a full work week (35-45 hours). If way off, ask about it
- Preserve the user's language when quoting discrepancies — don't sanitize frustration
- If a system cannot be accessed, note it explicitly — do NOT silently skip it
- System observation data is evidence, not interpretation — record what the data shows, not what it means

### Common Mistakes

| Mistake | Fix |
|---|---|
| Skipping system observation | Always connect to available systems BEFORE asking questions |
| Asking questions systems already answered | Check CRM/PM/Slack data first — don't ask what you can observe |
| Accepting materials at face value | Cross-reference materials against system data AND user reports |
| Vague discrepancy documentation | Be specific: "2 hours/week on X" not "some time on reports" |
| Not probing undocumented work | Ask about typical days, tedious tasks, workarounds |
| Thin time estimates | Get hours/week for every major activity |
| Editorializing | Capture facts, system data, and user's words — don't interpret |
| Ignoring limited access | Explicitly note which systems couldn't be accessed and why |
