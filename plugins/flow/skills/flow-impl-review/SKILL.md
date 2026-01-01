---
name: flow-impl-review
description: John Carmack-level implementation review via rp-cli for current branch changes. Use when reviewing code changes, PRs, or implementations. Triggers on mentions of code review, implementation review, or PR review.
---

# Implementation Review Mode (CLI)

Conduct a John Carmack-level review of implementation changes on the current branch using RepoPrompt's context builder and chat.

**Role**: Code Review Coordinator (NOT the reviewer)
**Tool**: rp-cli for context building and chat delegation

## Input

Arguments: #$ARGUMENTS
Format: `[additional context, focus areas, or special instructions]`

Example: `/flow:impl-review focus on the auth changes, ignore styling`

Reviews all changes on the **current branch** vs main/master.

## FIRST: Setup Question (if rp-cli available)

Check: `which rp-cli >/dev/null 2>&1`

If available, output this question as text (do NOT use AskUserQuestion tool):

```
Both modes use RepoPrompt for context building (builder, file selection, codemaps).
The difference is where the review happens:

Review mode:
a) RepoPrompt chat (default) — review via rp-cli chat
b) Export for external LLM — export context file for ChatGPT, Claude web, etc.

(Reply: "a", "b", "export", or just tell me)
```

Wait for response. Parse naturally.

If rp-cli NOT available: inform user that rp-cli is required for this skill.

## Context Sources

The workflow gathers context from:
- Git diff and commit messages
- Plan files referenced in commits
- PRD/architecture docs
- **Beads**: If you know which issue(s) this work relates to, include via `bd show`

## Critical Requirement

**DO NOT REVIEW CODE YOURSELF** – you are a coordinator, not the reviewer.

Your job is to:
1. Use `rp-cli -e 'windows'` to find the RepoPrompt window
2. Use `rp-cli -w <id> -e 'builder ...'` to build context
3. Use `rp-cli -w <id> -e 'chat ...'` to execute the review

The **RepoPrompt chat** conducts the actual review with full file context.

## Workflow

Read [workflow.md](workflow.md) and follow each phase in order. Phases include change identification, context building, and review execution.

## rp-cli Reference

Read [rp-cli-reference.md](rp-cli-reference.md) for command syntax and examples.
