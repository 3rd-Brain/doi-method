# DOI Method — Installation Guide

## Prerequisites

- **Claude Code** (Anthropic CLI) installed and configured
- **Claude Max or Team** subscription
- **macOS or Linux** (Windows supported via WSL/Git Bash)

## Installation

### Option 1: Install Script (Recommended)

```bash
git clone <repo-url>
cd doi-method
./install-doi.sh
```

The script copies:
- 10 skill directories → `~/.claude/skills/`
- 1 agent directory → `~/.claude/agents/`
- 6 scripts → `~/.claude/scripts/doi/`

### Option 2: Manual Installation

```bash
# Skills
cp -r skills/doi-* ~/.claude/skills/

# Agent
cp -r agents/doi-review ~/.claude/agents/

# Scripts
mkdir -p ~/.claude/scripts/doi
cp scripts/*.sh ~/.claude/scripts/doi/
chmod +x ~/.claude/scripts/doi/*.sh
```

## Verification

Open Claude Code and type:

```
/doi-run
```

You should see the DOI intake flow begin.

To verify individual components:

```bash
# Check skills installed
ls ~/.claude/skills/doi-*

# Check agent installed
ls ~/.claude/agents/doi-review/

# Check scripts installed
ls ~/.claude/scripts/doi/
```

## What Gets Installed

```
~/.claude/
  skills/
    doi-run/SKILL.md          # Orchestrator
    doi-intake/SKILL.md       # Phase 0
    doi-assess/SKILL.md       # Phase 1
    doi-setup/SKILL.md        # Phase 2
    doi-verify/SKILL.md       # Phase 3
    doi-roles/SKILL.md        # Phase 4
    doi-friction/SKILL.md     # Phase 5
    doi-route/SKILL.md        # Phase 6
    doi-pillars/SKILL.md      # Phase 7
    doi-roadmap/SKILL.md      # Phase 8
  agents/
    doi-review/AGENT.md       # Isolated critic
  scripts/
    doi/
      init-workspace.sh       # Scaffold engagement folders
      score-assessment.sh     # Calculate scores + hard caps
      check-prerequisites.sh  # Validate phase dependencies
      aggregate-snapshot.sh   # Build role snapshots
      calculate-friction.sh   # Friction rollup math
      update-state.sh         # State + registry updates
```

## Updating

Re-run the install script. It will detect existing files and ask before overwriting.

```bash
cd doi-method
git pull
./install-doi.sh
```

## Uninstall

```bash
rm -rf ~/.claude/skills/doi-*
rm -rf ~/.claude/agents/doi-review
rm -rf ~/.claude/scripts/doi/
```

This removes all DOI skills, the critic agent, and utility scripts. Engagement data in your workspace folders is not affected.

## Troubleshooting

### Skills not appearing in Claude Code

1. Verify files exist: `ls ~/.claude/skills/doi-run/SKILL.md`
2. Check file permissions: `chmod -R 644 ~/.claude/skills/doi-*`
3. Restart Claude Code

### Scripts failing with "permission denied"

```bash
chmod +x ~/.claude/scripts/doi/*.sh
```

### State file errors

If `.doi-state.md` or the registry becomes corrupted:

```bash
# View current state
cat <engagement-folder>/.doi-state.md

# View registry
cat ~/.claude/.doi-registry.md

# Reset a specific engagement's state (edit manually)
nano <engagement-folder>/.doi-state.md
```

### Windows (WSL/Git Bash) Notes

- Use forward slashes in paths
- Ensure `~/.claude/` resolves correctly in your shell
- The install script uses bash — run from Git Bash or WSL, not PowerShell
