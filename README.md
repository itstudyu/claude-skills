# claude-skills

Project-specific Claude Code skills for planning, workflow analysis, and code quality.

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
| `/workflow-blueprint` | Deep workflow trace with Mermaid sequence diagrams |
| `/workflow-blueprint-update` | Incremental workflow doc update via git diff |

### review/ — DevOps Quality
| Skill | Description |
|-------|-------------|
| `/devops-japanese-comments` | Japanese comment enforcement |

### utility/
| Skill | Description |
|-------|-------------|
| `/project-analyzer` | Deep 6-axis codebase analysis |
| `/skill-auditor` | Audit skills, propose upgrade diffs for review |
