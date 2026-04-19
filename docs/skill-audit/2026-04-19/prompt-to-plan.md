# Audit Report — prompt-to-plan

> Generated 2026-04-19 by `skill-auditor`.
> Rubric version: 1.0.0 (2026-04-19)
> Source: workflow/prompt-to-plan/SKILL.md

## Frontmatter Excerpt

```yaml
---
name: prompt-to-plan
description: |
  Transforms rough user input into structured implementation specs, then enters
  Plan Mode to build actionable plans. Only when explicitly requested.
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
---
```

## Score

**0.81** (yellow) — 13 Pass / 0 Warn / 3 Fail / 1 Skip

- Description length: 148 chars
- SKILL.md line count: 392

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 1 | 0 | 3 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |

## Per-Item Findings

### Axis A — Frontmatter Compliance

#### A1. name field format — **Pass**
- **Evidence:** `SKILL.md:2` — `name: prompt-to-plan`
- **Source:** platform.claude.com/docs/…/overview — "only lowercase letters, numbers, and hyphens"
- **Risk:** low

#### A2. description ≤1024 chars — **Pass**
- **Evidence:** `SKILL.md:3-5` — description ~148 chars, within 1..1024
- **Source:** platform.claude.com/docs/…/overview — "Maximum 1024 characters"
- **Risk:** medium

#### A3. description XML-tag-free — **Pass**
- **Evidence:** `SKILL.md:3-5` — no XML-like tags in the description block
- **Risk:** low

#### A4. allowed-tools hygiene — **Pass**
- **Evidence:** `SKILL.md:6-14` — no Write/Edit/Bash declared in allowed-tools; trivially passes
- **Risk:** medium

### Axis B — Description Quality

#### B1. Third-person framing — **Pass**
- **Evidence:** `SKILL.md:4` — starts with 'Transforms rough user input...'; no banned pronoun prefix
- **Source:** …/best-practices — "Always write in third person."
- **Risk:** low

#### B2. Multilingual triggers (EN / KO / JA) — **Fail**
- **Evidence:** `SKILL.md:3-5` — description has no Hangul or Hiragana/Katakana characters
- **Source:** Project convention — other 8 skills all carry KO+JA triggers
- **Risk:** low
- **Recommendation:** Add Korean and Japanese trigger phrases (e.g. '정리해서 플랜', '整理してプラン') to the description to enable multilingual routing.

#### B3. Proactive-suggest phrasing — **Fail**
- **Evidence:** `SKILL.md:3-5` — description lacks 'proactively suggest' / 'use this skill whenever' / 'trigger when' / 'make sure to use'
- **Source:** github.com/anthropics/skills/…/skill-creator — "skill descriptions a little bit 'pushy'"
- **Risk:** low
- **Recommendation:** Add a proactive phrasing cue such as 'use this skill whenever the user asks to refine a rough prompt into a plan'.

#### B4. ≥3 concrete trigger phrases — **Fail**
- **Evidence:** `SKILL.md:3-5` — description contains zero quoted trigger phrases
- **Source:** …/best-practices — "Be specific and include key terms."
- **Risk:** low
- **Recommendation:** Include at least three quoted example triggers in the description (EN/KO/JA).

### Axis C — Body Structure

#### C1. SKILL.md ≤500 lines — **Pass**
- **Evidence:** `SKILL.md:392` — 392 lines, ≤450
- **Risk:** high

#### C2. Reference depth = 1 level — **Pass**
- **Evidence:** `SKILL.md:268,272,308` — sibling links only originate from SKILL.md; no sibling→sibling cross-links
- **Risk:** medium

#### C3. TOC for long sibling files (>150 lines) — **Pass**
- **Evidence:** templates.md=118, research-protocol.md=64, plan-conventions.md=125 — no sibling exceeds 150 lines
- **Risk:** low

#### C4. No time-sensitive content — **Pass**
- **Evidence:** `SKILL.md` — no matches for 'as of YYYY' / 'latest version' / 'currently supports' / 'current model|version' / 'for now' / 'at the moment'
- **Risk:** low

#### C5. Skill name consistent — **Pass**
- **Evidence:** `SKILL.md` — no stale or near-miss slash-command names present
- **Risk:** medium

### Axis D — Project Conventions

#### D1. evals.json schema conformance — **Pass**
- **Evidence:** `evals/evals.json:1-46` — skill_name present, 3 evals in consistent Variant B schema (skills/query/files/expected_behavior)
- **Risk:** low

#### D2. Registration in skill-catalog.md — **Pass**
- **Evidence:** `skill-catalog.md:9` — row `| prompt-to-plan | workflow/prompt-to-plan/ | …`
- **Risk:** low

#### D3. Registration in CLAUDE.md + README.md — **Pass**
- **Evidence:** `CLAUDE.md:31` and `README.md:18` — both rows present under workflow/
- **Risk:** low

#### D4. HARD-GATE for evidence-bearing skills — **Skip**
- **Evidence:** SKIP — body has <2 HARD-GATE keywords (only 'Verify' at line 189)
- **Risk:** medium

## Top-3 Upgrade Recommendations

Sorted by risk, then axis. Fails first, then Warns.

1. **B2** (low) — Add Hangul and Hiragana/Katakana trigger phrases to the description for multilingual auto-routing. → See `upgrade-playbook.md#B2`
2. **B3** (low) — Add proactive phrasing like 'use this skill whenever' to the description. → See `upgrade-playbook.md#B3`
3. **B4** (low) — Add at least three distinct quoted trigger examples in the description. → See `upgrade-playbook.md#B4`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade prompt-to-plan"
