#!/bin/bash
# calculate-friction.sh — Roll up friction scores from task -> role -> department
#
# Mode 1 — Role friction tax:
#   Usage: calculate-friction.sh role <engagement-folder> <dept-slug> <role-slug>
#   Reads friction scores from task files, applies frequency weights, computes Role Friction Tax
#   Appends friction analysis to role-summary.md
#
# Mode 2 — Department friction report:
#   Usage: calculate-friction.sh department <engagement-folder> <dept-slug>
#   Aggregates all role friction data into department-level 3c-report.md
#
# Frequency weights: daily=20, weekly=4, monthly=1, quarterly=0.25, triggered=2, infinite=10
# (Using integer math: multiply by 100, so daily=2000, weekly=400, monthly=100, quarterly=25, triggered=200, infinite=1000)

set -e

MODE="$1"
ENGAGEMENT_DIR="$2"
DEPT_SLUG="$3"
ROLE_SLUG="$4"

# Frequency weight multiplied by 100 for integer math
freq_weight() {
    case "$1" in
        daily) echo 2000 ;;
        weekly) echo 400 ;;
        monthly) echo 100 ;;
        quarterly) echo 25 ;;
        triggered) echo 200 ;;
        infinite) echo 1000 ;;
        *) echo 100 ;;
    esac
}

# Extract friction total from a task file (looks for "| **Total** | **N/15**" pattern)
extract_friction() {
    local file="$1"
    # Look for the friction total line — extract number before /15
    local total=$(grep "/15" "$file" 2>/dev/null | grep -i "total" | sed 's/.*\*\*\([0-9]*\)\/15\*\*.*/\1/' | tail -1)
    if [ -z "$total" ]; then
        # Fallback: any line with N/15 pattern
        total=$(grep "/15" "$file" 2>/dev/null | tail -1 | sed 's/.*[^0-9]\([0-9][0-9]*\)\/15.*/\1/')
    fi
    echo "${total:-0}"
}

# Extract frequency from task frontmatter
extract_frequency() {
    local file="$1"
    local freq=""
    local in_fm=false
    while IFS= read -r line; do
        if [ "$line" = "---" ]; then
            if [ "$in_fm" = true ]; then break; else in_fm=true; continue; fi
        fi
        if [ "$in_fm" = true ]; then
            local k=$(echo "$line" | cut -d: -f1 | tr -d '[:space:]')
            local v=$(echo "$line" | cut -d: -f2- | tr -d '[:space:]')
            [ "$k" = "frequency" ] && freq="$v"
        fi
    done < "$file"
    echo "$freq"
}

extract_stage() {
    local file="$1"
    local stg=""
    local in_fm=false
    while IFS= read -r line; do
        if [ "$line" = "---" ]; then
            if [ "$in_fm" = true ]; then break; else in_fm=true; continue; fi
        fi
        if [ "$in_fm" = true ]; then
            local k=$(echo "$line" | cut -d: -f1 | tr -d '[:space:]')
            local v=$(echo "$line" | cut -d: -f2- | tr -d '[:space:]')
            [ "$k" = "stage" ] && stg="$v"
        fi
    done < "$file"
    echo "$stg"
}

