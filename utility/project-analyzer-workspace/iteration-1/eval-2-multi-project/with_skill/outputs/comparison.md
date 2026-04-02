# Cross-Project Comparison

> Analyzed on 2026-04-02
> Projects:
> - **claude-skills** — /Users/yu_s/Documents/GitHub/claude-skills
> - **superpowers** — /Users/yu_s/Documents/GitHub/superpowers

## Stack Comparison
| Aspect | claude-skills | superpowers | Notes |
|--------|--------------|-------------|-------|
| Primary Language | Bash + Python 3 (hooks) | JavaScript (ESM + CJS) + Bash (hooks) | claude-skills has no JS; superpowers has a full server |
| Content Format | Markdown (SKILL.md) | Markdown (SKILL.md) | Identical skill format |
| Package Manager | None | npm (package.json:1) | superpowers uses npm for version/type declaration |
| Version | 1.0.0 (VERSION:1) | 5.0.6 (package.json:2) | superpowers is significantly more mature |
| Production Deps | 0 | 0 (package.json) | Both are zero-dependency |
| Test Deps | 0 | 1 (ws ^8.19.0 — tests/brainstorm-server/package.json:8) | superpowers has WebSocket test client |
| Target Platform | Claude Code only (.claude/settings.json) | 5 platforms: Claude Code, Cursor, Gemini, OpenCode, Codex | superpowers is multi-platform |
| External Deps | gstack (required — CLAUDE.md:7) | None (self-contained) | claude-skills depends on gstack for 38 skills |
| CI/CD | Not detected | GitHub templates (.github/ — 5 files) | superpowers has issue/PR templates |
| Test Framework | JSON eval definitions (*/evals/evals.json) | Bash scripts + Node.js assert (tests/) | Different testing philosophies |
| Linting | Custom code-quality-check.sh (4 checks) | Not detected | claude-skills enforces coding standards via hooks |

## Structural Comparison
| Aspect | claude-skills | superpowers |
|--------|--------------|-------------|
| Architecture | Category-based skill directories + Hook system | Flat skills directory + Platform adapters |
| Skill Discovery | Symlink-based (install.sh + skill-catalog.md) | Plugin marketplace / platform native |
| Total Files | 73 | 138 |
| Directory Depth | 11 levels max | 8 levels max |
| Skill Count | 20+ (skill-catalog.md — 26 skills listed) | 13 (skills/ directory) |
| Skill Categories | 5 (workflow, figma, review, planning, utility) | None (flat under skills/) |
| Hook Count | 8 scripts | 1 script (session-start) |
| Hook Complexity | Profile-based gating with 3 tiers (.claude/hooks/run-with-profile.sh) | Single bootstrap injection (hooks/session-start) |
| Session Bootstrap | inject-instructions.sh + load-instincts.sh | session-start (injects using-superpowers) |
| Distribution | git clone + ./install.sh (CLAUDE.md:7) | Plugin marketplace + manual install for 5 platforms (README.md:28-89) |
| Eval System | Per-skill evals.json (utility/project-analyzer/evals/evals.json) | Bash test scripts + integration tests (tests/) |
| Code Quality Hooks | PostToolUse code-quality-check.sh | Not detected |
| Secret Scanning | PreToolUse secret-scanner.sh (11 patterns) | Not detected |
| Error Learning | PostToolUse learn-from-errors.sh → instincts system | Not detected |
| Documentation Location | docs/specs/ (per coding standards) | docs/superpowers/specs/, docs/superpowers/plans/ |
| Coding Standards | standards/common/CODING-STANDARDS.md (10 rules) | Not detected (no formal standards doc) |

## Shared Patterns

### 1. SKILL.md with YAML Frontmatter
Both projects use identical SKILL.md format with YAML frontmatter containing `name` and `description` fields.
- **claude-skills:** workflow/brainstorm/SKILL.md:1-12
- **superpowers:** skills/brainstorming/SKILL.md:1-3

