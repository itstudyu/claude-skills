# Features -- claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills

## Feature: Skill Loading System

The core feature of the project. Skills are Markdown files (SKILL.md) that contain natural-language instructions for Claude Code to follow. They are loaded by the Claude Code runtime when a user invokes a slash command or when auto-detection triggers match.

### How Skill Loading Works

1. **Installation** (`install.sh:45-65`):
   - The installer iterates through 5 category directories: `workflow`, `review`, `planning`, `figma`, `utility` (`install.sh:46`)
   - For each subdirectory containing a `SKILL.md` file, it creates a symlink from `~/.claude/skills/<skill-name>` pointing to the skill directory (`install.sh:56-64`)
   - Example: `~/.claude/skills/brainstorm -> /path/to/claude-skills/workflow/brainstorm/`

2. **Runtime Discovery**:
   - Claude Code scans `~/.claude/skills/*/SKILL.md` at startup
   - Each SKILL.md's YAML frontmatter `description` field contains trigger phrases (`workflow/brainstorm/SKILL.md:4-11`)
   - When user input matches a trigger phrase, Claude loads that skill's instructions

3. **Two-Tier Loading** (for plan-orchestrator, `planning/plan-orchestrator/SKILL.md:39-58`):
   - **Tier 1:** `skill-catalog.md` is always available -- lightweight index of all skills with name, path, description, tags (~500 tokens for 30 skills, `planning/plan-orchestrator/SKILL.md:43-58`)
   - **Tier 2:** Full SKILL.md loaded on-demand only when a skill is selected for execution

### Key Logic:
- Symlink creation logic at `install.sh:53-64`: loops through `"$cat_dir"/*/`, checks for SKILL.md existence, removes old symlinks, creates new ones
- Category list is hardcoded at `install.sh:46`: `CATEGORIES="workflow review planning figma utility"`
- Uninstall mode at `install.sh:16-27`: finds symlinks in `$SKILLS_DIR` whose target contains "claude-skills" and removes them

---

## Feature: Hook System

Automated behaviors that run at specific lifecycle points in Claude Code sessions.

### Entry Point: `.claude/settings.json:1-50`

Three hook types are configured:

| Hook Type | Matcher | Script | Purpose |
|-----------|---------|--------|---------|
| SessionStart | `["startup", "compact", "resume"]` | inject-instructions.sh | Reload CLAUDE.md into context (`.claude/settings.json:5-10`) |
| SessionStart | `["startup", "compact", "resume"]` | load-instincts.sh | Load high-confidence learned patterns (`.claude/settings.json:11-15`) |
| PreToolUse | `"Bash"` | secret-scanner.sh | Block commits containing secrets (`.claude/settings.json:19-26`) |
| PostToolUse | `"Bash"` | learn-from-errors.sh | Record Bash errors for pattern learning (`.claude/settings.json:30-37`) |
| PostToolUse | `["Edit", "Write"]` | code-quality-check.sh | Enforce coding standards on edited files (`.claude/settings.json:39-47`) |

### Hook Profile Gate (`run-with-profile.sh:1-58`)

Every hook is wrapped in a profile gate that controls which hooks run based on the `HOOK_PROFILE` environment variable:
- **minimal:** inject-instructions, load-instincts, learn-from-errors (`run-with-profile.sh:10`)
- **standard (default):** minimal + secret-scanner + code-quality-check (`run-with-profile.sh:11, 25`)
- **strict:** standard + future hooks (`run-with-profile.sh:12`)

Individual hooks can be disabled via `DISABLED_HOOKS` env var (`run-with-profile.sh:28-38`).

### Key Logic:
- Profile checking at `run-with-profile.sh:41-55`: parses `ALLOWED_PROFILES` CSV, checks if `CURRENT_PROFILE` is in the list
- Disabled hook checking at `run-with-profile.sh:28-38`: parses `DISABLED_HOOKS` CSV, short-circuits with `exit 0` if match found
- All hooks pass stdin through cleanly when skipped: `cat > /dev/null` then `exit 0` (`run-with-profile.sh:34-35`)

---

## Feature: Secret Scanner

Pre-commit security gate that blocks git operations containing secrets.

