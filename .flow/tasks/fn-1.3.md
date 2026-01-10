# fn-1.3 flowctl memory commands

## Description
Add flowctl commands for manual memory management. These complement auto-capture by allowing manual additions (conventions, decisions) and retrieval.

Commands:
- `flowctl memory init` - creates `.flow/memory/` structure
- `flowctl memory add --type <type> "<content>"` - manual entry
- `flowctl memory read [--type <type>]` - dump memory
- `flowctl memory list` - show entry count per file
- `flowctl memory search "<pattern>"` - grep across memory

All commands check `memory.enabled` config first.

## Acceptance
- [ ] `flowctl memory add --type pitfall "..."` appends to pitfalls.md
- [ ] `flowctl memory add --type convention "..."` appends to conventions.md
- [ ] `flowctl memory add --type decision "..."` appends to decisions.md
- [ ] `flowctl memory read` dumps all memory files
- [ ] `flowctl memory read --type pitfalls` filters to one file
- [ ] `flowctl memory list` shows entry counts
- [ ] `flowctl memory search "pattern"` greps across files
- [ ] All commands error gracefully when memory disabled

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
