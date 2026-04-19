# UPGRADE Delta v2 — skill-auditor online mode (2026-04-19)

Extends `skill-auditor` with an opt-in `--online` mode. Default behavior
remains unchanged (offline, deterministic).

## Motivation

The user flagged that the previous skill-auditor design never consulted
the network, so it could not:
- Detect when Anthropic's docs evolved past the rubric's stored quotes
- Compare the audited skill against Anthropic's reference skills
- Find similar/competing skills in the broader ecosystem

## Changes

### `utility/skill-auditor/SKILL.md`
- Added `WebFetch`, `WebSearch`, `Skill` to `allowed-tools`
- "Two Modes" section expanded to "Two Modes + Online Flag"
- New Phase 2.5 describes E1 (quote freshness), E2 (external comparison),
  E3 (similar-skill discovery via `find-skills`)
- Scope boundaries updated to note: default run never touches network;
  `--online` gated and advisory unless E3 ≥80% overlap

### `utility/skill-auditor/rubric.md`
- Version bumped 1.0.0 → **1.1.0**
- New Axis E with 3 items (E1 source freshness, E2 external comparison,
  E3 similar-skill discovery)
- "Why Manual" section renamed "Why Default-Offline (and When to Use --online)"
- Contents TOC updated

### `utility/skill-auditor/upgrade-playbook.md`
- New Axis E Entries section with E1/E2/E3 before/after templates
- Contents TOC updated

## Behavior

- Default `AUDIT`: unchanged. E1/E2/E3 are scored as `SKIP reason="offline mode"`.
  Score math untouched — SKIPs excluded from denominator.
- `AUDIT --online`: runs Phase 2.5. E-findings appear in per-skill reports
  under `### Axis E — Online Corroboration` with an `(online)` tag, keeping
  offline findings reproducible when compared across runs.

## Self-Audit (offline, regression check)

Manual 17-item regression after edits:

| Item | Verdict | Note |
|------|---------|------|
| A1 | Pass | name unchanged |
| A2 | Pass | description 737 chars (unchanged) |
| A3 | Pass | no XML tags in description |
| A4 | Pass | WebFetch/WebSearch/Skill all referenced in body |
| B1–B4 | Pass | description unchanged |
| C1 | Pass | 334 lines (was 273; +61 from Phase 2.5 + Modes section) |
| C2 | Pass | siblings still link only upward |
| C3 | Pass | rubric.md (347) + playbook (810) have TOCs |
| C4 | Pass | no time-sensitive phrasing |
| C5 | Pass | slash-command matches |
| D1 | Pass | evals.json unchanged |
| D2 | Pass | skill-catalog.md row present |
| D3 | Pass | CLAUDE.md + README.md rows present |
| D4 | Pass | HARD-GATE block intact |

Self-audit score: **1.00 (green)** — no regression.

## How to Invoke

```
# Default (offline, deterministic):
audit my skills

# Online-augmented (rubric-drift + reference-pattern + duplicate checks):
audit my skills --online
```

The `--online` flag routes through the same AUDIT mode but activates
Phase 2.5. UPGRADE mode remains offline regardless; any rubric updates
proposed by E1 still require per-item approval via the normal flow.

## Caveats

- `--online` depends on live source availability. A 503 on
  `platform.claude.com` degrades E1 to SKIP (reason="fetch failed"), not
  Fail — the audited skill shouldn't be punished for upstream outages.
- `find-skills` (E3) may not be installed in all environments. If the
  Skill tool call errors, E3 returns SKIP with reason
  `"find-skills not installed"`.
- The skill still does not auto-edit `rubric.md` during AUDIT. Quote-drift
  findings go into the report; the fix is an UPGRADE action on `rubric.md`
  itself (risk=medium, per-item approval).