- **Entry point:** `.claude/settings.json:22-25` -- PreToolUse hook on Bash
- **Script:** `.claude/hooks/secret-scanner.sh:1-74`
- **Guard:** Only activates on `git commit` or `git add` commands (`secret-scanner.sh:27-29`)
- **Scans:** `git diff --cached` for 11 secret patterns (`secret-scanner.sh:32-33`)
- **Patterns detected** (`secret-scanner.sh:51-62`):
  1. AWS Access Key ID: `AKIA[0-9A-Z]{16}`
  2. AWS Secret Key
  3. JWT Token: `eyJ...` pattern
  4. GitHub PAT: `ghp_...`
  5. GitHub OAuth: `gho_...`
  6. Private Key: `-----BEGIN PRIVATE KEY-----`
  7. Generic API Key
  8. Generic Secret
  9. Database URL (postgres/mysql/mongodb)
  10. Slack Token: `xox[bpas]-...`
  11. Google API Key: `AIza...`
- **Blocking behavior:** Exit code 2 = hard block (`secret-scanner.sh:72`)

---

## Feature: Code Quality Check

Post-edit enforcement of coding standards.

- **Entry point:** `.claude/settings.json:40-46` -- PostToolUse hook on Edit/Write
- **Script:** `.claude/hooks/code-quality-check.sh:1-173`
- **File filter:** Only checks `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.java`, `.go`, `.rb`, `.rs`, `.swift`, `.kt` files (`code-quality-check.sh:33-36`)
- **Exclusions:** Test files, config files, generated files, node_modules (`code-quality-check.sh:39`)
- **4 checks performed:**
  1. **Missing file header** (`code-quality-check.sh:46-61`): First line must be a comment -- references CODING-STANDARDS Rule 1 (`standards/common/CODING-STANDARDS.md:7-9`)
  2. **Function length > 30 lines** (`code-quality-check.sh:64-119`): Python3 inline script parses function definitions per language -- references Rule 2 (`standards/common/CODING-STANDARDS.md:13`)
  3. **Debug output** (`code-quality-check.sh:123-144`): Detects `console.log`, `print()`, `System.out.print`, `fmt.Print` per language
  4. **Excessive TODOs** (`code-quality-check.sh:147-155`): Warns when 5+ TODO/FIXME/HACK tags accumulate
- **Output:** Exit code 2 = feedback to Claude (not a hard block) (`code-quality-check.sh:170`)

---

## Feature: Instincts / Learned Patterns System

Automatic error pattern learning with confidence-based auto-loading.

### Error Recording (`learn-from-errors.sh:1-197`)
- **Trigger:** PostToolUse on Bash with non-zero exit code (`learn-from-errors.sh:29-30`)
- **Storage:** Appends to `docs/mistakes/auto-detected.md` with timestamp, command, and error output (`learn-from-errors.sh:86-98`)
- **Size limit:** 500KB per file (`learn-from-errors.sh:81`)

### Pattern Extraction (`learn-from-errors.sh:100-195`)
- **Trigger:** When 2+ similar errors are detected (matching by command word overlap, `learn-from-errors.sh:136-138`)
- **Output:** Creates `instincts/errors/error-<hash>.md` with YAML frontmatter
- **Confidence formula:** `min(0.9, 0.3 + (occurrences - 1) * 0.2)` (`learn-from-errors.sh:145`)
- **Error signature:** Normalizes command by replacing hashes and paths, then SHA-256 hashes it (`learn-from-errors.sh:117-119`)

### Auto-Loading (`load-instincts.sh:1-88`)
- **Trigger:** SessionStart hook
- **Filter:** Only loads instincts with `confidence >= 0.8` (`load-instincts.sh:48-49`)
- **Sources:** Scans `instincts/errors/`, `instincts/code-patterns/`, `instincts/review-patterns/` (`load-instincts.sh:23`)
- **Limits:** Max 10 instincts, max 2000 characters total output (`load-instincts.sh:68, 77`)

### Manually Authored Instincts
Three files with pre-written patterns (all at `confidence: 0.8`):
- `instincts/errors/common-angular-errors.md:1-22` -- 4 Angular error patterns
- `instincts/errors/common-git-errors.md:1-17` -- 3 Git error patterns
- `instincts/code-patterns/angular-component-patterns.md:1-18` -- Standalone component best practices
- `instincts/review-patterns/common-review-feedback.md:1-23` -- 4 common review findings

---

## Feature: Session Summary

Automatic work logging at session end.

- **Script:** `.claude/hooks/session-summary.sh:1-124`
- **Input:** Receives `transcript_path` from stdin JSON (`session-summary.sh:17-24`)
- **Output:** Appends to `docs/sessions/YYYY-MM-DD-summary.md` (`session-summary.sh:33`)
- **Tracks:** Modified files, tool usage counts, error counts, estimated token usage (`session-summary.sh:49-106`)
- **Token estimation:** ~800 tokens per tool call average (`session-summary.sh:98`)
- **Size limit:** 1MB per daily summary file (`session-summary.sh:35`)

