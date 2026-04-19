# Skill Audit — 2026-04-19 (--online)

> Rubric version: 1.3.0
> Auditor: `skill-auditor` in AUDIT `--online` mode
> Audit date: 2026-04-19
> Scope: 9 skills (`{workflow,review,utility}/*/SKILL.md`)
> Axes scored: A–D (offline) + F (offline) + **E (online)**

> Note: this INDEX overwrites an earlier same-day report. The prior run was
> offline (v1.0.0 rubric snapshot). This run uses v1.3.0 with Axis F (Longevity)
> and Axis E (online corroboration). Per-skill reports have been refreshed with
> updated findings.

## Summary Table

| Skill | Score | Classification | Pass | Warn | Fail | Skip | Top issue |
|-------|-------|----------------|------|------|------|------|-----------|
| [design-doc](design-doc.md) | 1.00 | green | 18 | 0 | 0 | 3 | — |
| [prompt-to-plan](prompt-to-plan.md) | 0.972 | green | 17 | 1 | 0 | 3 | C4 Warn: `Claude 4.6` model-pin may rot |
| [subagent-dev](subagent-dev.md) | 1.00 | green | 18 | 0 | 0 | 3 | — |
| [workflow-blueprint](workflow-blueprint.md) | 0.947 | green | 17 | 2 | 0 | 2 | A4 Warn (`Bash` unused), C1 Warn (450 lines at buffer) |
| [workflow-blueprint-update](workflow-blueprint-update.md) | 1.00 | green | 19 | 0 | 0 | 2 | — |
| [write-plan](write-plan.md) | 0.972 | green | 17 | 1 | 0 | 3 | A4 Warn (`Edit` listed but only Write verb forms used) |
| [devops-japanese-comments](devops-japanese-comments.md) | 1.00 | green | 18 | 0 | 0 | 3 | — |
| [project-analyzer](project-analyzer.md) | 1.00 | green | 19 | 0 | 0 | 2 | — |
| [skill-auditor](skill-auditor.md) | 1.00 | green | 19 | 0 | 0 | 2 | — |

All 9 skills classify **green** (≥0.90). Aggregate Warn count: 4. Zero Fails.

## Aggregate Offline Findings

- **A4 (allowed-tools hygiene)** — 2 skills list dangerous tools that their body
  never exercises: `workflow-blueprint` keeps `Bash` with zero usage;
  `write-plan` keeps `Edit` with zero verb-form usage. Consider pruning to
  reduce blast radius.
- **C1 (500-line body limit)** — `workflow-blueprint` sits exactly at the 450-
  line buffer. Not yet a fail, but any meaningful addition tips it over.
  Split now while the split is cheap.
- **C4 (time-sensitive content)** — `prompt-to-plan` hard-codes "Claude 4.6 (the
  default)" at lines 340, 364, 366, 370. Environment today reports a newer
  model family. This rots again at the next model rev. Replace with version-
  agnostic phrasing or move to a labeled "Old patterns" block.
- **B2 / D1 / D2 / D3 / F1 / F3** — all 9 skills carry full multilingual triggers
  (EN + KO + JA), have 3 valid evals, and are registered consistently in
  `CLAUDE.md` + `README.md` + `skill-catalog.md`, with anti-pattern blocks
  where body length warrants them.

## Axis E — Online Corroboration Findings

Tier-1/2 canonical sources fetched 2026-04-19. Tier-3 sources via WebSearch.

### E1 — Rubric Source Freshness

| Rubric item | Status | Notes |
|-------------|--------|-------|
| A1 (name format) | Warn (minor wording diff) | Live docs say "Must contain only lowercase letters, numbers, and hyphens"; rubric quote elides "Must contain only". Semantically identical. |
| A2 (description ≤1024) | Pass | Exact match. |
| A3 (description XML-free) | Pass | Exact match. |
| A4 (allowed-tools hygiene) | **Fail — rubric drift** | Rubric cites `skills/skill-creator/SKILL.md` for "only request tools you actually use"; that exact phrase is not present in live skill-creator. Principle still sound; re-source to overview's security-considerations section. |
| B1 (third-person) | Pass | Exact match. |
| B3 (pushy / undertrigger) | Warn (wording expanded) | Live adds "-- to not use them when they'd be useful" between clauses. |
| B4 (specific + key terms) | Pass | Exact match. |
| C1 (≤500 lines) | Pass | Semantic match. |
| C2 (one-level deep) | Pass | Exact match. |
| C3 (TOC for long siblings) | Pass | Exact match. |
| C4 (no time-sensitive) | Pass | Meaning preserved. |
| C5 (consistent terminology) | Pass | Exact match. |

