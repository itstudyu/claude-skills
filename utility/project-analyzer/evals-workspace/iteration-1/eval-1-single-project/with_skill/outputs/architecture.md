# Architecture Design Doc -- claude-skills

> Analyzed on 2026-04-02
> This document summarizes the detailed analysis in sibling files.

## System Overview

**What it is:** A skill pack for Claude Code that provides 19 project-specific skills (Figma automation, development workflow, code review) plus a hook system for automated quality enforcement, secret scanning, error learning, and session logging. Skills are Markdown instruction files that Claude Code loads and follows -- there is no compiled code.

**Stack:** Bash + Python3 (inline) + Markdown SKILL.md definitions + Claude Code hook engine

**Source:** /Users/yu_s/Documents/GitHub/claude-skills

## Architecture Layers

```
┌──────────────────────────────────────────────────────────────┐
│              CLAUDE.md Routing Layer                         │  CLAUDE.md
│  (routes user requests to skills via keyword matching)       │
├──────────────────────────────────────────────────────────────┤
│           Skill Catalog (skill-catalog.md)                   │  skill-catalog.md
│  (unified index of all skills from all sources)              │
├────────────────┬─────────────────────────────────────────────┤
│  Pipeline      │  Individual Skills (SKILL.md files)         │
│  Orchestrators │  - workflow/ (8 skills)                     │  workflow/*/SKILL.md
│  (chain skills │  - review/ (2 skills)                       │  review/*/SKILL.md
│   via Agent)   │  - planning/ (1 skill)                      │  planning/*/SKILL.md
│                │  - figma/ (5 skills)                         │  figma/*/SKILL.md
│                │  - utility/ (3 skills)                       │  utility/*/SKILL.md
├────────────────┴─────────────────────────────────────────────┤
│              Hook System (.claude/settings.json)             │  .claude/settings.json
│  SessionStart: inject-instructions, load-instincts           │  .claude/hooks/
│  PreToolUse:   secret-scanner                                │
│  PostToolUse:  learn-from-errors, code-quality-check         │
├──────────────────────────────────────────────────────────────┤
│              Hook Profile Gate (run-with-profile.sh)          │  .claude/hooks/run-with-profile.sh
│  Controls which hooks run: minimal | standard | strict        │
├──────────────────────────────────────────────────────────────┤
│              Instincts System (instincts/)                    │  instincts/
│  Auto-learned error patterns with confidence scoring          │
├──────────────────────────────────────────────────────────────┤
│              Coding Standards (standards/)                     │  standards/
│  common/CODING-STANDARDS.md + frontend/FRONTEND-STANDARDS.md  │
├──────────────────────────────────────────────────────────────┤
│              Installation (install.sh)                         │  install.sh
│  Symlinks skill dirs to ~/.claude/skills/                     │
└──────────────────────────────────────────────────────────────┘
```

## Key Features Summary
| Feature | Entry Point | Core Logic | Data |
|---------|-------------|------------|------|
| Skill Loading | install.sh:45-65 | Symlink creation from category dirs to ~/.claude/skills/ | SKILL.md frontmatter |
| Hook System | .claude/settings.json:1-50 | 5 hooks across 3 lifecycle events | Hook scripts in .claude/hooks/ |
| Hook Profiles | .claude/hooks/run-with-profile.sh:1-58 | Profile gating via HOOK_PROFILE env var | 3 profiles: minimal, standard, strict |
| Secret Scanner | .claude/hooks/secret-scanner.sh:1-74 | 11 regex patterns on git diff --cached | Exit code 2 blocks commit |
| Code Quality | .claude/hooks/code-quality-check.sh:1-173 | 4 checks per file edit | Exit code 2 provides feedback |
| Error Learning | .claude/hooks/learn-from-errors.sh:1-197 | Error recording + pattern extraction at 2+ occurrences | docs/mistakes/, instincts/errors/ |
| Instinct Loading | .claude/hooks/load-instincts.sh:1-88 | Filters by confidence >= 0.8, injects into session | instincts/ (3 subdirs) |
| Session Summary | .claude/hooks/session-summary.sh:1-124 | Parses transcript, logs tool usage + files modified | docs/sessions/ |
| Skill Catalog | utility/skill-catalog/SKILL.md | Scans all sources, generates unified index | skill-catalog.md |
| Figma Pipeline | figma/figma-component-writer/SKILL.md:42-60 | 4-phase: crawl -> diff -> preview -> generate | angular-web-common/registry.json |
| Build Pipeline | workflow/pipeline-build/SKILL.md:28-50 | 6-stage subagent chain | .claude/pipeline-state.json |
| Routing | CLAUDE.md:35-56 | Decision tree matching keywords to skills | N/A |

-> Details: [features.md](features.md)

## Data Flow

### Data Flow 1: Skill Installation and Loading

```
1. User runs `./install.sh`
2. install.sh:49-65 iterates CATEGORIES="workflow review planning figma utility"
3. For each category/skill-name/ with a SKILL.md:
   - Creates symlink: ~/.claude/skills/<skill-name> -> <category>/<skill-name>/
4. install.sh:70-74 copies .claude/hooks/*.sh to ~/.claude/hooks/
5. install.sh:77-82 symlinks standards/ to ~/.claude/standards/
6. On next Claude Code session start:
   - Claude Code discovers SKILL.md files via ~/.claude/skills/*/SKILL.md
   - Reads YAML frontmatter for trigger phrase matching
   - User says "brainstorm" -> matches workflow/brainstorm/SKILL.md:4-11 -> loads skill
```

### Data Flow 2: Error Learning Lifecycle

```
1. User runs a Bash command that fails (exit code != 0)
2. PostToolUse hook fires -> settings.json:30-37
3. run-with-profile.sh:41-55 checks HOOK_PROFILE includes "minimal" -> allowed
4. learn-from-errors.sh:13-50 parses JSON stdin, extracts command + output
5. Appends error to docs/mistakes/auto-detected.md (learn-from-errors.sh:86-98)
6. Python3 inline script (learn-from-errors.sh:104-195):
   a. Normalizes command -> creates signature hash
   b. Counts similar errors in auto-detected.md by word overlap
   c. If 2+ occurrences: creates/updates instincts/errors/error-<hash>.md
   d. Confidence = min(0.9, 0.3 + (occurrences - 1) * 0.2)
7. On next session start:
   - load-instincts.sh:16-81 reads instincts/ files
   - Filters confidence >= 0.8
   - Outputs max 10 instincts, max 2000 chars -> injected into Claude context
```

### Data Flow 3: Pipeline-Build Feature Implementation

```
1. User says "build feature: add user auth"
2. CLAUDE.md routing does not match any specific route -> direct skill
3. pipeline-build/SKILL.md loaded
4. Stage 1: Agent dispatches project-scan subagent (fresh context)
   -> Reads codebase -> outputs docs/project-overview.md
5. Stage 2: Agent dispatches design-doc subagent
   -> Reads overview + code -> outputs docs/specs/<feature>.md
6. Stage 3: Agent dispatches write-plan subagent
   -> Reads spec -> outputs docs/plans/<feature>-plan.md
7. Stage 4: Agent dispatches subagent-dev
   -> Dispatches sub-subagents per task + two-stage review
8. Stage 5: Agent dispatches review [gstack]
   -> Analyzes diff for issues
9. Stage 6: Agent dispatches verify-complete
   -> Runs verification commands, confirms output
```

## Data Model Overview
| Data Structure | Location | Key Fields | Relationships |
|---------------|----------|------------|---------------|
| settings.json | .claude/settings.json | hooks (SessionStart, PreToolUse, PostToolUse) | -> hook scripts |
| SKILL.md frontmatter | */*/SKILL.md | name, description, allowed-tools | <- skill-catalog.md |
| evals.json | */*/evals/evals.json | skill_name, evals[].prompt, expected_output | references SKILL.md |
| Instinct files | instincts/**/*.md | confidence, trigger, occurrences | <- learn-from-errors.sh |
| skill-catalog.md | skill-catalog.md | Skill, Path, Description, Tags | -> plan-orchestrator |
| auto-detected.md | docs/mistakes/ | Command, Error, timestamp | -> instincts/ (at 2+) |

-> Details: [data-model.md](data-model.md)

## Technical Decisions

- **Single repo (not monorepo):** All skills live in one flat repository organized by category directories. Evidence: no workspace config, no package.json, no lerna/nx/turborepo config.
- **No compiled code:** Entire project is Markdown instruction files + Bash scripts. No build step required. Evidence: no build tools, no tsconfig, no Makefile (except pre-commit-validate.sh references `make validate` for downstream projects at `.claude/hooks/pre-commit-validate.sh:8`).
- **Symlink-based installation:** Skills are installed by symlinking directories, not copying files. This means updates to the source repo are immediately reflected. Evidence: `install.sh:58-64` uses `ln -s`.
- **Hook profile system:** Hooks are gated by environment variable (`HOOK_PROFILE`) rather than config file, allowing per-terminal customization. Evidence: `.claude/hooks/run-with-profile.sh:25`.
- **Confidence-based instincts:** Error patterns are auto-promoted to "instincts" only after 2+ occurrences, with confidence scaling. This prevents one-off errors from polluting session context. Evidence: `learn-from-errors.sh:141-145`.
- **Subagent isolation for pipelines:** Each pipeline stage runs in a fresh Agent context rather than sequentially in one session. This prevents context window exhaustion on long workflows. Evidence: `workflow/pipeline-build/SKILL.md:28-31`.
- **gstack as external dependency:** General-purpose skills (browser, QA, review, ship) are delegated to the separate gstack pack rather than reimplemented. Evidence: `CLAUDE.md:7`, `README.md:3-6`.
- **Multi-language support:** All skill trigger phrases include English, Japanese, and Korean variants. Evidence: every SKILL.md description field.
- **Japanese comments convention:** Team convention requires all code comments and log messages in Japanese. Evidence: `standards/common/CODING-STANDARDS.md:23-24`, `review/devops-japanese-comments/SKILL.md:17-18`.

