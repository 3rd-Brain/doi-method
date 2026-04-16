#!/bin/bash
# update-state.sh — Update .doi-state.md and ~/.claude/.doi-registry.md
#
# Usage: update-state.sh <engagement-folder> <key=value> [key=value ...]
#
# Updates YAML frontmatter fields in .doi-state.md and the matching row
# in the global registry.
#
# Special keys:
#   phase=<value>          Updates phase in both state and registry
#   status=<value>         Updates status in both state and registry
#   current_department=<v> Updates current department in state
#   current_role=<v>       Updates current role in state
#   organization=<v>       Updates org name in state and registry
#   add_completed_role=<v> Moves role from remaining to completed
#   add_completed_dept=<v> Moves department from remaining to completed
#
# Always updates 'updated' timestamp in both files.

set -e

ENGAGEMENT_DIR="$1"
shift

if [ -z "$ENGAGEMENT_DIR" ]; then
    echo "ERROR: Usage: update-state.sh <engagement-folder> <key=value> ..."
    exit 1
fi

STATE_FILE="$ENGAGEMENT_DIR/.doi-state.md"
REGISTRY="${DOI_REGISTRY:-$HOME/.claude/.doi-registry.md}"
TODAY=$(date +%Y-%m-%d)

if [ ! -f "$STATE_FILE" ]; then
    echo "ERROR: State file not found: $STATE_FILE"
    exit 1
fi

# Parse key=value arguments
declare -A updates
for arg in "$@"; do
    key="${arg%%=*}"
    value="${arg#*=}"
    updates["$key"]="$value"
done

# Always update timestamp
updates["updated"]="$TODAY"

# Update .doi-state.md frontmatter
update_frontmatter() {
    local file="$1"
    local key="$2"
    local value="$3"
    local tmpfile="${file}.tmp"

    if grep -q "^${key}:" "$file" 2>/dev/null; then
        # Key exists — replace it
        sed "s|^${key}:.*|${key}: ${value}|" "$file" > "$tmpfile"
        mv "$tmpfile" "$file"
    else
        # Key doesn't exist — add before closing ---
        # Find the second --- and insert before it
        local line_num=$(grep -n "^---$" "$file" | sed -n '2p' | cut -d: -f1)
        if [ -n "$line_num" ]; then
            sed "${line_num}i\\${key}: ${value}" "$file" > "$tmpfile"
            mv "$tmpfile" "$file"
        fi
    fi
}

# Update state file
for key in "${!updates[@]}"; do
    case "$key" in
        add_completed_role|add_completed_dept)
            # These are list operations, skip frontmatter update
            ;;
        *)
            update_frontmatter "$STATE_FILE" "$key" "${updates[$key]}"
            ;;
    esac
done

# Update registry if it exists
if [ -f "$REGISTRY" ]; then
    # Extract org name from state for matching
    org_name=$(grep "^organization:" "$STATE_FILE" | head -1 | sed 's/^organization: *//')

    # Build new values for registry columns
    new_phase="${updates[phase]}"
    new_status="${updates[status]}"

    if [ -n "$org_name" ]; then
        # Update the matching row in the registry table
        tmpfile="${REGISTRY}.tmp"

        while IFS= read -r line; do
            if echo "$line" | grep -q "| $org_name " 2>/dev/null || echo "$line" | grep -q "|$org_name|" 2>/dev/null; then
                # This is the matching row — update fields
                if [ -n "$new_phase" ]; then
                    line=$(echo "$line" | awk -F'|' -v phase="$new_phase" '{
                        OFS="|"; $5=" "phase" "; print
                    }')
                fi
                if [ -n "$new_status" ]; then
                    line=$(echo "$line" | awk -F'|' -v status="$new_status" '{
                        OFS="|"; $6=" "status" "; print
                    }')
                fi
                # Always update timestamp
                line=$(echo "$line" | awk -F'|' -v date="$TODAY" '{
                    OFS="|"; $8=" "date" "; print
                }')
            fi
            echo "$line"
        done < "$REGISTRY" > "$tmpfile"
        mv "$tmpfile" "$REGISTRY"
    fi
fi

echo "State updated: $STATE_FILE"
[ -f "$REGISTRY" ] && echo "Registry updated: $REGISTRY"
