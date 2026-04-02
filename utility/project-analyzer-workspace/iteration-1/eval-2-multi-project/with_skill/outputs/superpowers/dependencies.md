# Dependencies — superpowers

> Analyzed on 2026-04-02

## Production Dependencies

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| (none in package.json) | N/A | Root package.json has no dependencies | package.json:1-6 |

The project intentionally uses zero production dependencies. The brainstorm server (`skills/brainstorming/scripts/server.cjs`) implements the WebSocket protocol from scratch using only Node.js built-in modules (`crypto`, `http`, `fs`, `path`) — server.cjs:1-4.

## Dev Dependencies (test-only)

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| ws | ^8.19.0 | WebSocket test client | tests/brainstorm-server/package.json:8, tests/brainstorm-server/server.test.js:13 |

## Dependency Health
- **Total production deps:** 0
- **Total dev deps:** 1 (test-scoped)
- **Lock file:** tests/brainstorm-server/package-lock.json present: yes
- **Outdated indicators:** None — minimal dependency surface

## Platform Dependencies
| Platform | Config File | Purpose |
|----------|-------------|---------|
| Claude Code | .claude-plugin/plugin.json:1 | Plugin manifest for Claude Code marketplace |
| Cursor | .cursor-plugin/plugin.json:1 | Plugin manifest for Cursor |
| Gemini CLI | gemini-extension.json:1 | Extension manifest for Gemini CLI |
| OpenCode | .opencode/plugins/superpowers.js:1 | Plugin with system prompt transform |
| Codex | .codex/INSTALL.md:1 | Manual install instructions via symlinks |

## Internal Skill Dependencies
| Skill | Path | Depends On |
|-------|------|-----------|
| brainstorming | skills/brainstorming/ | writing-plans (chains to next) — SKILL.md:66 |
| writing-plans | skills/writing-plans/ | subagent-driven-development or executing-plans — SKILL.md:146-150 |
| subagent-driven-development | skills/subagent-driven-development/ | writing-plans (input), test-driven-development, requesting-code-review, finishing-a-development-branch, using-git-worktrees — SKILL.md:268-277 |
| finishing-a-development-branch | skills/finishing-a-development-branch/ | using-git-worktrees (cleanup) — SKILL.md:200 |
| systematic-debugging | skills/systematic-debugging/ | test-driven-development (Phase 4), verification-before-completion — SKILL.md:179,287-288 |
| using-superpowers | skills/using-superpowers/ | All other skills (routing hub) — SKILL.md:29-30 |
