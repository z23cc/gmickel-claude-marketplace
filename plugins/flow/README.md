<div align="center">

# Flow

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../../LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet)](https://claude.ai/code)
[![Commands](https://img.shields.io/badge/Commands-4-green)](commands/)
[![Agents](https://img.shields.io/badge/Agents-5-yellow)](agents/)
[![Skills](https://img.shields.io/badge/Skills-5-blue)](skills/)

**Two‑step Claude Code workflow: plan first, work second.**

[Install](#install) · [Why Flow](#why-flow) · [Commands](#commands) · [How It Works](#how-it-works)

</div>

---

## Install

```bash
/plugin marketplace add https://github.com/gmickel/gmickel-claude-marketplace
/plugin install flow
```

```bash
/flow:plan Add OAuth login for users
/flow:work plans/add-oauth-login.md
```

---

## Why Flow

Most failures come from weak planning or drifting from the plan. Flow fixes both:

| Problem | Solution |
|---------|----------|
| Weak research | Strong research up front via parallel agents |
| Ignoring existing code | Explicit reuse of existing patterns |
| Drifting from plan | Plan re‑read between tasks |
| Unclear completion | Clear Definition of Done before shipping |

---

## Commands

| Command | Description |
|---------|-------------|
| `/flow:plan` | Research + produce `plans/<slug>.md` |
| `/flow:work` | Execute a plan end‑to‑end |
| `/flow:plan-review` | Carmack-level plan review via rp-cli |
| `/flow:impl-review` | Carmack-level impl review (current branch) |

### Agents

| Agent | Purpose |
|-------|---------|
| `repo-scout` | Find existing patterns in codebase |
| `practice-scout` | Gather best practices |
| `docs-scout` | Fetch official documentation |
| `flow-gap-analyst` | Identify missing flows/edge cases |
| `quality-auditor` | Optional risk scan |

### Skills

| Skill | Purpose |
|-------|---------|
| `flow-plan` | Planning workflow logic |
| `flow-work` | Execution workflow logic |
| `flow-plan-review` | Plan review via rp-cli + chat |
| `flow-impl-review` | Impl review via rp-cli + chat |
| `worktree-kit` | Safe parallel git workspaces |

Skills use **progressive disclosure**: only name + description (~100 tokens) loaded at startup. Full logic loads on-demand when triggered.

**Two ways to trigger**:
1. **Explicit**: `/flow:plan add OAuth` or `/flow:work plans/oauth.md`
2. **Natural language**: "help me plan out adding OAuth" or "implement the plan in plans/oauth.md" — Claude auto-triggers the matching skill

---

## How It Works

### `/flow:plan`

```
1. Run three research agents in parallel
2. Run flow gap check
3. Write plan with references + acceptance checks
4. Offer next step (open, work, create issue)
```

### `/flow:work`

```
1. Confirm plan + clarify blockers
2. Setup branch or worktree
3. Turn plan into TodoWrite tasks
4. Execute task loop with plan re‑read
5. Test + optional audit
6. Ship with Definition of Done
```

---

## Issue Creation

From `/flow:plan`, create issues in **GitHub**, **Linear**, or **Beads**.

Auto‑detects from CLAUDE.md, repo docs, MCP servers, or plugins. Asks if unclear.

---

## Review Commands

Carmack-level code reviews via rp-cli context builder + chat:

```bash
/flow:plan-review plans/add-oauth-login.md
/flow:impl-review
```

Reviews use RepoPrompt's context builder to gather relevant files, then run a thorough chat-based review covering correctness, simplicity, DRY, architecture, edge cases, tests, performance, security, and maintainability.

---

## Development

```bash
claude --plugin-dir ./plugins/flow
```

### Conventions

- Plan files live in `plans/`
- Prefer reuse of centralized code
- Tests and linting are part of the plan

---

<div align="center">

Made by [Gordon Mickel](https://mickel.tech) · [gordon@mickel.tech](mailto:gordon@mickel.tech)

</div>
