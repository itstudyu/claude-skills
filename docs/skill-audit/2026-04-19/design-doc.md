# Audit Report — design-doc

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: workflow/design-doc/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: design-doc
description: |
  Generate a structured design document for a specific feature by analyzing the existing
  code, database schema, API endpoints, and UI components related to that feature. Each
  feature gets its own file in docs/specs/ using a fixed template. The document serves
  as a reference for both humans and AI to understand how the feature works — what tables
  it uses, what APIs it calls, what business rules it follows, and what screens it has.
  Use this skill whenever the user says "create design doc", "write spec for this feature",
  "document this feature", "설계서 만들어", "설계서 작성", "기능 문서화", "이 기능 정리해줘",
  "設計書作成", "機能ドキュメント". Proactively suggest this skill when the user is about
  to modify a feature that has no design doc yet.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
---
```

## Score

**1.00** (green) — 16 Pass / 0 Warn / 0 Fail / 1 Skip

- Description length: 728 chars
- SKILL.md line count: 168

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: design-doc`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-12` ~728 chars
- **A3** XML-tag-free — **Pass** — no XML tags in description
- **A4** allowed-tools hygiene — **Pass** — `SKILL.md:13-19, 87, 149-150` Write/Edit declared and body-referenced ("Save the file", "Write to docs/specs/")

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:4` "Generate a structured design document for..." (no banned prefix)
- **B2** multilingual — **Pass** — `SKILL.md:10-11` Hangul (설계서 만들어) + Katakana (ドキュメント)
- **B3** proactive phrasing — **Pass** — `SKILL.md:9,11` "Use this skill whenever" + "Proactively suggest this skill when"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:9-11` 9 distinct quoted trigger phrases (EN/KO/JA)

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:168` lines
- **C2** reference depth = 1 — **Pass** — only SKILL.md exists, no siblings
- **C3** TOC for long siblings — **Pass** — no siblings >150 lines
- **C4** no time-sensitive content — **Pass** — no matches
- **C5** name consistent — **Pass** — `SKILL.md:2` vs `README.md:20` `/design-doc`

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:3-22` 3 evals, consistent variant
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:8`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:33`, `README.md:20`
- **D4** HARD-GATE conditional — **Skip** — 0 of 6 keywords (<2 required)

## Top-3 Upgrade Recommendations

No upgrades required — all scored items Pass.

## Next Steps

Skill is fully compliant. No UPGRADE invocation needed.
