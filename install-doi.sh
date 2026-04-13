#!/bin/bash
# DOI Method Installer
# Copies all DOI skills, agents, and scripts into your Claude Code directories.
# Run from the folder containing this script.

set -e

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"
SCRIPTS_DIR="$HOME/.claude/scripts"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_SKILLS="$SCRIPT_DIR/skills"
SOURCE_AGENTS="$SCRIPT_DIR/agents"
SOURCE_SCRIPTS="$SCRIPT_DIR/scripts"

# Check source exists
if [ ! -d "$SOURCE_SKILLS" ]; then
    echo "ERROR: No 'skills/' folder found next to this script."
    echo "Expected: $SOURCE_SKILLS"
    echo "Make sure you're running this from the DOI Method folder."
    exit 1
fi

# Create directories if they don't exist
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$SCRIPTS_DIR"

# Count what we're installing
SKILL_COUNT=$(find "$SOURCE_SKILLS" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ')
AGENT_COUNT=0
if [ -d "$SOURCE_AGENTS" ]; then
    AGENT_COUNT=$(find "$SOURCE_AGENTS" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ')
fi
SCRIPT_COUNT=0
if [ -d "$SOURCE_SCRIPTS" ]; then
    SCRIPT_COUNT=$(find "$SOURCE_SCRIPTS" -maxdepth 1 -type f -name "*.sh" | wc -l | tr -d ' ')
fi

echo ""
echo "DOI Method Installer"
echo "===================="
echo ""
echo "Digital Operations Institute"
echo ""
echo "Source:      $SCRIPT_DIR"
echo "Skills dir:  $SKILLS_DIR"
echo "Agents dir:  $AGENTS_DIR"
echo "Scripts dir: $SCRIPTS_DIR"
echo "Skills:      $SKILL_COUNT"
echo "Agents:      $AGENT_COUNT"
echo "Scripts:     $SCRIPT_COUNT"
echo ""

# Check for existing installs
EXISTING=0
for skill_dir in "$SOURCE_SKILLS"/doi-*; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    if [ -d "$SKILLS_DIR/$skill_name" ]; then
        EXISTING=$((EXISTING + 1))
    fi
done
if [ -d "$SOURCE_AGENTS" ]; then
    for agent_dir in "$SOURCE_AGENTS"/doi-*; do
        [ -d "$agent_dir" ] || continue
        agent_name=$(basename "$agent_dir")
        if [ -d "$AGENTS_DIR/$agent_name" ]; then
            EXISTING=$((EXISTING + 1))
        fi
    done
fi

if [ "$EXISTING" -gt 0 ]; then
    echo "WARNING: $EXISTING existing DOI skill(s)/agent(s) found. They will be overwritten."
    echo ""
    read -p "Continue? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Copy skills
echo "Installing skills..."
for skill_dir in "$SOURCE_SKILLS"/doi-*; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    echo "  $skill_name"
    rm -rf "$SKILLS_DIR/$skill_name"
    cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
done

# Copy agents
if [ -d "$SOURCE_AGENTS" ] && [ "$AGENT_COUNT" -gt 0 ]; then
    echo ""
    echo "Installing agents..."
    for agent_dir in "$SOURCE_AGENTS"/doi-*; do
        [ -d "$agent_dir" ] || continue
        agent_name=$(basename "$agent_dir")
        echo "  $agent_name"
        rm -rf "$AGENTS_DIR/$agent_name"
        cp -r "$agent_dir" "$AGENTS_DIR/$agent_name"
    done
fi

# Copy scripts
if [ -d "$SOURCE_SCRIPTS" ] && [ "$SCRIPT_COUNT" -gt 0 ]; then
    echo ""
    echo "Installing scripts..."
    mkdir -p "$SCRIPTS_DIR/doi"
    for script_file in "$SOURCE_SCRIPTS"/*.sh; do
        [ -f "$script_file" ] || continue
        script_name=$(basename "$script_file")
        echo "  $script_name"
        cp "$script_file" "$SCRIPTS_DIR/doi/$script_name"
        chmod +x "$SCRIPTS_DIR/doi/$script_name"
    done
fi

TOTAL=$((SKILL_COUNT + AGENT_COUNT + SCRIPT_COUNT))
echo ""
echo "Done. $SKILL_COUNT skills + $AGENT_COUNT agents + $SCRIPT_COUNT scripts installed."
echo ""
echo "To verify, open Claude Code and type: /doi-run"
echo ""
echo "To uninstall:"
echo "  rm -rf ~/.claude/skills/doi-*"
echo "  rm -rf ~/.claude/agents/doi-review"
echo "  rm -rf ~/.claude/scripts/doi/"
echo ""
