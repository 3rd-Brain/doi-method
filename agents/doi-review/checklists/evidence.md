# Checklist: evidence

**Applies to phases:** 5, 6, 7, 8, 9, 10

**Owner question:** Does every score, claim, or recommendation cite specific evidence from prior phases?

## Checks

- [ ] ev-1 — Every numeric score (friction, pillar, maturity-derived) cites at least one piece of evidence (file path + section, or `_uploads/MANIFEST.md` row) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] ev-2 — Every recommendation traces to a specific finding from a prior phase (no recommendations grounded in nothing) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] ev-3 — Verbatim operator quotes are tagged as such (e.g., `(operator quote)`) and not paraphrased — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] ev-4 — Inferred facts are explicitly tagged `(inferred)` or `(inferred from <filename>)` — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] ev-5 — `_uploads/MANIFEST.md` rows referenced in the output exist and contain the cited rows — emits finding `{check_id, severity, evidence_cite, finding}` if failed

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

- CRITICAL: missing citation on a numeric score; recommendation with no traceable origin
- MINOR: citation present but vague (e.g., "see prior phase" without file/section)
