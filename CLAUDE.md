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

## Skill Index (Tier 1 — lightweight, always loaded)

| Skill | Description | Tags |
|-------|-------------|------|
| brainstorm | Socratic design, 3 options before implementation | #design #planning |
| write-plan | Bite-sized 2-5min tasks, zero-context assumption | #planning #tasks |
| execute-plan | Sequential execution with human checkpoints | #execution |
| subagent-dev | Fresh subagent per task, two-stage review | #execution #parallel |
| tdd | RED-GREEN-REFACTOR, no code without failing test | #testing #quality |
| systematic-debug | 4-phase root cause investigation | #debugging |
| verify-complete | Evidence-based verification gate | #verification #quality |
| project-analyzer | Analyze project structure/framework/conventions | #analysis #onboarding |
| plan-orchestrator | Auto-scan skills, build execution plan | #planning #orchestration |
| review | PR code review (diff-based) | #review #quality |
| qa | Browser QA testing + fixes | #testing #browser |
| qa-only | QA report only (no fixes) | #testing #browser |
| investigate | Root cause debugging with browse | #debugging #browser |
| cso | OWASP Top 10 + STRIDE security audit | #security |
| ship | Test → PR → push workflow | #git #shipping |
| plan-ceo-review | CEO perspective plan review | #review #planning |
| plan-eng-review | Engineering perspective plan review | #review #planning |
| plan-design-review | Design perspective plan review | #review #design |
| autoplan | Auto-run CEO + design + eng reviews | #review #planning |
| design-consultation | Build design system from scratch | #design |
| design-review | Visual design audit + fixes | #design #browser |
| document-release | Post-ship doc updates | #docs #git |
| retro | Weekly engineering retrospective | #analysis #team |
| benchmark | Performance regression detection | #performance #browser |
| setup-browser-cookies | Import browser cookies for auth testing | #browser #setup |
| careful | Warn before destructive commands | #safety |
| freeze | Restrict edits to a directory | #safety |
| guard | careful + freeze combined | #safety |
| unfreeze | Remove freeze restriction | #safety |
| claude-skills-upgrade | Self-updater | #utility |
| figma-common-crawler | Crawl Figma URL for component styles | #figma #components |
| figma-common-diff | Compare crawled vs existing components | #figma #components |
| figma-common-mapper | Preview mapping + user confirmation | #figma #components |
| figma-component-writer | Orchestrate: Figma → angular-web-common | #figma #components #agent |
| figma-to-code | Figma URL → Angular code with common mapping | #figma #code-gen #agent |

## Commands

```bash
bun install          # install dependencies
bun test             # run tests
bun run build        # gen docs + compile binaries
./setup              # one-time setup: build + symlink skills
```

## Coding Conventions

- **Comments:** Japanese (日本語)
- **Commit messages:** Japanese, 1-4 lines
- **Framework default:** Angular (standalone components, OnPush, SCSS)
- **File header:** first line = one-line English summary comment

## Communication

- Respond in the **user's language**
- Always confirm before destructive actions
- Always ask when requirements are unclear
