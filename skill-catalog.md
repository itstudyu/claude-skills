# Skill Catalog
<!-- Manual registry for claude-skills -->

## claude-skills (source: ./)

| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| design-doc | workflow/design-doc/ | Generate per-feature design document with fixed template | #docs #design |
| prompt-to-plan | workflow/prompt-to-plan/ | Refine rough prompts into structured specs, enter Plan Mode, create implementation plans | #prompt #planning #refinement |
| subagent-dev | workflow/subagent-dev/ | Dispatch fresh subagents per task with two-stage review | #execution #parallel |
| workflow-blueprint | workflow/workflow-blueprint/ | Deep workflow trace with Mermaid sequence diagrams (entry → service → DB) | #analysis #workflow #diagrams |
| workflow-blueprint-update | workflow/workflow-blueprint-update/ | Incremental workflow doc update via git diff | #analysis #workflow #update |
| write-plan | workflow/write-plan/ | Create implementation plans from specs before touching code | #planning |
| devops-japanese-comments | review/devops-japanese-comments/ | Enforce Japanese language in code comments and log messages | #quality #i18n |
| project-analyzer | utility/project-analyzer/ | Deep fact-based 6-axis analysis (tech/features/data/patterns/deps/architecture) with file/line evidence | #analysis #deep |
| skill-auditor | utility/skill-auditor/ | Audit this repo's skills against Anthropic best-practices + project conventions; propose upgrade diffs for review | #audit #quality #meta |
