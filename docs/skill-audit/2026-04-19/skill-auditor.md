# Audit Report — skill-auditor

> Generated 2026-04-19 by `skill-auditor` (self-audit).
> Rubric version: 1.0.0 (2026-04-19)
> Source: utility/skill-auditor/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: skill-auditor
description: |
  Audit existing Claude Code skills in this repo against Anthropic's official
  skill-authoring best-practices and this project's own conventions, then
  propose upgrade diffs for review. Two modes: AUDIT (read-only scoring with
  file:line evidence) and UPGRADE (per-item approved edits). Use this skill
  whenever the user says "audit my skills", "audit skill X", "check skill
  compliance", "review all skills", "스킬 검수", "스킬 감사", "스킬 업그레이드",
  "스킬 체크", "スキル監査", "スキル検査", "スキル改善", or when reviewing
  SKILL.md files for frontmatter/structure/convention compliance.
  Proactively suggest this skill after any new skill is created or after
  editing an existing SKILL.md — stale or non-conformant skills drift
  silently and degrade Claude's trigger accuracy.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
---
```

## Score

**1.00** (green) — 17 Pass / 0 Warn / 0 Fail / 0 Skip

- Description length: 737 chars
- SKILL.md line count: 273

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: skill-auditor`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-14` 737 chars
- **A3** XML-tag-free — **Pass** — no `<[A-Za-z/]` in description YAML value (HARD-GATE at `SKILL.md:29` is in body, not description)
- **A4** allowed-tools hygiene — **Pass** — `SKILL.md:19-20` declares Write/Edit; body uses Write at `SKILL.md:170` ("3. Write INDEX.md") and Edit at `SKILL.md:257` ("All edits via Edit tool")

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:4` first 40 chars = "Audit existing Claude Code skills in thi"
- **B2** multilingual — **Pass** — `SKILL.md:9-10` Hangul ('스킬 검수') + Katakana ('スキル監査')
- **B3** proactive phrasing — **Pass** — `SKILL.md:8` "Use this skill whenever" + `SKILL.md:12` "Proactively suggest this skill"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:8-11` 11 quoted trigger strings

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:273` lines
- **C2** reference depth = 1 — **Pass** — `upgrade-playbook.md:369-420` sibling-like links appear only inside markdown code fences (example BEFORE/AFTER snippets), not real references
- **C3** TOC for long siblings — **Pass** — `rubric.md:10-18` TOC (280-line file); `upgrade-playbook.md:8-14` TOC (713-line file); `audit-report-template.md` is 101 lines (not subject)
- **C4** no time-sensitive content — **Pass** — `SKILL.md:161` "today's date" and `SKILL.md:192` "Latest AUDIT is N days old" are operational phrasing, not time-anchored claims
- **C5** name consistent — **Pass** — `README.md:34` / `CLAUDE.md:21` `/skill-auditor` matches frontmatter `name`

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:3-22` 3 evals all using consistent `{id, prompt, expected_output, files}` variant
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:16`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:47` and `README.md:34`
- **D4** HARD-GATE — **Pass** — `SKILL.md:29-33` HARD-GATE is conditional ("Every Pass/Warn/Fail verdict must cite file:line evidence"; "If a check cannot be verified, mark it SKIP")

## Top-3 Upgrade Recommendations

No actionable findings — skill passes all rubric checks.

## Next Steps

No action needed.
