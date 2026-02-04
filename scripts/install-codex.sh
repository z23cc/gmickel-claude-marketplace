#!/bin/bash
# Install Flow or Flow-Next skills and prompts into Codex CLI (~/.codex)
#
# Usage: ./scripts/install-codex.sh <flow|flow-next>
#
# What gets installed:
#   - Skills:    plugins/<plugin>/skills/*     → ~/.codex/skills/
#   - Agents:    plugins/<plugin>/agents/*     → ~/.codex/agents/
#   - Prompts:   plugins/<plugin>/commands/*   → ~/.codex/prompts/
#   - CLI tools: flowctl, flowctl.py           → ~/.codex/bin/
#   - Scripts:   worktree.sh, etc.             → ~/.codex/scripts/
#   - Templates: ralph-init templates          → ~/.codex/templates/
#
# Path patching:
#   All ${CLAUDE_PLUGIN_ROOT} references are replaced with ~/.codex
#   so skills work without Claude Code's plugin system.
#
# Agent conversion:
#   Claude Code frontmatter (name, description, model, tools, color) is
#   converted to Codex format (profile, approval_policy, sandbox_mode, model).
#   Override defaults via env vars:
#     CODEX_AGENT_MODEL=gpt-5.2-codex-medium
#     CODEX_AGENT_PROFILE=default
#     CODEX_AGENT_APPROVAL=on-request
#     CODEX_AGENT_SANDBOX=workspace-write
#
# Skill patching:
#   flow-next-work is patched to not spawn worker subagents. Instead,
#   worker.md is copied into the skill and phases.md is rewritten to
#   reference it directly (Codex lacks Task tool for subagent spawning).
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

# Codex agent defaults (override via env vars)
CODEX_AGENT_MODEL="${CODEX_AGENT_MODEL:-gpt-5.2-codex-medium}"
CODEX_AGENT_PROFILE="${CODEX_AGENT_PROFILE:-default}"
CODEX_AGENT_APPROVAL="${CODEX_AGENT_APPROVAL:-on-request}"
CODEX_AGENT_SANDBOX="${CODEX_AGENT_SANDBOX:-workspace-write}"

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
mkdir -p "$CODEX_DIR/agents"

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

# Function to convert Claude Code agent frontmatter to Codex format
# Claude Code: name, description, model, tools, disallowedTools, color
# Codex: profile, approval_policy, sandbox_mode, model (+ keeps name, description)
convert_agent_for_codex() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return
    fi

    # Use awk to transform the YAML frontmatter
    awk -v model="$CODEX_AGENT_MODEL" \
        -v profile="$CODEX_AGENT_PROFILE" \
        -v approval="$CODEX_AGENT_APPROVAL" \
        -v sandbox="$CODEX_AGENT_SANDBOX" '
    BEGIN {
        in_frontmatter = 0
        frontmatter_end = 0
        has_profile = 0
        has_approval = 0
        has_sandbox = 0
        has_model = 0
    }

    # First line: start of frontmatter
    NR == 1 && /^---/ {
        in_frontmatter = 1
        print
        next
    }

    # End of frontmatter
    in_frontmatter && /^---/ {
        # Add missing Codex fields before closing
        if (!has_profile) print "profile: " profile
        if (!has_approval) print "approval_policy: " approval
        if (!has_sandbox) print "sandbox_mode: " sandbox
        if (!has_model) print "model: " model
        in_frontmatter = 0
        frontmatter_end = 1
        print
        next
    }

    # Inside frontmatter: transform fields
    in_frontmatter {
        # Skip Claude-specific fields
        if (/^color:/ || /^disallowedTools:/ || /^tools:/) {
            next
        }

        # Transform model field
        if (/^model:/) {
            print "model: " model
            has_model = 1
            next
        }

        # Track existing Codex fields
        if (/^profile:/) has_profile = 1
        if (/^approval_policy:/) has_approval = 1
        if (/^sandbox_mode:/) has_sandbox = 1

        # Keep name, description, and other fields
        print
        next
    }

    # After frontmatter: pass through unchanged
    { print }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# Function to patch flow-next-work skill for Codex (no subagent spawning)
