# fn-1.5 Integration testing

## Description
End-to-end testing of memory system in all three contexts:
1. Manual `/flow-next:plan` - memory-scout runs in parallel
2. Manual `/flow-next:work` - memory-scout runs during re-anchor
3. Ralph mode - both capture (PostToolUse) and retrieval work

Test scenarios:
- Memory disabled: no scouts run, no capture happens
- Memory enabled but empty: scouts return nothing gracefully
- Memory enabled with entries: relevant entries retrieved
- NEEDS_WORK feedback captured correctly

## Acceptance
- [ ] `/flow-next:plan` spawns memory-scout when enabled
- [ ] `/flow-next:work` includes memory in re-anchor when enabled
- [ ] Ralph capture writes to pitfalls.md on NEEDS_WORK
- [ ] Memory-scout retrieves relevant entries in Ralph loop
- [ ] Disabled config prevents all memory operations
- [ ] Works in smoke test environment

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
