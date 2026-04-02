# Data Model — superpowers

> Analyzed on 2026-04-02

No database schema detected in source files. This project is a collection of Markdown skill definitions, JavaScript server code, and Bash hook scripts.

## File-Based Data Structures

### Brainstorm Server State
- **Source:** `skills/brainstorming/scripts/server.cjs`
- **Runtime state (in-memory):**
  | Variable | Type | Purpose |
  |----------|------|---------|
  | clients | Set | Connected WebSocket clients — server.cjs:6 (implied by broadcast pattern) |
  | contentDir | string | Directory where brainstorm content HTML is read from |
  | stateDir | string | Directory for server state persistence |
- **Wire protocol:** WebSocket frames per RFC 6455 — server.cjs:6-9
- **Frame encoding:** Custom implementation using opcodes TEXT (0x01), CLOSE (0x08), PING (0x09), PONG (0x0A) — server.cjs:8

### Spec Documents (output artifacts)
- **Location:** `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
- **Created by:** brainstorming skill — skills/brainstorming/SKILL.md:29
- **Example files present:**
  - `docs/superpowers/specs/2026-01-22-document-review-system-design.md`
  - `docs/superpowers/specs/2026-02-19-visual-brainstorming-refactor-design.md`
  - `docs/superpowers/specs/2026-03-11-zero-dep-brainstorm-server-design.md`
  - `docs/superpowers/specs/2026-03-23-codex-app-compatibility-design.md`

### Plan Documents (output artifacts)
- **Location:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- **Created by:** writing-plans skill — skills/writing-plans/SKILL.md:18
- **Example files present:**
  - `docs/superpowers/plans/2026-01-22-document-review-system.md`
  - `docs/superpowers/plans/2026-02-19-visual-brainstorming-refactor.md`
  - `docs/superpowers/plans/2026-03-11-zero-dep-brainstorm-server.md`
  - `docs/superpowers/plans/2026-03-23-codex-app-compatibility.md`

### Plugin Manifest
- **Source:** `.claude-plugin/plugin.json:1-20`
- **Schema:**
  | Field | Type | Value |
  |-------|------|-------|
  | name | string | "superpowers" |
  | description | string | "Core skills library..." |
  | version | string | "5.0.6" |
  | author | object | {name, email} |
  | keywords | string[] | ["skills", "tdd", ...] |

### Test Prompt Fixtures
- **Source:** `tests/explicit-skill-requests/prompts/*.txt`, `tests/skill-triggering/prompts/*.txt`
- **Structure:** Plain text files containing single prompts for test runners
