# Audit Report — workflow-blueprint

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: workflow/workflow-blueprint/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: workflow-blueprint
description: |
  Deep workflow flow analysis that traces every entry point through middleware,
  controllers, services, repositories, and database queries — then generates
  Mermaid sequence diagrams for each workflow. Produces docs/workflow/ directory
  with per-workflow documentation and a visual INDEX.

  Use this skill whenever the user wants to understand how data flows through
  a project end-to-end, trace an API endpoint from request to database, generate
  sequence diagrams for code paths, onboard to a codebase by understanding its
  workflows, or prepare for a refactor by mapping existing flows. Also use when
  the user asks "how does this endpoint work", "trace the flow", "show me the
  data path".

  Trigger phrases:
  - "workflow blueprint", "trace workflows", "workflow analysis", "flow diagram"
  - "sequence diagram", "trace the API flow", "map the data flow"
  - "how does this endpoint work end to end", "trace from route to database"
  - "워크플로우 분석", "워크플로우 청사진", "플로우 추적", "API 흐름 파악"
  - "시퀀스 다이어그램 생성", "진입점부터 DB까지 추적"
  - "ワークフロー分析", "フロー追跡", "シーケンス図生成", "APIフローの可視化"
  ...
---
```

## Score

**0.97** (green) — 16 Pass / 0 Warn / 1 Fail / 0 Skip

- Description length: **1258 chars** (exceeds 1024 cap)
- SKILL.md line count: 444

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 0 | 1 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: workflow-blueprint`
- **A2** description ≤1024 chars — **Fail** — `SKILL.md:3-27` description is 1258 chars, **exceeds Anthropic 1024-char hard cap**. **Recommendation:** move "Proactively suggest" bullets into SKILL.md body; keep only core description + top trigger phrases in frontmatter.
- **A3** XML-tag-free — **Pass** — no XML tags in description
- **A4** allowed-tools hygiene — **Pass** — `SKILL.md:33` Write declared, `SKILL.md:397-400` body references "Write all workflow files and INDEX.md". Bash listed but not clearly body-referenced — monitor.

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:36` `# Workflow Blueprint` heading (no banned prefix)
- **B2** multilingual — **Pass** — `SKILL.md:20-21` Hangul + `SKILL.md:22` Katakana
- **B3** proactive phrasing — **Pass** — `SKILL.md:9` "Use this skill whenever" + `SKILL.md:24` "Proactively suggest this skill when"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:13-22` many distinct quoted trigger phrases across EN/KO/JA

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:444` lines (≤450, edge of warn band — monitor growth)
- **C2** reference depth = 1 — **Pass** — no siblings
- **C3** TOC for long siblings — **Pass** — no siblings
- **C4** no time-sensitive content — **Pass** — no matches
- **C5** name consistent — **Pass** — no near-miss slash-commands in body

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals.json:3-48` 3 evals with consistent shape
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:11`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:35`, `README.md:22`
- **D4** HARD-GATE — **Pass** — `SKILL.md:39` "Every claim must reference file:line"; `SKILL.md:41-46` HARD-GATE block with 'instead of guessing' wording

## Top-3 Upgrade Recommendations

1. **A2** (high) — Description is 1258 chars (exceeds 1024 max). Move "Proactively suggest" bullets into SKILL.md body and keep frontmatter description tight. → See `upgrade-playbook.md#A2`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade workflow-blueprint"
