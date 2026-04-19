# Audit Report — devops-japanese-comments

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: review/devops-japanese-comments/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: devops-japanese-comments
description: |
  Enforce Japanese language in all code comments, log messages, JSDoc/docstrings, and
  TODO/FIXME annotations. Converts English comments to Japanese and adds missing comments
  to complex logic blocks. Use this skill after writing or reviewing code in any language.
  Trigger whenever the user says "日本語コメント", "japanese comments", "コメント変換",
  "コメントを日本語に", "add japanese comments", "translate comments to japanese",
  "코멘트 일본어로", "코멘트 일본어로 변환", "일본어 코멘트", or as part of any code
  quality workflow. Proactively suggest this skill after any code writing session
  where comments are in English or missing — the team convention requires all comments
  and logs to be in Japanese.
allowed-tools:
  - Read
  - Edit
  - Grep
  - Glob
---
```

## Score

**0.97** (green) — 15 Pass / 1 Warn / 0 Fail / 1 Skip

- Description length: 706 chars
- SKILL.md line count: 122

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 1 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: devops-japanese-comments`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-12` ~706 chars
- **A3** XML-tag-free — **Pass** — no HTML-like tags in description
- **A4** allowed-tools hygiene — **Warn** — `SKILL.md:13-17` lists Read/Edit/Grep/Glob, but `SKILL.md:96` references `git diff HEAD --name-only` implying Bash (not in allowed-tools). **Recommendation:** add Bash to allowed-tools, OR rewrite step 1 to use Glob-based discovery, OR note that the user runs git diff.

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:20-23` opens with "Japanese Comments Enforcement" / "Convert all code comments..." (no banned prefix)
- **B2** multilingual — **Pass** — `SKILL.md:7-9` Hangul (코멘트 일본어로) + Hiragana/Katakana (日本語コメント)
- **B3** proactive phrasing — **Pass** — `SKILL.md:7` "Trigger whenever the user says" + `SKILL.md:10` "Proactively suggest this skill"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:7-9` ≥3 quoted trigger strings

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:1-122` 122 lines
- **C2** reference depth = 1 — **Pass** — no cross-skill links
- **C3** TOC for long siblings — **Pass** — 122 lines, TOC not required (<150)
- **C4** no time-sensitive content — **Pass** — no temporal phrases
- **C5** name consistent — **Pass** — `README.md:28` `/devops-japanese-comments` matches

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:3-22` 3 evals with consistent schema (exactly at minimum threshold)
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:14`
- **D3** CLAUDE.md + README.md — **Pass** — both under `### review/`
- **D4** HARD-GATE — **Skip** — fewer than 2 evidence keywords present in a forensic context

## Top-3 Upgrade Recommendations

1. **A4** (medium) — Step 1 of "Scan & Fix Process" uses `git diff HEAD --name-only` but Bash isn't in allowed-tools. Either add Bash OR rewrite to use Glob-based discovery. → See `upgrade-playbook.md#A4`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade devops-japanese-comments"
