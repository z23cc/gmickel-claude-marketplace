# Flow-Next Setup Workflow

Follow these steps in order.

## Step 1: Initialize .flow/

```bash
FLOWCTL="${CLAUDE_PLUGIN_ROOT}/scripts/flowctl"
$FLOWCTL detect --json
```

If `.flow/` doesn't exist:
```bash
$FLOWCTL init --json
```

## Step 2: Check existing setup

Read `.flow/meta.json` and check for `setup_version` field.

If already set up:
- Compare `setup_version` to current plugin version
- If same: inform user, ask if they want to reinstall or just update docs
- If older: offer to update

## Step 3: Create .flow/bin/

```bash
mkdir -p .flow/bin
```

## Step 4: Copy flowctl scripts

**Copy** (not symlink) both files for portability:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/flowctl" .flow/bin/flowctl
cp "${CLAUDE_PLUGIN_ROOT}/scripts/flowctl.py" .flow/bin/flowctl.py
chmod +x .flow/bin/flowctl
```

## Step 5: Update meta.json

Read current `.flow/meta.json`, add/update:

```json
{
  "setup_version": "<PLUGIN_VERSION>",
  "setup_date": "<ISO_DATE>"
}
```

Get plugin version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.

Write back with Edit tool (preserve other fields like `schema_version`).

## Step 6: Ask about documentation

Output as text (do NOT use AskUserQuestion):

```
Setup complete! Add flow-next instructions to project docs?

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
2. Check if `## Flow-Next` section already exists
3. If exists: ask user if they want to replace it
4. If not: append the snippet

## Step 8: Print summary

```
Flow-Next setup complete!

Installed:
- .flow/bin/flowctl (v<VERSION>)
- .flow/bin/flowctl.py

To use from command line:
  export PATH=".flow/bin:$PATH"
  flowctl --help

Documentation updated:
- <files updated>

Notes:
- Re-run /flow-next:setup after plugin updates
- Uninstall: rm -rf .flow/bin and remove ## Flow-Next section from docs
- This setup is optional - plugin works without it
```
