# Features — superpowers

> Analyzed on 2026-04-02

## Feature: Multi-Platform Plugin Distribution

- **Entry point:** Multiple platform manifests
- **Platforms supported:**
  - Claude Code: `.claude-plugin/plugin.json:1`, `.claude-plugin/marketplace.json:1`
  - Cursor: `.cursor-plugin/plugin.json:1`
  - Gemini CLI: `gemini-extension.json:1`, `GEMINI.md:1`
  - OpenCode: `.opencode/plugins/superpowers.js:1`
  - Codex: `.codex/INSTALL.md:1`
- **Key logic:**
  - Each platform has its own manifest format and installation mechanism
  - Claude Code: JSON plugin manifest + marketplace registry — plugin.json:1-20
  - Cursor: JSON plugin with `skills`, `agents`, `commands`, `hooks` paths — .cursor-plugin/plugin.json:21-24
  - Gemini CLI: JSON with `contextFileName` pointing to GEMINI.md — gemini-extension.json:5
  - OpenCode: ESM plugin with `config` hook and system prompt transform — .opencode/plugins/superpowers.js:49-106
  - Codex: Clone + symlink instructions — .codex/INSTALL.md:14-20

## Feature: Session Bootstrap (Skill Auto-Loading)

- **Entry point:** `hooks/session-start:1`
- **Key logic:**
  - Detects plugin root directory — hooks/session-start:8
  - Checks for legacy `~/.config/superpowers/skills/` and warns if found — hooks/session-start:12-14
  - Reads `skills/using-superpowers/SKILL.md` into memory — hooks/session-start:18
  - Escapes content for JSON embedding using bash parameter substitution — hooks/session-start:23-29
  - Wraps in `<EXTREMELY_IMPORTANT>` tags — hooks/session-start:35
  - Platform detection: emits `hookSpecificOutput` for Claude Code, `additional_context` for Cursor/others — hooks/session-start:46-54
  - Uses `printf` instead of heredoc to work around bash 5.3+ bug with large content — hooks/session-start:44-45

## Feature: Skill Routing System

- **Entry point:** `skills/using-superpowers/SKILL.md:1`
- **Key logic:**
  - Establishes instruction priority: user > superpowers > system defaults — SKILL.md:20-26
  - Mandates skill invocation before ANY response: "even a 1% chance" — SKILL.md:10-16
  - Defines skill priority: process skills first, then implementation skills — SKILL.md:97-103
  - Categorizes skills as Rigid (TDD, debugging — follow exactly) or Flexible (patterns — adapt) — SKILL.md:107-109
  - "Red Flags" table lists 12 rationalization thoughts that must trigger skill loading — SKILL.md:80-93
  - Supports Claude Code `Skill` tool and Gemini `activate_skill` tool — SKILL.md:30-33

## Feature: Brainstorming with Visual Companion

- **Entry point:** `skills/brainstorming/SKILL.md:1`
- **Checklist (9 steps):** SKILL.md:22-33
- **Visual companion:**
  - Browser-based companion for mockups, diagrams, visual options — SKILL.md:147
  - Opt-in via dedicated message (not combined with other content) — SKILL.md:153-154
  - Per-question decision: browser for visual content, terminal for text — SKILL.md:156-161
  - Detailed guide: `skills/brainstorming/visual-companion.md` — SKILL.md:164
- **Brainstorm server:** Zero-dependency WebSocket server for live visual updates:
  - Implements RFC 6455 from scratch — scripts/server.cjs:6-9
  - File watching for content updates — referenced by start-server.sh
  - Start/stop scripts: `scripts/start-server.sh`, `scripts/stop-server.sh`
