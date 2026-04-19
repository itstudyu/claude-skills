# Audit Report — skill-auditor (self-audit)

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: utility/skill-auditor/SKILL.md (358 lines)

## Score

**1.00** (green) — 19 Pass / 0 Warn / 0 Fail / 2 Skip (offline)
Axis E: 2 Pass / 1 Warn (advisory — E1 rubric self-drift + E3 overlap with
`softaworks/skill-judge`).

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |
| F — Longevity & Compounding | 4 | 3 | 0 | 0 | 1 |
| E — Online Corroboration | 3 | 2 | 1 | 0 | 0 |

## Per-Item Findings

- **A1–A4 — Pass**: `Write` (4 verb refs) + `Edit` (8 verb refs) both
  justified extensively (UPGRADE-mode Edit-tool workflow).
- **B1–B4 — Pass**: third-person ("Audit existing Claude Code skills..."),
  KO+JA triggers, "Proactively suggest" phrase, 11 distinct quoted triggers.
- **C1 — Pass**: 358 lines. **C2 — Pass**: `upgrade-playbook.md:371-422`
  shows illustrative cross-sibling links inside code blocks
  (`[reference.md](reference.md)` etc.), but these are examples documenting
  *what* to write into a user's skill — not actual cross-refs from within
  skill-auditor's own sibling network. All real sibling references flow
  through SKILL.md. **C3 — Pass**: `rubric.md` (574 lines) and
  `upgrade-playbook.md` (961 lines) both have `## Contents` in first 30
  lines. **C4 — Pass**: no time-sensitive matches. **C5 — Pass**.
- **D1 — Pass**: 3 Variant-A evals. **D2/D3 — Pass**: `skill-catalog.md:16`,
  `CLAUDE.md:47`, `README.md:34`. **D4 — Pass**: 63 trigger keywords +
  explicit `<HARD-GATE>` at `:32-36`.
- **F1 — Pass**. **F2 — Skip**. **F3 — Pass**: body >100 lines; "Scope
  Boundaries (What This Skill Does NOT Do)" section (`:121-133`) lists 6
  reasoned anti-patterns; additional prohibitions scattered in Phase
  descriptions. **F4 — Pass**: all 3 siblings (rubric.md, upgrade-playbook.md,
  audit-report-template.md) are linked from SKILL.md (`:89, :104, :110`).
  No orphans, no name contradictions.
- **E1 — Self-drift advisory (meta)**: per INDEX.md E1 section, rubric
  quotes need refresh (A1 XML-tag rule missing; A4 skill-creator quote
  absent in live source; B3 and A1 wordings slightly stale). Marked Warn
  at the INDEX level; skill itself is Pass.
- **E2 — Pass**: structural pattern consistent with project.
- **E3 — Warn**: `softaworks/agent-toolkit/skills/skill-judge` is a
  widely-known skill-quality rubric (8 dimensions, 120 pts). Our rubric
  already cites it in the Trusted Sources Registry (Tier 2) and in F3's
  Source reference — so the overlap is acknowledged within the rubric. But
  it is **not** acknowledged in SKILL.md's body.
  - Trigger overlap with skill-judge ~60% (audit/review/improve SKILL.md).
  - Differentiators: project-convention axis D (D1–D4), two-mode
    AUDIT/UPGRADE flow with per-item approval gates, Axis E online drift
    detection, Axis F longevity/compounding checks, append-only archive
    policy, rubric self-refresh procedure (Appendix A).
  - Risk: medium
  - **Recommendation:** add a "Related rubrics" section to SKILL.md citing
    skill-judge and explaining when each applies (skill-judge = content-
    agnostic knowledge-delta focus; skill-auditor = project-integrated
    convention enforcement + upgrade workflow).

## Top-3 Upgrade Recommendations

1. **E1 rubric self-refresh** (medium risk): bump to 1.3.1, add XML-tag
   check to A1, re-source A4 quote, update A1/B3 verbatim quotes to match
   live doc wording.
2. **E3 — add Related-rubrics section to SKILL.md** citing skill-judge
   differentiator (advisory, medium risk).
3. (no further findings)

## Next Steps

For rubric-refresh, edit `utility/skill-auditor/rubric.md` directly and bump
the version. For the Related-rubrics section, run UPGRADE or do a direct
Edit.
