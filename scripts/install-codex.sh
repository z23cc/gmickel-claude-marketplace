#!/bin/bash
# Install Flow or Flow-Next skills and prompts into Codex CLI (~/.codex)
#
# Usage: ./scripts/install-codex.sh <flow|flow-next>
#
# What gets installed:
#   - Skills:    plugins/<plugin>/skills/*     → ~/.codex/skills/
#   - Prompts:   plugins/<plugin>/commands/*   → ~/.codex/prompts/
#   - CLI tools: flowctl, flowctl.py           → ~/.codex/bin/
#   - Scripts:   worktree.sh, etc.             → ~/.codex/scripts/
#   - Templates: ralph-init templates          → ~/.codex/templates/
#
# Path patching:
#   All ${CLAUDE_PLUGIN_ROOT} references are replaced with ~/.codex
#   so skills work without Claude Code's plugin system.
#
# Note: Subagents (parallel research) won't run in Codex since it
# doesn't support Claude Code's Task tool. The core plan/work flow still
# works well without them.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="$HOME/.codex"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse argument
PLUGIN="${1:-}"
if [ -z "$PLUGIN" ]; then
    echo -e "${RED}Error: Plugin name required${NC}"
    echo "Usage: $0 <flow|flow-next>"
    exit 1
fi

if [ "$PLUGIN" != "flow" ] && [ "$PLUGIN" != "flow-next" ]; then
    echo -e "${RED}Error: Invalid plugin '$PLUGIN'${NC}"
    echo "Usage: $0 <flow|flow-next>"
    exit 1
fi

PLUGIN_DIR="$REPO_ROOT/plugins/$PLUGIN"

echo "Installing $PLUGIN to Codex CLI..."
echo

# Check codex dir exists
if [ ! -d "$CODEX_DIR" ]; then
    echo -e "${RED}Error: ~/.codex not found. Is Codex CLI installed?${NC}"
    exit 1
fi

# Check plugin exists
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${RED}Error: Plugin '$PLUGIN' not found${NC}"
    exit 1
fi

# Create dirs
mkdir -p "$CODEX_DIR/skills"
mkdir -p "$CODEX_DIR/prompts"
mkdir -p "$CODEX_DIR/bin"
mkdir -p "$CODEX_DIR/scripts"
mkdir -p "$CODEX_DIR/templates"

# Function to patch CLAUDE_PLUGIN_ROOT references for Codex
patch_for_codex() {
    local file="$1"
    if [ -f "$file" ]; then
        # Replace ${CLAUDE_PLUGIN_ROOT}/scripts/flowctl with ~/.codex/bin/flowctl
        # Replace ${CLAUDE_PLUGIN_ROOT}/skills/*/templates/ with ~/.codex/templates/*/
        # Replace ${CLAUDE_PLUGIN_ROOT}/skills/*/scripts/ with ~/.codex/scripts/
        sed -i.bak \
            -e 's|\${CLAUDE_PLUGIN_ROOT}/scripts/flowctl|~/.codex/bin/flowctl|g' \
            -e 's|\${PLUGIN_ROOT}/scripts/flowctl|~/.codex/bin/flowctl|g' \
            -e 's|"\${CLAUDE_PLUGIN_ROOT}/scripts/flowctl"|"$HOME/.codex/bin/flowctl"|g' \
            -e 's|"\${PLUGIN_ROOT}/scripts/flowctl"|"$HOME/.codex/bin/flowctl"|g' \
            -e 's|\${CLAUDE_PLUGIN_ROOT}/scripts/|~/.codex/bin/|g' \
            -e 's|\${CLAUDE_PLUGIN_ROOT}/skills/flow-next-ralph-init/templates|~/.codex/templates/flow-next-ralph-init|g' \
            -e 's|\${CLAUDE_PLUGIN_ROOT}/skills/flow-next-worktree-kit/scripts|~/.codex/scripts|g' \
            -e 's|\${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json|~/.codex/plugin.json|g' \
            "$file"
        rm -f "${file}.bak"
    fi
}

# ====================
# Install CLI tools (flow-next only)
# ====================
HAS_FLOWCTL=false
if [ -f "$PLUGIN_DIR/scripts/flowctl" ]; then
    echo -e "${BLUE}Installing CLI tools...${NC}"
    cp "$PLUGIN_DIR/scripts/flowctl" "$CODEX_DIR/bin/"
    chmod +x "$CODEX_DIR/bin/flowctl"
    echo -e "  ${GREEN}✓${NC} flowctl"
    HAS_FLOWCTL=true
fi

if [ -f "$PLUGIN_DIR/scripts/flowctl.py" ]; then
    cp "$PLUGIN_DIR/scripts/flowctl.py" "$CODEX_DIR/bin/"
    echo -e "  ${GREEN}✓${NC} flowctl.py"
fi

