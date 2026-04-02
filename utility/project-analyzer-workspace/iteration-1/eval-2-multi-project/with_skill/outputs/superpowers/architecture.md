# Architecture Design Doc — superpowers

> Analyzed on 2026-04-02
> This document summarizes the detailed analysis in sibling files.

## System Overview

**What it is:** A cross-platform AI coding agent skill library that provides a complete software development workflow (brainstorming, planning, TDD, subagent execution, debugging, verification) distributed as plugins for Claude Code, Cursor, Gemini CLI, OpenCode, and Codex. Zero production dependencies.

**Stack:** JavaScript (Node.js, ESM + CommonJS) + Bash (hooks) + Markdown (skills) + JSON (manifests)

**Source:** /Users/yu_s/Documents/GitHub/superpowers

## Architecture Layers

```
┌─────────────────────────────────────────────────┐
│    Platform Adapters                             │
│    (Claude, Cursor, Gemini, OpenCode, Codex)     │
│    .claude-plugin/ .cursor-plugin/ .opencode/    │
│    .codex/ gemini-extension.json GEMINI.md       │
├─────────────────────────────────────────────────┤
│    Session Bootstrap (hooks/session-start)        │
│    Injects using-superpowers SKILL.md into        │
│    context with platform-specific JSON format     │
├─────────────────────────────────────────────────┤
│    Skill Router (using-superpowers)               │
│    "Even 1% chance → invoke skill"               │
│    Priority: user > superpowers > system          │
├─────────────────────────────────────────────────┤
│    Skills Library (13 skills)                     │
│    ├── Process: brainstorming, writing-plans,     │
│    │   executing-plans, subagent-driven-dev       │
│    ├── Quality: TDD, verification, code review    │
│    ├── Debugging: systematic-debugging            │
│    ├── Git: worktrees, branch finishing           │
│    └── Meta: writing-skills, using-superpowers    │
├─────────────────────────────────────────────────┤
│    Supporting Infrastructure                      │
│    ├── Brainstorm Server (zero-dep WebSocket)     │
│    ├── Agents (code-reviewer.md)                  │
│    ├── Commands (brainstorm, write-plan,           │
│    │   execute-plan)                              │
│    └── Tests (5 test suites)                      │
└─────────────────────────────────────────────────┘
```

## Key Features Summary
| Feature | Entry Point | Core Logic | Data |
|---------|-------------|------------|------|
| Multi-platform distribution | 5 manifest files | Platform-specific plugin format | .claude-plugin/, .cursor-plugin/, etc. |
| Session bootstrap | hooks/session-start:1 | Read SKILL.md, wrap in XML, emit JSON | using-superpowers/SKILL.md |
| Skill routing | using-superpowers/SKILL.md:1 | 1% threshold, priority order | Skill tool invocations |
| Brainstorming + Visual | brainstorming/SKILL.md:1 | 9-step checklist, WebSocket companion | specs/ docs |
| Subagent-driven dev | subagent-driven-development/SKILL.md:1 | Fresh agent per task, 2-stage review | Plans, git commits |
| Systematic debugging | systematic-debugging/SKILL.md:1 | 4-phase root cause process | N/A |
| TDD enforcement | test-driven-development/SKILL.md:1 | RED-GREEN-REFACTOR iron law | Test files |
| Git worktrees | using-git-worktrees/SKILL.md:1 | Auto-detect dir, verify ignored, setup | .worktrees/ |
| Writing skills (meta) | writing-skills/SKILL.md:1 | TDD for documentation | SKILL.md files |

--> Details: [features.md](features.md)

## Data Flow

**Example: Full Development Workflow**
1. User starts session; `hooks/session-start` injects `using-superpowers` SKILL.md — hooks/session-start:18
2. User describes feature; skill router detects brainstorming should apply — using-superpowers/SKILL.md:10-16
3. brainstorming: Socratic dialogue, 2-3 approaches, sectioned design, spec document — brainstorming/SKILL.md:22-33
4. using-git-worktrees: Create isolated branch + workspace — using-git-worktrees/SKILL.md
5. writing-plans: Break spec into bite-sized tasks with full code — writing-plans/SKILL.md
6. subagent-driven-development: Per-task subagent + spec review + quality review — subagent-driven-development/SKILL.md
7. test-driven-development: Each subagent follows RED-GREEN-REFACTOR — test-driven-development/SKILL.md
8. verification-before-completion: Evidence-based completion claims — verification-before-completion/SKILL.md
9. finishing-a-development-branch: Merge/PR/keep/discard options — finishing-a-development-branch/SKILL.md

**Example: Visual Brainstorming**
1. brainstorming skill offers visual companion in dedicated message — brainstorming/SKILL.md:152-154
2. If accepted, starts zero-dep WebSocket server — scripts/start-server.sh
3. server.cjs implements RFC 6455 handshake and frame encoding — server.cjs:8-37
4. Per-question decision: browser for visual, terminal for text — brainstorming/SKILL.md:156-161

