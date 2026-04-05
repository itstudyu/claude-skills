# Dependencies — claude-skills

> Analyzed on 2026-04-02

## Production Dependencies

This project has no package.json and no formal dependency manifest. Dependencies are runtime requirements documented in code:

| Dependency | Type | Purpose | Used In |
|-----------|------|---------|---------|
| gstack | Skill pack (external) | General-purpose skills (browse, review, QA, ship, security) | CLAUDE.md:7, install.sh:30-36 |
| Claude Code | Runtime platform | Hooks system, Skill tool, Agent tool | .claude/settings.json:1 |
| python3 | System binary | JSON parsing in hooks, code-quality analysis, instincts extraction | .claude/hooks/code-quality-check.sh:13, .claude/hooks/secret-scanner.sh:13, .claude/hooks/learn-from-errors.sh:13, .claude/hooks/load-instincts.sh:16 |
| bash | System binary | All hook scripts | .claude/hooks/*.sh |
| git | System binary | Used in secret-scanner for staged diff | .claude/hooks/secret-scanner.sh:32 |
| Figma MCP | External service | Required for figma-component-writer and figma-to-code | figma/figma-component-writer/SKILL.md:26 |
| angular-web-common | External repo | Target repo for Figma component generation | figma/figma-component-writer/SKILL.md:27 |
| Anthropic API | External API | LLM-as-judge evals | .env.example:5 |

## Dev Dependencies

| Dependency | Type | Purpose |
|-----------|------|---------|
| bun | Runtime (implied) | Auto-loads .env, eval runner | .env.example:2, .gitignore:16 |

## Dependency Health
- **Total production deps:** 0 (no package manifest)
- **Total dev deps:** 0
- **Lock file:** Not present (no package manager used for core project)
- **Outdated indicators:** N/A — project relies on system tools and external skill packs

## Internal Dependencies
| Skill Category | Path | Depends On |
|---------------|------|-----------|
| workflow/brainstorm | workflow/brainstorm/ | write-plan (chains to next) — SKILL.md:77 |
| workflow/write-plan | workflow/write-plan/ | subagent-dev or execute-plan — SKILL.md:147-148 |
| workflow/subagent-dev | workflow/subagent-dev/ | write-plan (input), tdd, verify-complete — SKILL.md:362-366 |
| workflow/pipeline-build | workflow/pipeline-build/ | project-scan, design-doc, write-plan, subagent-dev, review [gstack], verify-complete — SKILL.md:3-6 |
| planning/plan-orchestrator | planning/plan-orchestrator/ | skill-catalog.md (Tier 1 loading) — SKILL.md:39 |
| figma/figma-component-writer | figma/figma-component-writer/ | figma-common-crawler, figma-common-diff, figma-common-mapper — SKILL.md:15 |
