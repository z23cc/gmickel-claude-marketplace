# Claude Code Project Guide

## Purpose
This repo is a Claude Code plugin marketplace. It currently ships one plugin: **flow**.

## Structure
- Marketplace manifest: `.claude-plugin/marketplace.json`
- Plugins live in `plugins/`
- Flow plugin root: `plugins/flow/`
  - Manifest: `plugins/flow/.claude-plugin/plugin.json`
  - Commands: `plugins/flow/commands/`
  - Agents: `plugins/flow/agents/`
  - Skills: `plugins/flow/skills/`

## File tree (current)
```
.
├─ .claude-plugin/
│  └─ marketplace.json
├─ plugins/
│  └─ flow/
│     ├─ .claude-plugin/
│     │  └─ plugin.json
│     ├─ agents/
│     ├─ commands/
│     ├─ skills/
│     └─ README.md
├─ CHANGELOG.md
├─ CLAUDE.md
├─ LICENSE
└─ README.md
```

## Commands (flow)
- `/flow:plan` -> writes `plans/<slug>.md`
- `/flow:work` -> executes a plan
- `/flow:plan-review` -> Carmack-level plan review via rp-cli
- `/flow:impl-review` -> Carmack-level impl review (current branch)

## Current components
- Commands: 4
- Agents: 5
- Skills: 5

## Marketplace rules
- Keep `marketplace.json` and `plugins/flow/.claude-plugin/plugin.json` in sync (name, version, description, author, homepage).
- Only include fields supported by Claude Code specs.
- `source` in marketplace must point at plugin root.

## Versioning
- Use semver.
- When behavior changes, bump both:
  - `.claude-plugin/marketplace.json` -> plugin version
  - `plugins/flow/.claude-plugin/plugin.json` -> version

## Editing rules
- Keep prompts concise and direct.
- Avoid feature flags or backwards-compatibility scaffolding (plugin is pre-release).
- Do not add extra commands/agents/skills unless explicitly requested.

## Release checklist
1) Update versions + descriptions if counts change.
2) Update `CHANGELOG.md` with new version entry.
3) Validate JSON:
   - `jq . .claude-plugin/marketplace.json`
   - `jq . plugins/flow/.claude-plugin/plugin.json`
4) Confirm install flow:
   - `/plugin marketplace add https://github.com/gmickel/gmickel-claude-marketplace`
   - `/plugin install flow`

## Repo metadata
- Author: Gordon Mickel (gordon@mickel.tech)
- Homepage: https://mickel.tech
- Marketplace repo: https://github.com/gmickel/gmickel-claude-marketplace
