# Audit Report — write-plan

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: workflow/write-plan/SKILL.md (159 lines)

## Frontmatter Excerpt

```yaml
name: write-plan
description: |
  Create comprehensive, step-by-step implementation plans from specs or
  requirements before writing any code. [...]
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
```

## Score

**0.972** (green) — 17 Pass / 1 Warn / 0 Fail / 3 Skip

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 1 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 4 | 0 | 0 | 1 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |
| F — Longevity & Compounding | 4 | 2 | 0 | 0 | 2 |
| E — Online Corroboration | 3 | 2 | 1 | 0 | 0 |

## Per-Item Findings

### Axis A — Frontmatter

- **A1. name format — Pass**: `write-plan` valid.
- **A2. description ≤1024 — Pass**: 608 chars.
- **A3. XML-free — Pass**.
- **A4. allowed-tools hygiene — Warn**
  - Evidence: `SKILL.md:17` lists `Edit` in allowed-tools, but body has
    8 Write verb refs and 0 Edit verb refs. The skill writes plan files with
    Write; never edits existing files.
  - Source: github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
    — principle: only request tools you actually use.
  - Risk: medium
  - **Recommendation:** remove `Edit` from allowed-tools. Re-add if a future
    feature requires updating existing plan files in place (e.g., marking
    task checkboxes post-execution).

### Axis B — Description Quality

- **B1–B4 — Pass** (third-person, KO+JA triggers, proactive phrasing,
  9 distinct quoted triggers).

### Axis C — Body Structure

- **C1. ≤500 lines — Pass**: 159 lines.
- **C2. One-level deep — Pass**: no sibling .md files.
- **C3. TOC — Skip**: no siblings >150 lines (no siblings at all).
- **C4. No time-sensitive — Pass**: no matches.
- **C5. Name consistent — Pass**.

### Axis D — Project Conventions

- **D1. evals.json schema — Pass**: 3 evals, Variant A.
- **D2. skill-catalog.md — Pass**: `skill-catalog.md:13`.
- **D3. CLAUDE.md + README.md — Pass**: `CLAUDE.md:32`, `README.md:19`.
- **D4. HARD-GATE — Skip**: 2 trigger hits (both "verify" in TDD test-run
  steps at `:90, :102`), but context is test-execution, not forensic
  evidence-bearing. Rule does not apply.

### Axis F — Longevity & Compounding

- **F1. Index/schema consistency — Pass**.
- **F2. Append-only archive — Skip**.
- **F3. Anti-pattern section quality — Pass**: `SKILL.md:116-126` "No
  Placeholders" section with 7 explicit prohibitions and reasoning.
- **F4. Schema-lint self-consistency — Skip**: no siblings to lint.

### Axis E — Online Corroboration

- **E1. Rubric freshness — Pass** (delegated).
- **E2. External comparison — Pass**.
- **E3. Similar-skill discovery — Warn**
  - Evidence: `obra/superpowers` framework includes a `/write-plan` command
    with nearly identical shape (bite-sized TDD tasks, zero-context
    assumption, checkbox syntax, commit-at-end step). Trigger overlap ~70%.
  - Differentiator: our version has a stricter "No Placeholders" discipline
    (lines 116-126) and explicit `subagent-dev` handoff in `## Execution
    Handoff` (lines 140-154).
  - Risk: medium
  - **Recommendation:** add a brief "Prior art" note linking to
    obra/superpowers and clarifying the project's differentiators.

## Top-3 Upgrade Recommendations

1. **A4 — prune unused `Edit`** (medium risk) — single line in frontmatter.
2. **E3 — attribution + differentiator block** (advisory).
3. (no further findings)

## Next Steps

> "Upgrade write-plan"
