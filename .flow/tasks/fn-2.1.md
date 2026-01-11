# fn-2.1 Implement context hints for codex reviews

## Description

Implement context hints gathering for codex reviews. This replaces RP's context builder with a lightweight grep-based approach.

### Approach

Use repo-scout-style pattern (inline in flowctl, not subagent):
1. Get changed files from `git diff --name-only <base>`
2. Extract imports/references from changed files
3. Find files that reference changed exports (simple grep)
4. Format as hints: `- path/to/file.ts:42 - reason`

### Output format

```
Consider these related files:
- src/auth.ts:15 - imports validateToken (called by changed code)
- src/types.ts:42 - defines User interface (used in diff)
- src/middleware/session.ts:8 - session management pattern
```

### Implementation

Add to flowctl.py:
```python
def gather_context_hints(base_branch: str) -> str:
    # 1. git diff --name-only base_branch
    # 2. For each changed file, extract imports
    # 3. grep for references to changed symbols
    # 4. Format and return hints
```

This will be called from `codex impl-review` and `codex plan-review` (fn-2.2).

### Files to modify

- `plugins/flow-next/scripts/flowctl.py` - add context hints function
## Acceptance
- [ ] Context hints gathered from git diff
- [ ] Imports/exports extracted from changed files
- [ ] Related files found via grep
- [ ] Output format: `- path:line - reason`
- [ ] Works with empty diff (returns empty hints, no error)
- [ ] Works with large diff (reasonable limit, not 1000 files)
## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
