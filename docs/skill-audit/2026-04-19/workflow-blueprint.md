# Audit Report — workflow-blueprint

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: workflow/workflow-blueprint/SKILL.md (450 lines)

## Frontmatter Excerpt

```yaml
name: workflow-blueprint
description: |
  Deep workflow flow analysis that traces every entry point through middleware,
  controllers, services, repositories, and database queries — then generates
  Mermaid sequence diagrams for each workflow. [...]
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
```

## Score

**0.947** (green) — 17 Pass / 2 Warn / 0 Fail / 2 Skip

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 1 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 4 | 1 | 0 | 0 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |
| F — Longevity & Compounding | 4 | 3 | 0 | 0 | 1 |
| E — Online Corroboration | 3 | 2 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

#### A1. name format — **Pass**
- Evidence: `workflow/workflow-blueprint/SKILL.md:2` — `name: workflow-blueprint`
- Source: platform.claude.com agent-skills/overview
- Risk: low

#### A2. description ≤1024 chars — **Pass**
- Evidence: description length = 944 chars (<1024 cap)
- Risk: medium

#### A3. description XML-tag-free — **Pass**
- Evidence: no `<[A-Za-z/]` matches in description block
- Risk: low

#### A4. allowed-tools hygiene — **Warn**
- Evidence: `workflow/workflow-blueprint/SKILL.md:22` lists `Bash` in
  `allowed-tools`. Body has 0 verb-form references to Bash, no shell command
  invocations, no `` ` ``-quoted bash snippets. The detection tables mention
  `package.json` / `go.mod` but those are read via Glob, not Bash.
- Source: github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
  — principle: only request tools you actually use.
- Risk: medium
- **Recommendation:** remove `Bash` from `allowed-tools`. If future additions
  need shell (e.g., `git log`-based entry-point discovery), re-add then.

### Axis B — Description Quality

#### B1. Third-person framing — **Pass**
- Evidence: description opens "Deep workflow flow analysis that traces..."

#### B2. Multilingual triggers (EN/KO/JA) — **Pass**
- Evidence: KO `워크플로우 분석` + JA `ワークフロー分析` present

#### B3. Proactive-suggest phrasing — **Pass**
- Evidence: `SKILL.md:15-17` — "Proactively suggest this skill when the user
  is onboarding..."

#### B4. Concrete trigger phrases ≥3 — **Pass**
- Evidence: 17 distinct quoted trigger phrases

### Axis C — Body Structure

#### C1. SKILL.md ≤500 lines — **Warn**
- Evidence: `wc -l` = 450. Exactly at the Pass buffer (≤450). Any addition
  pushes into Warn band (451–500) and soon Fail (>500).
- Risk: high (splitting mid-workflow needs judgment)
- **Recommendation:** proactively split. Candidate siblings:
  - `framework-detection.md` (Step 1 table — 18 lines)
  - `mermaid-syntax.md` (Step 4 rules + examples — 40+ lines)
  - `edge-cases.md` (Edge Cases + Anti-patterns sections)

#### C2. Reference depth = 1 level — **Pass**
- Evidence: SKILL.md has no sibling .md files besides itself.

#### C3. TOC for long siblings — **Pass** (no siblings >150 lines)

#### C4. No time-sensitive content — **Pass**
- Evidence: no matches for "as of YYYY", "latest version", "currently", etc.

#### C5. Skill name consistent — **Pass**
- Evidence: no conflicting kebab-case mentions.

### Axis D — Project Conventions

#### D1. evals/evals.json schema — **Pass**
- Evidence: 3 evals, Variant A consistent, parses OK.

#### D2. Registration in skill-catalog.md — **Pass**
- Evidence: `skill-catalog.md:11` lists `workflow-blueprint` with correct path.

#### D3. Registration in CLAUDE.md + README.md — **Pass**
- Evidence: `CLAUDE.md:35`, `README.md:22`.

#### D4. HARD-GATE for evidence-bearing skills — **Pass**
- Evidence: 24 trigger keywords (trace/verify/file:line) + `<HARD-GATE>` block
  at `SKILL.md:31-36`.

### Axis F — Longevity & Compounding

#### F1. Index + schema consistency — **Pass**
- Evidence: row format matches other workflow/ rows in `skill-catalog.md`.

#### F2. Append-only audit archive — **Skip**
- Reason: only 1 dated audit directory present (2026-04-19). Not enough
  history for trend verification.

#### F3. Anti-pattern section quality — **Pass**
- Evidence: `SKILL.md:429-443` — explicit "Anti-patterns" section with
  reasoning per prohibition.

#### F4. Schema-linting self-consistency — **Pass** (no siblings)

### Axis E — Online Corroboration

#### E1. Rubric source freshness — **Pass** (delegated)
- Applies globally; see INDEX.md E1 section.

#### E2. External skill comparison — **Pass**
- Evidence: structural pattern (When to Use / Step 0–7 / Edge Cases /
  Anti-patterns) is internally consistent with other project skills.

#### E3. Similar-skill discovery — **Pass**
- Evidence: generic mermaid-diagram skills exist on Tier-3 sources, but none
  match the tracer shape (entry → controller → service → repository → DB
  with file:line evidence). No ≥60% trigger overlap from a single source.

## Top-3 Upgrade Recommendations

1. **A4 — prune unused `Bash`** (medium risk) — single line removal in
   frontmatter. See `upgrade-playbook.md#A4`.
2. **C1 — preemptive split** (high risk) — plan the three-way split before
   any new content crosses 500 lines. See `upgrade-playbook.md#C1`.
3. (none — skill has no Fails and only 2 Warns)

## Next Steps

To apply these recommendations, invoke `skill-auditor` in UPGRADE mode:

> "Upgrade workflow-blueprint"
