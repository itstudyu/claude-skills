# Tech Stack -- claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills

## Core
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | Bash (shell scripts) | N/A | .claude/hooks/*.sh (all 8 hook files) |
| Language | Python 3 (embedded in hooks) | System python3 | .claude/hooks/load-instincts.sh:16, .claude/hooks/learn-from-errors.sh:13 |
| Language | Markdown (skill definitions) | N/A | All SKILL.md files across 5 category directories |
| Framework | Claude Code Skills | 1.0.0 | VERSION:1 |
| Dependency | gstack | External (git-cloned) | CLAUDE.md:7, install.sh:30-36 |

## Infrastructure
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Hook Engine | Claude Code settings.json hooks | N/A | .claude/settings.json:1-50 |
| Installation | Shell symlinks | N/A | install.sh:45-65 |
| Environment | HOOK_PROFILE env var | N/A | .claude/hooks/run-with-profile.sh:7-9 |
| Environment | DISABLED_HOOKS env var | N/A | .claude/hooks/run-with-profile.sh:8 |
| API Key | ANTHROPIC_API_KEY | N/A | .env.example:4 (for LLM-as-judge evals) |

## Dev Tools
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Version Control | Git | System | .gitignore:1-19 |
| Eval Framework | evals.json (custom) | N/A | workflow/brainstorm/evals/evals.json:1 (all skills have evals/) |
| License | MIT | N/A | LICENSE:1 |

## Notes

- This project contains no compiled source code. It is a collection of Markdown skill definitions (SKILL.md files), Bash hook scripts, and JSON configuration. The "tech stack" is the Claude Code agent platform itself.
- Python 3 is used inline within Bash scripts (via `python3 -c "..."`) for JSON parsing and pattern matching in hooks -- not as a standalone application language. Evidence: `.claude/hooks/load-instincts.sh:16`, `.claude/hooks/learn-from-errors.sh:13`, `.claude/hooks/secret-scanner.sh:12`, `.claude/hooks/code-quality-check.sh:13`.
- The project depends on gstack (external skill pack from github.com/garrytan/gstack) for browser-based skills like `/browse`, `/qa`, `/review`, `/ship`. Detected at `CLAUDE.md:7` and `install.sh:30-36`.
