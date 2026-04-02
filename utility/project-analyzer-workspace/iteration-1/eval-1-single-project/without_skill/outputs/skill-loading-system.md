# Skill Loading System Analysis

> Analysis of claude-skills project at /Users/yu_s/Documents/GitHub/claude-skills
> Analyzed: 2026-04-02

## How Skills Are Discovered and Loaded

The claude-skills project uses a **SKILL.md convention** for skill discovery. A "skill" is
any directory containing a `SKILL.md` file. The loading system works in three layers:

### Layer 1: File System Convention

Each skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: |
  Multi-line description including trigger phrases in multiple languages.
  This description is what Claude Code uses for skill matching.
allowed-tools:
  - Bash
  - Read
  - Write
  # etc.
---
```

The rest of the file is Markdown instructions that Claude Code injects into its
context when the skill is invoked (e.g., via `/skill-name`).

**Key fields:**
- `name` -- the slash-command name (e.g., `brainstorm` becomes `/brainstorm`)
- `description` -- contains trigger phrases for auto-detection AND human-readable summary
- `allowed-tools` -- restricts which tools the skill can use (security boundary)

### Layer 2: Installation via Symlinks

The `install.sh` script (lines 49-65) creates **symlinks** from the project's
categorized directory structure into `~/.claude/skills/`:

```
Source:  claude-skills/workflow/brainstorm/SKILL.md
Symlink: ~/.claude/skills/brainstorm -> claude-skills/workflow/brainstorm/
```

This flattens the nested category structure into a flat namespace that Claude Code
can discover. The installer iterates over five category directories:
`workflow`, `review`, `planning`, `figma`, `utility`.

For each directory, it finds subdirectories containing `SKILL.md` and creates a
symlink in `~/.claude/skills/`.

### Layer 3: Skill Catalog (skill-catalog.md)

The `skill-catalog.md` file is a **generated registry** that aggregates skills from
ALL sources (gstack, claude-skills, custom packs). It is NOT the loading mechanism
itself -- it is a token-efficient index used by `plan-orchestrator` for skill matching.

**How it works:**
1. `/skill-catalog scan` reads all `~/.claude/skills/` directories
2. Groups skills by source (following symlinks to determine origin)
3. Parses SKILL.md frontmatter for name, description, tags
4. Writes a single Markdown table per source

**Token efficiency:** The catalog costs ~500 tokens for 30 skills vs reading 30 individual
SKILL.md files which would cost ~15,000+ tokens.

## Two-Tier Skill Loading (plan-orchestrator)

The `plan-orchestrator` skill implements a deliberate two-tier loading strategy:

- **Tier 1 (always loaded):** `skill-catalog.md` -- one line per skill with name,
  path, description, tags. Used for initial filtering.
- **Tier 2 (on demand):** Individual `SKILL.md` files -- full instructions read only
  for skills that matched in Tier 1. Typically 5-7 skills per plan.

This is a context-window optimization. Loading all 40+ skills at once would consume
a large portion of the context window.

## Relationship to gstack

gstack is a separate project (github.com/garrytan/gstack) that provides general-purpose
skills (browse, review, qa, ship, security, etc.). It installs to `~/.claude/skills/gstack/`
and uses the same SKILL.md convention.

The `setup` script in gstack (which lives at the claude-skills repo root for reference)
handles:
1. Building a headless browser binary (Playwright-based)
2. Symlinking gstack skill directories into `~/.claude/skills/`
3. Supporting multiple hosts: Claude Code, Codex, and Kiro

gstack skills are referenced by `[gstack]` source attribution in the skill catalog.
claude-skills skills are referenced by `[claude-skills]`.
