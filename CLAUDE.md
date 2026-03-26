# claude-skills

> Claude Code skill collection. gstack base + superpowers workflow + Figma automation.

## Routing

```
User Request
    ↓
CLAUDE.md (this file)
    ├→ Figma component URL + "common/shared/공통"
    │   → /figma-component-writer
    │
    ├→ Figma URL + "page/screen/implement/구현"
    │   → /figma-to-code
    │
    ├→ "/plan-orchestrator" or "plan this"
    │   → /plan-orchestrator (scans all skills, builds plan)
    │
    ├→ Idea/brainstorm ("brainstorm", "maybe", "어떻게")
    │   → /brainstorm → /write-plan → /execute-plan
    │
    ├→ Debug/error ("debug", "bug", "error", "broken")
    │   → /systematic-debug
    │
    ├→ Project analysis ("analyze project", "onboard")
    │   → /project-analyzer
    │
    └→ Other → direct /skill-name invocation
```

## Skill Index (Tier 1)

### workflow/
| Skill | Description | Tags |
|-------|-------------|------|
| brainstorm | Socratic design, 3 options before implementation | #design #planning |
| write-plan | Bite-sized 2-5min tasks, zero-context assumption | #planning #tasks |
| execute-plan | Sequential execution with human checkpoints | #execution |
| subagent-dev | Fresh subagent per task, two-stage review | #execution #parallel |
| tdd | RED-GREEN-REFACTOR, no code without failing test | #testing #quality |
| systematic-debug | 4-phase root cause investigation | #debugging |
| verify-complete | Evidence-based verification gate | #verification |

### review/
| Skill | Description | Tags |
|-------|-------------|------|
| review | PR code review (diff-based) | #review #quality |
| qa | Browser QA testing + fixes | #testing #browser |
| qa-only | QA report only (no fixes) | #testing #browser |
| cso | OWASP Top 10 + STRIDE security audit | #security |
| devops-japanese-comments | Japanese comment enforcement | #quality #i18n |
| devops-safety-check | Lightweight security scan | #security |
| devops-test-gen | Auto-generate tests for changed code | #testing |

### planning/
| Skill | Description | Tags |
|-------|-------------|------|
| plan-orchestrator | Auto-scan skills, build execution plan | #planning #orchestration |
| plan-ceo-review | CEO perspective plan review | #review #planning |
| plan-eng-review | Engineering perspective plan review | #review #planning |
| plan-design-review | Design perspective plan review | #review #design |
| autoplan | Auto-run CEO + design + eng reviews | #review #planning |

### figma/
| Skill | Description | Tags |
|-------|-------------|------|
| figma-common-crawler | Crawl Figma URL for component styles | #figma #components |
| figma-common-diff | Compare crawled vs existing components | #figma #components |
| figma-common-mapper | Preview mapping + user confirmation | #figma #components |
| figma-component-writer | Orchestrate: Figma → angular-web-common | #figma #agent |
| figma-to-code | Figma URL → Angular code with common mapping | #figma #agent |

### design/
| Skill | Description | Tags |
|-------|-------------|------|
| design-consultation | Build design system from scratch | #design |
| design-review | Visual design audit + fixes | #design #browser |

### safety/
| Skill | Description | Tags |
|-------|-------------|------|
| careful | Warn before destructive commands | #safety |
| freeze | Restrict edits to a directory | #safety |
| guard | careful + freeze combined | #safety |
| unfreeze | Remove freeze restriction | #safety |

### analysis/
| Skill | Description | Tags |
|-------|-------------|------|
| project-analyzer | Analyze project structure/framework/conventions | #analysis |
| investigate | Root cause debugging with browse | #debugging #browser |
| benchmark | Performance regression detection | #performance |
| retro | Weekly engineering retrospective | #analysis #team |

### utility/
| Skill | Description | Tags |
|-------|-------------|------|
| ship | Test → PR → push workflow | #git #shipping |
| document-release | Post-ship doc updates | #docs #git |
| setup-browser-cookies | Import browser cookies for auth testing | #browser |
| claude-skills-upgrade | Self-updater | #utility |

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
| Browse binary | `~/.claude/skills/browse/dist/browse` |
| Standards | `~/.claude/standards/common/CODING-STANDARDS.md` |
| Instincts | `~/.claude/skills/claude-skills/instincts/` |

## Communication

- Respond in the **user's language**
- **English** for all asset files (SKILL.md, etc.)
- Always confirm before destructive actions
