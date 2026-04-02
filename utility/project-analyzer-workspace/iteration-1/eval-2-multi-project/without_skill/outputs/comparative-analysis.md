# Comparative Analysis: claude-skills vs superpowers

## 1. Project Overview

| Dimension | claude-skills | superpowers |
|-----------|--------------|-------------|
| Author | itstudyu (personal/team project) | Jesse Vincent / Prime Radiant (open-source community) |
| Version | 1.0.0 | 5.0.6 |
| License | MIT | MIT |
| Total files | ~67 (excluding .git) | ~138 (excluding .git) |
| Skills count | 19 (in skill-catalog.md) | 14 (in skills/) |
| Primary target | Claude Code (project-specific) | Multi-platform (Claude Code, Cursor, Codex, OpenCode, Gemini CLI) |
| Repository | github.com/itstudyu/claude-skills | github.com/obra/superpowers |

## 2. Structural Differences

### 2.1 Directory Layout

**claude-skills:**
```
claude-skills/
  .claude/           # Claude Code hooks and settings
    hooks/           # 8 shell scripts (inject-instructions, secret-scanner, etc.)
    settings.json    # Hook configuration with profile system
  workflow/          # 8 skills (brainstorm, write-plan, subagent-dev, tdd, etc.)
  review/            # 2 skills (japanese-comments, test-gen)
  planning/          # 1 skill (plan-orchestrator)
  figma/             # 5 skills (Figma-to-Angular pipeline)
  utility/           # 3 skills (project-scan, skill-catalog, project-analyzer)
  standards/         # Coding standards (common/, frontend/)
  instincts/         # Auto-learned error patterns + code patterns
  docs/              # Images, skill docs
  skill-catalog.md   # Unified skill registry (all sources)
  CLAUDE.md          # Routing + behavioral modes + hook profiles
  install.sh         # Symlink-based installer
  setup              # Setup script
```

**superpowers:**
```
superpowers/
  skills/            # 14 SKILL.md files (flat, one dir per skill)
  commands/          # 3 deprecated slash commands
  hooks/             # 1 session-start hook + platform config
  agents/            # 1 agent definition (code-reviewer.md)
  tests/             # Comprehensive test suites (6 test categories)
  docs/              # Plans, specs, platform-specific docs
  .claude-plugin/    # plugin.json for Claude Code marketplace
  .cursor-plugin/    # plugin.json for Cursor
  .opencode/         # Plugin for OpenCode
  .codex/            # Install instructions for Codex
  .github/           # Issue templates, PR template, funding
  GEMINI.md          # Gemini CLI integration
  package.json       # npm-style package metadata (v5.0.6)
  gemini-extension.json
```

### 2.2 Skill Organization

**claude-skills** organizes skills into semantic categories (workflow/, review/, planning/, figma/, utility/). Each skill directory contains:
- `SKILL.md` -- the skill definition
- `evals/evals.json` -- evaluation test cases for the skill

**superpowers** uses a flat `skills/` directory with no subcategories. Skills do NOT have eval files. Some skills include `references/` subdirectories with supplementary documentation.

### 2.3 Platform Support

**claude-skills:**
- Claude Code only
- Depends on gstack for general-purpose skills (browse, review, QA, ship, security)
- Installed via `./install.sh` which creates symlinks into `~/.claude/skills/`

**superpowers:**
- Multi-platform: Claude Code, Cursor, Codex, OpenCode, Gemini CLI
- Self-contained -- no external dependencies
- Multiple installation methods: official plugin marketplace, manual git clone, platform-specific plugin systems
- Platform-specific configuration files (.claude-plugin/, .cursor-plugin/, .opencode/, .codex/, GEMINI.md)

### 2.4 Hook System

