# flow-next Plugin Test Findings

Test date: 2026-01-06
Test repo: `/tmp/flow-next-test` (Next.js 16 + shadcn)

## /flow-next:plan Test Results

### What Worked Well

1. **Skill invocation** - `/flow-next:plan Add a contact form...` correctly loaded skill
2. **rp-cli detection** - Checked for rp-cli, showed setup questions as text (not AskUserQuestion)
3. **User input parsing** - Parsed "1b 2a" correctly (repo-scout + Carmack review)
4. **Parallel scouts** - repo-scout, practice-scout, docs-scout ran in parallel via Task tool
5. **flowctl usage** - All .flow/ writes via flowctl, proper JSON output
6. **Epic/task creation** - fn-1 with 4 tasks, correct dependencies (fn-1.1→fn-1.2→fn-1.3→fn-1.4)
7. **Review integration** - rp-cli builder + chat_send worked
8. **selected_paths in re-review** - Correctly included in follow-up chat_send (critical fix from flow 0.8.3)
9. **Review loop** - First review "Needs Work" → fixes applied → re-review "Ship"
10. **Spec quality** - Full code samples, acceptance criteria, manual test checklist

### Issues Found & Fixed

1. **flowctl list doesn't exist** - Agent hallucinated `flowctl list --epic fn-1`
   - Fix: Added `aliases=["list", "ls"]` to show command in flowctl.py
   - Fix: Updated docs/flowctl.md with alias documentation

2. **RP window not open** - Agent detected missing window, waited, recovered when opened
   - No fix needed - graceful recovery worked

### Spec Quality Observations

**Pros of full code in specs:**
- Smaller models can execute without interpretation
- Review catches issues upfront
- Less drift from intent
- Specs become single source of truth

**Cons:**
- Copy-paste without understanding
- Verbose specs
- Changes require spec updates

**Verdict:** For flow-next's opinionated workflow, full code is probably right.

### Files Modified During Testing

```
plugins/flow-next/scripts/flowctl.py  - Added list/ls aliases
plugins/flow-next/docs/flowctl.md     - Documented aliases, cleaned up command list
plugins/flow-next/skills/flow-next-plan/steps.md - Reverted over-defensive Step 7 changes
```

### Test Artifacts

- Test session: `~/.claude/projects/-private-tmp-flow-next-test/7fed82f8-*.jsonl`
- Test checklist: `/tmp/flow-next-test-checklist.md`
- Created .flow/: `/tmp/flow-next-test/.flow/` with fn-1 epic and 4 tasks

## Next: /flow-next:work fn-1

Ready to test implementation workflow. Key things to verify:
1. Branch setup question works
2. Phase 3 prime/re-anchor runs correctly
3. Task loop (start → implement → commit → done)
4. Discovered work pathway (create new task mid-flow)
5. impl-review integration if chosen

## Multi-User (MU) Test Checklist

Added in MU work package. Run these tests to verify branch safety.

### MU-1: Merge-safe ID allocation

- [ ] Branch A: create epic → fn-1
- [ ] Branch B: create epic → fn-1 (same, but separate branch)
- [ ] Merge A then B → should not conflict (B becomes fn-2 on its branch if re-run)
- [ ] Branch A: create task in fn-1 → fn-1.1
- [ ] Branch B: create task in fn-1 → fn-1.1 (same)
- [ ] Merge → no duplicate task IDs (B becomes fn-1.2 if re-run after merge)

### MU-2: Soft-claim semantics

- [ ] `flowctl start fn-1.1` sets assignee to current actor
- [ ] `flowctl start fn-1.1` by different actor → fails with claim error
- [ ] `flowctl start fn-1.1 --force` by different actor → succeeds, updates claim_note
- [ ] `flowctl ready --epic fn-1` shows in_progress with assignees
- [ ] `flowctl done fn-1.1` requires in_progress status (unless --force)

### MU-3: Validation

- [ ] `flowctl validate --epic fn-1 --json` works
- [ ] `flowctl validate --all --json` validates all epics
- [ ] Break a task spec heading → validate fails
- [ ] Add cross-epic dependency → validate fails
- [ ] Create dependency cycle → validate fails
- [ ] Mark epic done with incomplete task → validate fails
- [ ] CI workflow blocks bad PRs

### MU-4: Deterministic formatting

- [ ] Evidence always in order: Commits, Tests, PRs
- [ ] Two branches completing different tasks → minimal conflicts

### MU-5: Actor resolution

- [ ] FLOW_ACTOR env var takes priority
- [ ] Falls back to git config user.email
- [ ] Falls back to git config user.name
- [ ] Falls back to $USER
- [ ] Falls back to "unknown"

## Uncommitted Changes

```
plugins/flow-next/  - All changes (not committed yet)
```

Run after testing complete:
```bash
git add plugins/flow-next/
git commit -m "flow-next: aliases, docs polish from plan testing"
```
