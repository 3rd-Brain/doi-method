# Checklist: principles

**Applies to phases:** 5, 7, 9, 10

**Owner question:** Does every intervention, decomposition, or artifact comply with the 3rd Brain Build Principles? (`scripts/_config/3rd-brain-build-principles.md`)

## Checks

- [ ] pr-1 (Frontend-first for apps) — app interventions lead with the user-facing surface, not data model or API contract — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-2 (Solo-agent-first for workflows) — Stage 3 default is 1 agent + N tools; multi-agent only with cited measured bottleneck — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-3 (Ship every week) — every Tier 1 intervention has a "1-week shippable subset" AND a "Demo definition" — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-4 (Single agent until proven otherwise) — >1 microservice or >1 agent at any stage requires a cited measured bottleneck (latency/quality/cost) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-5 (ICM + folders before infrastructure) — Tools interventions tagged `files-default` OR `infrastructure-justified` (with file-failure mode cited) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-6 (Start with what we have built) — Tools interventions tagged `extend-existing` (naming the verified tool) OR `new-system` (with one-line justification) — emits finding `{check_id, severity, evidence_cite, finding}` if failed
- [ ] pr-7 (Demo before doc + 3 architect questions) — every Tier 1-2 intervention answers state owner / feedback signal / deletion impact — emits finding `{check_id, severity, evidence_cite, finding}` if failed

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

- CRITICAL: missing principle tag, missing required answer (e.g., no shippable subset for Tier 1, no measured bottleneck for multi-agent), or violation without rationale
- MINOR: principle tag present but rationale is thin
