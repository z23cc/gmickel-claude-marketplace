# Flow Work Phases

(Branch question already asked in SKILL.md before reading this file)

**CRITICAL**: If you are about to create:
- a markdown TODO list,
- a task list outside `.flow/`,
- or any content under `plans/`,

**STOP** and instead:
- create/update tasks in `.flow/` using `flowctl`,
- record details in the epic/task spec markdown.

## Setup

```bash
FLOWCTL="${CLAUDE_PLUGIN_ROOT}/scripts/flowctl"
```

## Phase 1: Resolve Input

**Spec-less start (idea text)**:
1. Initialize: `$FLOWCTL init --json`
2. Create epic: `$FLOWCTL epic create --title "<idea>" --json`
3. Create single task: `$FLOWCTL task create --epic <epic-id> --title "Implement <idea>" --json`
4. Continue with epic-id

**Flow epic ID (fn-N)**:
- Read epic: `$FLOWCTL show <id> --json`
- Read spec: `$FLOWCTL cat <id>`
- Get first ready task: `$FLOWCTL ready --epic <id> --json`

**Flow task ID (fn-N.M)**:
- Read task: `$FLOWCTL show <id> --json`
- Read spec: `$FLOWCTL cat <id>`
- Get epic from task data for context: `$FLOWCTL show <epic-id> --json && $FLOWCTL cat <epic-id>`

## Phase 2: Apply Branch Choice

Based on user's answer from setup questions:

- **Worktree**: use `skill: flow-next-worktree-kit`
- **New branch**:
  ```bash
  git checkout main && git pull origin main
  git checkout -b <branch>
  ```
- **Current branch**: proceed (user already confirmed)

## Phase 3: Prime / Re-anchor Context (EVERY task)

**This phase runs at session start AND before each task.**

Per Anthropic's long-running agent guidance: re-anchor from sources of truth.

1. Identify epic + task:
   - If epic mode: `$FLOWCTL ready --epic <id> --json` → pick first ready task
   - If task mode: use provided task, get epic from task data

2. Re-read context:
   ```bash
   $FLOWCTL show <epic-id> --json
   $FLOWCTL cat <epic-id>
   $FLOWCTL show <task-id> --json
   $FLOWCTL cat <task-id>
   git status
   git log -10 --oneline
   ```

3. Sanity check before editing code:
   ```bash
   $FLOWCTL validate --epic <epic-id> --json
   ```
   Then run the smoke command from epic spec's "Quick commands" section.

## Phase 4: Execute Task Loop

**For each task** (one at a time):

1. **Start task**:
   ```bash
   $FLOWCTL start <task-id> --json
   ```

2. **Implement + test thoroughly**:
   - Read task spec for requirements
   - Write code
   - Run tests
   - Verify acceptance criteria

3. **If you discover new work**:
   - Draft new task title + acceptance checklist
   - Create immediately:
     ```bash
     # Write acceptance to temp file first
     $FLOWCTL task create --epic <epic-id> --title "Found: <issue>" --deps <current-task-id> --acceptance-file <temp-md> --json
     ```
   - Re-run `$FLOWCTL ready --epic <epic-id> --json` to see updated order

4. **Commit changes**:
   ```bash
   git add .
   git commit -m "<short summary of what was done>"
   ```

5. **Complete task**:
   Write done summary to temp file (required format):
   ```
   - What changed (1-3 bullets)
   - Why (1-2 bullets)
   - Verification (tests/commands run)
   - Follow-ups (optional, max 2 bullets)
   ```

   Write evidence to temp JSON file:
   ```json
   {"commits":["<sha>"],"tests":["<test command>"],"prs":[]}
   ```

   Then:
   ```bash
   $FLOWCTL done <task-id> --summary-file <summary.md> --evidence-json <evidence.json> --json
   ```

6. **Verify task completion**:
   ```bash
   $FLOWCTL validate --epic <epic-id> --json
   git status
   ```
   Ensure working tree is clean except intentional changes.

7. **Loop**: Return to Phase 3 for next task.

## Phase 5: Quality

After all tasks complete (or periodically for large epics):

- Run relevant tests
- Run lint/format per repo
- If change is large/risky, run the quality auditor subagent:
  - Task flow-next:quality-auditor("Review recent changes")
- Fix critical issues

## Phase 6: Ship

**Verify all tasks done**:
```bash
$FLOWCTL show <epic-id> --json
$FLOWCTL validate --epic <epic-id> --json
```

**Final commit** (if any uncommitted changes):
```bash
git add .
git status
git diff --staged
git commit -m "<final summary>"
```

**Close epic** (if all tasks done):
```bash
$FLOWCTL epic close <epic-id> --json
```

Then push + open PR if user wants.

## Phase 7: Review (if chosen at start)

If user chose "Yes" to review in setup questions:
1. Invoke `/flow-next:impl-review` to review the changes
2. If review returns "Needs Work" or "Major Rethink":
   - **Immediately fix the issues** (do NOT ask for confirmation — user already consented)
   - Commit fixes
   - Re-run `/flow-next:impl-review`
3. Repeat until review returns "Ship"

**No human gates here** — the review-fix-review loop is fully automated.

## Definition of Done

Confirm before ship:
- All tasks have status "done"
- `$FLOWCTL validate --epic <id>` passes
- Tests pass
- Lint/format pass
- Docs updated if needed
- Working tree is clean

## Example loop

```
Prime → Task A → test → commit → done → Prime → Task B → ...
```