# ====================
# Install scripts
# ====================
echo -e "${BLUE}Installing scripts...${NC}"

if [ -f "$PLUGIN_DIR/skills/flow-next-worktree-kit/scripts/worktree.sh" ]; then
    cp "$PLUGIN_DIR/skills/flow-next-worktree-kit/scripts/worktree.sh" "$CODEX_DIR/scripts/"
    chmod +x "$CODEX_DIR/scripts/worktree.sh"
    echo -e "  ${GREEN}✓${NC} worktree.sh"
fi

# ====================
# Install templates
# ====================
echo -e "${BLUE}Installing templates...${NC}"

if [ -d "$PLUGIN_DIR/skills/flow-next-ralph-init/templates" ]; then
    rm -rf "$CODEX_DIR/templates/flow-next-ralph-init"
    cp -r "$PLUGIN_DIR/skills/flow-next-ralph-init/templates" "$CODEX_DIR/templates/flow-next-ralph-init"
    # Make scripts executable
    chmod +x "$CODEX_DIR/templates/flow-next-ralph-init/"*.sh 2>/dev/null || true
    chmod +x "$CODEX_DIR/templates/flow-next-ralph-init/"*.py 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} flow-next-ralph-init templates"
fi

if [ -d "$PLUGIN_DIR/skills/flow-next-setup/templates" ]; then
    rm -rf "$CODEX_DIR/templates/flow-next-setup"
    cp -r "$PLUGIN_DIR/skills/flow-next-setup/templates" "$CODEX_DIR/templates/flow-next-setup"
    echo -e "  ${GREEN}✓${NC} flow-next-setup templates"
fi

# ====================
# Copy plugin.json for version info
# ====================
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    cp "$PLUGIN_DIR/.claude-plugin/plugin.json" "$CODEX_DIR/plugin.json"
    echo -e "  ${GREEN}✓${NC} plugin.json (version info)"
fi

# ====================
# Install skills (with patching)
# ====================
echo -e "${BLUE}Installing skills...${NC}"

for skill_dir in "$PLUGIN_DIR/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill=$(basename "$skill_dir")
        rm -rf "$CODEX_DIR/skills/$skill"
        # Remove trailing slash to copy directory itself, not just contents
        cp -r "${skill_dir%/}" "$CODEX_DIR/skills/"

        # Patch all markdown files in the skill (including nested)
        find "$CODEX_DIR/skills/$skill" -name "*.md" -type f | while read -r md_file; do
            patch_for_codex "$md_file"
        done

        echo -e "  ${GREEN}✓${NC} $skill"
    fi
done

# ====================
# Install prompts (commands)
# ====================
echo -e "${BLUE}Installing prompts...${NC}"

for cmd in "$PLUGIN_DIR/commands/$PLUGIN/"*.md; do
    if [ -f "$cmd" ]; then
        name=$(basename "$cmd")
        cp "$cmd" "$CODEX_DIR/prompts/$name"
        patch_for_codex "$CODEX_DIR/prompts/$name"
        echo -e "  ${GREEN}✓${NC} $name"
    fi
done

# ====================
# Summary
# ====================
echo
echo -e "${GREEN}Done!${NC} $PLUGIN installed to ~/.codex"
echo
echo -e "${BLUE}Directory structure:${NC}"
echo "  ~/.codex/"
if [ "$HAS_FLOWCTL" = true ]; then
echo "  ├── bin/flowctl          # CLI tool"
echo "  ├── bin/flowctl.py"
fi
echo "  ├── skills/              # Skill definitions"
echo "  ├── prompts/             # Command prompts"
if [ -d "$CODEX_DIR/scripts" ] && [ "$(ls -A "$CODEX_DIR/scripts" 2>/dev/null)" ]; then
echo "  ├── scripts/             # Helper scripts"
fi
if [ -d "$CODEX_DIR/templates" ] && [ "$(ls -A "$CODEX_DIR/templates" 2>/dev/null)" ]; then
echo "  └── templates/           # Ralph/setup templates"
fi
echo
echo -e "${YELLOW}Notes:${NC}"
echo "  • Subagents (parallel research) won't run in Codex"
echo "  • Core /$PLUGIN:plan and /$PLUGIN:work commands still work"
if [ "$HAS_FLOWCTL" = true ]; then
echo "  • Run 'flowctl --help' via ~/.codex/bin/flowctl"
fi
echo
echo -e "${BLUE}Quick start:${NC}"
if [ "$HAS_FLOWCTL" = true ]; then
echo "  1. Add ~/.codex/bin to PATH (optional)"
echo "  2. Use /$PLUGIN:plan to create a plan"
echo "  3. Use /$PLUGIN:work to execute tasks"
else
echo "  1. Use /$PLUGIN:plan to create a plan"
echo "  2. Use /$PLUGIN:work to execute tasks"
fi
