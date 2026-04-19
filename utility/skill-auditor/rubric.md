# Skill Auditor Rubric

Scored checklist used by the `skill-auditor` skill. 17 offline items across
4 axes (A–D) + 3 optional online items (E1–E3). Every item is self-contained:
source URL + verbatim quote + deterministic pass criterion.

> **Rubric version:** 1.3.1 (2026-04-19)
> Changelog:
> - 1.1.0: added Axis E (E1 source freshness, E2 external comparison,
>   E3 similar-skill discovery) — gated on `--online` flag.
> - 1.2.0: added Trusted Sources Registry with tiered semantics
>   (authoritative / widely-adopted / community-curated); E2 now iterates
>   Tier 1–2 refs, E3 escalates to Fail only on ≥2-source corroboration.
> - 1.3.0: added Axis F (Longevity & Compounding) — F1 index consistency,
>   F2 append-only archive, F3 anti-pattern guidance, F4 schema lint —
>   inspired by Karpathy's LLM-wiki gist (see Appendix B). Registry now
>   includes skills.sh, softaworks/skill-judge, and Karpathy's gist.
> - 1.3.1: E1-drift fixes — A1 now also checks `name: Cannot contain XML
>   tags` (new live rule); A1/B3 verbatim quotes refreshed to match live
>   docs; A4 re-sourced from skill-creator to platform.claude.com
>   security-considerations (skill-creator no longer carries the quote).
> When official sources change, refresh quotes per Appendix A.

## Contents

