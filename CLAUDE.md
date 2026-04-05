# claude-skills

> Project-specific Claude Code skills. Workflow, Figma automation, and DevOps review.
> General-purpose skills (browse, review, QA, ship, etc.) are provided by **gstack** (installed separately).

## Prerequisites

- **gstack**: `git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup`
- All gstack skills (browse, review, qa, ship, cso, etc.) are available via gstack global install.

## Routing

```
User Request
    ↓
CLAUDE.md (this file)
    ├→ Figma component URL + "common/shared/공통"
    │   → /figma-component-writer [claude-skills]
    │
    ├→ Figma URL + "page/screen/implement/구현"
    │   → /figma-to-code [claude-skills]
    │
    ├→ "/plan-orchestrator" or "plan this"
    │   → /plan-orchestrator [claude-skills] (reads skill-catalog.md for all sources)
    │
    ├→ Idea/brainstorm ("brainstorm", "maybe", "어떻게")
    │   → /brainstorm → /write-plan → /execute-plan [claude-skills]
    │
    ├→ Rough prompt + "refine and plan" / "정리해서 플랜" / "整理してプラン"
    │   → /prompt-to-plan [claude-skills]
    │
    ├→ Debug/error ("debug", "bug", "error", "broken")
    │   → /investigate [gstack]
    │
    ├→ Skill catalog ("scan skills", "update catalog", "add skill pack")
    │   → /skill-catalog [claude-skills]
    │
    ├→ Workflow analysis ("trace flow", "sequence diagram", "워크플로우 분석")
    │   → /workflow-blueprint (initial) or /workflow-blueprint-update (refresh)
    │
    └→ Other → direct /skill-name (check skill-catalog.md for available skills)
```

## Skill Discovery

**`skill-catalog.md`** is the unified skill registry. It lists ALL skills from ALL sources
(gstack, claude-skills, custom packs). Run `/skill-catalog scan` to regenerate.

plan-orchestrator reads this file as Tier 1 for skill matching.

## Project Skills (claude-skills)

### workflow/
| Skill | Description | Tags |
|-------|-------------|------|
| brainstorm | Socratic design, 3 options before implementation | #design #planning |
| write-plan | Bite-sized 2-5min tasks, zero-context assumption | #planning #tasks |
| prompt-to-plan | Refine rough prompts, enter Plan Mode, build implementation plan | #prompt #planning |
| design-doc | Generate per-feature design document with fixed template | #docs #design |
| subagent-dev | Fresh subagent per task, two-stage review | #execution #parallel |
| tdd | RED-GREEN-REFACTOR, no code without failing test | #testing #quality |
| verify-complete | Evidence-based verification gate | #verification |
| pipeline-build | Feature build: scan → design → plan → subagent-dev → review → verify | #pipeline |
| pipeline-figma | Figma → Code: figma-to-code → tests → qa → design-review | #pipeline |
| workflow-blueprint | Deep workflow trace with Mermaid sequence diagrams (entry → service → DB) | #analysis #workflow #diagrams |
| workflow-blueprint-update | Incremental workflow doc update via git diff | #analysis #workflow #update |

### review/
| Skill | Description | Tags |
|-------|-------------|------|
| devops-japanese-comments | Japanese comment enforcement | #quality #i18n |
| devops-test-gen | Auto-generate tests for changed code | #testing |

### planning/
| Skill | Description | Tags |
|-------|-------------|------|
| plan-orchestrator | Auto-scan skills from all sources, build execution plan | #planning #orchestration |

### figma/
| Skill | Description | Tags |
|-------|-------------|------|
| figma-common-crawler | Crawl Figma URL for component styles | #figma #components |
| figma-common-diff | Compare crawled vs existing components | #figma #components |
| figma-common-mapper | Preview mapping + user confirmation | #figma #components |
| figma-component-writer | Orchestrate: Figma → angular-web-common | #figma #agent |
| figma-to-code | Figma URL → Angular code with common mapping | #figma #agent |

### utility/
| Skill | Description | Tags |
|-------|-------------|------|
| project-scan | Scan codebase — tech stack, features, data model, patterns | #analysis #onboarding |
| skill-catalog | Scan and manage skills from multiple sources | #utility #catalog |

---

## Behavioral Modes (Auto-Detection)

| Mode | Auto-Detection | Behavior |
|------|---------------|----------|
| **BRAINSTORM** | Vague language ("maybe", "아마", "뭔가", "어떻게") | Present 3 options → user selects → then implement |
| **TASK_MANAGE** | 3+ files or 2+ directories affected | Auto-use TodoWrite for tracking |
| **TOKEN_SAVE** | Context usage 60%+ | Defer non-essential steps, minimize output |
| **INTROSPECT** | Same error repeated 2+ times | Search instincts/ first, force root cause analysis |

---

## Hook Profile System

```bash
export HOOK_PROFILE=standard    # minimal | standard | strict
export DISABLED_HOOKS="code-quality-check"  # comma-separated
```

| Profile | Active Hooks |
|---------|-------------|
| minimal | inject-instructions, load-instincts, learn-from-errors |
| standard | minimal + secret-scanner, code-quality-check |
| strict | standard + (future) |

---

## Instincts System

```
Error occurs → learn-from-errors.sh → docs/mistakes/auto-detected.md
  → 2+ similar → instincts/errors/ (confidence 0.6)
  → 3+ → auto-loaded at SessionStart (confidence 0.8+)
  → 5+ → suggest promotion to standards/
```

---

## Coding Standards

See `standards/common/CODING-STANDARDS.md` (always) + `standards/frontend/` or `standards/backend/` (by context).

Key rules:
- File header: one-line English summary
- Function max 30 lines
- Comments in Japanese
- Commit messages in Japanese

---

## Paths

| Resource | Path |
|----------|------|
| Browse binary | `~/.claude/skills/gstack/browse/dist/browse` |
| Standards | `~/.claude/standards/common/CODING-STANDARDS.md` |
| Skill catalog | `./skill-catalog.md` |
| Instincts | `./instincts/` |

## Communication

- Respond in the **user's language**
- **English** for all asset files (SKILL.md, etc.)
- Always confirm before destructive actions
