## Flow-Next

This project uses [Flow-Next](https://github.com/gmickel/gmickel-claude-marketplace/tree/main/plugins/flow-next) for task tracking. Use `flowctl` commands instead of markdown TODOs.

### Setup

```bash
# If .flow/bin exists (local install):
export PATH=".flow/bin:$PATH"
flowctl --help

# If using plugin:
FLOWCTL="${CLAUDE_PLUGIN_ROOT}/scripts/flowctl"
$FLOWCTL --help
```

### File Structure

```
.flow/
├── epics/fn-N.json     # Epic metadata
├── specs/fn-N.md       # Epic specifications
├── tasks/fn-N.M.json   # Task metadata
├── tasks/fn-N.M.md     # Task specifications
├── memory/             # Context memory
└── meta.json           # Project metadata
```

### IDs

- Epics: `fn-N` (e.g., fn-1, fn-2)
- Tasks: `fn-N.M` (e.g., fn-1.1, fn-1.2)

### Commands

```bash
flowctl show fn-1          # Epic with all tasks
flowctl show fn-1.2        # Single task
flowctl cat fn-1           # Epic spec (markdown)
flowctl cat fn-1.2         # Task spec (markdown)
flowctl ready --epic fn-1  # What's ready to work on
flowctl task create --epic fn-1 --title "..."
flowctl start fn-1.2       # Claim task
flowctl done fn-1.2 --summary-file s.md --evidence-json e.json
flowctl validate --all     # Check structure
```

### Workflow

1. `flowctl ready --epic fn-N` - find available tasks
2. `flowctl start fn-N.M` - claim task
3. Implement the task
4. `flowctl done fn-N.M --summary-file ... --evidence-json ...` - complete

### Rules

- Use flowctl for ALL task tracking
- Specs go in `.flow/specs/fn-N.md`
- Tasks go in `.flow/tasks/fn-N.M.md`
- Do NOT create markdown TODO lists or use TodoWrite
- Re-anchor (re-read spec + status) before every task