### 2. `<HARD-GATE>` Enforcement Tags
Both use `<HARD-GATE>` XML tags to enforce mandatory behavior in skill instructions.
- **claude-skills:** workflow/brainstorm/SKILL.md:20-24
- **superpowers:** skills/brainstorming/SKILL.md:12-14

### 3. Graphviz (`dot`) Flow Diagrams
Both embed `dot` language blocks in skill markdown to document process flows.
- **claude-skills:** workflow/tdd/SKILL.md:56-76, workflow/subagent-dev/SKILL.md:49-92
- **superpowers:** skills/test-driven-development/SKILL.md:48-69, skills/subagent-driven-development/SKILL.md:17-33

### 4. Rationalization Prevention Tables
Both include "Excuse | Reality" tables to prevent agents from skipping skill rules.
- **claude-skills:** workflow/tdd/SKILL.md:262-277
- **superpowers:** skills/test-driven-development/SKILL.md:256-270

### 5. RED-GREEN-REFACTOR TDD Cycle
Both enforce identical TDD discipline with the same Iron Law: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST."
- **claude-skills:** workflow/tdd/SKILL.md:39-41
- **superpowers:** skills/test-driven-development/SKILL.md:33-35

### 6. Brainstorm → Plan → Execute Pipeline
Both enforce the same sequential pipeline: brainstorming chains only to write-plan/writing-plans, never directly to implementation.
- **claude-skills:** workflow/brainstorm/SKILL.md:77-78 ("invoke write-plan skill (the ONLY next step)")
- **superpowers:** skills/brainstorming/SKILL.md:66 ("The terminal state is invoking writing-plans")

### 7. Subagent-Driven Development
Both implement fresh-subagent-per-task with two-stage review (spec compliance then code quality).
- **claude-skills:** workflow/subagent-dev/SKILL.md:15-19
- **superpowers:** skills/subagent-driven-development/SKILL.md:6-8

### 8. Verification Before Completion
Both require evidence-based completion claims with actual command output.
- **claude-skills:** workflow/verify-complete/SKILL.md (referenced but shares same concept)
- **superpowers:** skills/verification-before-completion/SKILL.md:22-37

### 9. Bite-Sized Task Granularity (2-5 minutes)
Both enforce the same task size for implementation plans.
- **claude-skills:** workflow/write-plan/SKILL.md:38-47
- **superpowers:** skills/writing-plans/SKILL.md:38-44

### 10. No-Placeholder Rule in Plans
Both prohibit "TBD", "TODO", "implement later" in implementation plans.
- **claude-skills:** workflow/write-plan/SKILL.md:109-120
- **superpowers:** skills/writing-plans/SKILL.md:108-116

## Divergent Patterns

### 1. Platform Scope
- **claude-skills:** Claude Code only — .claude/settings.json defines all hooks
- **superpowers:** 5 platforms with separate adapters — .claude-plugin/plugin.json, .cursor-plugin/plugin.json, gemini-extension.json, .opencode/plugins/superpowers.js, .codex/INSTALL.md

### 2. Skill Organization
- **claude-skills:** 5 categories (workflow/, figma/, review/, planning/, utility/) with subcategories — CLAUDE.md:32-67
- **superpowers:** Flat directory under skills/ — all 13 skills at same level

### 3. Hook Complexity
- **claude-skills:** 8 hook scripts across 3 lifecycle events (SessionStart, PreToolUse, PostToolUse) with profile-based gating — .claude/settings.json:3-49
- **superpowers:** 1 hook script (session-start) for SessionStart only — hooks/hooks.json:3-12

### 4. Self-Learning System
- **claude-skills:** Automated error learning (learn-from-errors.sh) → instincts system with confidence scores and auto-promotion — .claude/hooks/learn-from-errors.sh:100-195
- **superpowers:** No automated learning system detected

### 5. Coding Standards Enforcement
- **claude-skills:** Enforced via PostToolUse hook (code-quality-check.sh) checking file headers, function length, debug output, TODOs — .claude/hooks/code-quality-check.sh:46-156, plus formal CODING-STANDARDS.md with 10 rules
- **superpowers:** No automated code quality enforcement hooks; quality ensured via skill instructions alone

