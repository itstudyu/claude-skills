---
name: skill-auditor
description: |
  Audit existing Claude Code skills in this repo against Anthropic's official
  skill-authoring best-practices and this project's own conventions, then
  propose upgrade diffs for review. Two modes: AUDIT (read-only scoring with
  file:line evidence) and UPGRADE (per-item approved edits). Use this skill
  whenever the user says "audit my skills", "audit skill X", "check skill
  compliance", "review all skills", "스킬 검수", "스킬 감사", "스킬 업그레이드",
  "스킬 체크", "スキル監査", "スキル検査", "スキル改善", or when reviewing
  SKILL.md files for frontmatter/structure/convention compliance.
  Proactively suggest this skill after any new skill is created or after
  editing an existing SKILL.md — stale or non-conformant skills drift
  silently and degrade Claude's trigger accuracy.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - WebFetch
  - WebSearch
  - Skill
---

# Skill Auditor

Audits this repo's Claude Code skills against Anthropic's official best-practices
and this project's internal conventions. Produces evidence-based compliance
reports and — in a separate approval-gated mode — proposes upgrade diffs.

<HARD-GATE>
Every Pass/Warn/Fail verdict must cite file:line evidence from the audited skill.
No claim without evidence. If a check cannot be verified from file contents,
mark it SKIP and explain why. Do NOT infer author intent. Do NOT speculate.
</HARD-GATE>

## Two Modes + Online Flag

- **AUDIT** (default, read-only, offline) — Score skills against the 17
  offline items (A1–D4), emit per-skill reports + INDEX.md. Never modifies
  source files. Deterministic — no network.
- **AUDIT --online** — Adds Axis E (E1 rubric-quote freshness via WebFetch,
  E2 external-skill comparison against `github.com/anthropics/skills`,
  E3 similar-skill discovery via the `find-skills` Skill). Findings are
  appended to the same report as "(online)" entries. Non-deterministic —
  results depend on live source state.
- **UPGRADE** (approval-gated) — Requires a recent AUDIT report. Proposes
  before/after diffs per finding, waits for per-item `y/n/skip` approval,
  then applies Edit operations. No commits.

### When to use --online

- Rubric is older than 30 days (E1 catches Anthropic-docs drift)
- Introducing a brand-new skill (E2 checks structural gaps vs references,
  E3 detects duplicate/superseded functionality in the broader ecosystem)
- Skipped otherwise to keep default runs reproducible and fast.

## When to Use

Trigger phrases covered in frontmatter. Also invoke proactively:

- After any new skill is created in `workflow/`, `review/`, or `utility/`
- After editing an existing `SKILL.md` or its sibling files
- When `docs/skill-audit/` is missing or >7 days stale
- Before shipping a skill update to the shared library

## Workflow Overview

```
AUDIT Mode:
  Phase 0 — Scope discovery + Flipped-Interaction confirm
  Phase 1 — Load rubric.md (canonical snapshot, no network)
  Phase 2 — Per-skill scoring loop (17 items × 4 axes)
  Phase 3 — Report generation to docs/skill-audit/YYYY-MM-DD/
  Phase 4 — Summary output + UPGRADE suggestion

UPGRADE Mode:
  Phase 0 — Locate latest AUDIT report (refuse if absent)
  Phase 1 — Target selection + finding sort (risk-weighted)
  Phase 2 — Per-finding diff proposal (before/after + source URL)
  Phase 3 — Approval UX (per-item y/n, --yes-all = low-risk only)
  Phase 4 — Edit application (approved only)
  Phase 5 — Re-audit upgraded skill, report score delta
```

## Rubric

The full scored checklist lives in [rubric.md](rubric.md) — 17 items across
4 axes (A: Frontmatter, B: Description, C: Body structure, D: Project
conventions). Each item carries its source URL + verbatim quote so the
rubric is self-contained and deterministic.

## Upgrade Playbook

For each rubric failure mode, [upgrade-playbook.md](upgrade-playbook.md)
contains a before/after example indexed by rubric id. UPGRADE mode consults
this catalog when proposing diffs.

## Audit Report Template

[audit-report-template.md](audit-report-template.md) is the markdown skeleton
filled in per-skill during Phase 3 of AUDIT mode.

## Output Locations

- Per-skill reports: `docs/skill-audit/YYYY-MM-DD/<skill-name>.md`
- Aggregate index: `docs/skill-audit/YYYY-MM-DD/INDEX.md`
- Never writes outside `docs/skill-audit/` in AUDIT mode.
- UPGRADE mode edits source skill files + registration docs only after
  explicit per-item approval.

