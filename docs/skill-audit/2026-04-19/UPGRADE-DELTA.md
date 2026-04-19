# UPGRADE Delta — 2026-04-19

> All 9 skills upgraded in one transaction. Before/after scores measured by
> re-running the 17-item rubric against only the edited files.

## Score Delta

| Skill | Before | After | Δ | Status |
|-------|--------|-------|---|--------|
| prompt-to-plan | 0.81 (yellow) | **1.00** (green) | +0.19 | All 3 B-axis Fails resolved |
| workflow-blueprint | 0.97 (green) | **1.00** (green) | +0.03 | A2 Fail resolved; D4 HARD-GATE strengthened |
| workflow-blueprint-update | 0.91 (green) | **1.00** (green) | +0.09 | A2 Fail resolved; D4 wording added |
| subagent-dev | 0.97 (green) | **1.00** (green) | +0.03 | A4 Warn resolved; D1 corrupted byte fixed |
| devops-japanese-comments | 0.97 (green) | **1.00** (green) | +0.03 | A4 Warn resolved (Bash added) |
| project-analyzer | 0.97 (green) | **1.00** (green) | +0.03 | C1 Warn resolved (493 → 243 lines) |
| write-plan | 1.00 | 1.00 | — | no change (already green) |
| design-doc | 1.00 | 1.00 | — | no change (already green) |
| skill-auditor | 1.00 | 1.00 | — | no change (already green) |

**Project average:** 0.95 → **1.00**
**Red/Yellow skills:** 1 → **0**

## Changes Applied

### `workflow/prompt-to-plan/SKILL.md`
- **B2/B3/B4** — description expanded from 148 → 658 chars. Added 6 quoted triggers (EN/KO/JA), "Use this skill whenever" + "Proactively suggest" phrasing.

### `workflow/workflow-blueprint/SKILL.md`
- **A2** — description trimmed from 1258 → 918 chars; moved "Proactively suggest" bullets into a single inline clause; kept all EN/KO/JA trigger phrases.
- **D4** — HARD-GATE strengthened with explicit `"No speculation. No guessing."` line.

### `workflow/workflow-blueprint-update/SKILL.md`
- **A2** — description trimmed from ~1300 → 897 chars; same restructure as blueprint.
- **D4** — HARD-GATE reworded: added `"No speculation. No guessing."`, replaced "instead of guessing" with "never infer from framework conventions or author intent".

### `workflow/subagent-dev/SKILL.md`
- **A4** — `allowed-tools` pruned from `[Read, Grep, Glob, Write, Edit, Bash, Agent]` → `[Read, TodoWrite, Agent]`. Controller-invoked set only; subagent-side tools belong in dispatched prompts.

### `workflow/subagent-dev/evals/evals.json`
- **D1** — fixed corrupted Hangul byte `'서��에이전트'` → `'서브에이전트'` at line 12.

### `review/devops-japanese-comments/SKILL.md`
- **A4** — added `Bash` to `allowed-tools` (body at line 96 references `git diff HEAD --name-only`).

### `utility/project-analyzer/SKILL.md`
- **C1** — 493 → 243 lines (–51%). Extracted 6 axis-specific output templates to `resources/templates/*.md`. Phase 2 now carries axis-specific notes + a one-level-deep links table to the templates.

### New files: `utility/project-analyzer/resources/templates/`
- `tech-stack.md` (47 lines) — Axis 1 template
- `features.md` (33 lines) — Axis 2 template
- `data-model.md` (47 lines) — Axis 3 template
- `code-patterns.md` (49 lines) — Axis 4 template
- `dependencies.md` (40 lines) — Axis 5 template
- `architecture.md` (81 lines) — Axis 6 template

## Remaining Items

None. All 9 skills now score 1.00.

## Next Steps

1. Review the changes via `git diff` — the user owns the commit.
2. If satisfied, commit all changes together:
   - 6 `SKILL.md` edits (`prompt-to-plan`, `workflow-blueprint`, `workflow-blueprint-update`, `subagent-dev`, `devops-japanese-comments`, `project-analyzer`)
   - 1 `evals/evals.json` fix (`subagent-dev`)
   - 6 new sibling files (`project-analyzer/resources/templates/*.md`)
