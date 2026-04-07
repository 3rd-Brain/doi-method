#!/bin/bash
# score-assessment.sh — Calculate assessment scores, apply hard caps, determine level
#
# Mode 1 — Initial assessment (30-question):
#   Usage: score-assessment.sh initial <engagement-folder> <responses-file>
#   responses-file: one line per question, format: panel0_item0=true
#   Output: writes computed scores to stdout as key=value pairs
#
# Mode 2 — Foundational pillar assessment:
#   Usage: score-assessment.sh foundational <scores...>
#   9 scores in order: teamStructure skillsDevelopment trainingAdoption
#                      processMapping automationDesign efficiencyOptimization
#                      systemDesign dataInfrastructure toolIntegration
#   Output: pillar totals + level determination
#
# Mode 3 — Advanced gate check:
#   Usage: score-assessment.sh advanced-gate <foundational-level> <pillar1-total> <pillar2-total> <pillar3-total>
#   Output: ELIGIBLE or NOT_ELIGIBLE with reason

set -e

MODE="$1"
shift

case "$MODE" in

    initial)
        ENGAGEMENT_DIR="$1"
        RESPONSES_FILE="$2"

        if [ -z "$ENGAGEMENT_DIR" ] || [ -z "$RESPONSES_FILE" ]; then
            echo "ERROR: Usage: score-assessment.sh initial <engagement-folder> <responses-file>"
            exit 1
        fi

        if [ ! -f "$RESPONSES_FILE" ]; then
            echo "ERROR: Responses file not found: $RESPONSES_FILE"
            exit 1
        fi

        # Initialize category scores
        cat0=0; cat1=0; cat2=0; cat3=0; cat4=0

        # Track gate items
        panel2_item0="false"
        panel2_item4="false"
        panel3_item0="false"
        panel3_item3="false"
        panel3_item5="false"
        panel1_item0="false"
        panel1_item2="false"

        # Parse responses
        while IFS='=' read -r key value; do
            # Trim whitespace
            key=$(echo "$key" | tr -d '[:space:]')
            value=$(echo "$value" | tr -d '[:space:]')

            if [ "$value" = "true" ]; then
                case "$key" in
                    panel0_item*) cat0=$((cat0 + 1)) ;;
                    panel1_item*) cat1=$((cat1 + 1)) ;;
                    panel2_item*) cat2=$((cat2 + 1)) ;;
                    panel3_item*) cat3=$((cat3 + 1)) ;;
                    panel4_item*) cat4=$((cat4 + 1)) ;;
                esac
            fi

            # Track gate items
            case "$key" in
                panel2_item0) panel2_item0="$value" ;;
                panel2_item4) panel2_item4="$value" ;;
                panel3_item0) panel3_item0="$value" ;;
                panel3_item3) panel3_item3="$value" ;;
                panel3_item5) panel3_item5="$value" ;;
                panel1_item0) panel1_item0="$value" ;;
                panel1_item2) panel1_item2="$value" ;;
            esac
        done < "$RESPONSES_FILE"

        total=$((cat0 + cat1 + cat2 + cat3 + cat4))

        # Determine raw level from score
        if [ "$total" -le 6 ]; then
            raw_level=1
        elif [ "$total" -le 12 ]; then
            raw_level=2
        elif [ "$total" -le 18 ]; then
            raw_level=3
        elif [ "$total" -le 24 ]; then
            raw_level=4
        else
            raw_level=5
        fi

        # Apply hard caps
        capped="false"
        cap_reason=""
        final_level=$raw_level

        # Level 1 caps
        if [ "$panel2_item0" != "true" ] || [ "$panel2_item4" != "true" ]; then
            if [ "$final_level" -gt 1 ]; then
                final_level=1
                capped="true"
                reasons=""
                [ "$panel2_item0" != "true" ] && reasons="No cloud-based software (panel2_item0)"
                [ "$panel2_item4" != "true" ] && { [ -n "$reasons" ] && reasons="$reasons, "; reasons="${reasons}No tool connectivity (panel2_item4)"; }
                cap_reason="$reasons"
            fi
        fi

        # Level 2 caps (only apply if not already capped lower)
        if [ "$capped" = "false" ]; then
            if [ "$panel3_item0" != "true" ] || [ "$panel3_item3" != "true" ] || [ "$panel3_item5" != "true" ]; then
                if [ "$final_level" -gt 2 ]; then
                    final_level=2
                    capped="true"
                    reasons=""
                    [ "$panel3_item0" != "true" ] && reasons="No automated data entry (panel3_item0)"
                    [ "$panel3_item3" != "true" ] && { [ -n "$reasons" ] && reasons="$reasons, "; reasons="${reasons}No automated data flows (panel3_item3)"; }
                    [ "$panel3_item5" != "true" ] && { [ -n "$reasons" ] && reasons="$reasons, "; reasons="${reasons}No single source of truth (panel3_item5)"; }
                    cap_reason="$reasons"
                fi
            fi
        fi

        # Level 3 caps
        if [ "$capped" = "false" ]; then
            if [ "$panel1_item0" != "true" ] || [ "$panel1_item2" != "true" ]; then
                if [ "$final_level" -gt 3 ]; then
                    final_level=3
                    capped="true"
                    reasons=""
                    [ "$panel1_item0" != "true" ] && reasons="No documented processes (panel1_item0)"
                    [ "$panel1_item2" != "true" ] && { [ -n "$reasons" ] && reasons="$reasons, "; reasons="${reasons}No step-by-step instructions (panel1_item2)"; }
                    cap_reason="$reasons"
                fi
            fi
        fi

        # Level name
        case "$final_level" in
            1) level_name="Information Silos" ;;
            2) level_name="Integratable Cloud" ;;
            3) level_name="Unified Data Layer" ;;
            4) level_name="Automated Workflow with Human-in-the-Loop" ;;
            5) level_name="AI-Driven Automation" ;;
        esac

        # Output
        echo "total_score=$total"
        echo "people_team_score=$cat0"
        echo "process_doc_score=$cat1"
        echo "technology_score=$cat2"
        echo "data_management_score=$cat3"
        echo "automation_score=$cat4"
        echo "raw_level=$raw_level"
        echo "final_level=$final_level"
        echo "level_name=$level_name"
        echo "capped=$capped"
        echo "cap_reason=$cap_reason"
        ;;

    foundational)
        # Read 9 scores from arguments
        if [ $# -ne 9 ]; then
            echo "ERROR: Foundational mode requires exactly 9 scores."
            echo "Usage: score-assessment.sh foundational <ts> <sd> <ta> <pm> <ad> <eo> <syd> <di> <ti>"
            exit 1
        fi

        ts=$1; sd=$2; ta=$3   # Talent Strategy
        pm=$4; ad=$5; eo=$6   # Workflow Optimization
        syd=$7; di=$8; ti=$9  # Digital Architecture

        pillar1=$((ts + sd + ta))
        pillar2=$((pm + ad + eo))
        pillar3=$((syd + di + ti))
        total=$((pillar1 + pillar2 + pillar3))

        # Determine level
        if [ "$total" -le 20 ]; then
            level=1; level_name="Information Silos";
        elif [ "$total" -le 34 ]; then
            level=2; level_name="Integratable Cloud"
        else
            level=3; level_name="Unified Data Layer"
        fi

        echo "talent_strategy_total=$pillar1"
        echo "workflow_optimization_total=$pillar2"
        echo "digital_architecture_total=$pillar3"
        echo "foundational_total=$total"
        echo "foundational_level=$level"
        echo "level_name=$level_name"
        ;;

    advanced-gate)
        FOUND_LEVEL="$1"
        P1="$2"; P2="$3"; P3="$4"

        if [ -z "$FOUND_LEVEL" ] || [ -z "$P1" ] || [ -z "$P2" ] || [ -z "$P3" ]; then
            echo "ERROR: Usage: score-assessment.sh advanced-gate <level> <pillar1> <pillar2> <pillar3>"
            exit 1
        fi

        eligible="true"
        reasons=""

        if [ "$FOUND_LEVEL" -lt 3 ]; then
            eligible="false"
            reasons="Foundational level $FOUND_LEVEL < required 3"
        fi

        if [ "$P1" -lt 7 ]; then
            eligible="false"
            [ -n "$reasons" ] && reasons="$reasons; "
            reasons="${reasons}Talent Strategy $P1/15 < required 7/15"
        fi

        if [ "$P2" -lt 7 ]; then
            eligible="false"
            [ -n "$reasons" ] && reasons="$reasons; "
            reasons="${reasons}Workflow Optimization $P2/15 < required 7/15"
        fi

        if [ "$P3" -lt 7 ]; then
            eligible="false"
            [ -n "$reasons" ] && reasons="$reasons; "
            reasons="${reasons}Digital Architecture $P3/15 < required 7/15"
        fi

        if [ "$eligible" = "true" ]; then
            echo "gate=ELIGIBLE"
        else
            echo "gate=NOT_ELIGIBLE"
            echo "reason=$reasons"
        fi
        ;;

    *)
        echo "ERROR: Unknown mode '$MODE'"
        echo "Usage: score-assessment.sh <initial|foundational|advanced-gate> ..."
        exit 1
        ;;
esac