## Scope Boundaries (What This Skill Does NOT Do)

- Does not install or run OSS linters (SkillCheck-Free, Agnix) — only
  references them as "tool-assist" hints in the rubric.
- Does not generate missing evals — detects absence (D1) but creating test
  scenarios is a creative task out of scope.
- Does not auto-split SKILL.md bodies over 500 lines — flags only (C1).
- Does not commit or push — user reviews `git diff` and commits manually.
- Does not dynamically execute skills — static analysis only.
- Default mode does not touch the network. Network-backed checks (rubric
  freshness, external comparison, similar-skill discovery) run only with
  `--online` and are advisory unless explicitly marked Fail (E3 ≥80% overlap).

## Appendix A: Rubric Source Refresh (Manual)

When Anthropic's official skill docs change, refresh rubric.md's embedded
quotes manually. This skill intentionally avoids network fetches at runtime
to remain deterministic. See [rubric.md](rubric.md) for the refresh procedure.

## Detailed Workflows

### AUDIT Mode — Phase Details

#### Phase 0 — Scope Discovery

Parse the invocation for target phrasing:

| Phrase | Scope |
|--------|-------|
| "audit my skills" / "audit all" / default | `{workflow,review,utility}/*/SKILL.md` |
| "audit <name>" | Single skill at `<any-category>/<name>/SKILL.md` |
| "audit <category>" | `<category>/*/SKILL.md` |

Confirm scope with one Flipped-Interaction round before proceeding:

> "Found N skills in scope: [list]. Audit all? (y / adjust scope / cancel)"

Do not proceed without confirmation on multi-skill runs. For single-skill
invocations the scope is unambiguous — skip the confirmation.

#### Phase 1 — Load Rubric

1. Read [rubric.md](rubric.md) once at the start of the session.
2. Parse the 17 items into memory keyed by id (A1–D4).
3. Do not fetch any network sources at runtime. The rubric is the
   canonical snapshot.
4. If the user says "refresh sources", direct them to Appendix A in
   [rubric.md](rubric.md). The auditor itself never fetches.

#### Phase 2 — Per-Skill Scoring Loop

For each target skill:

1. Read `SKILL.md` in full.
2. Glob sibling markdown files (`<skill-dir>/*.md` excluding SKILL.md).
3. Read `<skill-dir>/evals/evals.json` if it exists.
4. For each rubric item A1–D4:
   - Execute the Method described in rubric.md
   - Record `{id, verdict: Pass|Warn|Fail|Skip, evidence: "file:line — snippet"}`
   - Every verdict **must** cite file:line evidence or be marked Skip with
     an explicit reason (HARD-GATE above).
5. If `--online` was specified, also run E1–E3 (Phase 2.5 below). Otherwise
   mark E1/E2/E3 as SKIP with reason `"offline mode"`.
6. Compute the score: `Σ(item_score) / count(non-skip items)` where Pass=1,
   Warn=0.5, Fail=0.
7. Classify: green ≥0.90, yellow 0.70–0.89, red <0.70.

#### Phase 2.5 — Online Corroboration (only when `--online`)

Run once per audit session (not per skill) for E1 — rubric quotes are
global. Run per-skill for E2 and E3.

**E1 — Rubric quote freshness**

1. For each URL in `rubric.md` → `Canonical Sources` list, `WebFetch` the
   page body.
2. For each rubric item A1–D4 that stores a `Source:` quote, substring-match
   the quote in the fetched body.
3. Emit one finding per drift:
   - Pass: exact match found
   - Warn: ≥90% token overlap but not exact (wording tweak)
   - Fail: quote absent → append a **rubric-drift advisory** to INDEX.md.
     Do NOT silently edit rubric.md during audit; that is an UPGRADE action.

**E2 — External skill comparison**

1. `WebFetch https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md`
   (and optionally one more reference skill from the same category as the
   audited skill). Use `WebSearch` to locate relevant reference skills when
   the category isn't covered by the skill-creator repo directly.
2. Extract section headings + frontmatter fields.
3. Diff against the audited skill. Emit advisory findings only — never Fail
   solely on structural difference, because the audited skill may legitimately
   specialize.

**E3 — Similar-skill discovery**

1. Call `Skill(skill: "find-skills", args: "<top 3 trigger phrases>")`.
2. If `find-skills` is not available in this environment (Skill tool call
   errors with "Unknown skill"), emit E3 as SKIP with reason
   `"find-skills not installed"`.
