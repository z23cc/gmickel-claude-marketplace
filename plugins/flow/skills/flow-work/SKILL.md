---
name: flow-work
description: Execute a plan file systematically with git setup, task tracking, quality checks, and commit workflow. Use when implementing a plan, working through a spec, or following documented steps.
---

# Flow work

Execute a plan systematically. Focus on finishing.

**Role**: execution lead, plan fidelity first.
**Goal**: complete every plan step in order with tests.

## Input

Plan file: #$ARGUMENTS

If empty, ask for the plan path.

## Workflow

Read [phases.md](phases.md) and execute each phase in order. Phases include setup, task tracking via TodoWrite, and quality checks.

## Guardrails

- Don't start without plan
- Don't skip tests
- Don't leave tasks half-done
