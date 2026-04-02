# Code Patterns — superpowers

> Analyzed on 2026-04-02

## Naming Conventions
| Context | Pattern | Example | Source |
|---------|---------|---------|--------|
| Skill directories | kebab-case (full phrases) | `subagent-driven-development` | skills/subagent-driven-development/ |
| Skill names (YAML) | kebab-case | `name: brainstorming` | skills/brainstorming/SKILL.md:2 |
| JS variables | camelCase | `computeAcceptKey`, `encodeFrame` | skills/brainstorming/scripts/server.cjs:11,15 |
| JS constants | UPPER_SNAKE_CASE | `OPCODES`, `WS_MAGIC` | skills/brainstorming/scripts/server.cjs:8,9 |
| Test files | kebab-case with `.test.` | `server.test.js`, `ws-protocol.test.js` | tests/brainstorm-server/ |
| Test prompt files | kebab-case `.txt` | `use-systematic-debugging.txt` | tests/explicit-skill-requests/prompts/ |

## Skill File Structure
Skills reside in `skills/<skill-name>/` with variable contents:
- `SKILL.md` — Skill definition with YAML frontmatter (required)
- Additional markdown files — supporting docs (optional)
- `scripts/` — executable code (optional, only in brainstorming)

No `evals/` directory convention — tests live in a separate `tests/` directory at root.
**Source:** skills/* directories, tests/ directory

## SKILL.md Frontmatter Pattern
```yaml
---
name: skill-name
description: Use when [trigger condition]
---
```
Descriptions are shorter than claude-skills, typically one sentence without multilingual triggers.
**Source:** skills/brainstorming/SKILL.md:2-3, skills/test-driven-development/SKILL.md:2-3

## Skill Content Patterns

### Hard Gate Pattern
Uses `<HARD-GATE>` tags (same as claude-skills):
```markdown
<HARD-GATE>
Do NOT invoke any implementation skill, write any code...
</HARD-GATE>
```
**Source:** skills/brainstorming/SKILL.md:12-14

### EXTREMELY-IMPORTANT Tags
Uses custom XML tags for emphasis beyond HARD-GATE:
```markdown
<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply...
</EXTREMELY-IMPORTANT>
```
**Source:** skills/using-superpowers/SKILL.md:6-16

### SUBAGENT-STOP Tags
Prevents subagents from loading root-level skills:
```markdown
<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>
```
**Source:** skills/using-superpowers/SKILL.md:6-8

### Graphviz Flow Diagrams
Same pattern as claude-skills — `dot` language blocks in Markdown:
**Source:** skills/brainstorming/SKILL.md:36-63, skills/subagent-driven-development/SKILL.md:17-33, skills/using-superpowers/SKILL.md:47-73

### Rationalization Prevention Tables
Same pattern as claude-skills:
**Source:** skills/test-driven-development/SKILL.md:256-270, skills/systematic-debugging/SKILL.md:248-257

### Red Flags / Stop Signals
Same pattern as claude-skills:
**Source:** skills/using-superpowers/SKILL.md:80-93, skills/test-driven-development/SKILL.md:272-293

### Prompt Templates (subagent system)
Separate markdown files as prompt templates for subagent dispatch:
- `implementer-prompt.md` — skills/subagent-driven-development/implementer-prompt.md
- `spec-reviewer-prompt.md` — skills/subagent-driven-development/spec-reviewer-prompt.md
- `code-quality-reviewer-prompt.md` — skills/subagent-driven-development/code-quality-reviewer-prompt.md
**Source:** skills/subagent-driven-development/SKILL.md:122-124

## Hook Architecture

### Single SessionStart Hook
Only one hook: `session-start` script that injects the `using-superpowers` SKILL.md content:
- Reads `skills/using-superpowers/SKILL.md` — hooks/session-start:18
- Wraps in `<EXTREMELY_IMPORTANT>` tags — hooks/session-start:35
- Outputs JSON with `hookSpecificOutput.additionalContext` (Claude Code) or `additional_context` (Cursor/other) — hooks/session-start:46-54
- Detects platform via environment variables (`CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`) — hooks/session-start:46-49

### Cross-Platform Hook Format
- Claude Code: `hooks/hooks.json` — hooks/hooks.json:1
- Cursor: `hooks/hooks-cursor.json` — hooks/hooks-cursor.json:1
- Windows: `hooks/run-hook.cmd` — hooks/run-hook.cmd

## JavaScript Code Patterns

### Zero-Dependency Server
The brainstorm server implements WebSocket RFC 6455 from scratch:
- Custom `computeAcceptKey()` using SHA-1 — server.cjs:11
- Custom `encodeFrame()` with variable-length payload support — server.cjs:15
- Custom `decodeFrame()` for incoming frames — server.cjs:39
**Source:** skills/brainstorming/scripts/server.cjs:1-40

### ESM Plugin Architecture
OpenCode plugin uses ES modules with dynamic path resolution:
```javascript
const __dirname = path.dirname(fileURLToPath(import.meta.url));
```
**Source:** .opencode/plugins/superpowers.js:13

### JSON Escaping (Bash)
Uses bash parameter substitution for JSON string escaping (performance optimization over character-by-character loop):
```bash
s="${s//\\/\\\\}"
s="${s//\"/\\\"}"
```
**Source:** hooks/session-start:23-29

## File Organization
```
superpowers/
├── .claude-plugin/         # Claude Code plugin manifest + marketplace
├── .cursor-plugin/         # Cursor plugin manifest
├── .codex/                 # Codex installation instructions
├── .opencode/              # OpenCode ESM plugin
├── .github/                # Issue templates, PR template, funding
├── skills/                 # All skill definitions (13 skills)
│   ├── brainstorming/      # Includes scripts/ with server code
│   └── ...                 # Each has SKILL.md + optional support files
├── agents/                 # Agent definitions (code-reviewer.md)
├── commands/               # Slash command definitions
├── hooks/                  # Platform-specific hook configurations
├── tests/                  # Comprehensive test suites
│   ├── brainstorm-server/  # Node.js integration tests
│   ├── claude-code/        # Claude Code skill tests
│   ├── explicit-skill-requests/ # Prompt-based skill trigger tests
│   ├── skill-triggering/   # Skill routing verification tests
│   ├── subagent-driven-dev/ # SDD workflow tests
│   └── opencode/           # OpenCode plugin tests
├── docs/                   # Plans, specs, design docs
├── gemini-extension.json   # Gemini CLI extension manifest
├── package.json            # Root manifest (ESM, version only)
└── GEMINI.md               # Gemini-specific context file
```

## Test Architecture
Tests are organized by concern in `tests/` with independent runners:
- **Integration tests:** Node.js with assert + ws client — tests/brainstorm-server/
- **Skill triggering tests:** Bash scripts running Claude Code with prompts — tests/skill-triggering/
- **Explicit request tests:** Multi-turn conversation tests — tests/explicit-skill-requests/
- **Token analysis:** Python script for usage analysis — tests/claude-code/analyze-token-usage.py
**Source:** tests/ directory structure
