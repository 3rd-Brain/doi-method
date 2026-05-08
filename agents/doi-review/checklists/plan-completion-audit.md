# Checklist: plan-completion-audit

**Applies to phases:** between phases (orchestrator-driven, not a phase output check)

**Owner question:** Did the current phase deliver against every actionable item from the prior phase's output?

## Checks

- [ ] pc-1 — Every actionable item in the prior phase output is classified as one of `DONE` / `PARTIAL` / `NOT_DONE` / `CHANGED` against the current phase — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pc-2 — Every `PARTIAL` or `NOT_DONE` item carries a forced WHY: one of `scope_cut` / `context_exhaustion` / `misunderstood` / `blocked` / `forgotten` — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pc-3 — Every `CHANGED` item carries a one-line rationale explaining what changed and why — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pc-4 — Items classified as `DONE` are independently verifiable in the current phase output (cite where) — emits finding `{check_id, severity, evidence_cite, finding}` if failed

## Output format per finding

```json
{
  "phase": "<phase number>",
  "checklist": "<checklist name>",
  "check_id": "<id from list above>",
  "severity": "CRITICAL|MINOR",
  "finding": "<one-line description>",
  "evidence_cite": "<file:line or section reference>",
  "confidence": <integer 1-10>
}
```

## Severity guide

- CRITICAL: any `NOT_DONE` item without a `scope_cut` justification — the phase silently dropped work
- MINOR: `DONE` claim with vague evidence cite (e.g., "covered in roadmap" without section reference)