case "$MODE" in

    role)
        if [ -z "$ROLE_SLUG" ]; then
            echo "ERROR: Usage: calculate-friction.sh role <engagement-folder> <dept-slug> <role-slug>"
            exit 1
        fi

        TASKS_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/tasks"
        SNAPSHOT="$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG/role-summary.md"

        if [ ! -d "$TASKS_DIR" ]; then
            echo "ERROR: Tasks directory not found: $TASKS_DIR"
            exit 1
        fi

        weighted_friction_sum=0
        weighted_max_sum=0
        task_count=0

        # Collect per-task data for the highest-friction table
        declare -a task_names=()
        declare -a task_freqs=()
        declare -a task_frictions=()
        declare -a task_stages=()
        declare -a task_weighted=()

        # Dimension accumulators
        dim_consistency=0; dim_clarity=0; dim_capacity=0
        dim_count=0

        for task_file in "$TASKS_DIR"/*.md; do
            [ -f "$task_file" ] || continue

            friction=$(extract_friction "$task_file")
            [ "$friction" -eq 0 ] && continue

            freq=$(extract_frequency "$task_file")
            stage=$(extract_stage "$task_file")
            weight=$(freq_weight "$freq")
            task_name=$(basename "$task_file" .md | tr '-' ' ')

            weighted=$((friction * weight / 100))
            max_weighted=$((15 * weight / 100))

            weighted_friction_sum=$((weighted_friction_sum + weighted))
            weighted_max_sum=$((weighted_max_sum + max_weighted))
            task_count=$((task_count + 1))

            task_names+=("$task_name")
            task_freqs+=("$freq")
            task_frictions+=("$friction")
            task_stages+=("$stage")
            task_weighted+=("$weighted")

            # Extract individual dimension scores if present
            for dim in "Consistency" "Clarity" "Capacity"; do
                val=$(grep -i "| $dim " "$task_file" 2>/dev/null | sed 's/.*| *\([0-9][0-9]*\) *|.*/\1/' | head -1)
                if [ -n "$val" ] && [ "$val" -eq "$val" ] 2>/dev/null; then
                    case "$dim" in
                        Consistency) dim_consistency=$((dim_consistency + val)) ;;
                        Clarity) dim_clarity=$((dim_clarity + val)) ;;
                        Capacity) dim_capacity=$((dim_capacity + val)) ;;
                    esac
                    dim_count=$((dim_count + 1))
                fi
            done
        done

        # Calculate friction tax
        if [ "$weighted_max_sum" -gt 0 ]; then
            friction_tax=$(( (weighted_friction_sum * 100) / weighted_max_sum ))
        else
            friction_tax=0
        fi

        # Calculate dimension averages (x10 for one decimal place)
        tasks_with_dims=$((dim_count / 3))
        if [ "$tasks_with_dims" -gt 0 ]; then
            avg_consistency=$(( (dim_consistency * 10) / tasks_with_dims ))
            avg_clarity=$(( (dim_clarity * 10) / tasks_with_dims ))
            avg_capacity=$(( (dim_capacity * 10) / tasks_with_dims ))
        else
            avg_consistency=0; avg_clarity=0; avg_capacity=0
        fi

        # Format averages as X.Y
        fmt_avg() { echo "$(($1 / 10)).$(($1 % 10))"; }

        # Append to snapshot
        cat >> "$SNAPSHOT" << EOF

## Friction Analysis

**Role Friction Tax: ${friction_tax}%**
${friction_tax}% of this role's operational capacity is consumed by friction, not output.