-> Stack details: [tech-stack.md](tech-stack.md)
-> Patterns: [code-patterns.md](code-patterns.md)
-> Dependencies: [dependencies.md](dependencies.md)

## File Map

```
claude-skills/                     # Root — skill pack for Claude Code
├── CLAUDE.md                      # Project instructions + routing table (loaded at session start)
├── README.md                      # Installation guide + skill index
├── VERSION                        # Semantic version (1.0.0)
├── CHANGELOG.md                   # Release history (tracks gstack upstream)
├── LICENSE                        # MIT License (Copyright 2026 Garry Tan)
├── install.sh                     # Installer — symlinks skills + copies hooks
├── setup                          # gstack setup script (referenced, not used directly)
├── skill-catalog.md               # Unified skill registry (generated by /skill-catalog scan)
├── .env.example                   # ANTHROPIC_API_KEY for LLM-as-judge evals
├── .gitignore                     # Excludes node_modules, .env, dist, bun.lock
│
├── .claude/
│   ├── settings.json              # Hook configuration (5 hooks across 3 lifecycle events)
│   └── hooks/
│       ├── run-with-profile.sh    # Profile gate — minimal|standard|strict
│       ├── inject-instructions.sh # SessionStart — reloads CLAUDE.md into context
│       ├── load-instincts.sh      # SessionStart — loads confidence>=0.8 patterns
│       ├── secret-scanner.sh      # PreToolUse — 11 secret patterns on git ops
│       ├── learn-from-errors.sh   # PostToolUse — error recording + instinct extraction
│       ├── code-quality-check.sh  # PostToolUse — 4 quality checks on edited files
│       ├── pre-commit-validate.sh # Git pre-commit hook (runs make validate)
│       └── session-summary.sh     # Stop hook — logs daily work summary
│
├── workflow/                      # Development lifecycle skills
│   ├── brainstorm/                # Socratic design exploration before implementation
│   ├── write-plan/                # Bite-sized task planning (2-5 min steps)
│   ├── design-doc/                # Per-feature design document generation
│   ├── subagent-dev/              # Fresh subagent per task + two-stage review
│   ├── tdd/                       # Test-driven development enforcement
│   ├── verify-complete/           # Evidence-based completion verification
│   ├── pipeline-build/            # 6-stage build pipeline (scan->design->plan->build->review->verify)
│   └── pipeline-figma/            # 4-stage Figma pipeline (figma->tests->qa->design-review)
│
├── review/                        # Code quality automation
│   ├── devops-japanese-comments/  # Japanese comment enforcement
│   └── devops-test-gen/           # Auto-generate unit/regression tests
│
├── planning/                      # Orchestration
│   └── plan-orchestrator/         # Scan skills + build multi-skill execution plan
│
├── figma/                         # Figma design automation
│   ├── figma-component-writer/    # Orchestrator: Figma -> angular-web-common
│   ├── figma-to-code/             # Figma URL -> Angular page code
│   ├── figma-common-crawler/      # Phase 1: Extract Figma styles/variants
│   ├── figma-common-diff/         # Phase 2: Compare crawled vs existing
│   └── figma-common-mapper/       # Phase 3: Preview + user approval
│
├── utility/                       # Analysis and catalog management
│   ├── project-scan/              # Codebase scan -> project-overview.md
│   ├── project-analyzer/          # Deep multi-axis analysis (this skill)
│   └── skill-catalog/             # Unified skill registry manager
│
├── standards/                     # Coding standards (loaded by hooks + referenced by skills)
│   ├── common/
│   │   └── CODING-STANDARDS.md    # 10 rules (file header, 30-line max, Japanese comments, etc.)
│   └── frontend/
│       └── FRONTEND-STANDARDS.md  # Angular conventions (standalone, OnPush, SCSS, BEM)
│
├── instincts/                     # Learned patterns (auto-generated + manually authored)
│   ├── errors/
│   │   ├── common-angular-errors.md  # 4 Angular error patterns (confidence: 0.8)
│   │   └── common-git-errors.md      # 3 Git error patterns (confidence: 0.8)
│   ├── code-patterns/
│   │   └── angular-component-patterns.md  # Standalone + OnPush best practices
│   └── review-patterns/
│       └── common-review-feedback.md      # Unused imports, hardcoded values, etc.
│
└── docs/
    ├── skills.md                  # Deep dive guides for gstack skills
    └── images/                    # Documentation images
        ├── github-2013.png
        └── github-2026.png
```
