# Tech Stack — claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills

## Core
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | Bash (shell scripts) | N/A | .claude/hooks/*.sh (all 8 scripts) |
| Language | Python 3 (embedded in hooks) | system | .claude/hooks/code-quality-check.sh:13 |
| Language | Markdown (skills content) | N/A | workflow/*/SKILL.md, figma/*/SKILL.md |
| Framework | Claude Code Skills System | N/A | CLAUDE.md:1 |
| Runtime dependency | gstack | N/A | CLAUDE.md:7, install.sh:30 |

## Infrastructure
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Hook System | Claude Code hooks (settings.json) | N/A | .claude/settings.json:2 |
| Hook Profile | HOOK_PROFILE env var | N/A | .claude/hooks/run-with-profile.sh:7-8 |
| Version Tracking | VERSION file (semver) | 1.0.0 | VERSION:1 |
| Environment Config | .env (bun auto-loads) | N/A | .env.example:2 |
| Eval API | Anthropic API (ANTHROPIC_API_KEY) | N/A | .env.example:5 |

## Dev Tools
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Installer | Bash install.sh (symlink-based) | N/A | install.sh:1-90 |
| Code Quality | code-quality-check.sh (PostToolUse hook) | N/A | .claude/hooks/code-quality-check.sh:1-172 |
| Secret Scanner | secret-scanner.sh (PreToolUse hook) | N/A | .claude/hooks/secret-scanner.sh:1-74 |
| Error Learning | learn-from-errors.sh (PostToolUse hook) | N/A | .claude/hooks/learn-from-errors.sh:1-198 |
| Instincts Loader | load-instincts.sh (SessionStart hook) | N/A | .claude/hooks/load-instincts.sh:1-82 |
| CI/CD | Not detected | N/A | N/A |
| Linting | Custom code-quality-check.sh (file header, function length, debug output, TODOs) | N/A | .claude/hooks/code-quality-check.sh:46-156 |
