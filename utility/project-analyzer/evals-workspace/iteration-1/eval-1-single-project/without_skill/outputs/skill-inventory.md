# Skill Inventory

> Complete inventory of all skills in the claude-skills project.
> 19 SKILL.md files found across 5 category directories.

## Skills by Category

### workflow/ (9 skills)

| Skill | Invocation | Type | Description |
|-------|-----------|------|-------------|
| brainstorm | `/brainstorm` | Interactive | Socratic design exploration. Asks questions one at a time, presents 2-3 approaches, gets user approval before any implementation. Terminal state: invokes write-plan. |
| design-doc | `/design-doc` | Generator | Creates structured per-feature design documents at docs/specs/. Analyzes code for data model, API endpoints, business logic, UI. Fills gaps by asking user. |
| write-plan | `/write-plan` | Generator | Creates bite-sized (2-5 min) implementation plans with exact file paths, complete code blocks, test commands. Follows TDD. Outputs to docs/plans/. |
| subagent-dev | `/subagent-dev` | Executor | Dispatches fresh subagent per task from a plan. Two-stage review after each task (spec compliance then code quality). Supports parallel dispatch for independent tasks. |
| tdd | `/tdd` | Methodology | Enforces RED-GREEN-REFACTOR cycle. Requires watching test fail before writing implementation. "If you didn't watch the test fail, you don't know if it tests the right thing." |
| verify-complete | `/verify-complete` | Gate | Evidence-based verification. "No completion claims without fresh verification evidence." Requires running commands and reading output before any success claim. |
| pipeline-build | `/pipeline-build` | Pipeline | 6-stage orchestrator: project-scan -> design-doc -> write-plan -> subagent-dev -> review -> verify-complete. Uses Agent tool for independent subagent contexts. State persists in .claude/pipeline-state.json. |
| pipeline-figma | `/pipeline-figma` | Pipeline | 4-stage orchestrator: figma-to-code -> devops-test-gen -> qa -> design-review. Each stage is independent subagent. State persists. |

Note: The skill-catalog.md also lists pipeline-debug, pipeline-full, pipeline-idea,
pipeline-onboard, pipeline-quality, pipeline-retro, pipeline-smart -- but no SKILL.md
files were found for these in the current codebase. They may be planned but not yet
implemented, or listed in the catalog from a previous scan.

### figma/ (5 skills)

| Skill | Invocation | Type | Description |
|-------|-----------|------|-------------|
| figma-component-writer | `/figma-component-writer` | Pipeline | Orchestrates full Figma-to-angular-web-common pipeline. Calls crawler -> diff -> mapper -> code gen -> registry update. User-facing. |
| figma-to-code | `/figma-to-code` | Generator | Converts Figma design URL into Angular page code. Maps common components from angular-web-common first, generates custom only for unmatched elements. User-facing. |
| figma-common-crawler | `/figma-common-crawler` | Internal | Phase 1 of component writer. Crawls Figma URL via MCP, extracts styles/variants/properties into standardized JSON. |
| figma-common-diff | `/figma-common-diff` | Internal | Phase 2 of component writer. Compares crawled components against registry.json. Classifies as NEW/CHANGED/UNCHANGED. |
| figma-common-mapper | `/figma-common-mapper` | Internal | Phase 3 of component writer. Presents sync preview table to user for approval. |

### review/ (2 skills)

| Skill | Invocation | Type | Description |
|-------|-----------|------|-------------|
| devops-japanese-comments | `/devops-japanese-comments` | Transformer | Converts English comments/logs to Japanese. Adds missing comments to complex logic. Team convention enforcement. |
| devops-test-gen | `/devops-test-gen` | Generator | Auto-generates unit and regression tests for new/changed code. Detects test framework automatically. |

### planning/ (1 skill)

| Skill | Invocation | Type | Description |
|-------|-----------|------|-------------|
| plan-orchestrator | `/plan-orchestrator` | Meta-skill | Reads skill-catalog.md (Tier 1), reads matched SKILL.md files (Tier 2), collects context via 4 sub-phases, generates structured execution plan, executes after user approval. |

### utility/ (3 skills, including project-analyzer)

| Skill | Invocation | Type | Description |
|-------|-----------|------|-------------|
| project-scan | `/project-scan` | Analyzer | Scans codebase for tech stack, directory structure, features, data model, code patterns. Generates docs/project-overview.md. |
| skill-catalog | `/skill-catalog` | Registry | Scans all skill sources, parses SKILL.md frontmatter, generates skill-catalog.md. Commands: scan, add, list, remove. |
| project-analyzer | `/project-analyzer` | Analyzer | (This evaluation workspace skill) |

## Skill Types

| Type | Count | Description |
|------|-------|-------------|
| Pipeline | 3 | Orchestrate multi-skill chains (pipeline-build, pipeline-figma, figma-component-writer) |
| Generator | 4 | Produce output files (design-doc, write-plan, figma-to-code, devops-test-gen) |
| Interactive | 1 | Require sustained user dialogue (brainstorm) |
| Executor | 1 | Execute plans via subagents (subagent-dev) |
| Methodology | 1 | Enforce development practices (tdd) |
| Gate | 1 | Verification checkpoint (verify-complete) |
| Meta-skill | 1 | Dynamically select and orchestrate other skills (plan-orchestrator) |
| Internal | 3 | Pipeline stages not meant for direct invocation (figma-common-*) |
| Transformer | 1 | Modify existing code (devops-japanese-comments) |
| Analyzer | 2 | Examine codebase and produce reports (project-scan, skill-catalog) |
| Registry | 1 | Manage skill discovery (skill-catalog) |

## Skills NOT in This Repo (from gstack)

The following skills appear in skill-catalog.md under the gstack source and are
loaded from ~/.claude/skills/gstack/:

browse, review, qa, qa-only, ship, cso, investigate, benchmark, canary,
design-review, design-shotgun, design-consultation, office-hours, retro,
codex, connect-chrome, setup-browser-cookies, setup-deploy, land-and-deploy,
document-release, gstack-upgrade, freeze, unfreeze, guard, careful, autoplan,
plan-ceo-review, plan-design-review, plan-eng-review

These are referenced by claude-skills pipelines (e.g., pipeline-build uses
`review [gstack]` and `qa [gstack]`) but are maintained in the separate gstack repository.
