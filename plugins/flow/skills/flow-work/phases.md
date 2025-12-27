# Flow Work Phases

## Phase 1: Confirm

- Read the plan fully
- Open referenced files/links
- Ask only blocking questions
- Get user go-ahead

**Beads alternative** - if Beads is in use (.beads/ exists, CLAUDE.md mentions it, or user explicitly passes Beads input):
1. If file exists: standard markdown plan
2. Else try `bd show <arg>` - if succeeds, treat as Beads ID
3. Else try `bd search "<arg>"` - if unique match, use that issue
4. Else: ask user for clarification

## Phase 2: Setup

Ask: "Work on current branch, create new branch, or use isolated worktree?"

If worktree, use skill:
- skill: worktree-kit

If new branch:
```bash
git checkout main && git pull origin main
git checkout -b <branch>
```

If current branch: confirm this is intentional.

## Phase 3: Task list

**Standard**: Use TodoWrite
- Convert plan to TodoWrite tasks
- Include tests + lint steps
- Keep tasks small + ordered

**Beads alternative**:
- `bd ready --parent <epic-id> --json` for next task
- If multiple ready: pick first (hybrid sort by priority/age is deterministic)
- `bd update <id> --status in_progress --json` to start
- `bd close <id> --json` to complete

## Phase 4: Execute loop

**Context recovery (every turn/task):**
Re-read plan or Beads state before each task. This ensures coherence across context windows per Anthropic's long-running agent guidance.
- `bd show <epic-id>` for Beads, or re-read plan file
- Check git log for recent commits
- Verify working state (run basic tests before starting new work)

**For each task:**
- Check remaining: TodoWrite or `bd ready --parent <epic-id>`
- Pick ONE task only - never batch
- Mark in_progress (`bd update <id> --status in_progress --json` for Beads)
- Implement + test thoroughly
- If you discover new work: `bd create "Found issue" -t bug -p 2 --deps discovered-from:<current-id> --json`
- Leave clean state: commit with descriptive message
- Mark TodoWrite task done (internal tracking)
- If Beads and wrapping up session: ask before closing (user may want to review first)

**Between tasks:**
- Re-read plan/Beads to confirm next task
- Verify no regressions before continuing

## Phase 5: Quality

- Run relevant tests
- Run lint/format per repo
- If change is large/risky, run the quality auditor subagent:
  - Task flow:quality-auditor("Review recent changes")
- Fix critical issues

## Phase 6: Ship

**Beads addition**: `bd dep tree <epic-id>` or `bd show <epic-id>`
Check that all child tasks are closed before commit.

```bash
git add .
git status
git diff --staged
git commit -m "<short summary>"
```

**CRITICAL for Beads**: Run `bd sync` at end of session to force immediate export/commit (bypasses 5s debounce).

Then push + open PR if user wants.

## Definition of Done

Confirm before ship:
- All plan steps completed or explicitly deferred
- All TodoWrite tasks done (or all Beads tasks closed)
- Tests pass
- Lint/format pass
- Docs updated if needed
- `bd sync` run (if using Beads)

## Example loop

Read plan -> task A -> test -> mark done -> re-read plan -> task B
