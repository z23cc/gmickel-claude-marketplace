# fn-1.4 Memory-scout subagent

## Description
Create memory-scout subagent for retrieving relevant memory during planning and work phases. One agent, two call sites:

1. `/flow-next:plan` Step 1 - parallel with repo-scout, practice-scout, docs-scout
2. `/flow-next:work` Phase 1 - during re-anchor after flowctl show/cat

Agent reads `.flow/memory/` files and returns only relevant entries (not everything).

Call pattern (matches existing scouts):
```
Task flow-next:memory-scout(<request>)
```

## Acceptance
- [ ] `agents/memory-scout.md` created with agent definition
- [ ] Agent reads pitfalls.md, conventions.md, decisions.md
- [ ] Returns only semantically relevant entries
- [ ] Added to plan skill Step 1 (gated by memory.enabled)
- [ ] Added to work skill Phase 1 re-anchor (gated by memory.enabled)
- [ ] Works with empty memory (returns nothing gracefully)
- [ ] Handles large memory files (selective return)

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
