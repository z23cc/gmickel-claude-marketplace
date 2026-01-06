# flowctl CLI Reference

CLI for `.flow/` task tracking. Agents must use flowctl for all writes.

## Available Commands

```
init, detect, epic, task, dep, show, cat, ready, start, done, validate
```

Aliases: `list` → `show`, `ls` → `show`

## Multi-User Safety

flowctl is designed for concurrent use:

- **ID allocation**: Scans existing files to determine next ID (merge-safe)
- **Soft claims**: Tasks have `assignee` field to prevent duplicate work
- **Actor resolution**: Uses `FLOW_ACTOR` env, git email, git name, or `$USER`
- **Validation**: `--all` mode for CI gates

## File Structure

```
.flow/
├── meta.json          # {schema_version, next_epic}
├── epics/fn-N.json    # Epic state
├── specs/fn-N.md      # Epic spec (markdown)
├── tasks/fn-N.M.json  # Task state
├── tasks/fn-N.M.md    # Task spec (markdown)
└── memory/            # Agent memory (reserved)
```

## ID Format

- Epic: `fn-N` (e.g., `fn-1`, `fn-42`)
- Task: `fn-N.M` (e.g., `fn-1.3`, `fn-42.7`)

## Commands

### init

Initialize `.flow/` directory.

```bash
flowctl init [--json]
```

### detect

Check if `.flow/` exists and is valid.

```bash
flowctl detect [--json]
```

Output:
```json
{"success": true, "exists": true, "valid": true, "path": "/repo/.flow"}
```

### epic create

Create new epic.

```bash
flowctl epic create --title "Epic title" [--json]
```

Output:
```json
{"success": true, "id": "fn-1", "title": "Epic title", "spec_path": ".flow/specs/fn-1.md"}
```

### epic set-plan

Overwrite epic spec from file.

```bash
flowctl epic set-plan fn-1 --file plan.md [--json]
```

### epic close

Close epic (requires all tasks done).

```bash
flowctl epic close fn-1 [--json]
```

### task create

Create task under epic.

```bash
flowctl task create --epic fn-1 --title "Task title" [--deps fn-1.2,fn-1.3] [--acceptance-file accept.md] [--json]
```

Output:
```json
{"success": true, "id": "fn-1.4", "epic": "fn-1", "title": "Task title", "depends_on": ["fn-1.2", "fn-1.3"]}
```

### task set-description

Set task description section.

```bash
flowctl task set-description fn-1.2 --file desc.md [--json]
```

### task set-acceptance

Set task acceptance section.

```bash
flowctl task set-acceptance fn-1.2 --file accept.md [--json]
```

### dep add

Add dependency to task.

```bash
flowctl dep add fn-1.3 fn-1.2 [--json]
```

Dependencies must be within same epic.

### show

Show epic or task details.

```bash
flowctl show fn-1 [--json]     # Epic with tasks
flowctl show fn-1.2 [--json]   # Task only
```

Epic output includes `tasks` array with id/title/status/depends_on.

### cat

Print spec markdown (no JSON mode).

```bash
flowctl cat fn-1      # Epic spec
flowctl cat fn-1.2    # Task spec
```

### ready

List tasks ready to start, in progress, and blocked.

```bash
flowctl ready --epic fn-1 [--json]
```

Output:
```json
{
  "success": true,
  "epic": "fn-1",
  "actor": "user@example.com",
  "ready": [{"id": "fn-1.3", "title": "...", "depends_on": []}],
  "in_progress": [{"id": "fn-1.1", "title": "...", "assignee": "user@example.com"}],
  "blocked": [{"id": "fn-1.4", "title": "...", "blocked_by": ["fn-1.2"]}]
}
```

### start

Start task (set status=in_progress). Sets assignee to current actor.

```bash
flowctl start fn-1.2 [--force] [--note "..."] [--json]
```

Validates:
- Status is `todo` (or `in_progress` if resuming own task)
- All dependencies are `done`
- Not claimed by another actor

Use `--force` to skip checks and take over from another actor.
Use `--note` to add a claim note (auto-set on takeover).

### done

Complete task with summary and evidence. Requires `in_progress` status.

```bash
flowctl done fn-1.2 --summary-file summary.md --evidence-json evidence.json [--force] [--json]
```

Use `--force` to skip status check.

Evidence JSON format:
```json
{"commits": ["abc123"], "tests": ["test_foo"], "prs": ["#42"]}
```

### validate

Validate epic structure (specs, deps, cycles).

```bash
flowctl validate --epic fn-1 [--json]
flowctl validate --all [--json]
```

Single epic output:
```json
{"success": false, "epic": "fn-1", "valid": false, "errors": ["..."], "warnings": [], "task_count": 5}
```

All epics output:
```json
{
  "success": false,
  "valid": false,
  "epics": [{"epic": "fn-1", "valid": true, ...}],
  "total_epics": 2,
  "total_tasks": 10,
  "total_errors": 1
}
```

Checks:
- Epic/task specs exist
- Task specs have required headings
- Dependencies exist and are within epic
- No dependency cycles
- Done status consistency

Exits with code 1 if validation fails (for CI use).

## JSON Output

All commands support `--json` (except `cat`). Wrapper format:

```json
{"success": true, ...}
{"success": false, "error": "message"}
```

Exit codes: 0=success, 1=error.

## Error Handling

- Missing `.flow/`: "Run 'flowctl init' first"
- Invalid ID format: "Expected format: fn-N (epic) or fn-N.M (task)"
- File conflicts: Refuses to overwrite existing epics/tasks
- Dependency violations: Same-epic only, must exist, no cycles
- Status violations: Can't start non-todo, can't close with incomplete tasks
