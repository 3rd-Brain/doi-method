#!/bin/bash
# check-prerequisites.sh — Validate required files exist for a given phase
# Usage: check-prerequisites.sh <phase-number> <engagement-folder> [dept-slug] [role-slug]
#
# Output: PASS or FAIL with list of missing files
# Exit code: 0 = pass, 1 = fail

set -e

PHASE="$1"
ENGAGEMENT_DIR="$2"
DEPT_SLUG="$3"
ROLE_SLUG="$4"

if [ -z "$PHASE" ] || [ -z "$ENGAGEMENT_DIR" ]; then
    echo "ERROR: Usage: check-prerequisites.sh <phase> <engagement-folder> [dept-slug] [role-slug]"
    exit 1
fi

MISSING=()

check_file() {
    if [ ! -f "$1" ]; then
        MISSING+=("$1")
    fi
}

check_dir_has_files() {
    if [ ! -d "$1" ] || [ -z "$(ls -A "$1" 2>/dev/null)" ]; then
        MISSING+=("$1 (directory empty or missing)")
    fi
}

case "$PHASE" in

    0)
        # Phase 0 (Intake): No prerequisites
        ;;

    1)
        # Phase 1 (Initial Assessment): company-profile.md must exist
        check_file "$ENGAGEMENT_DIR/company-profile.md"
        ;;

    2)
        # Phase 2 (Department Setup): maturity assessment must exist
        check_file "$ENGAGEMENT_DIR/assessments/maturity-assessment.md"
        ;;

    3)
        # Phase 3 (Verification): materials.md for the role
        if [ -z "$DEPT_SLUG" ] || [ -z "$ROLE_SLUG" ]; then
            echo "ERROR: Phase 3 requires dept-slug and role-slug"
            exit 1
        fi
        check_file "$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/materials.md"
        ;;

    4)
        # Phase 4 (Outcome Mapping): verified-role.md must exist
        if [ -z "$DEPT_SLUG" ] || [ -z "$ROLE_SLUG" ]; then
            echo "ERROR: Phase 4 requires dept-slug and role-slug"
            exit 1
        fi
        check_file "$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/verified-role.md"
        ;;

    5)
        # Phase 5 (Role Pipeline): verified-role.md for the role
        if [ -z "$DEPT_SLUG" ] || [ -z "$ROLE_SLUG" ]; then
            echo "ERROR: Phase 5 requires dept-slug and role-slug"
            exit 1
        fi
        check_file "$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/verified-role.md"
        ;;

    6)
        # Phase 6 (Friction): task files must exist for the role
        if [ -z "$DEPT_SLUG" ] || [ -z "$ROLE_SLUG" ]; then
            echo "ERROR: Phase 6 requires dept-slug and role-slug"
            exit 1
        fi
        check_dir_has_files "$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/tasks"
        ;;

    7)
        # Phase 7 (Bottleneck Routing): all role summaries in department
        if [ -z "$DEPT_SLUG" ]; then
            echo "ERROR: Phase 7 requires dept-slug"
            exit 1
        fi
        DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
        if [ ! -d "$DEPT_DIR/roles" ]; then
            MISSING+=("$DEPT_DIR/roles (no roles directory)")
        else
            for role_dir in "$DEPT_DIR"/roles/*/; do
                [ -d "$role_dir" ] || continue
                check_file "${role_dir}role-summary.md"
            done
        fi
        ;;

    8)
        # Phase 8 (Pillar Assessment): all role summaries + gap analysis
        if [ -z "$DEPT_SLUG" ]; then
            echo "ERROR: Phase 8 requires dept-slug"
            exit 1
        fi
        DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
        check_file "$DEPT_DIR/gap-analysis.md"
        if [ -d "$DEPT_DIR/roles" ]; then
            for role_dir in "$DEPT_DIR"/roles/*/; do
                [ -d "$role_dir" ] || continue
                check_file "${role_dir}role-summary.md"
            done
        fi
        ;;

    9)
        # Phase 9 (Roadmap): foundational assessment + 3c-report + gap analysis must exist
        if [ -z "$DEPT_SLUG" ]; then
            echo "ERROR: Phase 9 requires dept-slug"
            exit 1
        fi
        DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
        check_file "$DEPT_DIR/assessments/foundational.md"
        check_file "$DEPT_DIR/3c-report.md"
        check_file "$DEPT_DIR/gap-analysis.md"
        ;;

    *)
        echo "ERROR: Unknown phase '$PHASE'. Valid phases: 0-9"
        exit 1
        ;;
esac

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "PASS"
    exit 0
else
    echo "FAIL"
    echo "Missing prerequisites for Phase $PHASE:"
    for item in "${MISSING[@]}"; do
        echo "  - $item"
    done
    exit 1
fi
