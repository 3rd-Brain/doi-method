#!/usr/bin/env bash
set -euo pipefail

# Usage: update-index.sh <engagement-folder> <phase-key> <status>
# Example: update-index.sh ./engagements/acme "1_assess" "complete"
#
# Maintains the data/_index.json file in an engagement workspace.
# Status values: "pending", "in_progress", "complete".
# Phase key "scorecard" is special — also updates the top-level scorecard field.

ENGAGEMENT="$1"
PHASE_KEY="$2"
STATUS="$3"
INDEX="$ENGAGEMENT/data/_index.json"

mkdir -p "$ENGAGEMENT/data"

if [ ! -f "$INDEX" ]; then
  ORG_NAME="$(basename "$ENGAGEMENT")"
  cat > "$INDEX" <<EOF
{
  "organization": "$ORG_NAME",
  "phases": {},
  "scorecard": "pending"
}
EOF
fi

python - "$INDEX" "$PHASE_KEY" "$STATUS" <<'PY'
import json, sys
path, key, status = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    data = json.load(f)
data.setdefault("phases", {})[key] = status
if key == "scorecard":
    data["scorecard"] = status
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY
