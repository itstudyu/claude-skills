# claude-skills

Claude Code skill collection for development workflow automation.

## Install

```bash
git clone https://github.com/itstudyu/claude-skills
cd claude-skills
./install.sh
```

## Skills

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

### review/ — Code Quality
| Skill | Description |
|-------|-------------|
| `/review` | PR code review (diff-based) |
| `/qa` | Browser QA testing + auto-fix |
| `/qa-only` | QA report only (no fixes) |
| `/cso` | OWASP Top 10 + STRIDE security audit |
| `/devops-japanese-comments` | Japanese comment enforcement |
| `/devops-safety-check` | Lightweight security scan |
| `/devops-test-gen` | Auto-generate tests |

### planning/ — Plan & Review
| Skill | Description |
|-------|-------------|
| `/plan-orchestrator` | Auto-scan skills + build execution plan |
| `/plan-ceo-review` | CEO perspective plan review |
| `/plan-eng-review` | Engineering perspective plan review |
| `/plan-design-review` | Design perspective plan review |
| `/autoplan` | Auto-run all 3 plan reviews |

### figma/ — Figma Automation
| Skill | Description |
|-------|-------------|
| `/figma-component-writer` | Figma → angular-web-common shared components |
| `/figma-to-code` | Figma → Angular page code (with common mapping) |

### design/ — Design System
| Skill | Description |
|-------|-------------|
| `/design-consultation` | Build design system from scratch |
| `/design-review` | Visual design audit + fixes |

### safety/ — Safety Guards
| Skill | Description |
|-------|-------------|
| `/careful` | Warn before destructive commands |
| `/freeze` | Restrict edits to a directory |
| `/guard` | careful + freeze combined |
| `/unfreeze` | Remove freeze restriction |

### analysis/ — Analysis & Monitoring
| Skill | Description |
|-------|-------------|
| `/project-analyzer` | Analyze project structure/framework/conventions |
| `/investigate` | Root cause debugging with browser |
| `/benchmark` | Performance regression detection |
| `/retro` | Weekly engineering retrospective |

### utility/ — Utilities
| Skill | Description |
|-------|-------------|
| `/ship` | Test → PR → push workflow |
| `/document-release` | Post-ship documentation updates |
| `/setup-browser-cookies` | Import cookies for auth testing |
| `/claude-skills-upgrade` | Self-updater |
