---
name: flow-next-plan
description: Create structured build plans from feature requests or Flow IDs. Use when planning features or designing implementation. Triggers on /flow-next:plan with text descriptions or Flow IDs (fn-1, fn-1.2).
---

# Flow plan

Turn a rough idea into an epic with tasks in `.flow/`. This skill does not write code.

**IMPORTANT**: This plugin uses `.flow/` for ALL task tracking. Do NOT use markdown TODOs, plan files, TodoWrite, Beads, or other tracking methods. All task state must be read and written via `flowctl`.

**Role**: product-minded planner with strong repo awareness.
**Goal**: produce an epic with tasks that match existing conventions and reuse points.

## Input

Full request: #$ARGUMENTS

Accepts:
- Feature/bug description in natural language
- Flow epic ID `fn-N` to refine existing epic
- Flow task ID `fn-N.M` to refine specific task
- Chained instructions like "then review with /flow-next:plan-review"

Examples:
- `/flow-next:plan Add OAuth login for users`
- `/flow-next:plan fn-1`
- `/flow-next:plan fn-1 then review via /flow-next:plan-review`

If empty, ask: "What should I plan? Give me the feature or bug in 1-5 sentences."

## FIRST: Setup Questions (if rp-cli available)

Check: `which rp-cli >/dev/null 2>&1`

If available, output these questions as text (do NOT use AskUserQuestion tool):

```
Quick setup before planning:

1. **Research approach** — Use RepoPrompt for deeper context?
   a) Yes, context-scout (slower, thorough)
   b) No, repo-scout (faster)

2. **Review** — Run Carmack-level review after?
   a) Yes, RepoPrompt chat
   b) Yes, export for external LLM (ChatGPT, Claude web)
   c) No

(Reply: "1a 2a", "1b 2c", or just tell me naturally)
```

Wait for response. Parse naturally — user may reply terse ("1a 2b") or ramble via voice.

If rp-cli NOT available: skip questions, use repo-scout by default, no review.

## Workflow

Read [steps.md](steps.md) and follow each step in order. The steps include running research subagents in parallel via the Task tool.
If user chose review:
- Option 2a: run `/flow-next:plan-review` after Step 4, fix issues until it passes
- Option 2b: run `/flow-next:plan-review` with export mode after Step 4

## Output

All plans go into `.flow/`:
- Epic: `.flow/epics/fn-N.json` + `.flow/specs/fn-N.md`
- Tasks: `.flow/tasks/fn-N.M.json` + `.flow/tasks/fn-N.M.md`

**Never write to `plans/` directory. Never use TodoWrite for task tracking.**

## Output rules

- Only create/update epics and tasks via flowctl
- No code changes
- No plan files under `plans/`
