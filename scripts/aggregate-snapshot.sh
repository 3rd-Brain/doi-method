#!/bin/bash
# aggregate-snapshot.sh — Build role-snapshot.md from task and microservice files
# Usage: aggregate-snapshot.sh <engagement-folder> <dept-slug> <role-slug>
#
# Reads all tasks/{task-slug}.md files, extracts frontmatter, counts by frequency/stage,
# tallies microservices, and writes role-snapshot.md
#
# Task files must have YAML frontmatter with: task, frequency, stage, effort, confidence

set -e

ENGAGEMENT_DIR="$1"
DEPT_SLUG="$2"
ROLE_SLUG="$3"

if [ -z "$ENGAGEMENT_DIR" ] || [ -z "$DEPT_SLUG" ] || [ -z "$ROLE_SLUG" ]; then
    echo "ERROR: Usage: aggregate-snapshot.sh <engagement-folder> <dept-slug> <role-slug>"
    exit 1
fi

ROLE_DIR="$ENGAGEMENT_DIR/departments/$DEPT_SLUG/roles/$ROLE_SLUG"
TASKS_DIR="$ROLE_DIR/tasks"
MS_DIR="$ROLE_DIR/microservices"
OUTPUT="$ROLE_DIR/role-summary.md"

if [ ! -d "$TASKS_DIR" ]; then
    echo "ERROR: Tasks directory not found: $TASKS_DIR"
    exit 1
fi

# Initialize counters
total=0
daily=0; weekly=0; monthly=0; quarterly=0; triggered=0; infinite=0
stage1=0; stage2=0; stage3=0; stage4=0
ms_total=0; ms_stage2=0; ms_stage3=0; ms_stage4=0

# Read each task file
for task_file in "$TASKS_DIR"/*.md; do
    [ -f "$task_file" ] || continue
    total=$((total + 1))

    # Extract frontmatter values
    freq=""
    stg=""
    in_frontmatter=false

    while IFS= read -r line; do
        if [ "$line" = "---" ]; then
            if [ "$in_frontmatter" = true ]; then
                break
            else
                in_frontmatter=true
                continue
            fi
        fi

        if [ "$in_frontmatter" = true ]; then
            key=$(echo "$line" | cut -d: -f1 | tr -d '[:space:]')
            val=$(echo "$line" | cut -d: -f2- | tr -d '[:space:]')

            case "$key" in
                frequency) freq="$val" ;;
                stage) stg="$val" ;;
            esac
        fi
    done < "$task_file"

    # Count by frequency
    case "$freq" in
        daily) daily=$((daily + 1)) ;;
        weekly) weekly=$((weekly + 1)) ;;
        monthly) monthly=$((monthly + 1)) ;;
        quarterly) quarterly=$((quarterly + 1)) ;;
        triggered) triggered=$((triggered + 1)) ;;
        infinite) infinite=$((infinite + 1)) ;;
    esac

    # Count by stage
    case "$stg" in
        1) stage1=$((stage1 + 1)) ;;
        2) stage2=$((stage2 + 1)) ;;
        3) stage3=$((stage3 + 1)) ;;
        4) stage4=$((stage4 + 1)) ;;
    esac
done

# Count microservices per stage
if [ -d "$MS_DIR" ]; then
    for ms_file in "$MS_DIR"/*.md; do
        [ -f "$ms_file" ] || continue

        # Count markdown headers (##) as individual microservices within the file
        # Each microservice decomposition file may contain multiple microservices
        ms_count=$(grep -c "^## " "$ms_file" 2>/dev/null || echo "0")
        if [ "$ms_count" -eq 0 ]; then
            ms_count=1
        fi

        # Determine parent task stage from filename
        task_slug=$(basename "$ms_file" | sed 's/-microservices\.md$//')
        if [ -f "$TASKS_DIR/$task_slug.md" ]; then
            parent_stage=""
            in_fm=false
            while IFS= read -r line; do
                if [ "$line" = "---" ]; then
                    if [ "$in_fm" = true ]; then break; else in_fm=true; continue; fi
                fi
                if [ "$in_fm" = true ]; then
                    k=$(echo "$line" | cut -d: -f1 | tr -d '[:space:]')
                    v=$(echo "$line" | cut -d: -f2- | tr -d '[:space:]')
                    [ "$k" = "stage" ] && parent_stage="$v"
                fi
            done < "$TASKS_DIR/$task_slug.md"

            ms_total=$((ms_total + ms_count))
            case "$parent_stage" in
                2) ms_stage2=$((ms_stage2 + ms_count)) ;;
                3) ms_stage3=$((ms_stage3 + ms_count)) ;;
                4) ms_stage4=$((ms_stage4 + ms_count)) ;;
            esac
        fi
    done
fi

# Calculate percentages
calc_pct() {
    if [ "$2" -gt 0 ]; then
        echo $(( ($1 * 100) / $2 ))
    else
        echo 0
    fi
}

s1_pct=$(calc_pct $stage1 $total)
s2_pct=$(calc_pct $stage2 $total)
s3_pct=$(calc_pct $stage3 $total)
s4_pct=$(calc_pct $stage4 $total)

# Determine highest potential stage
potential_stage=0
[ "$stage1" -gt 0 ] && potential_stage=1
[ "$stage2" -gt 0 ] && potential_stage=2
[ "$stage3" -gt 0 ] && potential_stage=3
[ "$stage4" -gt 0 ] && potential_stage=4

# Get role name from responsibilities.md if it exists
role_name="$ROLE_SLUG"
if [ -f "$ROLE_DIR/responsibilities.md" ]; then
    extracted=$(grep -m1 "^# " "$ROLE_DIR/responsibilities.md" 2>/dev/null | sed 's/^# //')
    [ -n "$extracted" ] && role_name="$extracted"
fi

# Write snapshot
cat > "$OUTPUT" << EOF
---
role: $role_name
total_tasks: $total
---

# Role Summary -- $role_name

## Task Breakdown by Frequency
| Frequency | Count |
|---|---|
| Daily | $daily |
| Weekly | $weekly |
| Monthly | $monthly |
| Quarterly | $quarterly |
| Triggered | $triggered |
| Infinite | $infinite |
| **Total** | **$total** |

## Automation Distribution
| Stage | Count | % |
|---|---|---|
| Stage 1 (Workflow) | $stage1 | ${s1_pct}% |
| Stage 2 (AI Tool) | $stage2 | ${s2_pct}% |
| Stage 3 (AI Workflow) | $stage3 | ${s3_pct}% |
| Stage 4 (AI Coworker) | $stage4 | ${s4_pct}% |

## Microservices
| Stage | Microservices | Built |
|---|---|---|
| Stage 2 | $ms_stage2 | 0 |
| Stage 3 | $ms_stage3 | 0 |
| Stage 4 | $ms_stage4 | 0 |
| **Total** | **$ms_total** | **0** |

## Automation Overview
| Metric | Value |
|---|---|
| Current Stage | 0 |
| Potential Stage | $potential_stage |
| Tasks Automated | 0 / $total |
| Automation % | 0% |
EOF

echo "Snapshot written: $OUTPUT"