# Completely removes worker/subagent concepts and inlines implementation steps
patch_flow_next_work_for_codex() {
    local skill_dir="$1"
    local phases_file="$skill_dir/phases.md"
    local skill_md="$skill_dir/SKILL.md"

    if [ ! -f "$phases_file" ]; then
        return
    fi

    # Remove worker.md if copied (we inline everything)
    rm -f "$skill_dir/worker.md"

    # Create replacement content for section 3c
    cat > /tmp/codex-3c-replacement.md << 'SECTION3CEOF'
### 3c. Implement Task

**Implement the task directly. Follow these phases:**

#### Phase 1: Re-anchor (CRITICAL)

```bash
# Read task and epic specs
$FLOWCTL show <task-id> --json
$FLOWCTL cat <task-id>
$FLOWCTL show <epic-id> --json
$FLOWCTL cat <epic-id>

# Check git state
git status
git log -5 --oneline

# Check memory system
$FLOWCTL config get memory.enabled --json
```

If memory.enabled is true, read `.flow/memory/*.md` for relevant context.

Parse the spec carefully - identify acceptance criteria, dependencies, technical approach, test requirements.

#### Phase 2: Implement

```bash
# Capture base commit for scoped review
BASE_COMMIT=$(git rev-parse HEAD)
```

Read relevant code, implement the feature/fix. Follow existing patterns. Small, focused changes.

#### Phase 3: Commit

```bash
git add -A
git commit -m "feat(<scope>): <description>

- <detail>

Task: <task-id>"
```

#### Phase 4: Review (MANDATORY)

⚠️ **CRITICAL: You MUST run impl-review after EVERY task commit.**

This is NOT optional. Skipping reviews violates the workflow contract.

```
/flow-next:impl-review <task-id> --base $BASE_COMMIT
```

Loop until SHIP verdict. Do NOT proceed to Phase 5 without SHIP.

#### Phase 5: Complete

```bash
COMMIT_HASH=$(git rev-parse HEAD)
cat > /tmp/evidence.json << EOF
{"commits": ["$COMMIT_HASH"], "tests": ["<test commands>"], "prs": []}
EOF
cat > /tmp/summary.md << 'EOF'
<1-2 sentence summary>
EOF
$FLOWCTL done <task-id> --summary-file /tmp/summary.md --evidence-json /tmp/evidence.json
```

#### Phase 6: Epic Completion Review (when all tasks done)

When ALL tasks in the epic are done, you MUST run completion review before closing:

```bash
# Check remaining tasks
$FLOWCTL ready --epic <epic-id> --json
# If no tasks remaining, run completion review
/flow-next:epic-review <epic-id>
```

Do NOT skip completion review. It verifies the entire epic implementation.

#### Phase 7: LOOP - Continue to Next Task (CRITICAL)

⚠️ **DO NOT STOP after completing a task. DO NOT ask "Next steps?"**

After Phase 5 (task done), IMMEDIATELY:

1. Run `$FLOWCTL ready --epic <epic-id> --json` to find next task
2. If tasks remain → go back to Phase 1 (Re-anchor) with next task
3. If NO tasks remain → run Phase 6 (Epic Completion Review)
4. After epic review SHIP → epic is complete

```bash
# After each task, check for more work
NEXT=$($FLOWCTL ready --epic <epic-id> --json | jq -r '.tasks[0].id // empty')
if [ -n "$NEXT" ]; then
  echo "Continuing to task: $NEXT"
  # Go back to Phase 1 with $NEXT
else
  echo "All tasks done - running epic completion review"
  # Run Phase 6
fi
```

**You are an autonomous agent. Keep working until the epic is COMPLETE.**

SECTION3CEOF

    # Use awk to mark section boundaries, then replace with sed
    local start_line=$(grep -n "^### 3c\. Spawn Worker" "$phases_file" | cut -d: -f1)
    local end_line=$(grep -n "^### 3d\." "$phases_file" | cut -d: -f1)

    if [ -n "$start_line" ] && [ -n "$end_line" ]; then
        # Delete section 3c content (keep 3d header)
        end_line=$((end_line - 1))
        head -n $((start_line - 1)) "$phases_file" > "${phases_file}.tmp"
        cat /tmp/codex-3c-replacement.md >> "${phases_file}.tmp"
        echo "" >> "${phases_file}.tmp"
        tail -n +$end_line "$phases_file" >> "${phases_file}.tmp"
        mv "${phases_file}.tmp" "$phases_file"
    fi

    # Global text replacements
    sed -i.bak \
        -e 's/spawn a worker subagent with fresh context/implement the task directly/g' \
        -e 's/After worker returns/After implementing/g' \
        -e 's/the worker failed/implementation failed/g' \
        -e 's/Worker subagent model/Implementation model/g' \
        -e 's/worker subagent/direct implementation/g' \
        -e 's/worker handles/you handle/g' \
        -e 's/spawn worker/implement task/g' \
        -e 's/spawn the `plan-sync` subagent/run plan-sync/g' \
        -e 's/quality auditor subagent/quality check/g' \
        -e 's/Worker inherits/Implementation uses/g' \
        -e 's/after worker returns/after implementing/g' \
        -e 's/Worker runs in foreground/Implementation runs in foreground/g' \
        "$phases_file"
    rm -f "${phases_file}.bak"

    rm -f /tmp/codex-3c-replacement.md

    # Patch SKILL.md
    if [ -f "$skill_md" ]; then
        sed -i.bak \
            -e 's/worker subagent with fresh context/direct implementation/g' \
            -e 's/worker subagent/direct implementation/g' \
            -e 's/Worker subagent/Direct implementation/g' \
            -e 's/Each task is implemented by a `worker` subagent/Each task is implemented directly by you/g' \
            -e 's/worker handles/you handle/g' \
            -e 's/The worker invokes/Invoke/g' \
            -e 's/pass.*to the worker/handle directly/g' \
            "$skill_md"
        rm -f "${skill_md}.bak"
    fi
}

