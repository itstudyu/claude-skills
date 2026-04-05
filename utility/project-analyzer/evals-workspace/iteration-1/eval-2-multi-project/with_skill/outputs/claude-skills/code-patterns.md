# Code Patterns — claude-skills

> Analyzed on 2026-04-02

## Naming Conventions
| Context | Pattern | Example | Source |
|---------|---------|---------|--------|
| Skill directories | kebab-case | `figma-component-writer` | figma/figma-component-writer/ |
| Skill names (YAML) | kebab-case | `name: brainstorm` | workflow/brainstorm/SKILL.md:2 |
| Hook scripts | kebab-case | `code-quality-check.sh` | .claude/hooks/ |
| Skill categories | lowercase single word | `workflow`, `figma`, `review`, `planning`, `utility` | CLAUDE.md:32-67 |
| Pipeline skills | `pipeline-` prefix | `pipeline-build`, `pipeline-figma`, `pipeline-debug` | skill-catalog.md:54-62 |
| Instinct files | kebab-case | `common-angular-errors.md` | instincts/errors/ |

## Skill File Structure
Every skill follows a consistent structure — each skill resides in `<category>/<skill-name>/` containing:
- `SKILL.md` — Skill definition with YAML frontmatter (required)
- `evals/evals.json` — Evaluation test cases (required)

**Source:** All skill directories follow this pattern (e.g., `workflow/brainstorm/SKILL.md`, `workflow/brainstorm/evals/evals.json`)

## SKILL.md Frontmatter Pattern
```yaml
---
name: skill-name
description: |
  Multi-line description with trigger phrases in multiple languages
  (English, Japanese, Korean). Includes proactive suggestion guidance.
allowed-tools:    # optional — only in pipeline/orchestrator skills
  - Bash
  - Read
  ...
---
```
**Source:** workflow/brainstorm/SKILL.md:1-12, planning/plan-orchestrator/SKILL.md:1-21

## Skill Content Patterns

### Hard Gate Pattern
Skills use `<HARD-GATE>` tags to enforce mandatory behavior:
```markdown
<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project...
</HARD-GATE>
```
**Source:** workflow/brainstorm/SKILL.md:20-24

### Graphviz Flow Diagrams
Process flows are documented using `dot` language blocks within Markdown:
```dot
digraph brainstorming {
    "Explore project context" [shape=box];
    ...
}
```
**Source:** workflow/brainstorm/SKILL.md:47-74, workflow/tdd/SKILL.md:56-76, workflow/subagent-dev/SKILL.md:49-92

### Rationalization Prevention Tables
Skills include tables of "excuses vs reality" to prevent agents from circumventing skill rules:
```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
```
**Source:** workflow/tdd/SKILL.md:262-277, workflow/subagent-dev/SKILL.md:237-249

### Red Flags / Stop Signals
Skills list observable thoughts/behaviors that mean the agent should stop and re-engage with the process:
**Source:** workflow/tdd/SKILL.md:279-295

## Hook Architecture

### Profile-Based Gating
All hooks route through `run-with-profile.sh` which checks `HOOK_PROFILE` env var:
- `minimal` — inject-instructions, load-instincts, learn-from-errors
- `standard` — minimal + secret-scanner, code-quality-check
- `strict` — standard + future hooks
**Source:** .claude/hooks/run-with-profile.sh:7-8, .claude/settings.json:9

### Hook Lifecycle
| Event | Hook | Profiles | Purpose |
|-------|------|----------|---------|
| SessionStart | inject-instructions.sh | minimal,standard,strict | Reload CLAUDE.md into context |
| SessionStart | load-instincts.sh | minimal,standard,strict | Load high-confidence instincts |
| PreToolUse:Bash | secret-scanner.sh | standard,strict | Block commits with secrets |
| PostToolUse:Bash | learn-from-errors.sh | minimal,standard,strict | Auto-record errors + promote to instincts |
| PostToolUse:Edit/Write | code-quality-check.sh | standard,strict | Enforce coding standards |
**Source:** .claude/settings.json:3-49

## Import Patterns
Not applicable — project is Markdown + Bash, no module imports.

## Error Handling
Hook scripts use `set -e` (fail fast) and return specific exit codes:
- `0` — clean/no issues
- `1` — error (graceful continue)
- `2` — block/feedback (PreToolUse: hard block; PostToolUse: feedback to Claude)
**Source:** .claude/hooks/run-with-profile.sh:16-18

## File Organization
```
claude-skills/
├── .claude/hooks/          # 8 bash hook scripts
├── .claude/settings.json   # Hook wiring configuration
├── workflow/               # Core dev workflow skills (9 skills)
├── figma/                  # Figma automation pipeline (5 skills)
├── review/                 # Code quality review skills (2 skills)
├── planning/               # Orchestration skills (1 skill)
├── utility/                # Meta/analysis skills (3 skills)
├── instincts/              # Learned error/code/review patterns
├── standards/              # Coding standards docs
├── docs/                   # Documentation and images
├── skill-catalog.md        # Unified skill registry
├── CLAUDE.md               # Project instructions with routing table
├── install.sh              # Symlink-based installer
└── VERSION                 # Semver version file
```

## Multilingual Design
Skill descriptions include trigger phrases in English, Japanese, and Korean:
```yaml
description: |
  Use this skill whenever the user says "brainstorm", "ブレスト", "브레인스토밍"...
```
**Source:** workflow/brainstorm/SKILL.md:8-9

Coding standards require Japanese comments and commit messages:
**Source:** standards/common/CODING-STANDARDS.md:22-27