## Data Model Overview
| Data Store | Key Fields | Purpose |
|------------|-----------|---------|
| docs/superpowers/specs/*.md | design content | Design specifications |
| docs/superpowers/plans/*.md | tasks with code | Implementation plans |
| plugin manifests | name, version, paths | Platform registration |
| test prompts (*.txt) | prompt text | Skill trigger verification |

--> Details: [data-model.md](data-model.md)

## Technical Decisions
- **Single repo with multi-platform distribution:** One codebase, 5 platform adapters — .claude-plugin/, .cursor-plugin/, .codex/, .opencode/, gemini-extension.json
- **Zero production dependencies:** Brainstorm WebSocket server implements RFC 6455 from scratch — server.cjs:6-9
- **Self-contained skill system:** No dependency on external skill packs (unlike claude-skills which depends on gstack) — package.json shows 0 deps
- **Session bootstrap via hooks:** Single hook injects the master skill router — hooks/session-start:35
- **Aggressive skill invocation mandate:** "1% chance → must invoke" — using-superpowers/SKILL.md:10
- **Marketplace distribution:** Available via Claude Code official plugin marketplace — README.md:36-38
- **ESM + CommonJS hybrid:** Root package.json declares `"type": "module"` (package.json:4), brainstorm server uses `.cjs` extension for CommonJS compat — CHANGELOG.md:7
- **Spec → Plan → Execute pipeline:** Enforced sequence with no shortcuts — brainstorming/SKILL.md:66, writing-plans/SKILL.md:146

--> Stack details: [tech-stack.md](tech-stack.md)
--> Patterns: [code-patterns.md](code-patterns.md)
--> Dependencies: [dependencies.md](dependencies.md)

## File Map
```
superpowers/                                # Root project
├── .claude-plugin/                        # Claude Code plugin
│   ├── plugin.json                        # Plugin manifest (v5.0.6)
│   └── marketplace.json                   # Marketplace registry
├── .cursor-plugin/                        # Cursor plugin manifest
├── .codex/                                # Codex install instructions
├── .opencode/                             # OpenCode ESM plugin
│   └── plugins/superpowers.js             # System prompt transform
├── .github/                               # Issue/PR templates, funding
├── skills/                                # Skill definitions (13 skills)
│   ├── using-superpowers/                 # Skill router (master skill)
│   ├── brainstorming/                     # Design exploration + visual
│   │   ├── SKILL.md                       # Main skill definition
│   │   ├── scripts/                       # Zero-dep brainstorm server
│   │   │   ├── server.cjs                 # WebSocket server (RFC 6455)
│   │   │   ├── start-server.sh            # Server lifecycle
│   │   │   └── stop-server.sh
│   │   └── visual-companion.md            # Visual brainstorm guide
│   ├── writing-plans/                     # Task planning
│   ├── subagent-driven-development/       # Subagent execution
│   │   ├── SKILL.md
│   │   ├── implementer-prompt.md          # Subagent prompt templates
│   │   ├── spec-reviewer-prompt.md
│   │   └── code-quality-reviewer-prompt.md
│   ├── executing-plans/                   # Batch execution
│   ├── test-driven-development/           # TDD enforcement
│   ├── systematic-debugging/              # 4-phase debugging
│   │   ├── SKILL.md
│   │   ├── root-cause-tracing.md          # Supporting technique
│   │   ├── defense-in-depth.md
│   │   └── condition-based-waiting.md
│   ├── verification-before-completion/    # Evidence-based verification
│   ├── using-git-worktrees/               # Workspace isolation
│   ├── finishing-a-development-branch/    # Branch completion
│   ├── requesting-code-review/            # Review workflow
│   ├── receiving-code-review/             # Feedback handling
│   ├── dispatching-parallel-agents/       # Parallel execution
│   └── writing-skills/                    # Meta: skill creation
├── agents/                                # Agent definitions
│   └── code-reviewer.md                   # Code review agent
├── commands/                              # Slash commands
│   ├── brainstorm.md
│   ├── write-plan.md
│   └── execute-plan.md
├── hooks/                                 # Platform hooks
│   ├── session-start                      # Main bootstrap hook
│   ├── hooks.json                         # Claude Code hook config
│   ├── hooks-cursor.json                  # Cursor hook config
│   └── run-hook.cmd                       # Windows hook runner
├── tests/                                 # 5 test suites
│   ├── brainstorm-server/                 # Integration tests (ws)
│   ├── claude-code/                       # Claude Code tests
│   ├── explicit-skill-requests/           # Prompt trigger tests
│   ├── skill-triggering/                  # Routing tests
│   ├── subagent-driven-dev/               # SDD workflow tests
│   └── opencode/                          # OpenCode plugin tests
├── docs/                                  # Design specs + plans
├── gemini-extension.json                  # Gemini CLI manifest
├── GEMINI.md                              # Gemini context file
├── package.json                           # Root manifest (v5.0.6)
└── CHANGELOG.md                           # Release history
```
