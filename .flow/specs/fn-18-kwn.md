# fn-18-kwn RP CLI: Auto-open RepoPrompt window for reviews

## Overview

RepoPrompt now supports `rp-cli open <path>` to programmatically open a window. Update `flowctl rp` commands to auto-open RP window instead of requiring user to have it open beforehand.

## Scope

- Update `flowctl rp pick-window` to open window if none found
- Update `flowctl rp builder` to auto-open if needed
- Ralph reviews "just work" without manual RP window setup

## Approach

Modify `pick_window()` in flowctl.py to call `rp-cli open` when no existing window matches the repo root.

## Quick commands

```bash
# Test pick-window auto-opens
flowctl rp pick-window --repo-root .

# Verify with Ralph smoke test
KEEP_TEST_DIR=1 plugins/flow-next/scripts/ralph_smoke_test.sh
```

## Acceptance

- [ ] `flowctl rp pick-window --repo-root .` opens RP if not already open
- [ ] `flowctl rp builder` works without pre-existing RP window
- [ ] Existing open windows are reused (no duplicate windows)
- [ ] Clear error message if rp-cli not installed

## References

- `rp-cli --help`, `rp-cli open --help`
- `plugins/flow-next/scripts/flowctl.py` - rp subcommand
