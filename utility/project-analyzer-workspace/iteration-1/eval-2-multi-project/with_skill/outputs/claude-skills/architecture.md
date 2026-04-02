# Architecture Design Doc — claude-skills

> Analyzed on 2026-04-02
> This document summarizes the detailed analysis in sibling files.

## System Overview

**What it is:** A project-specific skill and hook collection for Claude Code that provides workflow automation, Figma-to-code pipelines, code quality enforcement, and a self-learning error pattern system. Designed to be installed alongside gstack (general-purpose skills) via symlinks.

**Stack:** Bash + Python 3 (hooks) + Markdown (skills) + JSON (config)

**Source:** /Users/yu_s/Documents/GitHub/claude-skills

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│         CLAUDE.md (Routing Table)            │  CLAUDE.md
├─────────────────────────────────────────────┤
│     Skill Catalog (Discovery Registry)       │  skill-catalog.md
├─────────────────────────────────────────────┤
│     Skills (5 categories, 20+ skills)        │  workflow/, figma/, review/,
│     ├── Pipelines (orchestrate multi-skill)  │  planning/, utility/
│     ├── Workflow (brainstorm, plan, execute)  │
│     ├── Figma (crawl, diff, map, write)      │
│     └── Review/Utility (quality, catalog)    │
├─────────────────────────────────────────────┤
│     Hooks (Profile-gated lifecycle)          │  .claude/hooks/*.sh
│     ├── SessionStart (inject, load instincts)│
│     ├── PreToolUse (secret scanner)          │
│     └── PostToolUse (quality, error learn)   │
├─────────────────────────────────────────────┤
│     Standards & Instincts                    │  standards/, instincts/
│     ├── Coding Standards (10 rules)          │
│     └── Learned Patterns (auto-extracted)    │
├─────────────────────────────────────────────┤
│     Claude Code Platform                     │  .claude/settings.json
└─────────────────────────────────────────────┘
```

## Key Features Summary
| Feature | Entry Point | Core Logic | Data |
|---------|-------------|------------|------|
| Installation | install.sh:1 | Symlink skills + copy hooks | ~/.claude/skills/ |
| Hook Profiles | run-with-profile.sh:1 | 3-tier profile gating | HOOK_PROFILE env var |
| Secret Scanner | secret-scanner.sh:1 | 11 regex patterns on staged diff | git diff --cached |
| Code Quality | code-quality-check.sh:1 | 4 checks (header, length, debug, TODOs) | CODING-STANDARDS.md |
| Error Learning | learn-from-errors.sh:1 | Auto-record + promote to instincts | docs/mistakes/, instincts/ |
| Brainstorm Pipeline | brainstorm/SKILL.md:1 | brainstorm → write-plan → subagent-dev | docs/specs/ |
| Figma Pipeline | figma-component-writer/SKILL.md:1 | crawl → diff → map → write | angular-web-common |
| Plan Orchestrator | plan-orchestrator/SKILL.md:1 | Scan skills, match, build plan | skill-catalog.md |

--> Details: [features.md](features.md)

## Data Flow

**Example: Error Learning Lifecycle**
1. User runs a Bash command that fails (exit code != 0)
2. PostToolUse hook triggers `learn-from-errors.sh` — .claude/settings.json:30-37
3. Extracts command and error output from tool JSON — learn-from-errors.sh:13-50
4. Appends entry to `docs/mistakes/auto-detected.md` — learn-from-errors.sh:86-98
5. Normalizes command, creates signature hash — learn-from-errors.sh:117-119
6. Counts similar errors by keyword overlap — learn-from-errors.sh:130-138
7. If 2+ occurrences: creates instinct in `instincts/errors/` with confidence 0.6 — learn-from-errors.sh:141-192
8. Next session: `load-instincts.sh` loads instincts with confidence >= 0.8 — load-instincts.sh:47

**Example: Brainstorm to Implementation**
1. User triggers brainstorm skill — workflow/brainstorm/SKILL.md
2. Socratic dialogue: explore context, clarify, propose 2-3 approaches — SKILL.md:82-99
3. Present design in sections, get approval per section — SKILL.md:96-98
4. Write design doc to specs directory, self-review — SKILL.md:109-117
5. Chain to write-plan (the ONLY next step) — SKILL.md:77-78
6. write-plan creates bite-sized tasks — workflow/write-plan/SKILL.md
7. Handoff to subagent-dev or execute-plan — workflow/write-plan/SKILL.md:147-148

## Data Model Overview
| Data Store | Key Fields | Purpose |
|------------|-----------|---------|
| instincts/*.md | id, trigger, confidence, occurrences | Learned error patterns |
| docs/mistakes/auto-detected.md | timestamp, command, error | Error log |
| skill-catalog.md | name, path, description, tags | Skill registry |
| */evals/evals.json | id, prompt, expected_output | Skill evaluation tests |

