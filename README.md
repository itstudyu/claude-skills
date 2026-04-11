# claude-skills

Project-specific Claude Code skills for workflow, Figma automation, and DevOps review.

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
| `/prompt-to-plan` | Refine rough prompts, then build an implementation plan |
| `/write-plan` | Bite-sized 2-5min task planning |
| `/design-doc` | Generate per-feature design document with fixed template |
| `/subagent-dev` | Fresh subagent per task + two-stage review |
| `/tdd` | Test-driven development (RED-GREEN-REFACTOR) |
| `/verify-complete` | Evidence-based verification gate |
| `/workflow-blueprint` | Deep workflow trace with Mermaid sequence diagrams |
| `/workflow-blueprint-update` | Incremental workflow doc update via git diff |

### review/ — DevOps Quality
| Skill | Description |
|-------|-------------|
| `/devops-japanese-comments` | Japanese comment enforcement |
| `/devops-test-gen` | Auto-generate tests |

### figma/ — Figma Automation
| Skill | Description |
|-------|-------------|
| `/figma-component-writer` | Orchestrate Figma → angular-web-common |
| `/figma-to-code` | Figma URL → Angular code |

### utility/
| Skill | Description |
|-------|-------------|
| `/project-analyzer` | Deep 6-axis codebase analysis |
| `/project-scan` | Fast codebase overview for onboarding |
| `/fork-sync` | Sync forked GitHub repo with upstream |
