# Skill Overlap Matrix

## Overlapping Skills (6 pairs)

| # | claude-skills skill | superpowers skill | Similarity | Notes |
|---|-------------------|------------------|-----------|-------|
| 1 | `brainstorm` | `brainstorming` | ~90% identical | claude-skills adds KR/JP trigger words, saves to generic specs dir vs superpowers-specific path |
| 2 | `write-plan` | `writing-plans` | ~90% identical | Same bite-sized task approach, same zero-context principle |
| 3 | `subagent-dev` | `subagent-driven-development` | ~90% identical | Same two-stage review (spec + quality), claude-skills adds parallel dispatch |
| 4 | `tdd` | `test-driven-development` | ~85% identical | Same RED-GREEN-REFACTOR cycle |
| 5 | `verify-complete` | `verification-before-completion` | ~85% identical | Same evidence-before-assertions pattern |
| 6 | (via gstack `review`) | `requesting-code-review` | ~70% similar | Different scope: gstack is PR-level, superpowers is per-step |

## claude-skills unique skills (13)

| Skill | Category | Purpose |
|-------|----------|---------|
| `plan-orchestrator` | planning | Auto-scan all skills, match to task, build execution plan |
| `design-doc` | workflow | Per-feature design document with fixed template |
| `pipeline-build` | workflow | End-to-end: scan -> design -> plan -> build -> review -> verify |
| `pipeline-figma` | workflow | Figma -> code -> tests -> QA -> design-review |
| `pipeline-debug` | workflow | Bug fix: investigate -> TDD -> review -> verify |
| `pipeline-full` | workflow | Full lifecycle: idea -> design -> plan -> build -> ship |
| `pipeline-idea` | workflow | Idea to plan: office-hours -> brainstorm -> design-doc -> write-plan |
| `pipeline-onboard` | workflow | Project onboarding: scan -> design-doc (all features) -> catalog |
| `pipeline-quality` | workflow | Pre-commit: tests -> japanese-comments -> review -> security |
| `figma-component-writer` | figma | Orchestrate Figma -> angular-web-common sync |
| `figma-to-code` | figma | Figma URL -> Angular production code |
| `figma-common-crawler` | figma | Crawl Figma component styles |
| `figma-common-diff` | figma | Compare crawled vs existing components |
| `figma-common-mapper` | figma | Preview mapping + user confirmation |
| `devops-japanese-comments` | review | Japanese comment enforcement |
| `devops-test-gen` | review | Auto-generate tests for changed code |
| `project-scan` | utility | Codebase structure analysis |
| `skill-catalog` | utility | Multi-source skill registry management |

## superpowers unique skills (8)

| Skill | Purpose |
|-------|---------|
| `systematic-debugging` | 4-phase root cause investigation (Iron Law: no fixes without root cause) |
| `using-git-worktrees` | Parallel development on isolated branches |
| `finishing-a-development-branch` | Merge/PR/keep/discard decision after task completion |
| `dispatching-parallel-agents` | Concurrent subagent coordination |
| `executing-plans` | Batch execution with human checkpoints |
| `receiving-code-review` | Responding to review feedback |
| `writing-skills` | Meta-skill for authoring new skills with best practices |
| `using-superpowers` | Bootstrap skill loaded at session start |
