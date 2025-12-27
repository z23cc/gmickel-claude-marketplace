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
