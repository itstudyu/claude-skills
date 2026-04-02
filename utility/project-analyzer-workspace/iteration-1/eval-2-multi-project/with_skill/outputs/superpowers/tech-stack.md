# Tech Stack — superpowers

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/superpowers

## Core
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | JavaScript (CommonJS — brainstorm server) | N/A | skills/brainstorming/scripts/server.cjs:1 |
| Language | JavaScript (ESM — OpenCode plugin) | N/A | .opencode/plugins/superpowers.js:1, package.json:4 |
| Language | Bash (hooks, test scripts) | N/A | hooks/session-start:1 |
| Language | Python (test analysis tool) | N/A | tests/claude-code/analyze-token-usage.py:1 |
| Language | Markdown (skills content) | N/A | skills/*/SKILL.md |
| Framework | Claude Code Plugin System | 5.0.6 | .claude-plugin/plugin.json:5 |
| Framework | Cursor Plugin System | 5.0.6 | .cursor-plugin/plugin.json:5 |
| Framework | Gemini CLI Extension | 5.0.6 | gemini-extension.json:4 |
| Framework | OpenCode Plugin System | 5.0.6 | .opencode/plugins/superpowers.js:49 |
| Framework | Codex (via AGENTS.md) | N/A | .codex/INSTALL.md:1 |
| Package Manager | npm | N/A | package.json:1 |

## Infrastructure
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| WebSocket Server | Node.js built-in (zero deps, RFC 6455) | N/A | skills/brainstorming/scripts/server.cjs:6-9 |
| HTTP Server | Node.js built-in http module | N/A | skills/brainstorming/scripts/server.cjs:2 |
| Plugin Marketplace | Claude Code marketplace | N/A | .claude-plugin/marketplace.json:1 |

## Dev Tools
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Test Framework | Node.js assert + custom runner (brainstorm server) | N/A | tests/brainstorm-server/server.test.js:16 |
| Test Client | ws (WebSocket client for tests) | ^8.19.0 | tests/brainstorm-server/package.json:8 |
| Test Runner | Bash scripts (skill triggering, explicit requests) | N/A | tests/skill-triggering/run-all.sh, tests/explicit-skill-requests/run-all.sh |
| CI/CD | GitHub (issue templates, PR template, funding) | N/A | .github/ISSUE_TEMPLATE/config.yml, .github/PULL_REQUEST_TEMPLATE.md |
| Linting | Not detected | N/A | N/A |
