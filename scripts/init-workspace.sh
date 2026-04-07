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

# If department specified, create department structure
if [ -n "$DEPT_SLUG" ]; then
    DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
    mkdir -p "$DEPT_DIR/source-docs"
    mkdir -p "$DEPT_DIR/assessments"

    # If roles specified, create role directories
    for role_slug in "${ROLE_SLUGS[@]}"; do
        if [ -n "$role_slug" ]; then
            ROLE_DIR="$DEPT_DIR/roles/$role_slug"
            mkdir -p "$ROLE_DIR/tasks"
            mkdir -p "$ROLE_DIR/microservices"
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