- **Output:** Design spec saved to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` — SKILL.md:29
- **Next step:** Chains ONLY to writing-plans skill — SKILL.md:66

## Feature: Subagent-Driven Development

- **Entry point:** `skills/subagent-driven-development/SKILL.md:1`
- **Key logic:**
  - Fresh subagent per task (isolated context) — SKILL.md:6
  - Two-stage review after each task: spec compliance first, then code quality — SKILL.md:8
  - Four implementer statuses: DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED — SKILL.md:104-118
  - Model selection by task complexity: cheap/standard/capable — SKILL.md:89-101
  - Prompt templates in separate files: `implementer-prompt.md`, `spec-reviewer-prompt.md`, `code-quality-reviewer-prompt.md` — SKILL.md:122-124
- **Integration:** Requires using-git-worktrees, writing-plans, requesting-code-review, finishing-a-development-branch — SKILL.md:268-271

## Feature: Systematic Debugging

- **Entry point:** `skills/systematic-debugging/SKILL.md:1`
- **Four phases:** SKILL.md:46-47
  1. Root Cause Investigation — read errors, reproduce, check changes, gather evidence, trace data flow — SKILL.md:52-119
  2. Pattern Analysis — find working examples, compare, identify differences — SKILL.md:127-143
  3. Hypothesis and Testing — form hypothesis, test minimally, verify — SKILL.md:147-169
  4. Implementation — failing test, single fix, verify — SKILL.md:173-211
- **3-fix escalation rule:** After 3+ failed fixes, question architecture fundamentals — SKILL.md:199-210
- **Supporting techniques:** root-cause-tracing.md, defense-in-depth.md, condition-based-waiting.md — SKILL.md:280-284

## Feature: Test-Driven Development

- **Entry point:** `skills/test-driven-development/SKILL.md:1`
- **Iron law:** "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" — SKILL.md:33
- **RED-GREEN-REFACTOR cycle:** SKILL.md:48-69
- **Good/Bad examples** for each phase — SKILL.md:76-98 (RED), SKILL.md:134-164 (GREEN)
- **Testing anti-patterns reference:** `testing-anti-patterns.md` — SKILL.md:359

## Feature: Git Worktree Management

- **Entry point:** `skills/using-git-worktrees/SKILL.md:1`
- **Key logic:**
  - Directory selection priority: existing dir > CLAUDE.md preference > ask user — SKILL.md:18-48
  - Safety verification: git check-ignore before creating project-local worktree — SKILL.md:53-69
  - Auto-detect and run project setup (npm/cargo/pip/poetry/go) — SKILL.md:103-118
  - Baseline test verification — SKILL.md:123-135

## Feature: Verification Before Completion

- **Entry point:** `skills/verification-before-completion/SKILL.md:1`
- **Gate function (5 steps):** IDENTIFY command, RUN it, READ output, VERIFY it, THEN claim — SKILL.md:28-37
- **Common failures table:** 7 claim types with what's required vs. insufficient — SKILL.md:41-49

## Feature: Development Branch Finishing

- **Entry point:** `skills/finishing-a-development-branch/SKILL.md:1`
- **4 options:** Merge locally, Push & create PR, Keep as-is, Discard — SKILL.md:50-62
- **Typed confirmation** required for discard — SKILL.md:116-124

## Feature: Writing Skills (Meta-Skill)

- **Entry point:** `skills/writing-skills/SKILL.md:1`
- **TDD mapping for documentation:** Test case = pressure scenario with subagent, production code = SKILL.md — SKILL.md:26-39
- **Graphviz conventions:** `skills/writing-skills/graphviz-conventions.dot`
- **Persuasion principles:** `skills/writing-skills/persuasion-principles.md`
- **Testing methodology:** `skills/writing-skills/testing-skills-with-subagents.md`

## Feature: Code Review System

- **Requesting review:** `skills/requesting-code-review/SKILL.md:1`
- **Receiving review:** `skills/receiving-code-review/SKILL.md:1`
- **Agent definition:** `agents/code-reviewer.md:1`

## Feature: Comprehensive Test Suites

- **Brainstorm server tests:** Integration tests with Node.js assert + ws client — tests/brainstorm-server/server.test.js:1
- **Skill triggering tests:** Verify skills activate for correct prompts — tests/skill-triggering/
- **Explicit request tests:** Multi-turn conversation tests — tests/explicit-skill-requests/
- **SDD workflow tests:** End-to-end subagent-driven development — tests/subagent-driven-dev/
- **OpenCode tests:** Plugin loading and tool tests — tests/opencode/
- **Token analysis:** Usage tracking with Python — tests/claude-code/analyze-token-usage.py
