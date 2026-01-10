# fn-2.3 Update impl-review skill for codex backend

## Description

Update `/flow-next:impl-review` skill to support codex backend alongside rp.

### Changes needed

1. **workflow.md** - Add backend detection and branching:
   - Check `FLOW_REVIEW_BACKEND` env var
   - Check `flowctl config get review.backend`
   - If interactive, prompt user (show available options)
   - Branch to rp or codex workflow

2. **Backend dispatch**:
   ```
   If backend == "rp":
       [existing RP workflow - setup-review, select-add, chat-send]

   If backend == "codex":
       eval "$(flowctl codex impl-review $TASK_ID --base $BASE_BRANCH)"
       # VERDICT now set

   If backend == "none":
       Skip review
   ```

### Files to modify

- `plugins/flow-next/skills/flow-next-impl-review/workflow.md`
- `plugins/flow-next/skills/flow-next-impl-review/SKILL.md` (if needed)
## Acceptance
- [ ] Skill detects backend from env var or config
- [ ] Interactive mode shows available backends (based on which codex/rp-cli)
- [ ] Codex path calls `flowctl codex impl-review`
- [ ] RP path unchanged (no regression)
- [ ] `none` skips review
- [ ] Verdict returned correctly from both backends
## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
