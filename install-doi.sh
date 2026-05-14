#!/bin/bash
# DOI Method Installer (Claude Code CLI)
# Official install mode: plugin install that registers in installed_plugins.json
#   and places the plugin under ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/
#   — the location Claude Code actually scans for plugins.
# Advanced mode: standalone skill install to ~/.claude/skills/.
# For Cowork, upload the repo as a custom plugin for the full flow.
# Run from the folder containing this script.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_SKILLS="$SCRIPT_DIR/skills"
SOURCE_AGENTS="$SCRIPT_DIR/agents"
SOURCE_SCRIPTS="$SCRIPT_DIR/scripts"

is_windows_bash() {
    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

# Place repo contents at $2 as a live link to $1 so `git pull` updates the
# install, falling back to a copy when that's not possible.
#   Unix/macOS: ln -s
#   Windows (Git Bash): cmd //c mklink /J  (directory junction, no admin needed)
make_live_link_or_copy() {
    src="$1"
    dst="$2"
    if is_windows_bash; then
        if command -v cygpath >/dev/null 2>&1; then
            src_win=$(cygpath -w "$src")
            dst_win=$(cygpath -w "$dst")
            if cmd //c "mklink /J \"$dst_win\" \"$src_win\"" >/dev/null 2>&1; then
                echo "Junctioned: $dst -> $src"
                return 0
            fi
        fi
        cp -r "$src" "$dst"
        echo "Copied:    $src -> $dst (Windows: junction unavailable, used copy)"
    else
        if ln -s "$src" "$dst" 2>/dev/null; then
            echo "Symlinked: $dst -> $src"
        else
            cp -r "$src" "$dst"
            echo "Copied:    $src -> $dst (symlink failed, used copy)"
        fi
    fi
}

usage() {
    echo "Usage: ./install-doi.sh [--plugin|--standalone|--legacy]"
    echo ""
    echo "  --plugin       Install DOI as a Claude Code plugin (default)"
    echo "  --standalone   Install DOI as standalone skills for bare /doi-run"
    echo "  --legacy       Alias for --standalone"
}

# Determine install mode
INSTALL_MODE="plugin"  # default: plugin install for /doi-method:doi-run
case "$1" in
    ""|--plugin)
        INSTALL_MODE="plugin"
        ;;
    --standalone|--legacy)
        INSTALL_MODE="standalone"
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo ""
echo "DOI Method Installer"
echo "===================="
echo ""

if [ "$INSTALL_MODE" = "plugin" ]; then
    # Claude Code plugin install. Modern Claude Code only discovers plugins that
    # are (a) cloned under ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/
    # AND (b) registered in ~/.claude/plugins/installed_plugins.json. Just
    # dropping a directory in ~/.claude/plugins/<name>/ is NOT enough — that was
    # this script's old behavior and silently failed on current Claude Code.

    # We need python 3 to safely edit the registry JSON files.
    PYTHON=""
    for cand in python3 python; do
        if command -v "$cand" >/dev/null 2>&1; then
            if "$cand" -c "import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)" 2>/dev/null; then
                PYTHON="$cand"
                break
            fi
        fi
    done
    if [ -z "$PYTHON" ]; then
        echo "ERROR: Plugin install needs python 3 on PATH (to update Claude Code's plugin registry)."
        echo "Either install Python 3, or rerun with --standalone."
        exit 1
    fi

    PLUGIN_MANIFEST="$SCRIPT_DIR/.claude-plugin/plugin.json"
    MARKETPLACE_MANIFEST="$SCRIPT_DIR/.claude-plugin/marketplace.json"
    if [ ! -f "$PLUGIN_MANIFEST" ]; then
        echo "ERROR: $PLUGIN_MANIFEST not found. Are you running this from the repo root?"
        exit 1
    fi

    PLUGIN_NAME=$("$PYTHON" -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "$PLUGIN_MANIFEST")
    PLUGIN_VERSION=$("$PYTHON" -c "import json,sys; print(json.load(open(sys.argv[1])).get('version','unknown'))" "$PLUGIN_MANIFEST")
    if [ -f "$MARKETPLACE_MANIFEST" ]; then
        MARKETPLACE_NAME=$("$PYTHON" -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "$MARKETPLACE_MANIFEST")
    else
        MARKETPLACE_NAME="$PLUGIN_NAME"
    fi

    PLUGINS_HOME="$HOME/.claude/plugins"
    CACHE_DIR="$PLUGINS_HOME/cache/$MARKETPLACE_NAME/$PLUGIN_NAME/$PLUGIN_VERSION"
    MARKETPLACE_DIR="$PLUGINS_HOME/marketplaces/$MARKETPLACE_NAME"
    INSTALLED_JSON="$PLUGINS_HOME/installed_plugins.json"
    KNOWN_MARKETPLACES_JSON="$PLUGINS_HOME/known_marketplaces.json"
    LEGACY_PLUGIN_DIR="$PLUGINS_HOME/$PLUGIN_NAME"
    PLUGIN_KEY="$PLUGIN_NAME@$MARKETPLACE_NAME"

    echo "Mode:        Claude Code plugin (official)"
    echo "Marketplace: $MARKETPLACE_NAME"
    echo "Plugin:      $PLUGIN_NAME @ $PLUGIN_VERSION"
    echo "Cache path:  $CACHE_DIR"
    echo "Command:     /$MARKETPLACE_NAME:doi-run"
    echo ""

    EXISTING_TARGETS=""
    [ -e "$CACHE_DIR" ] && EXISTING_TARGETS="${EXISTING_TARGETS}  $CACHE_DIR"$'\n'
    [ -e "$MARKETPLACE_DIR" ] && EXISTING_TARGETS="${EXISTING_TARGETS}  $MARKETPLACE_DIR"$'\n'
    [ -e "$LEGACY_PLUGIN_DIR" ] && EXISTING_TARGETS="${EXISTING_TARGETS}  $LEGACY_PLUGIN_DIR (legacy location from older installer)"$'\n'
    if [ -n "$EXISTING_TARGETS" ]; then
        echo "WARNING: The following will be replaced:"
        printf '%s' "$EXISTING_TARGETS"
        read -p "Continue? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
        rm -rf "$CACHE_DIR" "$MARKETPLACE_DIR" "$LEGACY_PLUGIN_DIR"
    fi

    mkdir -p "$(dirname "$CACHE_DIR")"
    mkdir -p "$(dirname "$MARKETPLACE_DIR")"

    # For this repo, marketplace.json declares "source": "./", so the marketplace
    # IS the plugin source — both dirs point at the same checkout.
    make_live_link_or_copy "$SCRIPT_DIR" "$CACHE_DIR"
    make_live_link_or_copy "$SCRIPT_DIR" "$MARKETPLACE_DIR"

    chmod +x "$CACHE_DIR/scripts/"*.sh 2>/dev/null || true

    # Register marketplace in known_marketplaces.json
    "$PYTHON" - "$KNOWN_MARKETPLACES_JSON" "$MARKETPLACE_NAME" "$MARKETPLACE_DIR" <<'PY'
