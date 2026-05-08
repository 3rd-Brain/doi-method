# Checklist: scope-drift

**Applies to phases:** all

**Owner question:** Does the phase output stay within the phase's scope contract (CAN/CANNOT)?

## Checks

- [ ] sd-1 — Output performs only operations the phase's `## Role Constraints` (or "CAN") section permits — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] sd-2 — Output does NOT perform operations the phase's "CANNOT" section forbids (e.g., `doi-verify` must not classify or score; `doi-friction` must not recommend) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] sd-3 — Output stays within the deliverable contract specified in the phase's `## Output Format` — no extra files written outside that contract — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] sd-4 — Output does not silently shift methodology (e.g., re-running prior phase work without flagging as a recompute) — emits finding `{check_id, severity, evidence_cite, finding}` if failed

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

- CRITICAL: explicit violation of a CANNOT (e.g., recommendation in a verification phase)
- MINOR: writing extra unrequested artifacts inside the phase scope (cleanup-worthy but not methodology breaking)
