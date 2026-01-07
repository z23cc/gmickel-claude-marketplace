#!/bin/bash
# Install Flow or Flow-Next skills and prompts into Codex CLI (~/.codex)
#
# Usage: ./scripts/install-codex.sh <flow|flow-next>
#
# What gets installed:
#   - Skills:  plugins/<plugin>/skills/*  → ~/.codex/skills/
#   - Prompts: plugins/<plugin>/commands/<plugin>/*.md → ~/.codex/prompts/
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

echo "Installing $PLUGIN to Codex CLI..."
echo

# Check codex dir exists
if [ ! -d "$CODEX_DIR" ]; then
    echo -e "${RED}Error: ~/.codex not found. Is Codex CLI installed?${NC}"
    exit 1
fi

# Check plugin exists
if [ ! -d "$REPO_ROOT/plugins/$PLUGIN" ]; then
    echo -e "${RED}Error: Plugin '$PLUGIN' not found${NC}"
    exit 1
fi

# Create dirs if needed
mkdir -p "$CODEX_DIR/skills"
mkdir -p "$CODEX_DIR/prompts"

# Get skill list based on plugin
if [ "$PLUGIN" = "flow" ]; then
    SKILLS=(flow-plan flow-work flow-interview flow-plan-review flow-impl-review rp-explorer worktree-kit)
else
    SKILLS=(flow-next-plan flow-next-work flow-next-interview flow-next-plan-review flow-next-impl-review)
fi

# Install skills
echo "Installing skills..."
for skill in "${SKILLS[@]}"; do
    if [ -d "$REPO_ROOT/plugins/$PLUGIN/skills/$skill" ]; then
        rm -rf "$CODEX_DIR/skills/$skill"
        cp -r "$REPO_ROOT/plugins/$PLUGIN/skills/$skill" "$CODEX_DIR/skills/"
        echo -e "  ${GREEN}✓${NC} $skill"
    fi
done

# Install prompts (commands)
echo "Installing prompts..."
for cmd in "$REPO_ROOT/plugins/$PLUGIN/commands/$PLUGIN/"*.md; do
    if [ -f "$cmd" ]; then
        name=$(basename "$cmd")
        cp "$cmd" "$CODEX_DIR/prompts/$name"
        echo -e "  ${GREEN}✓${NC} $name"
    fi
done

echo
echo -e "${GREEN}Done!${NC} $PLUGIN installed to ~/.codex"
echo
echo -e "${YELLOW}Note:${NC} Subagents (parallel research) won't run in Codex."
echo "The core /$PLUGIN:plan and /$PLUGIN:work commands still work well."
