# Dependencies -- claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills

## External Dependencies

This project has no package.json, requirements.txt, go.mod, or any package manifest. It is not a traditional software project -- it is a skill pack for the Claude Code agent platform. Dependencies are expressed as:

1. **Runtime requirements** (tools that must be present on the host)
2. **Skill pack dependencies** (other skill collections that provide capabilities)
3. **Platform dependencies** (the Claude Code agent runtime itself)

## Runtime Dependencies
| Dependency | Purpose | Required By |
|-----------|---------|-------------|
| python3 | JSON parsing, YAML frontmatter extraction, pattern matching in hooks | .claude/hooks/load-instincts.sh:16, learn-from-errors.sh:13, secret-scanner.sh:12, code-quality-check.sh:13 |
| bash | All hook scripts execute as bash | .claude/hooks/*.sh (all 8 files start with `#!/bin/bash`) |
| git | Version control, diff scanning for secret scanner, commit validation | .claude/hooks/secret-scanner.sh:32, .claude/hooks/pre-commit-validate.sh:6 |
| date | Timestamp generation for error logging and session summaries | .claude/hooks/learn-from-errors.sh:64-65, session-summary.sh:32 |
| grep | Pattern matching in code quality checks and secret scanning | .claude/hooks/secret-scanner.sh:27, code-quality-check.sh:127 |
| head/wc | File inspection in quality checks | .claude/hooks/code-quality-check.sh:48, learn-from-errors.sh:81 |
| make | Pre-commit validation | .claude/hooks/pre-commit-validate.sh:8 |

## Skill Pack Dependencies
| Pack | Source | Purpose | Referenced At |
|------|--------|---------|---------------|
| gstack | github.com/garrytan/gstack | Provides /browse, /review, /qa, /ship, /investigate, /design-review, /cso, and 20+ other skills | CLAUDE.md:7, install.sh:30-36, README.md:3-6 |
| Figma MCP | Claude AI integration | Required for figma-common-crawler, figma-to-code | figma/figma-common-crawler/SKILL.md:23, figma/figma-to-code/SKILL.md:25 |

## Internal Dependencies (Skill Chaining)

Skills depend on other skills within the same pack. These are not traditional code dependencies -- they are runtime invocation chains where one skill instructs Claude to load and execute another.

| Skill | Depends On | Evidence |
|-------|-----------|----------|
| figma-component-writer | figma-common-crawler, figma-common-diff, figma-common-mapper | figma/figma-component-writer/SKILL.md:43-56 |
| figma-to-code | angular-web-common registry (external repo) | figma/figma-to-code/SKILL.md:27-40 |
| pipeline-build | project-scan, design-doc, write-plan, subagent-dev, review [gstack], verify-complete | workflow/pipeline-build/SKILL.md:36-50 |
| pipeline-figma | figma-to-code, devops-test-gen, qa [gstack], design-review [gstack] | workflow/pipeline-figma/SKILL.md:36-49 |
| brainstorm | write-plan (transitions to it after design approval) | workflow/brainstorm/SKILL.md:45 |
| plan-orchestrator | skill-catalog.md (reads for skill matching) | planning/plan-orchestrator/SKILL.md:41-58 |
| skill-catalog | All SKILL.md files across all sources | utility/skill-catalog/SKILL.md:37-49 |

## Dependency Health
- **Total runtime deps:** 7 (python3, bash, git, date, grep, head, wc, make)
- **Total skill pack deps:** 2 (gstack, Figma MCP)
- **Lock file:** No lock file present (no package manager used)
- **Outdated indicators:** Not applicable -- no versioned package dependencies
