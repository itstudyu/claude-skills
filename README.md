# claude-skills

Project-specific Claude Code skills for workflow, Figma automation, and DevOps review.

General-purpose skills (browse, review, QA, ship, security, etc.) are provided by
[gstack](https://github.com/garrytan/gstack) — installed separately.

## Prerequisites

```bash
# Install gstack (general-purpose skills)
git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

## Install

```bash
git clone https://github.com/itstudyu/claude-skills
cd claude-skills
./install.sh
```

After install, run `/skill-catalog scan` to generate the unified skill catalog.

## Skills (16 project-specific)

### workflow/ — Development Workflow
| Skill | Description |
|-------|-------------|
| `/brainstorm` | Socratic design exploration, 3 options before implementation |
| `/write-plan` | Bite-sized 2-5min task planning |
| `/execute-plan` | Sequential execution with human checkpoints |
| `/subagent-dev` | Fresh subagent per task + two-stage review |
| `/tdd` | Test-driven development (RED-GREEN-REFACTOR) |
| `/systematic-debug` | 4-phase root cause investigation |
| `/verify-complete` | Evidence-based verification gate |

### review/ — DevOps Quality
| Skill | Description |
|-------|-------------|
| `/devops-japanese-comments` | Japanese comment enforcement |
| `/devops-safety-check` | Lightweight security scan |
| `/devops-test-gen` | Auto-generate tests |

### planning/ — Orchestration
| Skill | Description |
|-------|-------------|
| `/plan-orchestrator` | Auto-scan skills from all sources + build execution plan |

### figma/ — Figma Automation
| Skill | Description |
|-------|-------------|
| `/figma-component-writer` | Figma → angular-web-common shared components |
| `/figma-to-code` | Figma → Angular page code (with common mapping) |

### utility/ — Catalog Management
| Skill | Description |
|-------|-------------|
| `/skill-catalog` | Scan and manage skills from multiple sources |

## Skill Catalog

`skill-catalog.md` is the unified registry of ALL skills from ALL sources.
`/plan-orchestrator` reads this file for skill matching.

```bash
/skill-catalog scan      # Regenerate catalog from all sources
/skill-catalog list      # Show summary
/skill-catalog add       # Register a new skill pack
```