**claude-skills** has an elaborate hook system with 8 hook scripts and a profile system:
- `inject-instructions.sh` -- load CLAUDE.md instructions
- `load-instincts.sh` -- load learned error patterns
- `secret-scanner.sh` -- scan for secrets before Bash execution
- `code-quality-check.sh` -- quality check on Edit/Write
- `learn-from-errors.sh` -- auto-learn from Bash errors
- `pre-commit-validate.sh` -- pre-commit validation
- `session-summary.sh` -- session summary
- `run-with-profile.sh` -- profile-based hook activation (minimal/standard/strict)

Hooks are configured in `.claude/settings.json` with matchers for SessionStart, PreToolUse, and PostToolUse events.

**superpowers** has a single `session-start` hook that injects the `using-superpowers` skill content at session start. The hook is platform-aware (detects Claude Code vs Cursor vs other) and outputs the appropriate JSON format.

### 2.5 Behavioral Systems

**claude-skills** has unique systems not present in superpowers:

1. **Behavioral Modes (Auto-Detection):**
   - BRAINSTORM mode: triggered by vague language
   - TASK_MANAGE mode: triggered by multi-file changes
   - TOKEN_SAVE mode: triggered by 60%+ context usage
   - INTROSPECT mode: triggered by repeated errors

2. **Instincts System:** Auto-learned patterns from errors that graduate based on confidence:
   - 2+ occurrences -> instincts/errors/ (confidence 0.6)
   - 3+ -> auto-loaded at session start (confidence 0.8+)
   - 5+ -> suggest promotion to standards/

3. **Skill Catalog System:** Unified registry (`skill-catalog.md`) that aggregates skills from all sources (gstack, claude-skills, custom packs). Used by plan-orchestrator for skill discovery.

4. **Coding Standards:** Explicit standards in `standards/` directory (function max 30 lines, Japanese comments, branch naming conventions).

**superpowers** has unique systems not present in claude-skills:

1. **Agents System:** Separate `agents/` directory with agent definitions (e.g., code-reviewer) that are distinct from skills.

2. **Comprehensive Test Suite:** 6 test categories including:
   - claude-code tests (integration, token analysis)
   - explicit-skill-requests (prompt-based tests)
   - skill-triggering tests
   - subagent-driven-dev tests
   - brainstorm-server tests (WebSocket, lifecycle)
   - opencode tests

3. **Community Infrastructure:** GitHub issue templates, PR template, FUNDING.yml, CODE_OF_CONDUCT.md, Discord community.

## 3. Skill Comparison (Overlapping Skills)

Both projects share core workflow skills that appear to derive from the same origin:

| Skill Area | claude-skills | superpowers |
|-----------|--------------|-------------|
| Brainstorming | `brainstorm` | `brainstorming` |
| Plan writing | `write-plan` | `writing-plans` |
| Plan execution | (via pipeline-build) | `executing-plans` |
| Subagent dev | `subagent-dev` | `subagent-driven-development` |
| TDD | `tdd` | `test-driven-development` |
| Verification | `verify-complete` | `verification-before-completion` |
| Code review | (via gstack) | `requesting-code-review`, `receiving-code-review` |
| Debugging | (via gstack `/investigate`) | `systematic-debugging` |
| Git worktrees | (not present) | `using-git-worktrees` |
| Branch finish | (not present) | `finishing-a-development-branch` |
| Parallel agents | (via subagent-dev) | `dispatching-parallel-agents` |
| Meta/self-ref | (not present) | `using-superpowers`, `writing-skills` |

The SKILL.md content for overlapping skills (e.g., brainstorm, subagent-dev) is very similar -- same structure, same HARD-GATE patterns, same checklist items. **claude-skills appears to have forked/adapted these from superpowers and customized them** (added multilingual trigger words in Japanese/Korean, renamed for brevity, added eval files).

