# fn-23-zgk.4 Update skill docs and documentation

## Description
Update all skill documentation and other docs with new ID format examples.

**Size:** M
**Files:** 
- `plugins/flow-next/skills/*/SKILL.md` (~11 files)
- `plugins/flow-next/skills/*/steps.md`, `workflow.md`, etc.
- `plugins/flow-next/README.md`
- `plugins/flow-next/docs/flowctl.md`
- `.flow/usage.md`
- `plugins/flow-next/skills/flow-next-setup/templates/usage.md`

## Approach

1. Update skill SKILL.md files:
   ```bash
   grep -r "fn-[0-9]-[a-z0-9]\{3\}" plugins/flow-next/skills/
   ```
   Replace `fn-1-abc` style examples with `fn-1-add-feature` style

2. Update README.md ID Format section (line ~1294):
   - Explain new format: `fn-N-slug` where slug is derived from title
   - Note backwards compat with `fn-N` and `fn-N-xxx`

3. Update flowctl.md ID Format section (line ~46):
   - Same explanation as README

4. Update usage.md files:
   - `.flow/usage.md` (lines 25-28)
   - `templates/usage.md` (same section)

## Key context

Keep examples realistic:
- `fn-1-add-oauth` not `fn-1-abc`
- `fn-2-fix-login-bug` not `fn-2-xyz`
- Show variety: short slugs, multi-word slugs
## Acceptance
- [ ] All SKILL.md files updated (~11 files)
- [ ] README.md ID Format section explains new format
- [ ] flowctl.md ID Format section updated
- [ ] .flow/usage.md updated
- [ ] templates/usage.md updated
- [ ] Examples use descriptive slugs throughout
- [ ] Backwards compatibility note present (old formats still work)
- [ ] No broken example IDs (all match new regex)
## Done summary
TBD

## Evidence
- Commits:
- Tests:
- PRs:
