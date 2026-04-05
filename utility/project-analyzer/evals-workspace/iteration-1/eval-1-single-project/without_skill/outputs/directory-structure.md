# Directory Structure Analysis

> Analysis of claude-skills project at /Users/yu_s/Documents/GitHub/claude-skills

## Top-Level Structure

```
claude-skills/
├── .claude/              # Claude Code configuration (hooks + settings)
│   ├── hooks/            # 8 shell scripts for lifecycle automation
│   └── settings.json     # Hook registration (SessionStart, PreToolUse, PostToolUse)
├── docs/                 # Documentation and auto-generated records
│   ├── images/           # Documentation images
│   ├── mistakes/         # Auto-recorded errors (by learn-from-errors.sh)
│   └── skills.md         # Detailed skill documentation
├── figma/                # Figma automation skills (5 skills)
│   ├── figma-common-crawler/   # Phase 1: Crawl Figma URL for component data
│   ├── figma-common-diff/      # Phase 2: Diff crawled vs existing components
│   ├── figma-common-mapper/    # Phase 3: Preview mapping for user approval
│   ├── figma-component-writer/ # Orchestrator: Full Figma-to-component pipeline
│   └── figma-to-code/          # Figma URL to Angular page code
├── instincts/            # Learned patterns (auto-extracted from errors)
│   ├── code-patterns/    # Angular component patterns (1 file)
│   ├── errors/           # Recurring error patterns (2 files)
│   └── review-patterns/  # Code review feedback patterns (1 file)
├── planning/             # Planning and orchestration skills (1 skill)
│   └── plan-orchestrator/  # Auto-scan skills, build execution plans
├── review/               # Code review and quality skills (2 skills)
│   ├── devops-japanese-comments/  # Enforce Japanese comments
│   └── devops-test-gen/           # Auto-generate tests
├── standards/            # Coding standards (enforced by hooks)
│   ├── backend/          # Backend standards (empty)
│   ├── common/           # CODING-STANDARDS.md (10 rules)
│   ├── frontend/         # FRONTEND-STANDARDS.md
│   └── lang/             # Language-specific standards (empty)
├── utility/              # Utility skills (3 skills)
│   ├── project-analyzer/       # This evaluation workspace
│   ├── project-scan/           # Scan codebase for structure overview
│   └── skill-catalog/          # Scan and manage skill registry
├── workflow/             # Development workflow skills (9 skills)
│   ├── brainstorm/       # Socratic design exploration
│   ├── design-doc/       # Per-feature design documents
│   ├── pipeline-build/   # Full feature pipeline (6 stages)
│   ├── pipeline-figma/   # Figma-to-production pipeline (4 stages)
│   ├── subagent-dev/     # Fresh subagent per task execution
│   ├── tdd/              # Test-driven development enforcement
│   ├── verify-complete/  # Evidence-based verification gate
│   └── write-plan/       # Implementation plan generation
├── CLAUDE.md             # Project instructions (routing, modes, hooks)
├── README.md             # Project readme
├── install.sh            # Installer (symlinks + hooks)
├── setup                 # gstack setup script (reference copy)
├── skill-catalog.md      # Generated skill registry (all sources)
└── VERSION               # Version file
```

## Directory Purposes

### figma/ -- Figma Automation (5 skills)

These skills form a **pipeline** for converting Figma designs into Angular code.
Three of them (crawler, diff, mapper) are internal pipeline stages not meant to be
invoked directly. Two are user-facing orchestrators:

- `figma-component-writer` -- For updating the shared component library (angular-web-common)
- `figma-to-code` -- For generating page/screen-specific Angular code

### workflow/ -- Development Workflow (9 skills)

The core development lifecycle skills, from ideation to verification:

- **Ideation:** brainstorm, design-doc
- **Planning:** write-plan
- **Execution:** subagent-dev
- **Quality:** tdd, verify-complete
- **Pipelines:** pipeline-build, pipeline-figma (orchestrate multiple skills)

### review/ -- Code Review (2 skills)

Post-implementation quality enforcement:
- Japanese comment enforcement (team convention)
- Automatic test generation for changed code

### planning/ -- Orchestration (1 skill)

`plan-orchestrator` is the meta-skill that reads the skill catalog and assembles
multi-skill execution plans. It is the only skill that uses the two-tier loading system.

### utility/ -- Utilities (3 skills)

Infrastructure skills that support other skills:
- `project-scan` -- Generates project-overview.md for codebase understanding
- `skill-catalog` -- Generates skill-catalog.md for skill discovery

### instincts/ -- Learned Patterns

NOT skills. These are auto-generated knowledge files created by the `learn-from-errors.sh`
hook. They accumulate over time as the system encounters recurring errors.

Organized by type: `errors/`, `code-patterns/`, `review-patterns/`.
Each file has YAML frontmatter with a `confidence` score (0.0-1.0).
Only patterns with confidence >= 0.8 are auto-loaded at session start.

### standards/ -- Coding Standards

NOT skills. Reference documents that skills and hooks consult:
- `common/CODING-STANDARDS.md` -- 10 rules applicable to all code
- `frontend/FRONTEND-STANDARDS.md` -- Angular/frontend-specific rules

The `code-quality-check.sh` hook enforces a subset of these rules automatically.

### .claude/ -- Hook System

Configuration for Claude Code's hook lifecycle:
- `settings.json` -- Declares which hooks run at which lifecycle events
- `hooks/` -- Shell scripts that execute at SessionStart, PreToolUse, PostToolUse