- [How to Read This Rubric](#how-to-read-this-rubric)
- [Scoring](#scoring)
- [Axis A — Frontmatter Compliance](#axis-a--frontmatter-compliance) (A1–A4)
- [Axis B — Description Quality](#axis-b--description-quality) (B1–B4)
- [Axis C — Body Structure](#axis-c--body-structure) (C1–C5)
- [Axis D — Project Conventions](#axis-d--project-conventions) (D1–D4)
- [Axis E — Online Corroboration](#axis-e--online-corroboration---online-mode-only) (E1–E3, optional)
- [Axis F — Longevity & Compounding](#axis-f--longevity--compounding) (F1–F4)
- [Appendix A: Source Refresh Procedure](#appendix-a-source-refresh-procedure)
- [Appendix B: Karpathy LLM-Wiki Principles](#appendix-b-karpathy-llm-wiki-principles)

## How to Read This Rubric

Each item follows this schema:

```
### <id>. <name>
- Check:        What gets verified
- Method:       How (Read / Grep / Glob / regex / JSON parse / line count)
- Source:       <URL> — "<verbatim quote, ≤20 words>"
- Pass:         Deterministic binary rule
- Risk:         low | medium | high (gates UPGRADE auto-apply)
- Tool-assist:  SkillCheck-Free | Agnix | — (optional external linter)
```

Risk levels control UPGRADE behavior:

- **low** — May be batch-applied via `--yes-all`
- **medium** — Always requires per-item approval
- **high** — Requires explicit "yes high" confirmation; renames, refactors, deletions

## Scoring

Per skill:
- Pass = 1.0
- Warn = 0.5
- Fail = 0.0
- SKIP = not counted (denominator reduced)

`score = Σ(item_score) / count(scored_items)`

Classification:
- **green** ≥ 0.90
- **yellow** 0.70–0.89
- **red** < 0.70

---

## Axis A — Frontmatter Compliance

Verify YAML frontmatter conforms to Anthropic's official skill schema.
Frontmatter is the only metadata Claude pre-loads, so violations here
silently break skill discovery.

### A1. name field format

- **Check:** `name` is lowercase letters / digits / hyphens only, ≤64 chars, not a reserved word ("anthropic", "claude"), and contains no XML tags.
- **Method:** Read SKILL.md lines 1–20, extract `name:` value, apply regex `^[a-z0-9]+(-[a-z0-9]+)*$` and `len ≤ 64`, reject if matches `(?i)(anthropic|claude)`, reject if matches `<[A-Za-z/]`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — "Maximum 64 characters / Must contain only lowercase letters, numbers, and hyphens / Cannot contain XML tags / Cannot contain reserved words: 'anthropic', 'claude'."
- **Pass:** All four checks true.
- **Warn:** Never — binary.
- **Risk:** low (rename is mechanical) → **high** if the skill is referenced in `CLAUDE.md` routing block or other skills' bodies (requires cross-file update).
- **Tool-assist:** SkillCheck-Free

### A2. description length ≤1024 chars

- **Check:** The `description` field is non-empty and ≤1024 characters after YAML multiline folding.
- **Method:** Read frontmatter, concatenate multiline description (YAML `|` or `>` blocks), count UTF-8 characters.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — "description: Must be non-empty ... Maximum 1024 characters."
- **Pass:** `1 ≤ len(description) ≤ 1024`.
- **Warn:** `1000 < len ≤ 1024` (within 24 chars of the limit — advisory).
- **Risk:** medium (truncation changes trigger coverage; must preserve trigger phrases).
- **Tool-assist:** SkillCheck-Free

### A3. description XML-tag-free

- **Check:** The description body contains no XML tags. Angle brackets would be injected into the system prompt and can confuse parsing.
- **Method:** Grep `<[A-Za-z/]` inside the description block. Ignore legitimate comparison operators in plain prose (`<3`, `x < y`) by requiring an alpha or `/` after `<`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — "description ... Cannot contain XML tags."
- **Pass:** 0 matches.
- **Risk:** low (escape or rephrase).
- **Tool-assist:** SkillCheck-Free

### A4. allowed-tools hygiene

- **Check:** Every dangerous tool (`Write`, `Edit`, `Bash`) listed in `allowed-tools` is actually referenced at least once in the SKILL.md body or is justified by a workflow phase that needs it. Listing tools the skill never uses inflates its blast radius.
- **Method:** Read `allowed-tools` list, for each of `Write|Edit|Bash` grep SKILL.md body for the tool name, verb forms ("write", "edit", "run", "execute"), or a justifying phrase.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — security-considerations section: "Audit thoroughly ... Skills that fetch data from external URLs pose particular risk ... Tool misuse: Malicious Skills can invoke tools (file operations, bash commands, code execution) in harmful ways." Principle: minimize granted-tool surface to what the body actually uses.
- **Pass:** Every dangerous tool has at least one body reference.
- **Warn:** Dangerous tool referenced only in commented-out / placeholder block.
- **Risk:** medium (removing a tool can break execution; always per-item approval).
- **Tool-assist:** Agnix

---

## Axis B — Description Quality

Verify description triggers discovery effectively per skill-creator best
practices. Anthropic docs note that Claude *undertriggers* skills by default,
so descriptions must be assertive, specific, and written in third-person.

### B1. Third-person framing

- **Check:** Description does not start with first-person ("I ", "I'll", "I can") or second-person ("You ", "Your ") or meta-preamble ("This skill ", "This is ").
- **Method:** Extract first 40 characters of description (after frontmatter strip and whitespace trim), apply regex `^(You|Your|I |I'll|I can|This skill|This is)`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems."
- **Pass:** No match.
- **Risk:** low (rewrite opening clause).
- **Tool-assist:** —

### B2. Multilingual triggers (EN / KO / JA)

- **Check:** Description contains at least one Hangul codepoint AND one Hiragana/Katakana codepoint, in addition to ASCII English trigger phrases. This is a **project convention** (all 8 existing skills do this).
- **Method:** Regex `[\uAC00-\uD7AF]` (Hangul) and `[\u3040-\u309F\u30A0-\u30FF]` (Hiragana + Katakana) on the description body.
- **Source:** This repo's convention — see `workflow/prompt-to-plan/SKILL.md:1-15`, `workflow/write-plan/SKILL.md:1-18`, and 6 other skills. **Not an Anthropic rule** — project-specific.
- **Pass:** Both regexes match at least once.
- **Warn:** Only one of the two scripts present.
- **Risk:** low (append trigger phrases).
- **Tool-assist:** —

### B3. Proactive-suggest phrasing

- **Check:** Description contains explicit invitation for Claude to offer the skill without being asked. Literal phrases: "Proactively suggest", "Use this skill whenever", "Trigger when", or equivalent pushy wording.
- **Method:** Case-insensitive grep for any of: `proactively suggest`, `use this skill whenever`, `trigger when`, `make sure to use`.
- **Source:** https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md — "currently Claude has a tendency to 'undertrigger' skills -- to not use them when they'd be useful. To combat this, please make the skill descriptions a little bit 'pushy'."
- **Pass:** At least one phrase present.
- **Risk:** low (append a single sentence).
- **Tool-assist:** —

### B4. Concrete trigger phrases ≥3

- **Check:** Description lists at least 3 concrete trigger phrases in quotes. Vague descriptors ("when needed", "for relevant tasks") do not count.
- **Method:** Count quoted string literals in the description block (double-quotes or curly-quotes). Must be ≥3 distinct non-empty strings.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Be specific and include key terms. Include both what the Skill does and specific triggers/contexts for when to use it."
- **Pass:** ≥3 distinct quoted triggers.
- **Warn:** 1–2 quoted triggers present.
- **Risk:** low (add trigger phrases).
- **Tool-assist:** —

---

## Axis C — Body Structure

Verify SKILL.md body follows Anthropic's progressive-disclosure and
authoring guidance. Violations here waste context budget and cause Claude
to partially-read files.

### C1. SKILL.md ≤500 lines

- **Check:** SKILL.md body (including frontmatter) does not exceed 500 lines. Anthropic's canonical limit.
- **Method:** `wc -l` on SKILL.md path.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Keep SKILL.md body under 500 lines for optimal performance. If approaching this limit, split content into separate reference files."
- **Pass:** ≤450 lines (buffer).
- **Warn:** 451–500 lines (approaching limit — plan to split).
- **Fail:** >500 lines.
- **Risk:** high (splitting requires judgment about which sections move to siblings; not a mechanical transform).
- **Tool-assist:** SkillCheck-Free

### C2. Reference depth = 1 level

- **Check:** Sibling markdown files referenced from SKILL.md must not themselves reference other siblings. Claude may partially read deeply-nested files (via `head -100`), causing incomplete context.
- **Method:** Glob `<skill-dir>/*.md` excluding SKILL.md. For each sibling, Grep markdown links `\[.*\]\(.*\.md\)` that resolve to another sibling (not SKILL.md, not absolute URLs).
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md to ensure Claude reads complete files when needed."
- **Pass:** No cross-sibling links.
- **Warn:** Cross-sibling link exists but points to a TOC/index file (acceptable pattern).
- **Risk:** medium (restructuring references can break navigation flow).
- **Tool-assist:** —

### C3. TOC for long sibling files (>150 lines)

- **Check:** Any sibling `.md` file longer than 150 lines contains a Table of Contents or `## Contents` section within its first 30 lines.
- **Method:** For each sibling with `wc -l > 150`, grep first 30 lines for `^## (Contents|Table of Contents|Overview)$`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "For reference files longer than 100 lines, include a table of contents at the top. This ensures Claude can see the full scope of available information even when previewing with partial reads."
- **Pass:** Every sibling >150 lines has a TOC, or no sibling exceeds 150 lines.
- **Risk:** low (prepend TOC — mechanical).
- **Tool-assist:** —

### C4. No time-sensitive content

- **Check:** Body does not contain phrases that will become stale: "as of YYYY", "latest version", "currently", "for now", "current model". These rot silently.
- **Method:** Case-insensitive Grep for: `as of \d{4}`, `latest version`, `currently supports`, `current (model|version)`, `for now`, `at the moment`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Don't include information that will become outdated."
- **Pass:** 0 matches.
- **Warn:** Match present but within a clearly-labeled `## Old patterns` or `<details>` block.
- **Risk:** low (rephrase or move to old-patterns section).
- **Tool-assist:** SkillCheck-Free

### C5. Skill name consistent across frontmatter and body

- **Check:** The skill name declared in frontmatter matches all body references. No stale names, no typos, no `/old-skill-name` slash-command mentions.
- **Method:** Extract frontmatter `name`. Grep body for `/<any-kebab-name>` slash-commands and any plaintext near-matches (within edit distance 2 of the name). Flag mismatches.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — "Use consistent terminology. Choose one term and use it throughout the Skill."
- **Pass:** All body references match the frontmatter name exactly.
- **Warn:** Minor formatting variants (e.g. `skill_name` vs `skill-name`) — flag but do not fail.
- **Risk:** medium (renames can miss references; always per-item review).
- **Tool-assist:** —

---

## Axis D — Project Conventions

Verify skill integrates with this repo's registration + convention surface.
These are **project-specific rules** (not Anthropic-canonical) derived from
`CLAUDE.md`, `skill-catalog.md`, and the installer contract.

### D1. evals/evals.json schema conformance

- **Check:** File exists, parses as JSON, has top-level `skill_name` string + `evals` array with ≥3 entries. Each entry follows Variant A (`id`/`prompt`/`expected_output`/`files`) or Variant B (`skills`/`query`/`files`/`expected_behavior`) **consistently** — no mixing within one file.
- **Method:** Read path `<skill-dir>/evals/evals.json`. Parse JSON. Schema-check top level. Classify each eval as Variant A or B. Verify all entries use the same variant.
- **Source:** This repo's convention — 6 of 8 skills use Variant A (`utility/project-analyzer/evals/evals.json`, `workflow/write-plan/evals/evals.json`, etc.); `workflow/prompt-to-plan/evals/evals.json` uses Variant B. Anthropic's skill-creator prescribes Variant A shape; Variant B is a project extension.
- **Pass:** File exists, parses, ≥3 evals, consistent variant.
- **Warn:** ≥3 evals but mixed variants within the file.
- **Fail:** File missing, unparseable, or <3 evals.
- **Risk:** low (additive; never delete existing evals to fix count).
- **Tool-assist:** —

### D2. Registration in skill-catalog.md

- **Check:** The skill appears as a row in `/Users/yu_s/Documents/GitHub/claude-skills/skill-catalog.md` with the correct path.
- **Method:** Read `skill-catalog.md`. Regex `\| <name> \| <category>/<name>/` must match.
- **Source:** This repo's convention — `skill-catalog.md` is the canonical manual registry (header: `<!-- Manual registry for claude-skills -->`).
- **Pass:** Row present with matching path.
- **Warn:** Row present but path or description outdated.
- **Risk:** low (add/fix one row).
- **Tool-assist:** —

### D3. Registration in CLAUDE.md + README.md

- **Check:** The skill appears in the category table in both `CLAUDE.md` and `README.md`. Optional: routing hint in `CLAUDE.md` routing block.
- **Method:** Grep both files for `| <name> |` or `/<name>` in the correct category section.
- **Source:** This repo's convention — `CLAUDE.md:23-43` (category tables), `README.md:13-45` (category tables).
- **Pass:** Row present in both files' category tables.
- **Warn:** Row in one but not the other.
- **Risk:** low (add/fix one row per file).
- **Tool-assist:** —

### D4. HARD-GATE for evidence-bearing skills (conditional)

- **Check:** Skills whose SKILL.md body uses evidence-bearing vocabulary (file:line citations, trace, verify, audit) must contain a `<HARD-GATE>` block asserting the evidence rule. This prevents Claude from slipping into speculation during long analyses.
- **Method:** Count body occurrences of `evidence|trace|verify|file:line|audit|forensic`. If count ≥2, grep for `<HARD-GATE>`. If count <2, mark SKIP (rule does not apply to skills without evidence mandate).
- **Source:** This repo's convention — see `utility/project-analyzer/SKILL.md:27-31`, `workflow/workflow-blueprint/SKILL.md:38-41`, `workflow/workflow-blueprint-update/SKILL.md:42-46`. Not an Anthropic rule.
- **Pass:** `<HARD-GATE>` block present when trigger keywords ≥2, OR trigger keywords <2 (SKIP).
- **Warn:** HARD-GATE block present but lacks explicit "no speculation" / "no guessing" language.
- **Fail:** Trigger keywords ≥2 and no HARD-GATE block.
- **Risk:** medium (adding HARD-GATE is mechanical, but wording matters; per-item approval).
- **Tool-assist:** —

---

## Axis E — Online Corroboration (--online mode only)

Items E1–E3 run **only when the auditor is invoked with `--online`**. They use
network tools (WebFetch, WebSearch, Skill tool for `find-skills`) to cross-check
against live sources. Off by default to keep default runs deterministic.

### E1. Rubric source freshness (quote drift detection)

- **Check:** For each canonical URL in Appendix A, the verbatim quote stored in
  this `rubric.md` still appears in the live document. Drift means Anthropic's
  guidance moved on and the rubric item may now check the wrong rule.
- **Method:** WebFetch each URL in [Canonical Sources](#canonical-sources-maintained-set).
  For each rubric item A1–D4, substring-search the quote in the fetched body.
- **Source:** This skill's own design — freshness matters because the rubric
  is a frozen snapshot (Appendix A refresh procedure).
- **Pass:** Every stored quote found in its live URL.
- **Warn:** Quote found with minor wording diff (≥90% token overlap).
- **Fail:** Quote absent — the rule may no longer be sourced. Append a
  **rubric-drift finding** to the audit report; do not silently change scoring.
- **Risk:** medium (touches rubric.md, which affects all future audits).
- **Tool-assist:** WebFetch

### E2. External skill comparison (reference patterns)

- **Check:** The audited skill's structure is compared against reference
  skills from the Trusted Sources Registry. Flag obvious deviations:
  missing section types that ≥2 reference skills carry, unusual
  frontmatter-field usage, inconsistent progressive-disclosure depth.
- **Method:**
  1. Start with Tier 1/2 (`github.com/anthropics/skills`):
     WebFetch `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md`.
  2. If the audited skill targets a category skill-creator doesn't cover
     (e.g. DX audit, frontend design), `WebSearch` the Trusted Sources
     Registry for the closest reference (e.g. "site:github.com/anthropics/skills
     <category>"), then WebFetch the closest match. Stop after 3 fetches
     to bound cost.
  3. Extract section headings + frontmatter field set from each fetched
     reference. Build the union.
  4. Compare with the audited skill; report structural gaps found in ≥2
     references as advisory findings.
- **Source:** Trusted Sources Registry, Tiers 1–2.
- **Pass:** No structural gap, OR the gap is justified by the skill's
  specialization.
- **Warn:** Structural gap with no in-body justification (e.g. no "When to
  Use" section while ≥2 reference skills carry one).
- **Risk:** low — findings are advisory, not mandatory.
- **Tool-assist:** WebFetch + WebSearch

### E3. Similar-skill discovery (duplicate / overlap detection)

- **Check:** No widely-used public skill covers the same trigger space with
  a significantly better-known name or richer feature set. This protects
  against reinventing an existing skill under a different name.
- **Method:** Run in this priority order; stop at the first that succeeds:
  1. **Primary** — `Skill(skill: "find-skills", args: "<top 3 trigger phrases>")`.
     If the call errors with `Unknown skill`, fall through to step 2.
  2. **Secondary** — WebFetch `https://registry.modelcontextprotocol.io`
     search API (or the MCP registry homepage) with the top trigger phrases.
     Extract any MCP skill/tool with ≥60% trigger overlap.
  3. **Tertiary** — WebSearch `"<skill trigger phrase>" site:github.com topic:claude-skills`
     and `topic:claude-code-skills`. WebFetch each top-3 SKILL.md and
     measure trigger overlap against the audited skill.
  Stop at step 2 if MCP registry yields ≥2 matches. Escalate to Fail only
  when ≥2 independent Trusted Sources agree on ≥80% overlap.
- **Source:** Trusted Sources Registry, Tier 3 (plus `find-skills` Tier
  3-primary if installed).
- **Pass:** No overlap from any Tier 3 source, OR overlap is with a sibling
  skill in the same repo (intentional).
- **Warn:** External skill overlaps ≥60% of triggers from a single Tier 3
  source AND has ≥3× the community usage signal (star count, MCP registry
  presence).
- **Fail:** External skill supersedes the audited skill (≥80% overlap
  corroborated across ≥2 Tier 3 sources). Recommend consolidation in the
  report — do NOT auto-delete.
- **Risk:** medium (suggests renames or deprecations).
- **Tool-assist:** Skill (`find-skills`) + WebFetch + WebSearch

---

## Axis F — Longevity & Compounding

These rules come from Karpathy's LLM-wiki gist (Appendix B). They check
whether a skill is a **persistent, compounding artifact** — something that
keeps accruing value across sessions — rather than a one-shot query-time
aid that has to be re-derived each run. All F items run offline; they are
static checks on the skill's convention surface.

### F1. Index + schema consistency

- **Check:** The repo has both (a) a schema/convention file (`CLAUDE.md`
  or `AGENTS.md`) declaring how skills are organized, and (b) an index
  file (`skill-catalog.md` or equivalent) cataloging every skill. The
  audited skill appears in both and its row matches the schema's declared
  format.
- **Method:** Read `CLAUDE.md` + `skill-catalog.md`. Verify the audited
  skill's row in `skill-catalog.md` conforms to the column order declared
  (or implied by the majority of rows). Verify `CLAUDE.md` references the
  same skill under the same name.
- **Source:** Karpathy gist — "Maintain an index file … cataloging all
  wiki pages" + "Create a schema file (e.g., CLAUDE.md) defining wiki
  structure, conventions, and workflows".
- **Pass:** Both files present, audited skill appears in both with
  matching formatting.
- **Warn:** Row present but column order or tag format diverges from
  other rows.
- **Fail:** Skill missing from `skill-catalog.md` or not referenced in
  `CLAUDE.md`. (This overlaps D2/D3 — F1 is the *structural consistency*
  layer on top of *presence*.)
- **Risk:** low (formatting fix in one row).
- **Tool-assist:** —

### F2. Append-only audit archive

- **Check:** Prior audits are preserved under
  `docs/skill-audit/YYYY-MM-DD/` without in-place rewriting. Each audit
  run writes a new dated directory; older reports are not modified except
  for the same-day re-audit after UPGRADE (which overwrites only the
  affected skill's report and the day's INDEX).
- **Method:** Glob `docs/skill-audit/*/INDEX.md`. If ≥2 exist, verify
  their dates are distinct and the older files' timestamps haven't been
  rewritten today. If only 1 exists, mark SKIP (not enough history to
  evaluate).
- **Source:** Karpathy gist — "Keep an append-only chronological log
  documenting ingests, queries, and maintenance actions" + "Use
  consistent naming conventions for log entries (e.g., `## [DATE]
  operation | description`)".
- **Pass:** ≥2 dated audit directories present; no back-dated overwrite
  detected.
- **Warn:** Same-day re-audit detected but only the affected skill's
  report was rewritten (expected UPGRADE behavior) — mark Warn if the
  INDEX lost historical entries.
- **Fail:** Prior audit directory was deleted or older dates were
  overwritten wholesale.
- **Risk:** medium (touches audit history).
- **Tool-assist:** —

### F3. Anti-pattern section quality

- **Check:** If the skill body has more than 100 lines of procedural
  guidance, it should include at least one explicit "Do NOT / Avoid /
  Anti-pattern" block with specific reasoning — not just happy-path
  instructions.
- **Method:** If SKILL.md body >100 lines: grep for `NEVER`, `Do not`,
  `Avoid`, `Anti-pattern`, `❌`, `Don't`. Count blocks containing ≥1
  reasoning sentence after the prohibition.
- **Source:** Karpathy gist — "DO NOT allow the LLM to unilaterally
  rewrite sections without human verification" (example of explicit
  anti-pattern with reasoning). Also softaworks/skill-judge "Anti-Pattern
  Quality" dimension (15 pts in their rubric).
- **Pass:** ≥1 anti-pattern block with reasoning, OR body ≤100 lines
  (anti-pattern section not required for short skills).
- **Warn:** Anti-pattern keyword found but no reasoning sentence follows
  ("Don't do X." without the *why*).
- **Fail:** Body >100 lines with zero prohibition language.
- **Risk:** low (additive edit to SKILL.md).
- **Tool-assist:** —

### F4. Schema-linting self-consistency

- **Check:** The audited skill's sibling reference files (*.md under
  `<skill-dir>/`, excluding evals/ and evals-workspace/) do not
  contradict each other: same skill name, same `/slash-command`,
  compatible version/date if declared, and no orphaned siblings (every
  sibling should be linked from SKILL.md at least once).
- **Method:**
  1. Glob siblings.
  2. For each sibling, grep for `name:` or the skill's kebab name — flag
     if the mentioned name differs from SKILL.md's frontmatter `name`.
  3. For each sibling, check SKILL.md body for a link to that sibling
     (`](sibling-filename.md)` or `[sibling-filename](...)`) — flag
     orphans.
- **Source:** Karpathy gist — "Lint the wiki periodically: check
  contradictions, flag stale claims, identify orphan pages".
- **Pass:** No name contradictions, no orphan siblings.
- **Warn:** Orphan sibling exists but is a template/resource that may be
  loaded dynamically (matches `resources/*`, `templates/*`).
- **Fail:** Name contradiction (sibling uses different skill name than
  frontmatter) OR orphan sibling not under `resources/` or `templates/`.
- **Risk:** medium (fixing orphan may involve rename or linkage).
- **Tool-assist:** —

---

## Appendix A: Source Refresh Procedure

When Anthropic's official skill docs are updated, refresh this rubric's
embedded quotes manually:

1. WebFetch each canonical URL listed below
2. Compare against the stored `Source` quote
3. If the quote is stale but the underlying rule unchanged, update the quote
4. If the rule itself changed, update `Check` / `Pass` / `Method` as needed
5. Bump the version comment at the top of this file

### Canonical Sources (maintained set)

Primary sources for offline rubric quotes (A1–D4). These are
**verbatim-quoted** in rubric items and refreshed manually per Appendix A.

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://code.claude.com/docs/en/skills
- https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md

### Trusted Sources Registry (online-mode corroboration)

These sources are consulted by Axis E (E1/E2/E3) when `--online` is active.
They are **not** verbatim-quoted in rubric items — they provide live
corroboration signals. Each entry lists the domain, what it's used for,
and which rubric item consumes it.

| Tier | Source | Usage | Item |
|------|--------|-------|------|
| 1 (authoritative) | platform.claude.com | Anthropic skill-authoring rules | E1 |
| 1 | code.claude.com | Claude Code skill-authoring rules | E1 |
| 1 | github.com/anthropics/skills | Official reference skill collection | E1, E2 |
| 2 (widely-adopted) | github.com/anthropics/skills/tree/main/skills | Category-specific reference SKILL.md | E2 |
| 2 | github.com/anthropics/claude-code | Claude Code product reference (features, slash commands, hooks) | E2 fallback |
| 2 | docs.anthropic.com (if distinct from platform) | API / product docs for context | E2 fallback |
| 2 | gist.github.com/karpathy/442a6bf555914893e9891c11519de94f | Karpathy's LLM-wiki principles — consulted by Axis F (see Appendix B) | F-axis |
| 2 | skills.sh (vercel-labs/skills registry) | Install-count leaderboard for Tier 3 overlap corroboration | E3 |
| 2 | github.com/softaworks/agent-toolkit/tree/main/skills/skill-judge | Independent skill-quality rubric (8-axis / 120-pt system) — cross-compared during rubric refresh | E1, F3 |
| 3 (community-curated) | registry.modelcontextprotocol.io | Public MCP servers/skills → E3 overlap detection | E3 |
| 3 | github.com/topics/claude-skills | Community skill repos — trigger overlap search | E3 |
| 3 | github.com/topics/claude-code-skills | Community skill repos — trigger overlap search | E3 |
| 3 | `find-skills` Skill (if installed) | Aggregated local + community registry | E3 primary |

**Tier semantics:**

- **Tier 1** — Authoritative. Findings Fail/Warn carry weight.
- **Tier 2** — Widely adopted but not normative. Findings are Warn at most.
- **Tier 3** — Community signals. Findings are advisory (report-only) unless
  overlap exceeds 80% across multiple Tier 3 sources simultaneously (→ Fail).

### Trusted Sources — rules of thumb

1. **Never fetch a domain not in this registry.** If a new authoritative
   source appears, add it here first, then update the E-item's Method.
2. **Cross-check Tier 3 findings with ≥2 independent sources before escalating
   to Fail.** One overlapping skill in one registry is not enough evidence.
3. **Link rot protocol** — if a Tier 1 URL 404s, record it in the audit
   report and fall back to the closest live Tier 2 equivalent. Do NOT
   silently substitute.
4. **`WebSearch` scope** — allowed only to locate canonical URLs within the
   Trusted Sources Registry (e.g. finding the exact reference SKILL.md for a
   given category). Not for free-form web research.

### Why Default-Offline (and When to Use --online)

Default runs never fetch the network, so scores are reproducible across runs
and Anthropic-docs outages. Use `--online` when (a) the rubric version is
more than 30 days old and you want drift detection (E1), or (b) you're
introducing a brand-new skill and want reference/duplicate checks (E2, E3).

---

## Appendix B: Karpathy LLM-Wiki Principles

Source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

The gist outlines how a human + LLM can build a **persistent, compounding
knowledge artifact** instead of re-querying an LLM from scratch each time.
Skills in this repo aim to be that kind of artifact. Axis F encodes the
checkable parts of the gist. The full set of principles (for human
reference, not mechanically scored):

**Human-LLM division of labor**
- Human curates sources, asks the right questions, verifies outputs.
- LLM does grunt work: ingestion, cross-referencing, synthesis, linting.
- **Never** let the LLM unilaterally rewrite sections — verification first.

**Persistent, compounding artifact**
- Build once; re-read many times. Do not re-derive knowledge per query.
- Synthesis and cross-references are pre-computed, not regenerated.
- Source documents stay **immutable**; summaries are separate artifacts.

**Concrete workflow rules**
- Maintain an **index file** cataloging every page + summary (→ F1).
- Keep an **append-only chronological log** with consistent naming
  (`## [DATE] operation | description`) for parsability (→ F2).
- Update 10–15 pages per source ingested; touch cross-references
  immediately.
- **Lint periodically**: check contradictions, flag stale claims, identify
  orphan pages (→ F4).

**Schema + configuration**
- Declare structure/conventions/workflows in a schema file
  (`CLAUDE.md` / `AGENTS.md`).
- Co-evolve the schema with actual use cases (→ F1).

**Search strategy**
- At scale, keyword search alone degrades — implement hybrid search
  (BM25 + vector + re-ranking). Single-source discovery is fragile;
  corroborate across ≥2 sources (see Trusted Sources rules-of-thumb #2).

**Anti-patterns**
- Assuming the artifact will self-maintain without structured workflows.
- Treating generated summaries as replacements for source documents.
- Claiming scalability while depending on "small enough" scale —
  acknowledge the boundary explicitly.

**Human involvement is non-negotiable** in regulated domains (aerospace,
finance, military) — and in this repo, every UPGRADE edit still requires
per-item approval (SKILL.md Phase 3).