### 6. Secret Scanning
- **claude-skills:** PreToolUse hook scans 11 secret patterns in staged git changes — .claude/hooks/secret-scanner.sh:51-61
- **superpowers:** No secret scanning detected

### 7. External Skill Dependency
- **claude-skills:** Requires gstack for 38 general-purpose skills (browse, review, qa, ship, security) — CLAUDE.md:7, install.sh:30-36
- **superpowers:** Self-contained, no external skill packs required

### 8. Figma Integration
- **claude-skills:** 5 Figma-specific skills forming a complete pipeline (crawl, diff, map, write, to-code) — figma/ directory
- **superpowers:** No Figma integration detected

### 9. Pipeline Skills
- **claude-skills:** 9 pipeline skills that orchestrate multi-skill workflows (pipeline-build, pipeline-figma, pipeline-debug, pipeline-full, etc.) — skill-catalog.md:54-63
- **superpowers:** No explicit pipeline skills; workflow chaining defined within individual skills

### 10. Multilingual Support
- **claude-skills:** Skill trigger phrases in English, Japanese, Korean — workflow/brainstorm/SKILL.md:8-9; Comments/commits required in Japanese — standards/common/CODING-STANDARDS.md:22-27
- **superpowers:** English only in skill descriptions — skills/brainstorming/SKILL.md:2-3

### 11. Distribution Model
- **claude-skills:** Clone + symlink installer (install.sh) — install.sh:56
- **superpowers:** Plugin marketplace (`/plugin install superpowers@claude-plugins-official` — README.md:38), plus manual install for other platforms

### 12. Debugging Skill
- **claude-skills:** No dedicated debugging skill; delegates to gstack's `/investigate` — CLAUDE.md:42
- **superpowers:** Full 4-phase systematic-debugging skill with supporting technique docs — skills/systematic-debugging/SKILL.md

### 13. Skill Meta-Creation
- **claude-skills:** No skill-writing skill detected
- **superpowers:** writing-skills meta-skill applies TDD to documentation creation — skills/writing-skills/SKILL.md:10-11

### 14. Executable Code
- **claude-skills:** No runtime code (only hooks and markdown)
- **superpowers:** Brainstorm WebSocket server (zero-dep, RFC 6455 implementation) — skills/brainstorming/scripts/server.cjs

### 15. Test Infrastructure
- **claude-skills:** Per-skill evals.json with prompt/expected_output pairs — utility/project-analyzer/evals/evals.json
- **superpowers:** 5 distinct test suites: integration tests (Node.js assert + ws), bash script runners, prompt-based tests, SDD workflow tests, OpenCode plugin tests — tests/ directory

## Shared Dependencies
| Package | claude-skills Version | superpowers Version |
|---------|----------------------|---------------------|
| Claude Code (platform) | Required | One of 5 supported platforms |
| Node.js / Bash | Bash + Python 3 | Node.js + Bash |
| git | Used by secret-scanner | Used by using-git-worktrees |

## Data Model Overlap
Both projects use Markdown files as their primary data format with no database:
- **Skill definitions:** Both use `SKILL.md` with YAML frontmatter
- **Design specs:** claude-skills saves to `docs/specs/`, superpowers saves to `docs/superpowers/specs/`
- **Implementation plans:** claude-skills saves to `docs/plans/`, superpowers saves to `docs/superpowers/plans/`

## Summary of Key Differences

| Dimension | claude-skills | superpowers |
|-----------|--------------|-------------|
| **Philosophy** | Infrastructure-heavy: hooks enforce standards, auto-learn, scan secrets | Skill-heavy: skills teach discipline, platform adapts |
| **Scale** | 26 skills (own) + 38 skills (gstack) = 64 total | 13 skills (self-contained) |
| **Maturity** | v1.0.0 | v5.0.6 (much more mature) |
| **Reach** | Claude Code only | 5 platforms |
| **Unique Strength** | Hook automation (profiles, learning, quality gates, secret scanning) | Cross-platform distribution + zero-dep runtime code |
| **Domain Focus** | Angular/Figma workflow + Japanese dev team standards | General-purpose software development workflow |