### Highest Friction Tasks
| Task | Frequency | Friction | Stage | Weighted Impact |
|---|---|---|---|---|
EOF

        # Sort by weighted impact (simple bubble - small dataset)
        n=${#task_weighted[@]}
        for ((i=0; i<n; i++)); do
            for ((j=i+1; j<n; j++)); do
                if [ "${task_weighted[$j]}" -gt "${task_weighted[$i]}" ]; then
                    # Swap all arrays
                    tmp="${task_names[$i]}"; task_names[$i]="${task_names[$j]}"; task_names[$j]="$tmp"
                    tmp="${task_freqs[$i]}"; task_freqs[$i]="${task_freqs[$j]}"; task_freqs[$j]="$tmp"
                    tmp="${task_frictions[$i]}"; task_frictions[$i]="${task_frictions[$j]}"; task_frictions[$j]="$tmp"
                    tmp="${task_stages[$i]}"; task_stages[$i]="${task_stages[$j]}"; task_stages[$j]="$tmp"
                    tmp="${task_weighted[$i]}"; task_weighted[$i]="${task_weighted[$j]}"; task_weighted[$j]="$tmp"
                fi
            done
        done

        # Write top tasks (max 10)
        limit=$n
        [ "$limit" -gt 10 ] && limit=10
        for ((i=0; i<limit; i++)); do
            echo "| ${task_names[$i]} | ${task_freqs[$i]} | ${task_frictions[$i]}/15 | ${task_stages[$i]} | ${task_weighted[$i]} |" >> "$SNAPSHOT"
        done

        cat >> "$SNAPSHOT" << EOF

### Friction by Dimension (Role Average)
| Dimension | Avg Score |
|---|---|
| Consistency | $(fmt_avg $avg_consistency) |
| Clarity | $(fmt_avg $avg_clarity) |
| Capacity | $(fmt_avg $avg_capacity) |
EOF

        echo "friction_tax=$friction_tax"
        echo "tasks_scored=$task_count"
        echo "Friction analysis appended to: $SNAPSHOT"
        ;;

    department)
        if [ -z "$DEPT_SLUG" ]; then
            echo "ERROR: Usage: calculate-friction.sh department <engagement-folder> <dept-slug>"
            exit 1
        fi

        DEPT_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG"
        OUTPUT="$DEPT_DIR/3c-report.md"

        if [ ! -d "$DEPT_DIR/roles" ]; then
            echo "ERROR: No roles directory: $DEPT_DIR/roles"
            exit 1
        fi

        # Collect role-level friction data
        dept_total_tasks=0
        dept_weighted_friction=0
        dept_weighted_max=0

        declare -a role_names=()
        declare -a role_task_counts=()
        declare -a role_taxes=()

        for role_dir in "$DEPT_DIR"/roles/*/; do
            [ -d "$role_dir" ] || continue
            role_slug=$(basename "$role_dir")
            snapshot="$role_dir/role-summary.md"

            if [ ! -f "$snapshot" ]; then
                continue
            fi

            # Extract friction tax from snapshot
            tax=$(grep "Role Friction Tax:" "$snapshot" 2>/dev/null | sed 's/.*Tax: *\([0-9]*\).*/\1/' || echo "0")
            [ -z "$tax" ] && tax=0
            task_count=$(grep "total_tasks:" "$snapshot" 2>/dev/null | sed 's/.*total_tasks: *\([0-9]*\).*/\1/' || echo "0")
            [ -z "$task_count" ] && task_count=0

            # Get role name
            rname=$(grep -m1 "^# Role Summary -- " "$snapshot" 2>/dev/null | sed 's/^# Role Summary -- //')
            [ -z "$rname" ] && rname="$role_slug"

            role_names+=("$rname")
            role_task_counts+=("$task_count")
            role_taxes+=("$tax")

            dept_total_tasks=$((dept_total_tasks + task_count))
        done

        # Calculate department friction tax (average of role taxes, weighted by task count)
        if [ "$dept_total_tasks" -gt 0 ]; then
            weighted_tax_sum=0
            for ((i=0; i<${#role_names[@]}; i++)); do
                weighted_tax_sum=$((weighted_tax_sum + role_taxes[$i] * role_task_counts[$i]))
            done
            dept_tax=$((weighted_tax_sum / dept_total_tasks))
        else
            dept_tax=0
        fi

        # Get department name
        dept_name="$DEPT_SLUG"
        if [ -f "$DEPT_DIR/department.md" ]; then
            extracted=$(grep -m1 "^# " "$DEPT_DIR/department.md" 2>/dev/null | sed 's/^# //')
            [ -n "$extracted" ] && dept_name="$extracted"
        fi

        TODAY=$(date +%Y-%m-%d)

        cat > "$OUTPUT" << EOF
---
department: $dept_name
department_friction_tax: ${dept_tax}%
assessed_date: $TODAY
---

# Friction Report -- $dept_name

**Department Friction Tax: ${dept_tax}%**
${dept_tax}% of this department's total capacity is friction.

## By Role
| Role | Tasks | Friction Tax |
|---|---|---|
EOF

        for ((i=0; i<${#role_names[@]}; i++)); do
            echo "| ${role_names[$i]} | ${role_task_counts[$i]} | ${role_taxes[$i]}% |" >> "$OUTPUT"
        done

        echo "" >> "$OUTPUT"
        echo "Friction report written: $OUTPUT"
        echo "department_friction_tax=$dept_tax"
        ;;

    *)
        echo "ERROR: Unknown mode '$MODE'"
        echo "Usage: calculate-friction.sh <role|department> ..."
        exit 1
        ;;
esac
