# fn-1.1 Config + memory directory structure

## Description
Add `.flow/config.json` support to flowctl for project settings. Create config commands and memory init that creates `.flow/memory/` structure when enabled.

Key implementation:
- `load_flow_config()` helper that handles missing file gracefully
- `get_config(key, default)` for nested keys like `memory.enabled`
- Both `flowctl init` and `/flow-next:setup` create config if missing
- Memory commands check `memory.enabled` before running

## Acceptance
- [ ] `flowctl config get <key>` returns nested config values
- [ ] `flowctl config set <key> <value>` updates config.json
- [ ] Default config has `memory.enabled: false`
- [ ] `flowctl init` creates config.json with defaults
- [ ] `/flow-next:setup` creates config.json with defaults (idempotent)
- [ ] Setup Step 7 mentions: "Memory: disabled. Enable with flowctl config set memory.enabled true"
- [ ] `flowctl memory init` creates `.flow/memory/` (only if enabled)
- [ ] Memory templates created: pitfalls.md, conventions.md, decisions.md
- [ ] Memory commands error gracefully when disabled

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
