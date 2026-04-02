# Features — claude-skills

> Analyzed on 2026-04-02

## Feature: Skill Installation & Discovery

- **Entry point:** `install.sh:1` — Bash installer script
- **Key logic:**
  - Checks for gstack prerequisite (install.sh:30-36)
  - Creates `~/.claude/skills/` directory (install.sh:39)
  - Iterates 5 skill categories: workflow, review, planning, figma, utility (install.sh:49)
  - For each skill directory containing `SKILL.md`, creates symlink to `~/.claude/skills/<skill-name>` (install.sh:53-65)
  - Copies hook scripts to `~/.claude/hooks/` with +x permissions (install.sh:70-74)
  - Symlinks `standards/` directory to `~/.claude/standards` (install.sh:77-82)
  - Supports `--uninstall` flag to remove symlinks (install.sh:16-27)
- **Dependencies:** bash, ln, cp, chmod

## Feature: Hook Profile System

- **Entry point:** `.claude/settings.json:1` — Hook configuration
- **Controller:** `.claude/hooks/run-with-profile.sh:1` — Profile gate
- **Key logic:**
  - Reads `HOOK_PROFILE` env var (default: "standard") — run-with-profile.sh:24
  - Reads `DISABLED_HOOKS` env var for per-hook opt-out — run-with-profile.sh:28
  - Checks if current profile is in hook's allowed profiles CSV — run-with-profile.sh:41-52
  - If not allowed, passes stdin through and exits clean (no-op) — run-with-profile.sh:52-54
  - If allowed, `exec`s the actual hook script — run-with-profile.sh:57
- **Three profiles:** minimal (3 hooks), standard (5 hooks), strict (5+ hooks) — run-with-profile.sh:10-12

## Feature: Secret Scanner (PreToolUse)

- **Entry point:** `.claude/settings.json:20-28` — PreToolUse matcher for "Bash"
- **Handler:** `.claude/hooks/secret-scanner.sh:1`
- **Key logic:**
  - Only activates on `git commit` or `git add` commands — secret-scanner.sh:27-29
  - Reads `git diff --cached` for staged content — secret-scanner.sh:32
  - Checks 11 secret patterns: AWS keys, JWT, GitHub PAT/OAuth, private keys, API keys, secrets, DB URLs, Slack tokens, Google API keys — secret-scanner.sh:51-61
  - Returns exit code 2 (hard block) if secrets detected — secret-scanner.sh:68

## Feature: Code Quality Check (PostToolUse)

- **Entry point:** `.claude/settings.json:40-47` — PostToolUse matcher for "Edit/Write"
- **Handler:** `.claude/hooks/code-quality-check.sh:1`
- **Key logic:**
  - Extracts `file_path` from tool_input JSON — code-quality-check.sh:13-24
  - Only checks source code files (ts, tsx, js, jsx, py, java, go, rb, rs, swift, kt) — code-quality-check.sh:33-35
  - Skips test/config/generated files — code-quality-check.sh:39
  - Check 1: File header comment (CODING-STANDARDS Rule 1) — code-quality-check.sh:46-61
  - Check 2: Function length > 30 lines (Rule 2) — code-quality-check.sh:64-119
  - Check 3: Debug output (console.log, print, etc.) — code-quality-check.sh:123-144
  - Check 4: Excessive TODOs (>= 5) — code-quality-check.sh:147-155

## Feature: Error Learning & Instincts System (PostToolUse)

- **Entry point:** `.claude/settings.json:30-37` — PostToolUse matcher for "Bash"
- **Handler:** `.claude/hooks/learn-from-errors.sh:1`
- **Key logic:**
  - Detects non-zero exit codes from Bash tool — learn-from-errors.sh:14-50
  - Appends error entry to `docs/mistakes/auto-detected.md` with timestamp, command, output — learn-from-errors.sh:68-98
  - Auto-extracts instincts: normalizes command, creates signature hash — learn-from-errors.sh:117-119
  - Counts similar errors by keyword overlap — learn-from-errors.sh:130-138
  - Promotes to instinct if 2+ occurrences — learn-from-errors.sh:141
  - Confidence calculation: `min(0.9, 0.3 + (occurrences - 1) * 0.2)` — learn-from-errors.sh:144
  - Creates instinct file in `instincts/errors/` with YAML frontmatter — learn-from-errors.sh:164-192

## Feature: Instincts Loading (SessionStart)

- **Entry point:** `.claude/settings.json:3-17` — SessionStart hook
- **Handler:** `.claude/hooks/load-instincts.sh:1`
- **Key logic:**
  - Scans `instincts/` subdirectories (errors, code-patterns, review-patterns) — load-instincts.sh:23
  - Parses YAML frontmatter for confidence field — load-instincts.sh:39-47
  - Only loads instincts with confidence >= 0.8 — load-instincts.sh:47
  - Extracts id, trigger, and action summary — load-instincts.sh:52-57
  - Limits to 10 instincts, 2000 chars max — load-instincts.sh:70,76

## Feature: Skill Catalog Management

- **Entry point:** `skill-catalog.md:1` — Generated registry
- **Skill handler:** `utility/skill-catalog/SKILL.md:1`
- **Key logic:**
  - Scans all skill sources (gstack, claude-skills, custom packs)
  - Generates unified markdown table with skill name, path, description, tags
  - Used by plan-orchestrator for Tier 1 skill matching — skill-catalog.md:2

## Feature: Brainstorm-to-Implementation Pipeline

- **Entry point:** `workflow/brainstorm/SKILL.md:1`
- **Pipeline chain:**
  1. brainstorm → design exploration with Socratic dialogue — SKILL.md:14-17
  2. write-plan → bite-sized implementation tasks — workflow/write-plan/SKILL.md:17-19
  3. subagent-dev → fresh subagent per task with 2-stage review — workflow/subagent-dev/SKILL.md:15-19
  4. verify-complete → evidence-based verification — workflow/verify-complete/SKILL.md
- **Terminal state enforcement:** brainstorm chains ONLY to write-plan, never directly to implementation — workflow/brainstorm/SKILL.md:77-78

## Feature: Figma-to-Code Pipeline

- **Entry point:** `figma/figma-component-writer/SKILL.md:1`
- **Pipeline chain:**
  1. figma-common-crawler → extract styles from Figma URL via MCP
  2. figma-common-diff → compare against angular-web-common registry
  3. figma-common-mapper → preview mapping for user confirmation
  4. figma-component-writer → generate/update Angular components
- **Alternative:** figma-to-code for page-specific code (not shared components) — figma/figma-to-code/SKILL.md

## Feature: Pipeline Orchestration

- **Entry point:** `workflow/pipeline-build/SKILL.md:1`
- **Key logic:**
  - 6-stage pipeline: project-scan → design-doc → write-plan → subagent-dev → review → verify-complete
  - Each stage runs as independent subagent via Agent tool — pipeline-build/SKILL.md:30
  - Multiple pipeline variants: build, figma, debug, full, idea, onboard, quality, retro, smart — skill-catalog.md:54-63

## Feature: Coding Standards Enforcement

- **Entry point:** `standards/common/CODING-STANDARDS.md:1`
- **10 rules enforced:**
  1. File header — English summary comment (line 8)
  2. Function max 30 lines (line 14)
  3. One file, one responsibility (line 17)
  4. Commit confirmation required (line 20)
  5. Comments in Japanese (line 23)
  6. Commit messages in Japanese (line 26)
  7. Branch naming: `feature/{TaskNumber}/{Name}` (line 29)
  8. No hardcoded values (line 31)
  9. Import ordering (line 34)
  10. Specific error handling (line 40)
