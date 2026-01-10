# fn-1.6 Documentation

## Description
Document memory system in relevant places. Key point: memory is a flow-next feature (not Ralph-specific), works in manual + Ralph modes.

Clarify:
- Config in `.flow/config.json` (not Ralph's `env.config`)
- Enable with `flowctl config set memory.enabled true`
- Auto-capture only happens via Ralph hook
- Manual additions via `flowctl memory add`

## Acceptance
- [ ] Memory section added to flow-next README
- [ ] Memory mentioned in ralph.md (note: separate config)
- [ ] CLAUDE.md updated with memory quick-reference
- [ ] Clear distinction: flow-next feature vs Ralph-only
- [ ] flowctl memory commands documented with examples

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