### Skills Unique to claude-skills
- **Figma pipeline** (5 skills): figma-common-crawler, figma-common-diff, figma-common-mapper, figma-component-writer, figma-to-code
- **Pipelines** (6+): pipeline-build, pipeline-figma, pipeline-debug, pipeline-full, pipeline-idea, pipeline-onboard, pipeline-quality
- **plan-orchestrator**: Skill-aware plan generation
- **design-doc**: Feature design document generation
- **devops-japanese-comments**: Japanese comment enforcement
- **devops-test-gen**: Auto test generation
- **project-scan**: Codebase analysis
- **skill-catalog**: Multi-source skill management

### Skills Unique to superpowers
- **systematic-debugging**: 4-phase root cause investigation
- **using-git-worktrees**: Parallel branch management
- **finishing-a-development-branch**: Merge/PR decision workflow
- **dispatching-parallel-agents**: Concurrent agent coordination
- **receiving-code-review**: Responding to review feedback
- **writing-skills**: Meta-skill for creating new skills
- **using-superpowers**: Bootstrap/introduction skill

## 4. Design Philosophy Differences

| Aspect | claude-skills | superpowers |
|--------|--------------|-------------|
| **Scope** | Project-specific customization layer on top of gstack | Self-contained general-purpose toolkit |
| **Extensibility** | Modular: separate skill packs can be added via skill-catalog | Monolithic: all skills in one repo |
| **Automation** | Heavy automation (instincts, behavioral modes, hook profiles) | Minimal automation (one session hook, skill-driven) |
| **Customization** | Deep: coding standards, Japanese comments, Angular/Figma specific | Broad: platform-agnostic, no framework assumptions |
| **Skill triggering** | CLAUDE.md routing table + behavioral mode auto-detection | using-superpowers skill with "1% chance = must invoke" rule |
| **Eval/Testing** | Every skill has evals/evals.json for quality measurement | Separate tests/ directory with integration test scripts |
| **Maturity** | v1.0.0 -- newer project | v5.0.6 -- mature, community-driven |
| **Dependencies** | Requires gstack for core capabilities | No external dependencies |

## 5. Key Commonalities

1. **Same core workflow**: Both implement the brainstorm -> plan -> execute -> verify cycle
2. **SKILL.md format**: Both use the same frontmatter format (name, description) and Markdown body
3. **Subagent-driven development**: Both implement the "fresh subagent per task + two-stage review" pattern
4. **HARD-GATE pattern**: Both use `<HARD-GATE>` tags to enforce mandatory behaviors
5. **TDD emphasis**: Both enforce RED-GREEN-REFACTOR as a core development practice
6. **Graphviz flow diagrams**: Both use `dot` diagrams in SKILL.md to illustrate process flows
7. **MIT License**: Both are MIT licensed
8. **Evidence-based verification**: Both require proof before declaring work complete

## 6. Relationship Between Projects

Based on the evidence:
- claude-skills explicitly lists superpowers-origin skills in its skill-catalog.md (gstack section)
- The SKILL.md content for overlapping skills shares nearly identical text, structure, and patterns
- claude-skills adds project-specific layers: Figma automation, Angular-specific tooling, Japanese language requirements, and a sophisticated hook/instincts infrastructure
- claude-skills serves as a **project-specific customization layer** that extends general-purpose skill ecosystems (gstack + superpowers) with domain-specific capabilities
- superpowers is the **upstream general-purpose skill library** that provides the foundational workflow patterns

## 7. Summary

**superpowers** is a mature, multi-platform, community-driven general-purpose skill library focused on software development workflow (brainstorming, planning, TDD, debugging, code review). It is self-contained with no dependencies and supports 5+ coding agent platforms.

**claude-skills** is a newer, Claude Code-specific project that builds on top of the superpowers/gstack ecosystem. It adds project-specific capabilities (Figma-to-Angular automation, Japanese coding standards, pipeline orchestration) and sophisticated automation systems (instincts, behavioral modes, hook profiles, skill catalog). It is designed for a specific team's workflow rather than general community use.

The two projects are complementary rather than competing: superpowers provides the foundation, and claude-skills extends it for a specific use case.