# Function to patch RP review skills for Codex (add CRITICAL wait instructions)
# Codex tends to assume commands are stuck and retry - we need to prevent this
patch_rp_review_skills_for_codex() {
    local codex_skills_dir="$1"

    # Create warning file
    cat > /tmp/codex-rp-warning.md << 'WARNINGEOF'

---

## ⚠️ CRITICAL: RepoPrompt Commands Are SLOW - DO NOT RETRY

**READ THIS BEFORE RUNNING ANY COMMANDS:**

1. **`setup-review` takes 5-15 MINUTES** - It runs the RepoPrompt context builder which indexes files. This is NORMAL. Do NOT assume it is stuck.

2. **`chat-send` takes 2-10 MINUTES** - It waits for the LLM to generate a full review. This is NORMAL. Do NOT assume it is stuck.

3. **Run commands directly and WAIT** - Do NOT use background jobs. Just run the command and wait:
   ```bash
   # Run setup-review - takes 5-15 minutes, just wait
   $FLOWCTL rp setup-review --repo-root "$REPO_ROOT" --summary "..."
   # You will see file paths printed as it indexes - this is progress, not errors
   ```

4. **Output is progress, not errors** - The context builder prints file paths as it indexes. Seeing many lines of output is NORMAL. Do not interpret this as an error loop.

5. **NEVER retry these commands** - If you run them again, you will create duplicate reviews and waste time. Run ONCE and WAIT.

6. **Exit code 0 = success** - When the command finishes, check the exit code. If it's 0, it worked.

**If a command has been running for less than 15 minutes, WAIT. Do not retry. Do not output <promise>RETRY</promise>.**

---

WARNINGEOF

    # Patch workflow files by inserting warning after first markdown heading
    for skill in flow-next-impl-review flow-next-plan-review flow-next-epic-review; do
        local wf="$codex_skills_dir/$skill/workflow.md"
        if [ -f "$wf" ]; then
            # Insert warning after first line (the # heading)
            head -1 "$wf" > "${wf}.tmp"
            cat /tmp/codex-rp-warning.md >> "${wf}.tmp"
            tail -n +2 "$wf" >> "${wf}.tmp"
            mv "${wf}.tmp" "$wf"
        fi
    done

    # Patch SKILL.md files with timeout notes
    for skill in flow-next-impl-review flow-next-plan-review flow-next-epic-review; do
        local skill_md="$codex_skills_dir/$skill/SKILL.md"
        if [ -f "$skill_md" ]; then
            sed -i.bak \
                -e 's|setup-review|setup-review (⚠️ 5-15 min, DO NOT RETRY)|g' \
                -e 's|chat-send|chat-send (⚠️ 2-10 min, DO NOT RETRY)|g' \
                "$skill_md"
            rm -f "${skill_md}.bak"
        fi
    done

    rm -f /tmp/codex-rp-warning.md
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

# Patch flow-next-work for Codex (no subagent spawning)
if [ -d "$CODEX_DIR/skills/flow-next-work" ]; then
    patch_flow_next_work_for_codex "$CODEX_DIR/skills/flow-next-work"
    echo -e "  ${GREEN}✓${NC} flow-next-work (patched for Codex - no subagent)"
fi

# Patch all RP review skills for Codex (add CRITICAL wait instructions)
patch_rp_review_skills_for_codex "$CODEX_DIR/skills"
echo -e "  ${GREEN}✓${NC} RP review skills (patched for Codex - DO NOT RETRY warnings)"

# Patch skills that reference scouts to use Codex subagent paths
patch_scout_references_for_codex() {
    local skills_dir="$1"

    # Create Codex subagent instructions header
    cat > /tmp/codex-subagent-note.md << 'SUBAGENTEOF'

---

## Codex Subagent Instructions

**To run scouts as subagents in Codex**, use the agent files in `~/.codex/agents/`:

```
Run these agents as subagents (in parallel where possible):
- ~/.codex/agents/repo-scout.md
- ~/.codex/agents/practice-scout.md
- ~/.codex/agents/docs-scout.md
- ~/.codex/agents/github-scout.md
- ~/.codex/agents/memory-scout.md (if memory.enabled)
- ~/.codex/agents/epic-scout.md
- ~/.codex/agents/docs-gap-scout.md
```

Pass the request/context to each subagent. Collect their findings before proceeding.

---

SUBAGENTEOF

    # Patch flow-next-plan steps.md
    if [ -f "$skills_dir/flow-next-plan/steps.md" ]; then
        local sf="$skills_dir/flow-next-plan/steps.md"
        # Insert note after "## Step 1" heading
        sed -i.bak '/^## Step 1/r /tmp/codex-subagent-note.md' "$sf"
        rm -f "${sf}.bak"

        # Replace flow-next:scout-name with ~/.codex/agents/scout-name.md
        sed -i.bak \
            -e 's|`flow-next:context-scout`|`~/.codex/agents/context-scout.md`|g' \
            -e 's|`flow-next:repo-scout`|`~/.codex/agents/repo-scout.md`|g' \
            -e 's|`flow-next:practice-scout`|`~/.codex/agents/practice-scout.md`|g' \
            -e 's|`flow-next:docs-scout`|`~/.codex/agents/docs-scout.md`|g' \
            -e 's|`flow-next:github-scout`|`~/.codex/agents/github-scout.md`|g' \
            -e 's|`flow-next:memory-scout`|`~/.codex/agents/memory-scout.md`|g' \
            -e 's|`flow-next:epic-scout`|`~/.codex/agents/epic-scout.md`|g' \
            -e 's|`flow-next:docs-gap-scout`|`~/.codex/agents/docs-gap-scout.md`|g' \
            -e 's|Task flow-next:flow-gap-analyst.*|Run subagent: ~/.codex/agents/flow-gap-analyst.md (pass request + research findings)|g' \
            "$sf"
        rm -f "${sf}.bak"
    fi

    rm -f /tmp/codex-subagent-note.md
}

patch_scout_references_for_codex "$CODEX_DIR/skills"
echo -e "  ${GREEN}✓${NC} flow-next-plan (patched for Codex - subagent paths)"

# ====================
# Install agents (with patching)
# ====================
if [ -d "$PLUGIN_DIR/agents" ] && [ "$(ls -A "$PLUGIN_DIR/agents" 2>/dev/null)" ]; then
    echo -e "${BLUE}Installing agents...${NC}"
    AGENT_COUNT=0

    for agent_file in "$PLUGIN_DIR/agents/"*.md; do
        if [ -f "$agent_file" ]; then
            name=$(basename "$agent_file")
            cp "$agent_file" "$CODEX_DIR/agents/$name"
            patch_for_codex "$CODEX_DIR/agents/$name"
            convert_agent_for_codex "$CODEX_DIR/agents/$name"
            echo -e "  ${GREEN}✓${NC} ${name%.md}"
            AGENT_COUNT=$((AGENT_COUNT + 1))
        fi
    done
fi

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
if [ -d "$CODEX_DIR/agents" ] && [ "$(ls -A "$CODEX_DIR/agents" 2>/dev/null)" ]; then
echo "  ├── agents/              # Agent definitions"
fi
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
echo "  • ⚠️  Reviews are MANDATORY - run /flow-next:impl-review after each task"
echo "  • ⚠️  Run /flow-next:epic-review when all tasks in an epic are done"
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