3. Otherwise parse the returned skill list; report any overlap ≥60% of the
   audited skill's trigger set. Flag ≥80% overlap as Fail (recommend
   consolidation).

All E-findings go into the same audit report under a new
`### Axis E — Online Corroboration` section, each tagged `(online)`.

#### Phase 3 — Report Generation

1. Determine output directory: `docs/skill-audit/YYYY-MM-DD/` using today's
   date. Ask user to confirm the location before the first write (mimic
   project-analyzer Phase 1).
2. For each skill, write `<skill-name>.md` using
   [audit-report-template.md](audit-report-template.md) filled with:
   - Frontmatter excerpt
   - Score + classification
   - Per-item findings with evidence
   - Top-3 upgrade recommendations (Fails first, sorted by risk)
3. Write `INDEX.md` with:
   - Audit date + rubric version (from rubric.md top comment)
   - Sortable table: skill | score | fails | warns | classification | top-issue
   - Aggregate findings (e.g. "3 skills missing HARD-GATE", "2 skills
     exceed 500 lines")

#### Phase 4 — Summary

1. Print the INDEX table to chat.
2. Suggest next action: "Run UPGRADE on <top-priority-skill>?" where
   top-priority = highest risk-weighted Fail count.
3. Do not modify any file outside `docs/skill-audit/`.

### UPGRADE Mode — Phase Details

#### Phase 0 — Prerequisite Check

1. Glob `docs/skill-audit/*/INDEX.md` and pick the newest date directory.
2. If no AUDIT report exists: **refuse**. Message:
   > "No AUDIT report found. Run AUDIT first — `skill-auditor` operates in
   > two modes and UPGRADE requires evidence from a prior AUDIT."
3. If the newest report is older than 7 days: warn and offer re-audit:
   > "Latest AUDIT is N days old. The codebase may have drifted. Re-audit
   > before upgrade? (y = re-audit / n = proceed with stale data)"

#### Phase 1 — Target Selection

1. Read the target skill's audit report.
2. Filter Fails + Warns (ignore Passes and Skips).
3. Sort by risk descending (high → medium → low), then by axis (A → B → C → D).
4. For each finding, Read the matching entry in
   [upgrade-playbook.md](upgrade-playbook.md) keyed by rubric id.

#### Phase 2 — Diff Proposal

For each finding, render to chat:

```
### Finding <id> — <short name> (verdict: <Fail|Warn>)
File:   <path>
Risk:   <low|medium|high>
Source: <URL> — "<verbatim quote>"

BEFORE (lines X–Y):
    <current content>

AFTER:
    <proposed content>

Rationale: <why this fix matters>

Apply? [y / n / skip-all-<risk> / explain more]
```

Do not concatenate proposals — one finding per chat turn to preserve
review granularity.

#### Phase 3 — Approval UX

Default: **per-item** `y / n / skip`.

Shortcut flags:

- `--yes-all` or user phrase "apply all low-risk" → auto-apply every
  finding where `risk: low`. Medium and high **still prompt**.
- Medium findings always require per-item `y`.
- High findings require explicit `yes high` confirmation — never
  auto-apply.

If the user approves, proceed to Phase 4. If skip, record the skip and
move to the next finding.

#### Phase 4 — Edit Application

Apply edits in this order within a single skill:

1. `SKILL.md` frontmatter (A1–A4)
2. `SKILL.md` body (B1–B4, C1, C4, C5)
3. Sibling files (C2, C3 — rubric/playbook/templates inside skill dir)
4. `evals/evals.json` (D1)

Then cross-file registration fixes (D2, D3):

5. `skill-catalog.md` row
6. `CLAUDE.md` category table + routing block
7. `README.md` category table

All edits via `Edit` tool. Never `git add` or `git commit` — the user
owns commits.

If the user rejects a finding mid-transaction, surface the partial state:

> "Applied 3 of 7 findings. Remaining: [list]. Skill is in a partially-
> upgraded state. Continue? (y = resume / n = stop and report)"

Do not auto-rollback. Suggest `git diff` for manual review.

#### Phase 5 — Post-Upgrade Verification

1. Re-run AUDIT on just the upgraded skill(s).
2. Print score delta: `before → after` per skill.
3. If any Fail remains, list it explicitly. Do not claim success.
4. Write the re-audit report to the same-day `docs/skill-audit/YYYY-MM-DD/`
   directory, overwriting the pre-upgrade report for the affected skill.
