<div align="center">

# Flow-Next

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../../LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](../../CHANGELOG.md)
[![Commands](https://img.shields.io/badge/Commands-5-green)](commands/)
[![Agents](https://img.shields.io/badge/Agents-6-yellow)](agents/)
[![Skills](https://img.shields.io/badge/Skills-7-blue)](skills/)

**Plan first, work second. No external dependencies.**

</div>

---

A simplified alternative to [Flow](../flow/) that uses a repo-native `.flow/` directory instead of Beads. Same plan-first workflow, bundled `flowctl.py` CLI, zero external tools required.

---

## Install

```bash
/plugin marketplace add https://github.com/gmickel/gmickel-claude-marketplace
/plugin install flow-next
```

---

## Quick Start

```bash
/flow-next:plan Add OAuth login for users
/flow-next:work fn-1
```

That's it. Plan creates an epic in `.flow/`, work executes its tasks.

---

## Commands

| Command | Description |
|---------|-------------|
| `/flow-next:plan` | Research + produce epic with tasks in `.flow/` |
| `/flow-next:work` | Execute epic or single task |
| `/flow-next:interview` | Deep interview about an epic/task |
| `/flow-next:plan-review` | Carmack-level plan review via rp-cli |
| `/flow-next:impl-review` | Carmack-level impl review (current branch) |

---

## .flow/ Directory Structure

```
.flow/
├── meta.json              # Schema version
├── epics/
│   └── fn-1.json          # Epic metadata (id, title, status)
├── specs/
│   └── fn-1.md            # Epic spec (plan content)
├── tasks/
│   ├── fn-1.1.json        # Task metadata (id, status, deps, assignee)
│   ├── fn-1.1.md          # Task spec (description, acceptance, done summary)
│   ├── fn-1.2.json
│   └── fn-1.2.md
└── memory/                # (reserved for future context)
```

### IDs

- **Epic**: `fn-N` (e.g., `fn-1`, `fn-12`)
- **Task**: `fn-N.M` (e.g., `fn-1.1`, `fn-12.5`)

### Separation of Concerns

- **JSON**: Metadata only (IDs, status, deps)
- **Markdown**: Narrative/spec (descriptions, acceptance, done summaries)

---

## flowctl CLI

Bundled Python script for managing `.flow/`. Skills call this automatically.

```bash
flowctl init                          # Create .flow/ structure
flowctl epic create --title "..."     # Create epic
flowctl task create --epic fn-1 ...   # Create task with deps
flowctl ready --epic fn-1             # List ready/in_progress/blocked
flowctl start fn-1.1                  # Claim + mark in_progress
flowctl done fn-1.1 --summary-file... # Mark done + record summary
flowctl show fn-1 --json              # Epic with all tasks (alias: list, ls)
flowctl cat fn-1                      # Print epic spec
flowctl validate --all                # Validate all epics (for CI)
```

See [docs/flowctl.md](docs/flowctl.md) for full reference.

---

## Flow vs Flow-Next

| Aspect | Flow | Flow-Next |
|--------|------|-----------|
| Task tracking | Beads (`bd` CLI) or plan files | `.flow/` (bundled `flowctl`) |
| Plan files | `plans/<slug>.md` | None (specs in `.flow/specs/`) |
| External deps | Optional Beads CLI | None (Python 3 only) |
| RepoPrompt | Optional, enhances review | Optional, enhances review |
| CLAUDE.md edits | Required for Beads | Not required |

**Choose Flow-Next when:**
- You want zero external dependencies
- You prefer repo-native task tracking
- You don't need Beads' full issue management

**Choose Flow when:**
- You already use Beads for issue tracking
- You want plan files as standalone artifacts

---

## RepoPrompt Integration

When [RepoPrompt](https://repoprompt.com) rp-cli is detected, plan/work commands offer cross-model review. Without it, reviews are skipped gracefully.

---

## Multi-User Safety

Built for teams working in parallel branches:

- **Merge-safe IDs**: Scans existing files to allocate IDs (no shared counters to conflict)
- **Soft claims**: Tasks track `assignee` - prevents accidental duplicate work
- **Scoped writes**: Task ops only write task files; epic ops only write epic files
- **CI validation**: `flowctl validate --all` gates PRs (see `docs/ci-workflow-example.yml`)

```bash
# Actor A starts task
flowctl start fn-1.1   # Sets assignee automatically

# Actor B tries to start same task
flowctl start fn-1.1   # Fails: "claimed by actor-a@example.com"
flowctl start fn-1.1 --force  # Override with explicit flag
```

No locking servers, no hooks, no daemons. Just social coordination via file ownership.

---

## Why Flow-Next?

- **Non-invasive**: No hooks, daemons, or global config edits
- **No instruction-file modifications**: `CLAUDE.md`/`AGENTS.md` remain untouched
- **Merge-friendly**: One epic/task per file; minimal conflict surface
- **Agent-first**: Skills orchestrate; `flowctl` is the deterministic contract
- **Easy uninstall**: Delete `.flow/` and stop using the plugin

---

## Roadmap

- **Memory** (optional): Curated `.flow/memory/` for decisions, conventions, and compaction summaries. Persistent context across sessions without bloating specs.
- **Ralph Wiggum Mode** (optional): Lightweight, humorous progress narration. Status flavor without affecting artifacts. "I'm helping!"

---

## Requirements

- Python 3.8+ (for bundled flowctl)
- git
- rp-cli (optional, for reviews)

---

## Development

```bash
claude --plugin-dir ./plugins/flow-next
```

---

<div align="center">

Made by [Gordon Mickel](https://mickel.tech)

</div>
