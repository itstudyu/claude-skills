# Code Patterns -- claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills
> Files sampled: 15+ files across hooks, skills, standards, and configuration

## Naming Conventions
| Context | Pattern | Example | Source |
|---------|---------|---------|--------|
| Skill directories | kebab-case | `figma-component-writer/` | figma/ directory listing |
| Skill names (frontmatter) | kebab-case | `name: brainstorm` | workflow/brainstorm/SKILL.md:2 |
| Hook scripts | kebab-case | `learn-from-errors.sh` | .claude/hooks/ directory |
| Category directories | lowercase single word | `workflow/`, `figma/`, `review/` | project root listing |
| Environment variables | UPPER_SNAKE_CASE | `HOOK_PROFILE`, `DISABLED_HOOKS` | .claude/hooks/run-with-profile.sh:7-8 |
| Shell variables | UPPER_SNAKE_CASE | `INSTINCTS_DIR`, `PROJECT_ROOT` | .claude/hooks/load-instincts.sh:7-8 |
| Markdown headers | Title Case or sentence case | `# Brainstorming Ideas Into Designs` | workflow/brainstorm/SKILL.md:14 |

## File Organization

### Skill Directory Structure (Canonical Pattern)
Every skill follows the same two-file structure:
```
<category>/<skill-name>/
  SKILL.md       # Skill definition with YAML frontmatter + instructions
  evals/
    evals.json   # Test cases for the skill
```
- **Evidence:** All 16 skill directories follow this exact pattern. Examples: `workflow/brainstorm/SKILL.md` + `workflow/brainstorm/evals/evals.json`, `figma/figma-to-code/SKILL.md` + `figma/figma-to-code/evals/evals.json`.

### Category Grouping
Skills are organized into 5 top-level categories:
| Category | Count | Purpose | Source |
|----------|-------|---------|--------|
| workflow/ | 8 skills | Development lifecycle (brainstorm, write-plan, tdd, etc.) | install.sh:46 `CATEGORIES="workflow review planning figma utility"` |
| review/ | 2 skills | Code quality automation | install.sh:46 |
| planning/ | 1 skill | Multi-skill orchestration | install.sh:46 |
| figma/ | 5 skills | Figma design-to-code pipeline | install.sh:46 |
| utility/ | 3 skills | Codebase analysis and catalog management | install.sh:46 |

## SKILL.md Authoring Pattern

Every SKILL.md follows a consistent structure:

1. **YAML frontmatter** (lines 1-N): `name`, `description`, optional `allowed-tools`
2. **Title** (H1): Matches skill purpose
3. **HARD-GATE block** (optional): Absolute constraints that must never be violated
4. **When to Use section**: Trigger conditions and decision criteria
5. **Process/Pipeline section**: Step-by-step instructions with numbered phases
6. **Output specification**: What files/artifacts the skill produces

- **HARD-GATE evidence:** `workflow/brainstorm/SKILL.md:20-24` ("Do NOT invoke any implementation skill... until design is approved"), `workflow/tdd/SKILL.md:39-44` ("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST"), `workflow/verify-complete/SKILL.md:22-27` ("NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE")
- **Allowed-tools evidence:** `workflow/pipeline-build/SKILL.md:12-20`, `planning/plan-orchestrator/SKILL.md:12-20`

## Hook Script Pattern

All 8 hook scripts follow a consistent structure:

1. **Shebang + header comment** explaining purpose and matcher
2. **Path resolution** using `SCRIPT_DIR` and `PROJECT_ROOT`
3. **Read JSON from stdin** (for PreToolUse/PostToolUse hooks)
4. **Python3 inline script** for JSON parsing
5. **Guard clause** (early exit if hook doesn't apply)
6. **Core logic** (scan, match, report)
7. **Exit code semantics:** 0 = clean, 1 = error (continue), 2 = block/feedback

- **Evidence:** `.claude/hooks/run-with-profile.sh:14-18` documents exit code semantics. All hooks follow this pattern -- see `secret-scanner.sh:9-24`, `code-quality-check.sh:9-24`, `learn-from-errors.sh:6-10`.

### Hook Profile Gate Pattern
Every hook in settings.json is wrapped with `run-with-profile.sh`:
```bash
bash .claude/hooks/run-with-profile.sh <hook-id> <allowed-profiles> bash .claude/hooks/<actual-script>.sh
```
- **Evidence:** `.claude/settings.json:9` (inject-instructions), `:13` (load-instincts), `:24` (secret-scanner), `:36` (learn-from-errors), `:44` (code-quality-check)
- **Profiles:** minimal (lifecycle only), standard (default, + security + quality), strict (standard + future) -- `.claude/hooks/run-with-profile.sh:10-12`

## Instincts System Pattern

Three-tier confidence-based learning:
1. **Tier 1 (confidence < 0.6):** Error recorded in `docs/mistakes/auto-detected.md` -- `.claude/hooks/learn-from-errors.sh:86-98`
2. **Tier 2 (2+ occurrences, confidence 0.3-0.9):** Auto-extracted to `instincts/errors/<id>.md` -- `.claude/hooks/learn-from-errors.sh:141-194`
3. **Tier 3 (confidence >= 0.8):** Auto-loaded into Claude context at session start -- `.claude/hooks/load-instincts.sh:48-49`

Confidence formula: `min(0.9, 0.3 + (occurrences - 1) * 0.2)` -- `.claude/hooks/learn-from-errors.sh:145`

## Pipeline / Chaining Pattern

Pipelines chain skills by dispatching independent subagents via the `Agent` tool. Each stage runs in isolated context to prevent context window exhaustion.

```
pipeline-build orchestrator
    |-> Agent: skill-1 (fresh context)
    |-> Agent: skill-2 (fresh context, uses skill-1 output)
    |-> Agent: skill-3 (fresh context, uses skill-2 output)
```

- **Evidence:** `workflow/pipeline-build/SKILL.md:28-50` describes the 6-stage subagent architecture. `workflow/pipeline-figma/SKILL.md:28-49` describes the 4-stage Figma pipeline.
- **State tracking:** Pipeline state is persisted to `.claude/pipeline-state.json` for resume capability -- `workflow/pipeline-build/evals/evals.json:7` references this.

## Multi-Language Trigger Pattern

Every skill description includes trigger phrases in 3 languages:
- English: primary triggers
- Japanese: `"ブレスト"`, `"テスト駆動"`, `"プロジェクト分析"`
- Korean: `"브레인스토밍"`, `"TDD로"`, `"프로젝트 분석"`

- **Evidence:** `workflow/brainstorm/SKILL.md:7-9`, `workflow/tdd/SKILL.md:7-8`, `utility/project-scan/SKILL.md:8-11`

## Import/Dependency Pattern

Skills reference other skills by name in natural language instructions, not through code imports. The plan-orchestrator uses `skill-catalog.md` as a lookup table to find available skills.

- **Evidence:** `planning/plan-orchestrator/SKILL.md:41-58` describes the two-tier loading system
- **Tier 1:** `skill-catalog.md` provides the index (~500 tokens for 30 skills)
- **Tier 2:** Full SKILL.md loaded on-demand only for matched skills

## Error Handling

- **Secret scanner:** Exit code 2 blocks the operation, outputs to stderr -- `.claude/hooks/secret-scanner.sh:63-72`
- **Code quality check:** Exit code 2 provides feedback (does not block), outputs to stderr -- `.claude/hooks/code-quality-check.sh:164-171`
- **Learn-from-errors:** Always exits 0, failure is silent -- `.claude/hooks/learn-from-errors.sh:197`
- **Load-instincts:** Always exits 0, no instincts directory is a valid state -- `.claude/hooks/load-instincts.sh:12`

## Behavioral Mode Detection

CLAUDE.md defines 4 auto-detection modes based on user behavior:
| Mode | Detection Signal | Source |
|------|-----------------|--------|
| BRAINSTORM | Vague language ("maybe", "아마", "어떻게") | CLAUDE.md:109 |
| TASK_MANAGE | 3+ files or 2+ directories affected | CLAUDE.md:110 |
| TOKEN_SAVE | Context usage 60%+ | CLAUDE.md:111 |
| INTROSPECT | Same error repeated 2+ times | CLAUDE.md:112 |