import json, os, sys, datetime
path, name, install_loc = sys.argv[1], sys.argv[2], sys.argv[3]
install_loc = os.path.normpath(install_loc)
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
        if not isinstance(data, dict):
            data = {}
    except Exception:
        data = {}
data[name] = {
    "source": {"source": "local", "path": install_loc},
    "installLocation": install_loc,
    "lastUpdated": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z"),
}
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY

    # Register plugin in installed_plugins.json
    "$PYTHON" - "$INSTALLED_JSON" "$PLUGIN_KEY" "$CACHE_DIR" "$PLUGIN_VERSION" <<'PY'
import json, os, sys, datetime
path, key, install_path, version = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
install_path = os.path.normpath(install_path)
data = {"version": 2, "plugins": {}}
if os.path.exists(path):
    try:
        with open(path) as f:
            loaded = json.load(f)
        if isinstance(loaded, dict):
            data = loaded
            data.setdefault("version", 2)
            data.setdefault("plugins", {})
    except Exception:
        pass
now = datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z")
data["plugins"][key] = [{
    "scope": "user",
    "installPath": install_path,
    "version": version,
    "installedAt": now,
    "lastUpdated": now,
}]
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY

    echo ""
    echo "Registered:  $PLUGIN_KEY"
    echo "Done. Restart Claude Code, then run: /$MARKETPLACE_NAME:doi-run"

else
    # Standalone mode: copy skills/agents/scripts to ~/.claude/ subdirectories
    SKILLS_DIR="$HOME/.claude/skills"
    AGENTS_DIR="$HOME/.claude/agents"
    SCRIPTS_DIR="$HOME/.claude/scripts"

    echo "Mode:        Standalone skills (advanced)"
    echo "Skills dir:  $SKILLS_DIR"
    echo "Agents dir:  $AGENTS_DIR"
    echo "Scripts dir: $SCRIPTS_DIR"
    echo "Command:     /doi-run"
    echo ""

    mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$SCRIPTS_DIR"

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
    if [ -d "$SOURCE_AGENTS" ]; then
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
    if [ -d "$SOURCE_SCRIPTS" ]; then
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

        # Copy _config (build doctrine + any future config files)
        if [ -d "$SOURCE_SCRIPTS/_config" ]; then
            echo "  _config/"
            rm -rf "$SCRIPTS_DIR/doi/_config"
            cp -r "$SOURCE_SCRIPTS/_config" "$SCRIPTS_DIR/doi/_config"
        fi
    fi

    echo ""
    echo "Done. Open Claude Code and run: /doi-run"
fi

echo ""
echo "To uninstall:"
if [ "$INSTALL_MODE" = "plugin" ]; then
    echo "  /plugin uninstall $PLUGIN_KEY     (preferred — run inside Claude Code)"
    echo "  or manually:"
    echo "    rm -rf \"$CACHE_DIR\" \"$MARKETPLACE_DIR\""
    echo "    and remove the \"$PLUGIN_KEY\" entry from $INSTALLED_JSON"
else
    echo "  rm -rf ~/.claude/skills/doi-*"
    echo "  rm -rf ~/.claude/agents/doi-review"
    echo "  rm -rf ~/.claude/agents/doi-builder"
    echo "  rm -rf ~/.claude/scripts/doi/"
fi
echo ""
