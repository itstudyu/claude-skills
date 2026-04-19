# Audit Report — write-plan

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: workflow/write-plan/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: write-plan
description: |
  Create comprehensive, step-by-step implementation plans from specs or requirements
  before writing any code. Plans include exact file paths, complete code blocks, test
  commands, and verification steps — no placeholders, no hand-waving. Use this skill
  whenever the user says "write a plan", "make a plan", "create implementation plan",
  "plan this out", "break this into tasks", "プラン作成", "計画を書いて", "플랜 작성해줘",
  "구현 계획 세워줘", or before any implementation that involves more than a single file
  change. Proactively suggest this skill when a spec is ready — implementation
  without a plan leads to rework.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
---
```

## Score

**1.00** (green) — 15 Pass / 0 Warn / 0 Fail / 2 Skip

- Description length: 598 chars
- SKILL.md line count: 160

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 4 | 0 | 0 | 1 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: write-plan`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-11` ~598 chars
- **A3** XML-tag-free — **Pass** — no `<[A-Za-z/]` in description block
- **A4** allowed-tools hygiene — **Pass** — `SKILL.md:156` Write referenced in "Save Location"; Edit used for plan-update steps

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:4` "Create comprehensive, step-by-step…" (imperative, third-person)
- **B2** multilingual — **Pass** — `SKILL.md:8` Hangul "플랜 작성해줘" + Japanese "プラン作成 / 計画を書いて"
- **B3** proactive phrasing — **Pass** — `SKILL.md:6` "Use this skill whenever" + `SKILL.md:10` "Proactively suggest"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:7-9` 9 quoted triggers (EN/KO/JA)

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:160` lines
- **C2** reference depth = 1 — **Pass** — no sibling markdown files exist
- **C3** TOC for long siblings — **Skip** — no siblings
- **C4** no time-sensitive content — **Pass** — no matches for trigger phrases
- **C5** name consistent — **Pass** — `CLAUDE.md:15` `/write-plan` matches

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:1-23` 3 evals, consistent Variant A
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:13`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:32`, `README.md:19`
- **D4** HARD-GATE conditional — **Skip** — only 'verify' keyword present (<2 distinct of required set)

## Top-3 Upgrade Recommendations

No upgrades required — all scored items Pass.

## Next Steps

Skill is fully compliant. No UPGRADE invocation needed.
