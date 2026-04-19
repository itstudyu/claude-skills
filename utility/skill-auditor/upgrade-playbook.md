# Upgrade Playbook

Before/after catalog indexed by rubric id. UPGRADE mode consults this file
to produce diff proposals. Each entry shows a concrete transformation plus
the rubric rationale.

## Contents

- [How to Read This Playbook](#how-to-read-this-playbook)
- [Application Order](#application-order-within-one-skill-during-upgrade-phase-4)
- [Axis A Entries](#axis-a-entries) (A1–A4)
- [Axis B Entries](#axis-b-entries) (B1–B4)
- [Axis C Entries](#axis-c-entries) (C1–C5)
- [Axis D Entries](#axis-d-entries) (D1–D4)
- [Axis E Entries (online-only)](#axis-e-entries-online-only) (E1–E3)
- [Axis F Entries (longevity & compounding)](#axis-f-entries-longevity--compounding) (F1–F4)

## How to Read This Playbook

Each entry follows this schema:

```
### <rubric-id> — <name>

Rubric source: <URL> — "<quote>"
Risk: low | medium | high

#### BEFORE
    <minimal excerpt that triggers the failure>

#### AFTER
    <corrected form>

#### Rationale
    <1-3 sentences explaining why the fix matters>

#### Edge cases
    <any situations where this transformation doesn't apply>
```

## Application Order (within one skill, during UPGRADE Phase 4)

1. **SKILL.md frontmatter** — A1, A2, A3, A4
2. **SKILL.md body** — B1–B4, C1, C4, C5
3. **Sibling files** — C2, C3 (rubric/playbook/templates inside skill dir)
4. **evals/evals.json** — D1
5. **Cross-file registration** — D2 (skill-catalog.md), D3 (CLAUDE.md + README.md)

HARD-GATE (D4) is handled in-body during step 2.

---

## Axis A Entries

### A1 — name field format

**Rubric source:** platform.claude.com skills/overview — "name: Maximum 64 characters ... only lowercase letters, numbers, and hyphens ... Cannot contain reserved words: 'anthropic', 'claude'."
**Risk:** low (high if referenced in CLAUDE.md routing or other skills)

#### BEFORE

```yaml
name: Claude_Helper_V2
```

#### AFTER

```yaml
name: skill-helper-v2
```

#### Rationale

Reserved word "claude" forbidden. Underscores and uppercase invalid. Fix
is mechanical but rename propagates — if the skill appears in
`CLAUDE.md` routing or another skill's body, treat as risk=high and
update all references in the same transaction.

#### Edge cases

- If the directory name differs from the frontmatter name, rename the
  directory too (directory-name drives `/slash-command` invocation).
- If the name is referenced in `install.sh` CATEGORIES or a hook, update
  those files.

---

### A2 — description length ≤1024

**Rubric source:** platform.claude.com skills/overview — "description: Must be non-empty ... Maximum 1024 characters."
**Risk:** medium

#### BEFORE

```yaml
description: |
  [1200-char description with redundant phrasing, explanations of what
  skills are in general, and marketing-style preamble before the actual
  trigger information...]
```

#### AFTER

```yaml
description: |
  [Compressed to ≤1024 chars: one-sentence purpose, then trigger
  phrases, then "Proactively suggest" clause. Removed generic
  preamble and redundant explanation.]
```

#### Rationale

Descriptions are preloaded into every Claude session. Every character
costs tokens across all conversations. Compress aggressively: Claude
already knows what skills are.

#### Edge cases

- Never remove trigger phrases to save chars — trigger coverage beats
  brevity. Compress prose instead.
- If >1024 chars is unavoidable, that's a signal the skill is trying to
  do too much. Consider splitting into two skills.

---

### A3 — description XML-tag-free

**Rubric source:** platform.claude.com skills/overview — "description ... Cannot contain XML tags."
**Risk:** low

#### BEFORE

```yaml
description: |
  Generate <report> documents from source data. Use when the user
  asks for <sales-report> or <weekly-summary>.
```

#### AFTER

```yaml
description: |
  Generate report documents from source data. Use when the user asks
  for "sales report", "weekly summary", or similar structured outputs.
```

#### Rationale

XML tags in description can confuse the system-prompt parser. Replace
with quoted strings.

#### Edge cases

- Use double quotes or backticks for emphasis, not `<tags>`.
- Code samples with XML belong in the body, not the description.

---

### A4 — allowed-tools hygiene

**Rubric source:** github.com/anthropics/skills skill-creator — principle: "only request tools you actually use".
**Risk:** medium

#### BEFORE

```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - Bash
  - WebFetch
  - WebSearch
```

Body never invokes Bash, WebFetch, or WebSearch.

#### AFTER

```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
```

#### Rationale

Unused dangerous tools expand blast radius unnecessarily. Removing them
is reversible and documents actual behavior.

#### Edge cases

- If a tool is used conditionally (only in one Phase), keep it and add a
  body reference explaining the condition.
- If removing a tool breaks a workflow branch not covered by tests, flag
  as risk=high and ask the user.

---

## Axis B Entries

### B1 — Third-person framing

**Rubric source:** platform.claude.com skills/best-practices — "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems."
**Risk:** low

#### BEFORE

```yaml
description: |
  I can help you analyze codebases. You should use this when you want
  deep analysis...
```

#### AFTER

```yaml
description: |
  Analyzes codebases with file:line evidence. Use this skill when
  deep analysis is needed...
```

#### Rationale

First/second-person voice confuses the system prompt perspective.
Third-person describes what the skill *is*, which is what Claude
matches against.

#### Edge cases

- "You" is acceptable inside the body (which is written *for* Claude),
  just not in the description.

---

### B2 — Multilingual triggers (EN/KO/JA)

**Rubric source:** Repo convention — see 8 existing skills.
**Risk:** low

#### BEFORE

```yaml
description: |
  Audit skills. Use when the user says "audit my skills" or "check
  skill compliance".
```

#### AFTER

```yaml
description: |
  Audit skills. Use when the user says "audit my skills", "check skill
  compliance", "스킬 검수", "스킬 감사", "スキル監査", "スキル検査".
```

#### Rationale

This repo's users operate in English, Korean, and Japanese. Triggering
on only English phrases leaves gaps. Append localized triggers for both
Korean (Hangul) and Japanese (Hiragana/Katakana).

#### Edge cases

- If the skill is genuinely language-specific (e.g. a Japanese-comments
  enforcer), weight the primary language's triggers accordingly but
  still include cross-language fallbacks.

---

### B3 — Proactive-suggest phrasing

**Rubric source:** github.com/anthropics/skills skill-creator — "Claude has a tendency to 'undertrigger' skills ... make descriptions a little bit 'pushy'."
**Risk:** low

#### BEFORE

```yaml
description: |
  Audits skills against best-practices. Users can invoke it when
  reviewing SKILL.md files.
```

#### AFTER

```yaml
description: |
  Audits skills against best-practices. Proactively suggest this skill
  after any new skill is created or after editing an existing SKILL.md
  — stale or non-conformant skills drift silently.
```

#### Rationale

Without a "Proactively suggest" clause, Claude tends to undertrigger.
The clause invites the model to surface the skill without explicit
request.

#### Edge cases

- Don't make every skill proactive — reserve for skills whose value is
  time-sensitive or catch-a-mistake-early.

---

### B4 — Concrete trigger phrases ≥3

**Rubric source:** platform.claude.com skills/best-practices — "Be specific and include key terms. Include both what the Skill does and specific triggers/contexts for when to use it."
**Risk:** low

#### BEFORE

```yaml
description: |
  Review skills for compliance. Use when relevant.
```

#### AFTER

```yaml
description: |
  Review skills for compliance. Use when the user says "audit my
  skills", "check SKILL.md compliance", "스킬 검수", or "スキル監査".
```

#### Rationale

"When relevant" is meaningless to a triggering model. Concrete quoted
phrases become retrieval anchors.

#### Edge cases

- Avoid trigger phrases that overlap with other skills' triggers. Check
  `skill-catalog.md` first.

---

## Axis C Entries

### C1 — SKILL.md ≤500 lines

**Rubric source:** platform.claude.com skills/best-practices — "Keep SKILL.md body under 500 lines for optimal performance. If approaching this limit, split content into separate reference files."
**Risk:** high (refactor, not mechanical)

#### BEFORE

`SKILL.md` = 612 lines with three long embedded sections:

- Lines 200–320: "Complete API reference table"
- Lines 400–500: "Troubleshooting gallery with 15 scenarios"
- Lines 510–612: "Example walkthroughs"

#### AFTER

`SKILL.md` = 380 lines. Three new sibling files:

- `reference.md` — former lines 200–320 (120 lines)
- `troubleshooting.md` — former lines 400–500 (100 lines)
- `examples.md` — former lines 510–612 (102 lines)

SKILL.md references each sibling one-level-deep:

```markdown
## API Reference

See [reference.md](reference.md) for the complete table of endpoints.

## Troubleshooting

For the scenario catalog, see [troubleshooting.md](troubleshooting.md).

## Examples

See [examples.md](examples.md) for end-to-end walkthroughs.
```

#### Rationale

Over-length SKILL.md wastes context on every invocation. Progressive
disclosure loads siblings only when Claude decides they're relevant.

#### Edge cases

- Don't split mid-procedure — keep workflow phases intact.
- If a section is truly essential to every invocation (HARD-GATE,
  scoping rules), keep it in SKILL.md even if that means cutting
  elsewhere.

---

### C2 — Reference depth = 1 level

**Rubric source:** platform.claude.com skills/best-practices — "Keep references one level deep from SKILL.md."
**Risk:** medium

#### BEFORE

```
SKILL.md → advanced.md → details.md → api-spec.md
```

#### AFTER

```
SKILL.md → advanced.md
SKILL.md → details.md
SKILL.md → api-spec.md
```

In `SKILL.md`:

```markdown
## Advanced features

**Architecture:** see [advanced.md](advanced.md)
**Detailed behavior:** see [details.md](details.md)
**API spec:** see [api-spec.md](api-spec.md)
```

#### Rationale

Claude may partially-read deeply-nested files, missing content. Flatten
the reference tree so every sibling is discoverable from SKILL.md.

#### Edge cases

- A sibling's internal anchor links (`[foo](#bar)`) are fine — only
  cross-file sibling links count as depth violations.

---

### C3 — TOC for long sibling files (>150 lines)

**Rubric source:** platform.claude.com skills/best-practices — "For reference files longer than 100 lines, include a table of contents at the top."
**Risk:** low

#### BEFORE

`rubric.md` = 280 lines, starts directly with "## Axis A — Frontmatter".

#### AFTER

`rubric.md` = 280 lines, prepended with:

```markdown
## Contents

- [How to Read This Rubric](#how-to-read-this-rubric)
- [Scoring](#scoring)
- [Axis A — Frontmatter Compliance](#axis-a--frontmatter-compliance)
- [Axis B — Description Quality](#axis-b--description-quality)
- [Axis C — Body Structure](#axis-c--body-structure)
- [Axis D — Project Conventions](#axis-d--project-conventions)
- [Appendix A: Source Refresh Procedure](#appendix-a-source-refresh-procedure)
```

#### Rationale

TOC lets Claude see the full scope of a long file even when previewing
with `head`.

#### Edge cases

- Files at 100–150 lines are border cases — add TOC if the structure is
  non-obvious; skip if linear.

---

### C4 — No time-sensitive content

**Rubric source:** platform.claude.com skills/best-practices — "Don't include information that will become outdated."
**Risk:** low

#### BEFORE

```markdown
As of 2024, the latest version of the API is v3. Use v3 for all new
integrations. The current model is Claude 3.5 Sonnet.
```

#### AFTER

```markdown
Use the stable API version documented in the project README. Model
selection follows the project's default; override only when a specific
behavior requires it.

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used <code>api.example.com/v1/messages</code>. No longer
supported.
</details>
```

#### Rationale

Time-stamped facts rot silently. Point to an authoritative source
(project README, version manifest) instead, and quarantine legacy
references in a collapsible section.

#### Edge cases

- "Historical context" in a clearly-labeled old-patterns block is
  acceptable; the rule targets load-bearing current claims.

---

### C5 — Skill name consistency

**Rubric source:** platform.claude.com skills/best-practices — "Use consistent terminology. Choose one term and use it throughout the Skill."
**Risk:** medium

#### BEFORE

```yaml
---
name: skill-auditor
---

# Skill Audit

Invoke `/skillaudit` to run the audit...
```

#### AFTER

```yaml
---
name: skill-auditor
---

# Skill Auditor

Invoke `/skill-auditor` to run the audit...
```

#### Rationale

Mismatches between frontmatter name and body references confuse both
Claude and users. `/slash-commands` must match the frontmatter name
exactly.

#### Edge cases

- Aliases documented in the description (e.g. "also invokable as X") are
  allowed if the canonical name is used everywhere else.

---

## Axis D Entries

### D1 — evals/evals.json schema conformance

**Rubric source:** Repo convention — 6 of 8 skills use Variant A; prompt-to-plan uses Variant B.
**Risk:** low

#### BEFORE (missing file)

`evals/evals.json` does not exist.

#### AFTER (Variant A skeleton)

```json
{
  "skill_name": "<name>",
  "evals": [
    {
      "id": 1,
      "prompt": "<realistic user query>",
      "expected_output": "<narrative expectation>",
      "files": []
    },
    {
      "id": 2,
      "prompt": "<different scenario>",
      "expected_output": "<narrative expectation>",
      "files": []
    },
    {
      "id": 3,
      "prompt": "<edge case or refusal scenario>",
      "expected_output": "<narrative expectation>",
      "files": []
    }
  ]
}
```

#### Rationale

Evals document intent and enable regression testing. Three evals is the
repo minimum (and Anthropic's guidance).

#### Edge cases

- If mixing variants, pick one and migrate — don't leave a half-typed
  file.
- UPGRADE mode never invents eval prompts. It creates the file with
  placeholders and asks the user to fill them.

---

### D2 — Registration in skill-catalog.md

**Rubric source:** Repo convention — `skill-catalog.md` is the canonical manual registry.
**Risk:** low

#### BEFORE

`skill-catalog.md` has no row for `skill-auditor`.

#### AFTER

Add one row under the correct category section (alphabetical within
category):

```markdown
| skill-auditor | utility/skill-auditor/ | Audit Claude Code skills against Anthropic best-practices + project conventions; propose upgrade diffs | #audit #quality #meta |
```

#### Rationale

skill-catalog.md is the single source of truth for "what skills live
here". Missing entries cause drift.

#### Edge cases

- Maintain alphabetical order within the category block.

---

### D3 — Registration in CLAUDE.md + README.md

**Rubric source:** Repo convention — CLAUDE.md:23-43 and README.md:13-45 host category tables.
**Risk:** low

#### BEFORE

Neither CLAUDE.md nor README.md mentions the skill.

#### AFTER

In CLAUDE.md under `### utility/`:

```markdown
| skill-auditor | Audit skills against Anthropic + project rubric, propose upgrades | #audit #meta |
```

In README.md under `### utility/`:

```markdown
| `/skill-auditor` | Audit skills, propose upgrade diffs for review |
```

Optionally, add a routing hint in CLAUDE.md's routing block:

```
├→ "audit my skills" / "스킬 검수" / "スキル監査"
│   → /skill-auditor
```

#### Rationale

Both files are user-facing navigation. Skipping one leaves users with
an inconsistent picture of available tooling.

#### Edge cases

- If a skill is intentionally unlisted (e.g. internal-only), use
  `user-invocable: false` in frontmatter and skip the tables — but
  document the choice.

---

### D4 — HARD-GATE for evidence-bearing skills

**Rubric source:** Repo convention — see project-analyzer:27-31, workflow-blueprint:38-41.
**Risk:** medium

#### BEFORE

`SKILL.md` body mentions "file:line evidence" and "trace" repeatedly
but lacks a HARD-GATE block.

#### AFTER

Add near the top of SKILL.md:

```markdown
<HARD-GATE>
Every Pass/Warn/Fail verdict must cite file:line evidence from the
audited skill. No claim without evidence. If a check cannot be
verified from file contents, mark it SKIP and explain why. Do NOT
infer author intent. Do NOT speculate.
</HARD-GATE>
```

#### Rationale

Long analytical workflows tend to drift toward speculation. HARD-GATE
is a self-reminder that anchors Claude to the evidence rule throughout
the session.

#### Edge cases

- Not every skill needs a HARD-GATE. The rule triggers only when the
  body uses evidence vocabulary ≥2 times.
- Keep the block terse — 3-5 lines. Long HARD-GATEs get ignored.

---

## Axis E Entries (online-only)

### E1 — Rubric quote freshness

**Rubric source:** `rubric.md` Appendix A — manual refresh procedure
**Risk:** medium (affects `rubric.md`, which shapes every future audit)

#### BEFORE

Stored quote in `rubric.md`:

```
Source: platform.claude.com/.../overview — "description: Must be non-empty ... Maximum 1024 characters."
```

Live page now reads: "description: non-empty string, max 1024 characters."

#### AFTER

Update `rubric.md` A2 Source field to the new live quote **and** bump the
rubric version comment at the top (e.g. `1.1.0 → 1.1.1`). Keep the URL.

#### Rationale

When Anthropic's docs evolve, the stored quote must follow or the rule
claim loses provenance. This is the whole reason E1 exists.

#### Edge cases

- If the underlying rule changed (not just the wording), update `Check` +
  `Pass` too — not just the quote. Flag as risk=high and ask the user.
- If a URL 404s, replace with the closest live equivalent rather than
  removing the check.

---

### E2 — External skill comparison

**Rubric source:** `github.com/anthropics/skills/skill-creator` — reference pattern
**Risk:** low (advisory)

#### BEFORE

Audited skill has no `## When to Use` section while 4/5 reference skills
in `anthropics/skills/skills/*/SKILL.md` do.

#### AFTER

Add a `## When to Use` section to the audited SKILL.md body, listing
concrete triggering scenarios (not a restatement of the description).

#### Rationale

Reference skills represent Anthropic's own opinion on skill structure.
Deviating is allowed but should be intentional.

#### Edge cases

- If the audited skill is a specialized one-off (e.g. a code-transformer
  with a single clear trigger), a "When to Use" section may be redundant.
  Justify inline rather than adding cargo-cult sections.

---

### E3 — Similar-skill consolidation

**Rubric source:** `find-skills` discovery
**Risk:** medium (may suggest deprecation or rename)

#### BEFORE

`find-skills` returns `gstack/qa` with ≥80% trigger overlap against the
audited `myrepo/test-runner` skill — `gstack/qa` has more downloads and a
wider fix loop.

#### AFTER

Either (a) deprecate `test-runner` and document the migration path in the
repo README, or (b) differentiate by trimming triggers to a narrower niche
(e.g. "TDD red-green loop") and updating the description to emphasize the
distinction.

#### Rationale

Two skills with 80% trigger overlap fight each other in discovery. The
user's intent won't resolve cleanly. Consolidate or specialize.

#### Edge cases

- If the overlapping skill is in a private registry the user doesn't use,
  downgrade the finding to Warn and keep both.
- Never auto-delete an existing skill to resolve E3 — always propose
  migration first.

---

## Axis F Entries (longevity & compounding)

Rules in this axis come from Karpathy's LLM-wiki gist (see `rubric.md`
Appendix B). They check whether the skill is a compounding artifact, not
a one-shot aid.

### F1 — Index + schema consistency

**Rubric source:** Karpathy gist — "Maintain an index file … cataloging all wiki pages"
**Risk:** low

#### BEFORE

`skill-catalog.md` row for `my-skill` uses different column order than
the 8 sibling rows:

```
| my-skill | Some description | #tag | my-area/my-skill/ |
```

(rest of file uses `Skill | Path | Description | Tags`)

#### AFTER

```
| my-skill | my-area/my-skill/ | Some description | #tag |
```

#### Rationale

Consistent column order lets readers — human and LLM — scan the catalog
by position. Divergent rows break parsing and silently demote the skill
in discovery.

#### Edge cases

- If the whole catalog migrates to a new schema, update every row in one
  transaction; never mix old + new layouts.

---

### F2 — Append-only audit archive

**Rubric source:** Karpathy gist — "Keep an append-only chronological log"
**Risk:** medium

#### BEFORE

Running `skill-auditor` today rewrites `docs/skill-audit/2026-04-12/INDEX.md`
with today's data — historical audit lost.

#### AFTER

Today's run writes a new directory `docs/skill-audit/2026-04-19/` and
leaves `2026-04-12/` untouched. Only post-UPGRADE re-audit overwrites
the affected skill's report within the same day's directory (per
SKILL.md Phase 5).

#### Rationale

Historical audits are the evidence trail for rubric-drift detection
(E1) and for tracking whether specific skills regress over time. Rewriting
them destroys that evidence.

#### Edge cases

- If a partial audit failed mid-run, mark its directory with a
  `INCOMPLETE.md` file rather than deleting it.

---

### F3 — Anti-pattern section quality

**Rubric source:** Karpathy gist (explicit Do / Do-Not blocks) + softaworks/skill-judge Anti-Pattern Quality dimension
**Risk:** low

#### BEFORE

A 250-line skill whose body is entirely happy-path instructions ("Do X",
"Then do Y") with no prohibitions:

```markdown
## Workflow
1. Read the config
2. Apply the transform
3. Write the output
```

#### AFTER

```markdown
## Workflow
1. Read the config
2. Apply the transform
3. Write the output

## Anti-patterns

- **Do NOT transform in place.** A crashed write leaves the user with
  corrupt state. Always write to `<name>.tmp` then atomic-rename.
- **Do NOT infer schema from filename.** Open the config and verify —
  filename conventions rot.
```

#### Rationale

Failure modes are more informative than success recipes. Karpathy's gist
and skill-judge both treat explicit "do not / because" blocks as a
first-class quality signal.

#### Edge cases

- Skills <100 lines of procedural guidance are exempt. Don't pad with
  invented anti-patterns.

---

### F4 — Schema-linting self-consistency

**Rubric source:** Karpathy gist — "Lint the wiki periodically: check contradictions, flag stale claims, identify orphan pages"
**Risk:** medium

#### BEFORE

`<skill-dir>/notes.md` mentions the skill as `/my_skill` (underscore
typo) while SKILL.md frontmatter declares `name: my-skill`. Also:
`<skill-dir>/draft.md` exists but SKILL.md never links to it.

#### AFTER

1. Edit `notes.md` to use `/my-skill` consistently.
2. Either link `draft.md` from SKILL.md's references table, move it to
   `resources/` or `templates/`, or delete it if stale.

#### Rationale

Orphan files are dead context that Claude may partially load; mismatched
names confuse discovery. A periodic lint catches both before they
accumulate.

#### Edge cases

- Siblings under `resources/` or `templates/` are assumed to be loaded
  dynamically — not linking them from SKILL.md is OK.
- If the orphan is a historical artifact the user wants to preserve,
  link it from SKILL.md under a "History" section rather than leaving it
  unreferenced.
