# Audit Report — subagent-dev

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: workflow/subagent-dev/SKILL.md (367 lines)

## Score

**1.00** (green) — 18 Pass / 0 Warn / 0 Fail / 3 Skip (offline)
Axis E: 2 Pass / 1 Warn (advisory, not counted in core score).

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 3 | 0 | 0 | 1 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 3 | 0 | 0 | 1 |
| F — Longevity & Compounding | 4 | 2 | 0 | 0 | 2 |
| E — Online Corroboration | 3 | 2 | 1 | 0 | 0 |

## Per-Item Findings

- **A1–A3 — Pass**. **A4 — Skip**: allowed-tools = `Read + TodoWrite + Agent`;
  no Write/Edit/Bash listed, so the hygiene rule doesn't apply.
- **B1–B4 — Pass**: third-person, KO+JA, proactive phrasing, 5 quoted
  triggers.
- **C1 — Pass**: 367 lines. **C2 — Pass**: no siblings. **C3 — Skip-equivalent**
  (no siblings). **C4 — Pass**. **C5 — Pass**.
- **D1 — Pass**: 3 Variant-A evals. **D2/D3 — Pass**. **D4 — Skip**: 3 trigger
  keywords all "verify" in test/fix-verification context (lines 171, 338, 361);
  not forensic-evidence context. Rule does not apply.
- **F1 — Pass**. **F2 — Skip**. **F3 — Pass**: body >100 lines; "Red Flags"
  section (`:240-269`) is an explicit anti-pattern block with reasoning.
  **F4 — Skip** (no siblings).
- **E1 — Pass**. **E2 — Pass**.
- **E3 — Warn (advisory)**: `obra/superpowers` framework contains a
  `subagent-driven-development` skill with near-identical trigger space
  ("dispatches fresh subagent per task with two-stage review: spec compliance,
  then code quality"). Overlap ~80% with a single Tier-3 source. Cannot
  escalate to Fail (rubric requires ≥2 independent corroborating sources).
  - **Recommendation:** add a "Related skills / Prior art" section
    acknowledging obra/superpowers and clarifying project-specific
    differentiators (model-selection table at lines 98-112, local TodoWrite
    integration, Anthropic parallel-dispatch examples).

## Top-3 Upgrade Recommendations

1. **E3 — add Prior-Art attribution block** (advisory).
2. (none)
3. (none)

## Next Steps

Skill is green. Optional UPGRADE for E3 attribution.
