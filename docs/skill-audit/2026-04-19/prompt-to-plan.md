# Audit Report — prompt-to-plan

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: workflow/prompt-to-plan/SKILL.md (399 lines)

## Frontmatter Excerpt

```yaml
name: prompt-to-plan
description: |
  Transforms rough user input into structured implementation specs using proven
  prompt engineering frameworks (Anthropic, CO-STAR, 7R), then enters Plan Mode
  to build actionable implementation plans. [...]
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
```

## Score

**0.972** (green) — 17 Pass / 1 Warn / 0 Fail / 3 Skip

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 0 | 0 | 1 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 4 | 1 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |
| F — Longevity & Compounding | 4 | 3 | 0 | 0 | 1 |
| E — Online Corroboration | 3 | 2 | 1 | 0 | 0 |

## Per-Item Findings

### Axis A — Frontmatter

- **A1. name format — Pass**: `name: prompt-to-plan` valid kebab-case.
- **A2. description ≤1024 — Pass**: 674 chars.
- **A3. XML-free — Pass**: no XML tags in description.
- **A4. allowed-tools hygiene — Skip**: no Write/Edit/Bash in allowed-tools
  (only Read/Grep/Glob/WebSearch/WebFetch + mode-enter tools). Rule doesn't
  apply.

### Axis B — Description Quality

- **B1. Third-person — Pass**: opens "Transforms rough user input..."
- **B2. Multilingual triggers — Pass**: KO + JA present.
- **B3. Proactive-suggest — Pass**: "Proactively suggest this skill when the
  user's request is vague..."
- **B4. Trigger phrases ≥3 — Pass**: 6 distinct quoted triggers.

### Axis C — Body Structure

- **C1. ≤500 lines — Pass**: 399 lines.
- **C2. One-level deep — Pass**: SKILL.md links siblings `templates.md`,
  `research-protocol.md`, `plan-conventions.md` directly. No nested refs.
- **C3. TOC for long siblings — Pass**: largest sibling is 125 lines
  (plan-conventions.md) — under 150-line trigger.
- **C4. No time-sensitive content — Warn**
  - Evidence: `SKILL.md:340` `"are regular text on Claude 4.6, not thinking budget controls."`;
    `SKILL.md:364` `"### Claude 4.6 Notes"`;
    `SKILL.md:366` `"executed by Claude 4.6 (the default)"`;
    `SKILL.md:370` `"Opus 4.6 tends to create extra files..."`.
  - Source: platform.claude.com agent-skills/best-practices — "Don't include
    information that will become outdated."
  - Risk: low
  - **Recommendation:** replace hard-coded `Claude 4.6` / `Opus 4.6` with
    version-agnostic phrasing ("current-generation Claude models",
    "Anthropic's latest Claude family") OR move to a `## Old patterns`
    `<details>` block as the live best-practices doc prescribes. Current env
    reports Opus 4.7 — the guidance is already partially stale.
- **C5. Name consistent — Pass**: no slash-command mismatches.

### Axis D — Project Conventions

- **D1. evals.json schema — Pass**: 3 evals, Variant B (`skills`/`query`).
  Only skill using Variant B; internally consistent.
- **D2. skill-catalog.md — Pass**: `skill-catalog.md:9`.
- **D3. CLAUDE.md + README.md — Pass**: `CLAUDE.md:31`, `README.md:18`.
- **D4. HARD-GATE — Skip**: only 1 trigger keyword in body; rule requires ≥2.

### Axis F — Longevity & Compounding

- **F1. Index/schema consistency — Pass**: row format matches.
- **F2. Append-only archive — Skip**: only 1 dated audit dir.
- **F3. Anti-pattern section quality — Pass**: `SKILL.md:346-354` "Common
  Pitfalls" with 8 reasoned items; `SKILL.md:317-344` "Best Practices"
  includes "Do NOT / Avoid" framing.
- **F4. Schema-lint self-consistency — Pass**: templates.md, research-
  protocol.md, plan-conventions.md all linked from SKILL.md (`:275`, `:279`,
  `:315`). No orphans, no name contradictions.

### Axis E — Online Corroboration

- **E1. Rubric freshness — Pass** (delegated to INDEX).
- **E2. External comparison — Pass**: structural consistency with project
  pattern.
- **E3. Similar-skill discovery — Warn**
  - Evidence: WebSearch on `topic:claude-skills` found
    `ckelsoe/prompt-architect` (CO-STAR/7R framework prompt refiner) and
    `Hashaam101/prompt-optimizer` (silent refinement skill). Both overlap the
    rough-prompt → refined-spec trigger space (~60%).
  - Differentiator: prompt-to-plan's value is the **two-gate REFINE→PLAN**
    flow into Plan Mode (not just refinement output). This gate isn't
    prominent in the first clause of the description.
  - Risk: medium
  - **Recommendation:** elevate "enters Plan Mode" into the first sentence of
    the description so the Plan-Mode handoff is what disambiguates this skill
    from pure prompt-refiners. Optionally add a "Related skills" section
    citing prompt-architect as prior art.

## Top-3 Upgrade Recommendations

1. **C4 — purge Claude-4.6 hard-codes** (low risk) — 4 line edits; replace
   with version-agnostic phrasing or move to Old-patterns block.
2. **E3 — add Related-skills attribution + elevate Plan-Mode gate in description** (medium risk, advisory).
3. (no further findings)

## Next Steps

> "Upgrade prompt-to-plan"
