# Checklist: Schema Conformance

**Applies to phases:** 1, 7, 8, 9, 10 (the phases that emit JSON outputs)

**Owner question:** Does the phase's JSON output exist, parse, and validate against its schema?

## Checks

- [ ] sc-1 — `data/phase-N-*.json` exists for the completed phase — emits CRITICAL finding if missing
- [ ] sc-2 — JSON parses as valid JSON — emits CRITICAL with parser error message in finding if parse fails
- [ ] sc-3 — JSON validates against `scripts/_config/output-schemas/<name>.json` — emits CRITICAL with the specific schema error path (e.g., `/tier_1/0/shippable_subset_1_week is required`)
- [ ] sc-4 — `data/_index.json` reflects the phase as `complete` — emits MINOR if missing or stale
- [ ] sc-5 — Conditional schema rules pass (e.g., for `route.json`: every `tools` bottleneck has both required tag pairs; for `roadmap.json`: every Tier 1 has `shippable_subset_1_week` and `demo_definition`) — emits CRITICAL on conditional rule failure

## How the critic runs this

The critic runs schema validation using the `jsonschema` Python library:

```bash
python -c "
import json
from jsonschema import Draft202012Validator, ValidationError
schema = json.load(open('scripts/_config/output-schemas/<name>.json'))
data = json.load(open('<engagement>/data/phase-N-<name>.json'))
errors = list(Draft202012Validator(schema).iter_errors(data))
for e in errors:
    path = '/'.join(str(p) for p in e.absolute_path)
    print(f'{path}: {e.message}')
"
```

If `jsonschema` is unavailable, the critic emits a MINOR finding noting the dependency missing AND falls back to a structural check: confirms the top-level required keys named in the schema's `required` array are present in the data.

## Output format per finding

```json
{
  "phase": "<phase number>",
  "checklist": "schema-conformance",
  "check_id": "<sc-1, sc-2, sc-3, sc-4, or sc-5>",
  "severity": "CRITICAL|MINOR",
  "finding": "<one-line description with the JSON path>",
  "evidence_cite": "<engagement>/data/phase-N-<name>.json",
  "confidence": <integer 1-10>
}
```

## Severity guide

- CRITICAL: missing JSON file, invalid JSON, schema validation fails, conditional rule fails (e.g., Tier 1 intervention missing `demo_definition`)
- MINOR: index file stale, optional fields missing, jsonschema library unavailable (graceful degradation)
