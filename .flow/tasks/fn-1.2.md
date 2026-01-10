# fn-1.2 Capture hook

## Description
Extend ralph-guard.py PostToolUse handler to capture learnings from NEEDS_WORK reviews. When chat-send returns NEEDS_WORK/MAJOR_RETHINK, parse feedback and append to pitfalls.md.

Key implementation:
- Check `memory.enabled` config before processing
- `extract_feedback(response)` parses review into structured format
- `is_learnable(feedback)` filters to actionable patterns only
- Append to `.flow/memory/pitfalls.md` with date, task, issue, fix, category

Filter criteria (`is_learnable`):
- Has specific actionable fix (not vague)
- References code pattern, API, or convention
- Not a one-off typo or obvious bug

## Acceptance
- [ ] PostToolUse handler detects chat-send with NEEDS_WORK
- [ ] Checks `memory.enabled` before processing
- [ ] Parses feedback into structured format (issue, fix, category)
- [ ] `is_learnable()` filters out non-actionable items
- [ ] Appends to pitfalls.md with correct format
- [ ] Handles missing memory dir gracefully

## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
