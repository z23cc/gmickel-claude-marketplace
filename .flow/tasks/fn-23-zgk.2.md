# fn-23-zgk.2 Update ID regex patterns

## Description
Update all regex patterns that parse epic/task IDs to support variable-length slugs while maintaining backwards compatibility with existing formats.

**Size:** M
**Files:** 
- `plugins/flow-next/scripts/flowctl.py` (4 regex locations)
- `plugins/flow-next/scripts/hooks/ralph-guard.py` (1 location)

## Approach

1. Update main `parse_id()` regex at line 590:
   ```python
   # Current: r"^fn-(\d+)(?:-[a-z0-9]{3})?(?:\.(\d+))?$"
   # New: supports fn-N, fn-N-xxx, fn-N-longer-slug
   r"^fn-(\d+)(?:-[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)?(?:\.(\d+))?$"
   ```

2. Update file glob regexes at lines 1738, 4094, 6372:
   ```python
   # Current: r"^fn-(\d+)(?:-[a-z0-9]{3})?\.json$"
   # New: same pattern adjustment
   ```

3. Update ralph-guard.py receipt parsing at lines 276-284

## Key context

The regex must accept all three formats:
- `fn-1` (legacy numeric only)
- `fn-1-abc` (current 3-char random)
- `fn-1-add-oauth-login` (new slugified)

Pattern explanation:
- `[a-z0-9]` - must start with alphanumeric
- `(?:[a-z0-9-]*[a-z0-9])?` - optional middle with hyphens, must end alphanumeric
- This prevents leading/trailing hyphens in slug
## Acceptance
- [ ] `parse_id("fn-1")` returns valid (legacy format)
- [ ] `parse_id("fn-1-abc")` returns valid (3-char format)
- [ ] `parse_id("fn-1-add-oauth")` returns valid (slug format)
- [ ] `parse_id("fn-1.2")` returns valid (legacy task)
- [ ] `parse_id("fn-1-abc.2")` returns valid (3-char task)
- [ ] `parse_id("fn-1-add-oauth.2")` returns valid (slug task)
- [ ] `parse_id("fn-1-")` returns invalid (trailing hyphen)
- [ ] `parse_id("fn-1--double")` returns invalid (double hyphen)
- [ ] File glob patterns match all three formats
- [ ] ralph-guard receipt parsing works with slug format
- [ ] All 45 smoke tests pass
## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
