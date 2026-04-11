# Skill Catalog
<!-- Manual registry for claude-skills -->

## claude-skills (source: ./)

| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| design-doc | workflow/design-doc/ | Generate per-feature design document with fixed template | #docs #design |
| prompt-to-plan | workflow/prompt-to-plan/ | Refine rough prompts into structured specs, enter Plan Mode, create implementation plans | #prompt #planning #refinement |
| subagent-dev | workflow/subagent-dev/ | Dispatch fresh subagents per task with two-stage review | #execution #parallel |
| tdd | workflow/tdd/ | Test-Driven Development — RED-GREEN-REFACTOR cycle | #testing #quality |
| verify-complete | workflow/verify-complete/ | Evidence-based verification gate — run commands, confirm output | #verification |
| workflow-blueprint | workflow/workflow-blueprint/ | Deep workflow trace with Mermaid sequence diagrams (entry → service → DB) | #analysis #workflow #diagrams |
| workflow-blueprint-update | workflow/workflow-blueprint-update/ | Incremental workflow doc update via git diff | #analysis #workflow #update |
| write-plan | workflow/write-plan/ | Create implementation plans from specs before touching code | #planning |
| figma-component-writer | figma/figma-component-writer/ | Orchestrate Figma → angular-web-common component sync (crawl/diff/mapper are internal resources) | #figma #agent |
| figma-to-code | figma/figma-to-code/ | Figma URL → Angular production code with common component mapping | #figma #agent |
| devops-japanese-comments | review/devops-japanese-comments/ | Enforce Japanese language in code comments and log messages | #quality #i18n |
| devops-test-gen | review/devops-test-gen/ | Auto-generate tests for new/changed code with regression protection | #testing |
| fork-sync | utility/fork-sync/ | Sync a forked GitHub repo with upstream — fetch, fast-forward/merge, push | #git #fork #utility |
| project-analyzer | utility/project-analyzer/ | Deep fact-based 6-axis analysis (tech/features/data/patterns/deps/architecture) with file/line evidence | #analysis #deep |
| project-scan | utility/project-scan/ | Fast project overview + onboarding doc — structure, tech stack, features | #analysis #onboarding |