---

## Feature: Skill Catalog Management

Unified registry of all skills from all sources.

- **Skill:** `utility/skill-catalog/SKILL.md:1-50`
- **Output:** `skill-catalog.md` at project root
- **Current catalog:** `skill-catalog.md:1-70` -- lists 38 gstack skills + 28 claude-skills skills
- **Commands:** scan, add, list, remove (`utility/skill-catalog/SKILL.md:28-34`)
- **Scan sources:** `~/.claude/skills/` (global, grouped by symlink target) + project local directories (`utility/skill-catalog/SKILL.md:39-49`)
- **Consumer:** `plan-orchestrator` reads this file as Tier 1 for skill matching (`planning/plan-orchestrator/SKILL.md:41-43`)

---

## Feature: Figma-to-Code Pipeline

Four-phase pipeline converting Figma designs to Angular components.

### Orchestrator: figma-component-writer (`figma/figma-component-writer/SKILL.md:1-60`)
- **Phase 1:** figma-common-crawler -- Crawl Figma URL, extract styles/variants/properties (`SKILL.md:43-45`)
- **Phase 2:** figma-common-diff -- Compare crawled data against angular-web-common registry (`SKILL.md:48-50`)
- **Phase 3:** figma-common-mapper -- Present preview table, get user approval (`SKILL.md:53-56`)
- **Phase 4:** Code generation (after approval) (`SKILL.md:60`)
- **Hard gate:** No code generation without explicit user approval (`SKILL.md:58`)
- **angular-web-common detection:** Checks 3 paths in order: `./`, `../`, `~/Documents/GitHub/` (`SKILL.md:30-34`)

### Page-Level: figma-to-code (`figma/figma-to-code/SKILL.md:1-60`)
- Distinct from figma-component-writer: generates page/screen code, not shared library components (`SKILL.md:10-11`)
- Falls back gracefully if angular-web-common not found: treats all components as CUSTOM_NEEDED (`SKILL.md:37-40`)

---

## Feature: Pipeline Orchestration

Multi-skill chains that execute complete workflows through independent subagents.

### pipeline-build (`workflow/pipeline-build/SKILL.md:1-50`)
6 stages: project-scan -> design-doc -> write-plan -> subagent-dev -> review -> verify-complete
- Each stage runs as independent Agent (fresh context) (`SKILL.md:28-31`)
- State tracked in `.claude/pipeline-state.json` for resume (`workflow/pipeline-build/evals/evals.json:7`)
- Stages can be skipped if user provides pre-existing outputs (`workflow/pipeline-build/evals/evals.json:12-14`)

### pipeline-figma (`workflow/pipeline-figma/SKILL.md:1-49`)
4 stages: figma-to-code -> devops-test-gen -> qa -> design-review
- Same subagent architecture as pipeline-build (`SKILL.md:28-30`)

---

## Feature: Coding Standards Enforcement

Two standards files loaded by hooks and referenced by skills:

### Common Standards (`standards/common/CODING-STANDARDS.md:1-40`)
10 rules: file header, function max 30 lines, single responsibility, commit confirmation, Japanese comments, Japanese commit messages, branch naming, no hardcoded values, import ordering, error handling

### Frontend Standards (`standards/frontend/FRONTEND-STANDARDS.md:1-36`)
Angular-specific: standalone components, OnPush change detection, SCSS, BEM naming, mobile-first, new control flow syntax (@if/@for), signals for state management, colocated tests

---

## Feature: Routing System

CLAUDE.md defines a decision tree that routes user requests to the appropriate skill:

- **Figma component URL + "common/shared"** -> `/figma-component-writer` (`CLAUDE.md:38-39`)
- **Figma URL + "page/screen/implement"** -> `/figma-to-code` (`CLAUDE.md:41-42`)
- **"plan-orchestrator" or "plan this"** -> `/plan-orchestrator` (`CLAUDE.md:44-45`)
- **Vague language ("maybe", "brainstorm")** -> `/brainstorm` -> `/write-plan` -> `/execute-plan` (`CLAUDE.md:47-48`)
- **Debug/error keywords** -> `/investigate` [gstack] (`CLAUDE.md:50-51`)
- **"scan skills"** -> `/skill-catalog` (`CLAUDE.md:53-54`)
- **Other** -> direct `/skill-name` (`CLAUDE.md:56`)