**Rubric-drift advisory (new rule):** Live overview adds `name: Cannot contain
XML tags` — not currently scored by A1. Recommend rubric v1.3.1: add an XML-
tag check to A1's Method and Pass criterion.

### E2 — External Skill Comparison

Fetched baselines:
- `github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md`
- `github.com/anthropics/skills/blob/main/skills/pdf/SKILL.md`

Reference-skill heading union: Overview, Quick Start, Python Libraries,
Command-Line Tools, Common Tasks, Quick Reference, Next Steps, Running and
evaluating test cases, Description Optimization.

Our 9 skills use a different but consistent pattern: `When to Use` / numbered
Phases or Steps / `Edge Cases` / `Anti-patterns` / `HARD-GATE` (for evidence-
bearing skills). Specialization is valid — the Anthropic refs are content
skills, ours are process skills. **No E2 findings Warn/Fail.**

### E3 — Similar-Skill Discovery

Primary (`find-skills` Skill tool): not installed in this environment — fell
through. Secondary (MCP registry): not queried. Tertiary (WebSearch on
`topic:claude-skills` + `topic:claude-code-skills`):

| Skill | Overlap source | Trigger overlap | Verdict | Recommendation |
|-------|----------------|-----------------|---------|----------------|
| skill-auditor | softaworks/skill-judge (Tier 2) | ~60% | Warn | Add "Related skills" acknowledgement; differentiator is project-convention axis D + UPGRADE approval flow + online drift detection. |
| subagent-dev | obra/superpowers (Tier 3) | ~80% | Warn | Likely upstream. Add attribution. Differentiator: local project conventions. |
| write-plan | obra/superpowers (Tier 3) | ~70% | Warn | Cite prior art. Differentiator: "No Placeholders" discipline + subagent-dev handoff. |
| prompt-to-plan | ckelsoe/prompt-architect + Hashaam101/prompt-optimizer (Tier 3 x2) | ~60% | Warn | Unique value: two-gate REFINE→PLAN flow into Plan Mode. Elevate in description. |
| workflow-blueprint | generic mermaid skills | low | Pass | Our skill is a tracer, not a diagrammer. |
| workflow-blueprint-update | — | — | Pass | Unique niche. |
| design-doc | — | — | Pass | docs/specs/ + fixed template is project-unique. |
| devops-japanese-comments | — | — | Pass | Niche convention. |
| project-analyzer | generic analyzers | low | Pass | File:line-evidence 6-axis shape is distinctive. |

**E3 Fail count:** 0. Fail requires ≥2 independent Tier-3 sources with ≥80%
overlap; none observed. All E3 findings above are advisory Warn.

## Suggested UPGRADE Order

Sorted by risk-weighted impact:

1. **Self-upgrade of `skill-auditor`'s own rubric** (E1 drift)
   - Bump rubric to v1.3.1
   - Add XML-tag check to A1 Method
   - Re-source A4 quote (remove skill-creator citation or replace with overview's security-considerations)
   - Update A1 and B3 quotes to match live wording verbatim
2. **workflow-blueprint** — A4 (prune `Bash` from allowed-tools) + C1 (plan a split before the 500-line fail threshold)
3. **prompt-to-plan** — C4 (replace hard-coded `Claude 4.6` with version-agnostic or Old-patterns block)
4. **write-plan** — A4 (prune `Edit` or add an explicit edit step)
5. **Related-skills attribution** for skill-auditor / subagent-dev / write-plan / prompt-to-plan (E3 Warn)

No Fails on any skill. All 9 remain safe to use as-is; the Warns are polish
opportunities, not blockers.

## Next Steps

Run UPGRADE on the top-priority skill:

> `skill-auditor upgrade workflow-blueprint`

UPGRADE walks each finding with a before/after diff and per-item approval.
For the rubric self-upgrade (item 1), edit `utility/skill-auditor/rubric.md`
directly and bump the version comment.
