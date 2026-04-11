# claude-skills

> Project-specific Claude Code skills. Workflow, Figma automation, and DevOps review.

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
    ├→ Rough prompt + "refine and plan" / "정리해서 플랜" / "整理してプラン"
    │   → /prompt-to-plan
    │
    ├→ "write a plan" / "플랜 작성" / "計画を書いて"
    │   → /write-plan
    │
    ├→ Workflow analysis ("trace flow", "sequence diagram", "워크플로우 분석")
    │   → /workflow-blueprint (initial) or /workflow-blueprint-update (refresh)
    │
    └→ Other → direct /skill-name
```

## Project Skills (claude-skills)

### workflow/
| Skill | Description | Tags |
|-------|-------------|------|
| prompt-to-plan | Refine rough prompts, enter Plan Mode, build implementation plan | #prompt #planning |
| write-plan | Bite-sized 2-5min tasks, zero-context assumption | #planning #tasks |
| design-doc | Generate per-feature design document with fixed template | #docs #design |
| subagent-dev | Fresh subagent per task, two-stage review | #execution #parallel |
| tdd | RED-GREEN-REFACTOR, no code without failing test | #testing #quality |
| verify-complete | Evidence-based verification gate | #verification |
| workflow-blueprint | Deep workflow trace with Mermaid sequence diagrams | #analysis #workflow #diagrams |
| workflow-blueprint-update | Incremental workflow doc update via git diff | #analysis #workflow #update |

### review/
| Skill | Description | Tags |
|-------|-------------|------|
| devops-japanese-comments | Japanese comment enforcement | #quality #i18n |
| devops-test-gen | Auto-generate tests for changed code | #testing |

### figma/
| Skill | Description | Tags |
|-------|-------------|------|
| figma-component-writer | Orchestrate: Figma → angular-web-common | #figma #agent |
| figma-to-code | Figma URL → Angular code with common mapping | #figma #agent |

### utility/
| Skill | Description | Tags |
|-------|-------------|------|
| project-analyzer | Deep 6-axis codebase analysis | #analysis |
| project-scan | Scan codebase — tech stack, features, data model, patterns | #analysis #onboarding |
| fork-sync | Sync forked GitHub repo with upstream (fetch → merge → push) | #git #fork |

---

## Behavioral Modes (Auto-Detection)

| Mode | Auto-Detection | Behavior |
|------|---------------|----------|
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
| Standards | `./standards/common/CODING-STANDARDS.md` |
| Instincts | `./instincts/` |

## Communication

- Respond in the **user's language**
- **English** for all asset files (SKILL.md, etc.)
- Always confirm before destructive actions