--> Details: [data-model.md](data-model.md)

## Technical Decisions
- **Single repo:** All skills, hooks, standards in one project — directory structure
- **Symlink-based installation:** install.sh creates symlinks to ~/.claude/skills/ rather than copying files — install.sh:56
- **External dependency on gstack:** General skills not duplicated; gstack provides browse, review, QA, ship, security — CLAUDE.md:7
- **Profile-based hook system:** 3 tiers (minimal/standard/strict) with per-hook disable — run-with-profile.sh:10-12
- **Auto-learning instincts:** Errors auto-promote to instincts based on occurrence count — learn-from-errors.sh:141
- **Multilingual skill triggers:** Japanese, Korean, English trigger phrases in every skill description — workflow/brainstorm/SKILL.md:8-9
- **Japanese comments/commits standard:** Enforced via CODING-STANDARDS.md and code-quality-check.sh — standards/common/CODING-STANDARDS.md:22-27

--> Stack details: [tech-stack.md](tech-stack.md)
--> Patterns: [code-patterns.md](code-patterns.md)
--> Dependencies: [dependencies.md](dependencies.md)

## File Map
```
claude-skills/                          # Root project
├── .claude/
│   ├── hooks/                         # 8 bash hook scripts
│   │   ├── run-with-profile.sh        # Profile gate (all hooks route through)
│   │   ├── inject-instructions.sh     # SessionStart: reload CLAUDE.md
│   │   ├── load-instincts.sh          # SessionStart: load learned patterns
│   │   ├── secret-scanner.sh          # PreToolUse: block secrets in commits
│   │   ├── code-quality-check.sh      # PostToolUse: enforce coding standards
│   │   ├── learn-from-errors.sh       # PostToolUse: auto-record errors
│   │   ├── pre-commit-validate.sh     # Pre-commit validation
│   │   └── session-summary.sh         # Session summary generation
│   └── settings.json                  # Hook wiring configuration
├── workflow/                          # Dev workflow skills
│   ├── brainstorm/                    # Design exploration
│   ├── write-plan/                    # Implementation planning
│   ├── subagent-dev/                  # Subagent execution
│   ├── tdd/                           # Test-driven development
│   ├── verify-complete/               # Verification gate
│   ├── design-doc/                    # Feature design docs
│   ├── pipeline-build/                # Full feature pipeline
│   └── pipeline-figma/                # Figma pipeline
├── figma/                             # Figma automation (5 skills)
├── review/                            # Quality review (2 skills)
├── planning/                          # Orchestration (1 skill)
├── utility/                           # Meta tools (3 skills)
├── instincts/                         # Auto-learned patterns
│   ├── errors/                        # Error patterns
│   ├── code-patterns/                 # Code patterns
│   └── review-patterns/               # Review patterns
├── standards/                         # Coding standards
│   ├── common/CODING-STANDARDS.md     # 10 universal rules
│   └── frontend/FRONTEND-STANDARDS.md # Frontend-specific
├── CLAUDE.md                          # Project routing + skill table
├── skill-catalog.md                   # Unified skill registry
├── install.sh                         # Symlink installer
└── VERSION                            # 1.0.0
```
