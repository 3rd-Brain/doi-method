# Checklist: invented-data

**Applies to phases:** 3, 5, 7, 9, 10

**Owner question:** Does every instance-specific fact in the output trace to a verifiable source?

## Checks

- [ ] id-1 — Every vendor field name, API endpoint, integration capability, error rate, or instance-specific feature claim traces to either: a `_uploads/MANIFEST.md` row, a web-search citation in `integration-research.md`, or the verified tool list in `verified-role.md` — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] id-2 — Web-search citations include URL + date accessed (not just "web search confirmed") — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] id-3 — Verified tool list entries used as citations are not bare tool names ("uses HubSpot") — they cite the specific row/feature claim from the verified-tool table — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] id-4 — `_uploads/MANIFEST.md` rows cited in the output actually exist in the file — emits finding `{check_id, severity, evidence_cite, finding}` if failed

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

- CRITICAL: any untraceable instance-specific claim (this is the "no invented data" rule — load-bearing)
- MINOR: citation exists but is too imprecise to verify in one step
