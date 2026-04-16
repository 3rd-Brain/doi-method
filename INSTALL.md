# Installing DOI Method

## Cowork Plugin (recommended)

```bash
git clone https://github.com/gentoftech/doi-method.git
cd doi-method
./install-doi.sh
```

Installs to `~/.claude/plugins/doi-method/`. If the source is a git repo, it symlinks for easy `git pull` updates.

## Legacy Install

```bash
./install-doi.sh --legacy
```

Copies skills to `~/.claude/skills/`, agents to `~/.claude/agents/`, scripts to `~/.claude/scripts/doi/`.

## Verify

Open Claude Code and type `/doi-run`. If the skill loads, you're set.

## Uninstall

**Cowork:** `rm -rf ~/.claude/plugins/doi-method`

**Legacy:** `rm -rf ~/.claude/skills/doi-* ~/.claude/agents/doi-review ~/.claude/scripts/doi/`
