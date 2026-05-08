#!/bin/bash
# init-workspace.sh — Create the DOI engagement folder tree
# Usage: init-workspace.sh <engagement-folder> [dept-slug] [role-slugs...]
#
# If only engagement-folder provided: creates top-level structure
# If dept-slug provided: creates department structure
# If role-slugs provided: creates role directories within department
#
# Idempotent — safe to re-run.

set -e

ENGAGEMENT_DIR="$1"
DEPT_SLUG="$2"
shift 2 2>/dev/null || true
ROLE_SLUGS=("$@")

if [ -z "$ENGAGEMENT_DIR" ]; then
    echo "ERROR: Engagement folder path required."
    echo "Usage: init-workspace.sh <engagement-folder> [dept-slug] [role-slugs...]"
    exit 1
fi

# Create top-level structure
mkdir -p "$ENGAGEMENT_DIR/assessments"
mkdir -p "$ENGAGEMENT_DIR/departments"
mkdir -p "$ENGAGEMENT_DIR/reviews"

# Upload tree — operator drops materials here, skills ingest from here
mkdir -p "$ENGAGEMENT_DIR/_uploads/general"
mkdir -p "$ENGAGEMENT_DIR/_uploads/tool-exports"

# Seed MANIFEST.md if it does not exist yet
MANIFEST="$ENGAGEMENT_DIR/_uploads/MANIFEST.md"
if [ ! -f "$MANIFEST" ]; then
    cat > "$MANIFEST" <<'EOF'
# Uploads Manifest

Provenance ledger for `_uploads/`. Every file ingested by a phase MUST be appended here.
The critic uses this to verify no invented data — if a phase output cites a fact not
traceable to either the operator's words or a manifest row, that is a methodology violation.

## Folder Map

- `_uploads/general/` — org-wide materials (org charts, P&Ls, decks, prior assessments)
- `_uploads/tool-exports/` — CRM dumps, Zapier/Make exports, integration screenshots, API specs
- `_uploads/{dept-slug}/` — department-scoped materials
- `_uploads/{dept-slug}/{role-slug}/` — role-scoped materials (job descriptions, SOPs, day-in-life docs)

## Ingestion Log

| File | Phase | Consumed By | Informed | Date |
|---|---|---|---|---|
EOF
fi

# Scorecard infrastructure — live one-page rendering during the engagement.
# Operators serve the engagement folder via `bash serve.sh` or double-click `serve.cmd`,
# then open http://localhost:8765/scorecard.html. Sections render "pending" until each
# phase JSON appears in data/. Refresh the browser to see updates.
mkdir -p "$ENGAGEMENT_DIR/data"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_SRC="$SCRIPT_DIR/_templates/scorecard.html"
if [ -f "$TEMPLATE_SRC" ] && [ ! -f "$ENGAGEMENT_DIR/scorecard.html" ]; then
    cp "$TEMPLATE_SRC" "$ENGAGEMENT_DIR/scorecard.html"
fi

INDEX_SCRIPT="$SCRIPT_DIR/update-index.sh"
if [ -x "$INDEX_SCRIPT" ] && [ ! -f "$ENGAGEMENT_DIR/data/_index.json" ]; then
    "$INDEX_SCRIPT" "$ENGAGEMENT_DIR" "0_intake" "in_progress"
fi

if [ ! -f "$ENGAGEMENT_DIR/serve.sh" ]; then
    cat > "$ENGAGEMENT_DIR/serve.sh" <<'SERVE_EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
python3 -m http.server 8765
SERVE_EOF
    chmod +x "$ENGAGEMENT_DIR/serve.sh"
fi

if [ ! -f "$ENGAGEMENT_DIR/serve.cmd" ]; then
    cat > "$ENGAGEMENT_DIR/serve.cmd" <<'SERVE_EOF'
@echo off
cd /d "%~dp0"
python -m http.server 8765
SERVE_EOF
fi

# If department specified, create department structure
if [ -n "$DEPT_SLUG" ]; then
    DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
    mkdir -p "$DEPT_DIR/source-docs"
    mkdir -p "$DEPT_DIR/assessments"

    # Department-scoped upload bucket
    mkdir -p "$ENGAGEMENT_DIR/_uploads/$DEPT_SLUG"

    # If roles specified, create role directories
    for role_slug in "${ROLE_SLUGS[@]}"; do
        if [ -n "$role_slug" ]; then
            ROLE_DIR="$DEPT_DIR/roles/$role_slug"
            mkdir -p "$ROLE_DIR/tasks"
            mkdir -p "$ROLE_DIR/microservices"

            # Role-scoped upload bucket
            mkdir -p "$ENGAGEMENT_DIR/_uploads/$DEPT_SLUG/$role_slug"
        fi
    done
fi

echo "Workspace initialized: $ENGAGEMENT_DIR"
if [ -n "$DEPT_SLUG" ]; then
    echo "  Department: $DEPT_SLUG"
fi
for role_slug in "${ROLE_SLUGS[@]}"; do
    if [ -n "$role_slug" ]; then
        echo "  Role: $role_slug"
    fi
done
