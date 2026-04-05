# Architecture Summary

> Comprehensive summary of the claude-skills project architecture.

## What This Project Is

claude-skills is a collection of **Claude Code skills** -- structured Markdown instruction
files (SKILL.md) that extend Claude Code's capabilities with reusable workflows.
It is designed for a team doing Angular frontend development with Figma designs,
using Japanese as the code comment language.

The project works alongside **gstack** (a separate open-source project by Garry Tan)
which provides general-purpose skills like browser automation, code review, QA testing,
shipping, and security auditing.

## Core Design Principles

### 1. Skills as Markdown Instructions

Each skill is a directory with a `SKILL.md` file. The SKILL.md is NOT code -- it is
a set of natural language instructions that Claude Code follows when the skill is
invoked. The YAML frontmatter declares the skill's name, description (with trigger
phrases), and allowed tools.

This means skills are authored by writing Markdown, not by writing code.

### 2. Flat Namespace Installation

Skills are organized in categories (workflow/, figma/, review/, etc.) for human
navigation, but installed as a flat namespace via symlinks in `~/.claude/skills/`.
Claude Code discovers skills by scanning this flat directory.

### 3. File-Based Inter-Skill Communication

Skills communicate through the filesystem, not through shared memory or session context.
Key interchange files:
- `docs/project-overview.md` -- codebase understanding
- `docs/specs/*.md` -- feature design specifications
- `docs/plans/*.md` -- implementation plans
- `skill-catalog.md` -- skill registry
- `.claude/pipeline-state.json` -- pipeline progress tracking
- `crawled-components.json`, `diff-report.json` -- Figma pipeline intermediates

### 4. Subagent Isolation

Pipeline skills dispatch each stage as an independent subagent (via Claude Code's
Agent tool). Each subagent gets a fresh context window. This prevents context
exhaustion -- a single session running a 6-stage pipeline would run out of context.

### 5. User Gates

Critical decision points require explicit user approval. No skill auto-proceeds
past a "HARD GATE." This prevents unwanted code generation, destructive operations,
or commitment to a design the user hasn't reviewed.

### 6. Self-Learning Hook System

The hook system creates an automated feedback loop:
- Errors are automatically logged
- Recurring errors are promoted to "instincts" with confidence scores
- High-confidence instincts are auto-loaded into future sessions
- Very frequent patterns can be promoted to coding standards

### 7. Two-Tier Token Optimization

The plan-orchestrator uses a two-tier approach to avoid loading all skill instructions:
- Tier 1: Read skill-catalog.md (~500 tokens for 30 skills)
- Tier 2: Read only matched SKILL.md files (~5-7 per plan)

## System Topology

```
                         User Request
                              |
                         CLAUDE.md
                         (routing)
                              |
              +---------------+----------------+
              |               |                |
         Direct Skill    plan-orchestrator   Behavioral Mode
         Invocation      (dynamic plan)      Auto-Detection
              |               |                |
              v               v                v
         SKILL.md        skill-catalog.md   CLAUDE.md rules
         (loaded by      (Tier 1 scan)      (BRAINSTORM,
          Claude Code)        |              TASK_MANAGE,
              |          matched SKILL.md    TOKEN_SAVE,
              |          (Tier 2 load)       INTROSPECT)
              |               |
              v               v
         Execution       Plan Generation
              |          + Execution
              |               |
              v               v
         Hooks fire      Hooks fire
         (Pre/Post       (Pre/Post
          ToolUse)        ToolUse)
              |               |
              v               v
         Standards       Instincts
         Enforcement     Learning
```

## Cross-Project Dependencies

| This Project | Depends On | For |
|-------------|-----------|-----|
| claude-skills | gstack (~/.claude/skills/gstack/) | browse, review, qa, ship, cso, design-review, and ~25 other general-purpose skills |
| claude-skills | angular-web-common (../angular-web-common/) | Figma component registry for figma-to-code and figma-component-writer |
| claude-skills | Figma MCP (runtime) | Figma API access for figma-* skills |
| claude-skills | Claude Code (runtime) | Skill loading, hook execution, Agent tool for subagents |

## Quantitative Summary

| Metric | Count |
|--------|-------|
| SKILL.md files | 19 |
| Category directories | 5 (workflow, figma, review, planning, utility) |
| Hook scripts | 8 (6 registered in settings.json) |
| Instinct files | 4 |
| Standards files | 2 (common + frontend) |
| Pipeline skills | 3 (pipeline-build, pipeline-figma, figma-component-writer) |
| User-facing skills | 14 |
| Internal pipeline stages | 3 (figma-common-crawler/diff/mapper) |
| gstack skills referenced | ~30 |
| Coding standards rules | 10 (common) + frontend-specific |
| Supported languages for triggers | English, Japanese, Korean |
| Max pipeline depth | 3 levels (pipeline-build -> subagent-dev -> sub-subagents) |
