# Audit Report — project-analyzer

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: utility/project-analyzer/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: project-analyzer
description: |
  Deep fact-based 6-axis analysis of one or more codebases — tech stack, features,
  data model, code patterns, dependencies, and architecture. Every claim traces back
  to a file/line. Supports cross-project comparison. Use this skill whenever the user
  says "deep project analysis", "project analysis", "analyze projects", "compare
  projects", "deep dive into this codebase", "tell me exactly what this project does",
  "프로젝트 깊이 분석", "코드베이스 깊이 분석", "프로젝트 비교", "프로젝트 상세 분석",
  "プロジェクト詳細分析", "コードベース詳細分析", "プロジェクト比較". Proactively suggest
  when the user asks questions about project internals that require reading actual
  source code.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---
```

## Score

**0.97** (green) — 15 Pass / 1 Warn / 0 Fail / 1 Skip

- Description length: 740 chars
- SKILL.md line count: 493

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 3 | 1 | 0 | 1 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: project-analyzer`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-12` ~740 chars
- **A3** XML-tag-free — **Pass** — no `<Tag` patterns in description (HARD-GATE is in body, not description)
- **A4** allowed-tools hygiene — **Pass** — `SKILL.md:13-19` lists Bash/Write; body references bash block (`SKILL.md:46-54`) and Write/save steps (`SKILL.md:81-101, 395-405`)

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:4` "Deep fact-based 6-axis analysis of one..."
- **B2** multilingual — **Pass** — `SKILL.md:9-10` Hangul (프로젝트) + Katakana (プロジェクト)
- **B3** proactive phrasing — **Pass** — `SKILL.md:6` "Use this skill whenever" + `SKILL.md:10` "Proactively suggest"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:6-10` 13 quoted trigger phrases (EN/KO/JA)

### Axis C — Body Structure

- **C1** ≤500 lines — **Warn** — `SKILL.md:493` lines (warn band 451–500). **Recommendation:** extract per-axis output-format code blocks into `resources/templates/*.md` and reference them, targeting <450 lines.
- **C2** reference depth = 1 — **Pass** — `SKILL.md:355,375,385-387` sibling-like links appear only inside example ```markdown code blocks, not as real sibling refs
- **C3** TOC for long siblings — **Skip** — no documentation siblings >150 lines
- **C4** no time-sensitive content — **Pass** — no matches
- **C5** name consistent — **Pass** — no slash-command invocations in body

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:3-22` 3 evals, consistent Variant A
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:15`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:46`, `README.md:33`
- **D4** HARD-GATE — **Pass** — `SKILL.md:27-31` HARD-GATE present; `SKILL.md:25` "never guess"; `SKILL.md:449` "Do not speculate"; body uses evidence/trace/verify/file:line (≥2)

## Top-3 Upgrade Recommendations

1. **C1** (high) — SKILL.md is 493 lines (warn band 451–500). Extract per-axis output-format templates into `resources/templates/*.md` to drop under 450. → See `upgrade-playbook.md#C1`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade project-analyzer"
