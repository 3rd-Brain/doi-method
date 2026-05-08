---
name: doi-render
description: "Use when handing off a finalized DOI scorecard to a client (post-engagement archive, email/Slack share, no-server environments). Reads data/*.json from the engagement folder and bakes it into a single self-contained scorecard-handoff.html where data is inlined and the file works without python -m http.server. Cannot modify scorecard content — only converts the live HTML+JSON pair into a static frozen artifact."
user-invocable: true
license: GPL-3.0
metadata:
  version: 1.0.0
  author: 3rd Brain DigiOps
  category: operations
  domain: digital-operations-intelligence
  updated: 2026-05-09
---

### Overview

> **Voice:** Read `scripts/_config/voice.md` before drafting any client-facing output. Verification rule, vocabulary blocklist, Confusion Protocol all apply.

This skill freezes a completed DOI scorecard into a single self-contained HTML file. The live `scorecard.html` produced by `doi-intake` reads `data/scorecard.json` and `data/_index.json` over `fetch()`, which only works under a server (e.g., `python -m http.server`). The handoff version inlines the JSON directly into the HTML so the file opens via `file://` — emailable, Slack-attachable, archivable, no server required.

This is doi-scorecard's sibling, not its successor. doi-scorecard produces the data and the live page; doi-render converts that pair into a frozen artifact for distribution. The visual output is identical — same `render()` function, same data shape, same CSS — only the data load mechanism changes.

#### Role Constraints

- CAN: read `data/*.json`, read the live `scorecard.html`, produce `scorecard-handoff.html` with data baked in
- CANNOT: modify scorecard content (compression, verdict, ratings, deployable list, remediation — those belong to `doi-scorecard`); invent data not present in `data/scorecard.json`; change the visual rendering (the same `render()` function runs in both modes)

### Inputs

- The engagement folder path (input parameter, supplied by the operator or the orchestrator).
- `<engagement>/data/_index.json` — read for status; the `scorecard` field must be `"complete"`.
- `<engagement>/data/scorecard.json` — must exist and must parse as JSON.
- `<engagement>/scorecard.html` — the live template scaffolded by `doi-intake` via `init-workspace.sh`. If missing, fall back to `scripts/_templates/scorecard.html` and warn the operator that the engagement is using the canonical template rather than its own (any operator hand-edits to the live page would be lost in that fallback).

If `data/scorecard.json` is missing or `_index.json.scorecard !== "complete"`, the skill REFUSES with: `"Cannot render handoff before scorecard is complete. Run doi-scorecard first."` Do not produce a partial handoff. Do not synthesize a stand-in. Stop and tell the operator which phase has not yet completed.

### Process

1. Verify the inputs exist. Read `_index.json`. Confirm `scorecard === "complete"`. If not, refuse with the message above and stop.
2. Read `data/scorecard.json` (parse as JSON; abort with a clear error if it does not parse).
3. Read the engagement's `scorecard.html`. If missing, fall back to `scripts/_templates/scorecard.html` and warn the operator.
4. Replace the `async function load() { ... } load();` block with a `/* load() removed */` comment plus an inline `<script>`-internal data declaration: `const DATA = {...inlined JSON...}; render(DATA);`. The replacement preserves `PILLAR_LABELS`, `render()`, and `escapeHtml()` (those are unchanged) — only the async load + invocation are swapped for synchronous inline data + immediate render.
5. Write the result to `<engagement>/scorecard-handoff.html`.
6. Print a confirmation line with the absolute path to the new file and a one-line note: `"Open this file directly in a browser; no server required."`

### Output

Single artifact: `scorecard-handoff.html` in the engagement root. Self-contained: opens directly via `file://`, no server, no fetch, no external assets. Identical visual output to the live scorecard.

### Implementation note (for the agent running this skill)

The transformation is a straightforward find-and-replace on the source HTML. Pseudocode:

```python
import json, re

def render_handoff(engagement_folder):
    idx = json.load(open(f"{engagement_folder}/data/_index.json"))
    if idx.get("scorecard") != "complete":
        raise RuntimeError("Cannot render handoff before scorecard is complete. Run doi-scorecard first.")
    data = json.load(open(f"{engagement_folder}/data/scorecard.json"))
    html = open(f"{engagement_folder}/scorecard.html").read()

    # Replace the load() definition + invocation with inlined data + immediate render.
    # The load() function is the only async piece; everything else (PILLAR_LABELS,
    # render(), escapeHtml()) stays untouched.
    inline_script = (
        f"const DATA = {json.dumps(data, ensure_ascii=False)};\n"
        f"render(DATA);"
    )
    output = re.sub(
        r"async function load\(\)[\s\S]+?load\(\);",
        f"/* load() removed in handoff — data inlined */\n{inline_script}",
        html
    )
    open(f"{engagement_folder}/scorecard-handoff.html", "w").write(output)
```

The agent invoking this skill writes the actual transformation as a small Python script (or equivalent stdlib-only program) and runs it once. This is a templater, not a long-running process. No new dependencies — `json`, `re`, and `open` from the standard library are sufficient.

### Constraints

- Output must render IDENTICALLY to the live scorecard. Same `render()` function, same `PILLAR_LABELS`, same `escapeHtml()`, same data shape. The only difference is the data-load mechanism (inline `const DATA = ...` instead of `async function load()` + `fetch()`).
- Must NOT alter scorecard content. The verdict, the five pillar ratings, the deployable list, and the remediation roadmap are `doi-scorecard`'s outputs. doi-render is downstream of all of that and re-emits without editing.
- Must NOT invent data not present in `data/scorecard.json`. If a field is missing in the JSON, it stays missing in the handoff — same as in the live page.
- Must NOT inject extra metadata, branding, commentary, or footer notes. The handoff is the same artifact, just frozen.
- If the live `scorecard.html` has been hand-edited by the operator (e.g., a logo addition, a custom stylesheet), preserve those edits — the substitution targets only the `load()` block, not the page chrome.
- Stdlib only. No new dependencies.
- The output filename is `scorecard-handoff.html`. Do NOT overwrite the live `scorecard.html` — that file stays available for ongoing engagement use.

### Critic checks

The `doi-review` critic loads `evidence.md`, `principles.md`, `scope-drift.md`, and `invented-data.md` for this phase. The source `scorecard.json` was already validated against its schema by `doi-scorecard` before reaching this skill — doi-render does not re-validate the JSON, it refuses to run if `_index.json.scorecard !== "complete"`. The critic's job here is to confirm no content drift (the handoff renders the same verdict, ratings, deployables, and remediation as the source JSON) and no scope drift (the handoff adds nothing not in the source).
