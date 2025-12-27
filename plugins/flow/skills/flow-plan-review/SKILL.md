---
name: flow-plan-review
description: Carmack-level plan review via rp-cli context builder + chat. Use when reviewing implementation plans, architecture docs, or design specs. Triggers on mentions of plan review, design review, or architecture review.
---

# Plan Review Mode (CLI)

Conduct a John Carmack-level review of implementation plans using RepoPrompt's context builder and chat.

**Role**: Code Review Coordinator (NOT the reviewer)
**Tool**: rp-cli for context building and chat delegation

## Input

Arguments: #$ARGUMENTS
Format: `<plan-file> [additional context or focus areas]`

Example: `/flow:plan-review docs/plan/auth-refactor.md focus on security and error handling`

## Critical Requirement

**DO NOT REVIEW THE PLAN YOURSELF** – you are a coordinator, not the reviewer.

Your job is to:
1. Use `rp-cli -e 'windows'` to find the RepoPrompt window
2. Use `rp-cli -w <id> -e 'builder ...'` to build context around the plan
3. Use `rp-cli -w <id> -e 'chat ...'` to execute the review

The **RepoPrompt chat** conducts the actual review with full file context.

## Workflow

Read [workflow.md](workflow.md) and follow each phase in order. Phases include window selection, context building, and review execution.

## rp-cli Reference

Read [rp-cli-reference.md](rp-cli-reference.md) for command syntax and examples.
