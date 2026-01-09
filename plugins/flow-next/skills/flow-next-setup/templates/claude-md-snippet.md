## Flow-Next

Task tracking in `.flow/`. CLI: `.flow/bin/flowctl` (or via flow-next plugin).

**IDs**: `fn-N` (epic), `fn-N.M` (task)

**Commands**:
```bash
flowctl --help             # All commands
flowctl show fn-1          # Epic with tasks
flowctl cat fn-1.2         # Task spec
flowctl ready --epic fn-1  # What's ready
flowctl task create --epic fn-1 --title "..."
flowctl start fn-1.2
flowctl done fn-1.2 --summary-file s.md --evidence-json e.json
flowctl validate --all
```

**Workflow**: plan (`/flow-next:plan`) -> work (`/flow-next:work`) -> review. Re-anchor before every task.

Docs: https://github.com/gmickel/gmickel-claude-marketplace/tree/main/plugins/flow-next
