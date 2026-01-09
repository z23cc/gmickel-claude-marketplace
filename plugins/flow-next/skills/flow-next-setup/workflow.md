# Flow-Next Setup Workflow

Follow these steps in order. This workflow is **idempotent** - safe to re-run.

## Step 1: Initialize .flow/ (if needed)

```bash
FLOWCTL="${CLAUDE_PLUGIN_ROOT}/scripts/flowctl"
$FLOWCTL detect --json
```

- If `.flow/` exists: continue (don't reinitialize - preserves existing epics/tasks)
- If `.flow/` doesn't exist: run `$FLOWCTL init --json`

## Step 2: Check existing setup

Read `.flow/meta.json` and check for `setup_version` field.

**If `setup_version` exists (already set up):**
- Compare to current plugin version (from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`)
- If **same version**: tell user "Already set up with v<VERSION>. Re-run to update docs only? (y/n)"
  - If yes: skip to Step 6 (docs)
  - If no: done
- If **older version**: tell user "Updating from v<OLD> to v<NEW>" and continue

**If no `setup_version`:** continue (first-time setup)

## Step 3: Create .flow/bin/

```bash
mkdir -p .flow/bin
```

## Step 4: Copy files

Copy scripts and usage guide (overwrites existing - safe for updates):

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/flowctl" .flow/bin/flowctl
cp "${CLAUDE_PLUGIN_ROOT}/scripts/flowctl.py" .flow/bin/flowctl.py
chmod +x .flow/bin/flowctl
```

Also copy usage guide from [templates/usage.md](templates/usage.md) to `.flow/usage.md`.

## Step 5: Update meta.json

Read current `.flow/meta.json`, add/update these fields (preserve all others like `schema_version`, `next_epic`):

```json
{
  "setup_version": "<PLUGIN_VERSION>",
  "setup_date": "<ISO_DATE>"
}
```

Get plugin version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.

## Step 6: Ask about documentation

Output as text (do NOT use AskUserQuestion):

```
Add flow-next instructions to project docs?

1. CLAUDE.md only
2. AGENTS.md only
3. Both
4. Neither

(Reply: 1, 2, 3, or 4)
```

Wait for response.

## Step 7: Update documentation

Read the template from [templates/claude-md-snippet.md](templates/claude-md-snippet.md).

For each chosen file:
1. Read the file (create if doesn't exist)
2. Check if `<!-- BEGIN FLOW-NEXT -->` marker exists
3. If exists: replace everything between `<!-- BEGIN FLOW-NEXT -->` and `<!-- END FLOW-NEXT -->` (inclusive) with the new snippet
4. If not exists: append the snippet

## Step 8: Print summary

```
Flow-Next setup complete!

Installed:
- .flow/bin/flowctl (v<VERSION>)
- .flow/bin/flowctl.py
- .flow/usage.md

To use from command line:
  export PATH=".flow/bin:$PATH"
  flowctl --help

Documentation updated:
- <files updated or "none">

Notes:
- Re-run /flow-next:setup after plugin updates to refresh scripts
- Uninstall: rm -rf .flow/bin .flow/usage.md and remove <!-- BEGIN/END FLOW-NEXT --> block from docs
- This setup is optional - plugin works without it
```
