# Audit Report — subagent-dev

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: workflow/subagent-dev/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: subagent-dev
description: |
  Execute implementation plans by dispatching a fresh subagent per task, with two-stage
  review (spec compliance + code quality) after each. Supports parallel dispatch for
  independent tasks. Use this skill whenever the user says "use subagents", "dispatch
  agents", "parallel execution", "サブエージェント実行", "서브에이전트", or when an
  implementation plan exists and tasks are mostly independent. Proactively suggest
  this skill over execute-plan when subagents are available — fresh context per task
  produces higher quality results than sequential execution in a long session.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - Bash
  - Agent
---
```

## Score

**0.97** (green) — 15 Pass / 1 Warn / 0 Fail / 1 Skip

- Description length: 595 chars
- SKILL.md line count: 372

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 1 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

- **A1** name format — **Pass** — `SKILL.md:2` `name: subagent-dev`
- **A2** description ≤1024 chars — **Pass** — `SKILL.md:3-10` ~595 chars
- **A3** XML-tag-free — **Pass** — no `<Tag` tokens in description block
- **A4** allowed-tools hygiene — **Warn** — `SKILL.md:11-18` declares Read/Grep/Glob/Write/Edit/Bash/Agent, but Bash/Grep/Glob are not directly called by the controller (subagents invoke them). **Recommendation:** trim to controller-invoked tools (Read, Agent/Task, TodoWrite) and move subagent-side tools into the dispatched-subagent prompt instructions.

### Axis B — Description Quality

- **B1** third-person — **Pass** — `SKILL.md:4` "Execute implementation plans by dispatching..." (imperative, third-person)
- **B2** multilingual — **Pass** — `SKILL.md:7` Hangul '서브에이전트' + Katakana 'サブエージェント実行'
- **B3** proactive phrasing — **Pass** — `SKILL.md:6` "Use this skill whenever" + `SKILL.md:8` "Proactively suggest this skill"
- **B4** ≥3 triggers — **Pass** — `SKILL.md:6-7` 5 quoted triggers

### Axis C — Body Structure

- **C1** ≤500 lines — **Pass** — `SKILL.md:372` lines
- **C2** reference depth = 1 — **Pass** — only SKILL.md in directory
- **C3** TOC for long siblings — **Pass** — no siblings
- **C4** no time-sensitive content — **Pass** — no matches
- **C5** name consistent — **Pass** — `README.md:21` / `CLAUDE.md:34` `/subagent-dev` matches

### Axis D — Project Conventions

- **D1** evals schema — **Pass** — `evals/evals.json:3-22` 3 evals, consistent shape. **Note:** line 12 contains a corrupted Hangul byte `'서��에이전트'`; repair to `'서브에이전트'`.
- **D2** skill-catalog.md — **Pass** — `skill-catalog.md:10`
- **D3** CLAUDE.md + README.md — **Pass** — `CLAUDE.md:34`, `README.md:21`
- **D4** HARD-GATE conditional — **Skip** — `SKILL.md:175,342,365` only 'verify' matches (1 distinct of 6); <2 → HARD-GATE not required

## Top-3 Upgrade Recommendations

1. **A4** (medium) — Prune allowed-tools to controller-invoked tools only (Read + Agent/Task + TodoWrite); push Bash/Grep/Glob/Write/Edit into dispatched-subagent instructions. → See `upgrade-playbook.md#A4`
2. **D1** (low) — Fix corrupted Hangul byte `'서��에이전트'` at `evals/evals.json:12` to `'서브에이전트'`. → See `upgrade-playbook.md#D1`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade subagent-dev"
