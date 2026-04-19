# Skill Auditor Rubric

Scored checklist used by the `skill-auditor` skill. 17 items across 4 axes.
Every item is self-contained: source URL + verbatim quote + deterministic
pass criterion.

> **Rubric version:** 1.0.0 (2026-04-19)
> When official sources change, refresh quotes per Appendix A.

## Contents

- [How to Read This Rubric](#how-to-read-this-rubric)
- [Scoring](#scoring)
- [Axis A — Frontmatter Compliance](#axis-a--frontmatter-compliance) (A1–A4)
- [Axis B — Description Quality](#axis-b--description-quality) (B1–B4)
- [Axis C — Body Structure](#axis-c--body-structure) (C1–C5)
- [Axis D — Project Conventions](#axis-d--project-conventions) (D1–D4)
- [Appendix A: Source Refresh Procedure](#appendix-a-source-refresh-procedure)

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

- **Check:** `name` is lowercase letters / digits / hyphens only, ≤64 chars, not a reserved word ("anthropic", "claude").
- **Method:** Read SKILL.md lines 1–20, extract `name:` value, apply regex `^[a-z0-9]+(-[a-z0-9]+)*$` and `len ≤ 64`, reject if matches `(?i)(anthropic|claude)`.
- **Source:** https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — "name: Maximum 64 characters ... only lowercase letters, numbers, and hyphens ... Cannot contain reserved words: 'anthropic', 'claude'."
- **Pass:** All three checks true.
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
- **Source:** https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md — principle: "only request tools you actually use".
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
- **Source:** https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md — "Claude has a tendency to 'undertrigger' skills. To combat this, please make the skill descriptions a little bit 'pushy'."
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

## Appendix A: Source Refresh Procedure

When Anthropic's official skill docs are updated, refresh this rubric's
embedded quotes manually:

1. WebFetch each canonical URL listed below
2. Compare against the stored `Source` quote
3. If the quote is stale but the underlying rule unchanged, update the quote
4. If the rule itself changed, update `Check` / `Pass` / `Method` as needed
5. Bump the version comment at the top of this file

### Canonical Sources (maintained set)

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://code.claude.com/docs/en/skills
- https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md

### Why Manual

Runtime network fetches would make AUDIT non-deterministic across runs and
bind skill behavior to Anthropic's docs site uptime. Storing verbatim
quotes in this file gives every AUDIT run the same input.
