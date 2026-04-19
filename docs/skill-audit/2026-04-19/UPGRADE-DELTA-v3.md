# Upgrade Delta — 2026-04-19 (run 3, --online follow-up)

> `skill-auditor` UPGRADE mode applied 5 findings from the AUDIT `--online`
> run. Re-audited the affected skills; reporting score delta + rubric
> version bump.

## Findings applied

| # | Skill / Target | Finding | Verdict before | After |
|---|----------------|---------|----------------|-------|
| 1 | workflow-blueprint SKILL.md:22 | A4 — pruned unused `Bash` from allowed-tools | Warn | Pass |
| 2 | write-plan SKILL.md:17 | A4 — pruned unused `Edit` from allowed-tools | Warn | Pass |
| 3 | prompt-to-plan SKILL.md:340,364,366,370 | C4 — replaced `Claude 4.6` hard-codes with version-agnostic phrasing | Warn | Pass |
| 4 | utility/skill-auditor/rubric.md | E1 self-drift — bump to v1.3.1: added XML-tag check to A1, re-sourced A4 quote, refreshed A1/B3 verbatim quotes | Fail (rubric-drift advisory) | Fixed |
| 5 | workflow-blueprint/ | C1 — split 450-line SKILL.md into SKILL.md (368 lines) + mermaid-syntax.md (75 lines) + edge-cases.md (40 lines) | Warn | Pass |

No Findings rejected or skipped.

## Score delta

| Skill | Score before | Score after |
|-------|--------------|-------------|
| workflow-blueprint | 0.947 | **1.00** |
| write-plan | 0.972 | **1.00** |
| prompt-to-plan | 0.972 | **1.00** |
| skill-auditor | 1.00 (offline) | 1.00 (E1 self-drift resolved; rubric now v1.3.1) |

Aggregate Warns across all 9 skills: **4 → 0** (offline scoring).
All 9 skills classify **green**.

## Post-upgrade sanity checks

- `allowed-tools` re-check:
  - `workflow-blueprint`: `[Read, Grep, Glob, Write]` — all dangerous tools
    justified (Write verb refs = 4).
  - `write-plan`: `[Read, Grep, Glob, Write]` — Write verb refs = 8.
  - `prompt-to-plan`: unchanged (no dangerous tools listed).
- `Claude 4.6` / `Opus 4.6` grep: **0 hits** across all SKILL.md files.
- Line counts: workflow-blueprint SKILL.md 450 → 368; siblings add up to
  483 total (still well under any per-file limit, and each sibling is now
  loaded only when Claude needs that specific aspect).
- Sibling linkage: `mermaid-syntax.md` linked at Step 4; `edge-cases.md`
  linked at "Edge Cases and Anti-patterns" section. Both siblings have
  `## Contents` TOC in first 30 lines (C3 compliance).
- Rubric self-consistency:
  - A1 Method now includes XML-tag regex reject.
  - A1 Source quote matches live platform.claude.com wording verbatim.
  - A4 Source re-pointed from skill-creator (quote absent) to overview's
    security-considerations section.
  - B3 Source quote updated to include the "-- to not use them when they'd
    be useful" clause from live skill-creator.

## Residual advisories (not applied)

E3 attribution blocks (Related-skills / Prior-art notes) for
`skill-auditor`, `subagent-dev`, `write-plan`, `prompt-to-plan` remain
**advisory only** — these were flagged in the AUDIT but were not part of
the current UPGRADE batch. User can apply them in a follow-up pass with:

> `"Upgrade related-skills attribution"` — adds a one-paragraph "Related
> skills" section to each of the 4 affected SKILL.md files, citing the
> external skill and the local differentiator.

## Files touched

```
workflow/workflow-blueprint/SKILL.md         (edited)
workflow/workflow-blueprint/mermaid-syntax.md (new)
workflow/workflow-blueprint/edge-cases.md     (new)
workflow/write-plan/SKILL.md                  (edited)
workflow/prompt-to-plan/SKILL.md              (edited)
utility/skill-auditor/rubric.md               (edited — v1.3.0 → v1.3.1)
docs/skill-audit/2026-04-19/UPGRADE-DELTA-v3.md (this file)
```

No `git add` / `git commit` performed — per skill-auditor policy, the user
owns commits. Run `git diff` to review before committing.
