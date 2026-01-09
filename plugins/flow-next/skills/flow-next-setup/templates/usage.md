# Flow-Next Usage Guide

Task tracking for AI agents. All state lives in `.flow/`.

## CLI

```bash
.flow/bin/flowctl --help              # All commands
.flow/bin/flowctl <cmd> --help        # Command help
```

## File Structure

```
.flow/
├── bin/flowctl         # CLI (this install)
├── epics/fn-N.json     # Epic metadata
├── specs/fn-N.md       # Epic specifications
├── tasks/fn-N.M.json   # Task metadata
├── tasks/fn-N.M.md     # Task specifications
├── memory/             # Context memory
└── meta.json           # Project metadata
```

## IDs

- Epics: `fn-N` (e.g., fn-1, fn-2)
- Tasks: `fn-N.M` (e.g., fn-1.1, fn-1.2)

## Common Commands

```bash
# View
.flow/bin/flowctl show fn-1          # Epic with all tasks
.flow/bin/flowctl show fn-1.2        # Single task
.flow/bin/flowctl cat fn-1           # Epic spec (markdown)
.flow/bin/flowctl cat fn-1.2         # Task spec (markdown)

# Status
.flow/bin/flowctl ready --epic fn-1  # What's ready to work on
.flow/bin/flowctl validate --all     # Check structure

# Create
.flow/bin/flowctl epic create --title "..."
.flow/bin/flowctl task create --epic fn-1 --title "..."

# Work
.flow/bin/flowctl start fn-1.2       # Claim task
.flow/bin/flowctl done fn-1.2 --summary-file s.md --evidence-json e.json
```

## Workflow

1. `.flow/bin/flowctl ready --epic fn-N` - find available tasks
2. `.flow/bin/flowctl start fn-N.M` - claim task
3. Implement the task
4. `.flow/bin/flowctl done fn-N.M --summary-file ... --evidence-json ...` - complete

## Evidence JSON Format

```json
{"commits": ["abc123"], "tests": ["npm test"], "prs": []}
```

## More Info

- Full docs: https://github.com/gmickel/gmickel-claude-marketplace/tree/main/plugins/flow-next
- CLI reference: `.flow/bin/flowctl --help`
