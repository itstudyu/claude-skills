# Audit Report — project-analyzer

> Generated 2026-04-19 by `skill-auditor` (AUDIT `--online`)
> Rubric version: 1.3.0
> Source: utility/project-analyzer/SKILL.md (243 lines)

## Score

**1.00** (green) — 19 Pass / 0 Warn / 0 Fail / 2 Skip

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | 4 | 0 | 0 | 0 |
| B — Description | 4 | 4 | 0 | 0 | 0 |
| C — Body Structure | 5 | 5 | 0 | 0 | 0 |
| D — Project Conventions | 4 | 4 | 0 | 0 | 0 |
| F — Longevity & Compounding | 4 | 3 | 0 | 0 | 1 |
| E — Online Corroboration | 3 | 3 | 0 | 0 | 0 |

## Per-Item Findings

- **A1–A4 — Pass**: `Write` has 8 verb refs, `Bash` has 1 verb ref (the
  `find` example at `:46-54`) — both justified.
- **B1–B4 — Pass**: third-person, KO+JA triggers, "Proactively suggest"
  phrase, 13 distinct quoted triggers.
- **C1 — Pass**: 243 lines. **C2 — Pass**: SKILL.md body references
  `resources/templates/*.md` but these are template resources (one level
  deep). **C3 — Pass**: no sibling .md >150 lines. **C4 — Pass**. **C5 —
  Pass**.
- **D1 — Pass**: 3 Variant-A evals. **D2/D3 — Pass**. **D4 — Pass**: 12
  trigger keywords + explicit `<HARD-GATE>` at `:27-31`.
- **F1 — Pass**. **F2 — Skip**. **F3 — Pass**: body >100 lines; "Key
  Principles" section (`:236-243`) carries explicit constraints
  ("Facts only", "Ask, don't assume", "Never write without confirmation")
  with reasoning. **F4 — Pass**: `resources/templates/*.md` siblings linked
  from SKILL.md at `:114-119` (Axis table); template files are expected to
  be loaded dynamically.
- **E1 — Pass**. **E2 — Pass**. **E3 — Pass**: generic codebase-analyzer
  skills exist but none match the 6-axis + file:line-evidence + Flipped-
  Interaction shape; no ≥60% trigger overlap from a single Tier-3 source.

## Top-3 Upgrade Recommendations

- None. No Fails or Warns.

## Next Steps

Skill is green. No UPGRADE needed.
