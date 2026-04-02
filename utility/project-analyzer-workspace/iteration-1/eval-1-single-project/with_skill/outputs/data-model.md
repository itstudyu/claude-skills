# Data Model -- claude-skills

> Analyzed on 2026-04-02
> Source: /Users/yu_s/Documents/GitHub/claude-skills

## Database Schema

No database schema detected in source files. This project has no SQL migrations, ORM models, Prisma schemas, or database connection configuration.

## Structured Data Formats

The project uses several structured data formats as its "data model" -- these are not database tables but file-based data structures that the system reads and writes at runtime.

### 1. settings.json (Hook Configuration)

- **Source:** `.claude/settings.json:1-50`
- **Structure:**
  | Field | Type | Description |
  |-------|------|-------------|
  | hooks | Object | Top-level container |
  | hooks.SessionStart | Array of HookGroup | Hooks triggered on session startup/resume |
  | hooks.PreToolUse | Array of HookGroup | Hooks triggered before tool execution |
  | hooks.PostToolUse | Array of HookGroup | Hooks triggered after tool execution |
  | HookGroup.matcher | String or String[] | Event types to match (e.g., "Bash", ["Edit", "Write"]) |
  | HookGroup.hooks | Array of Hook | Hook definitions |
  | Hook.type | String | Always "command" |
  | Hook.command | String | Shell command to execute |

### 2. SKILL.md Frontmatter (Skill Metadata)

- **Source:** All SKILL.md files (e.g., `workflow/brainstorm/SKILL.md:1-12`)
- **Structure (YAML frontmatter):**
  | Field | Type | Required | Description |
  |-------|------|----------|-------------|
  | name | String | Yes | Skill identifier (e.g., "brainstorm") |
  | description | String | Yes | Multi-line description with trigger phrases |
  | allowed-tools | String[] | No | Tool whitelist for the skill (e.g., `["Bash", "Read", "Agent"]`) |

- **Evidence:** `workflow/pipeline-build/SKILL.md:12-20` shows `allowed-tools` field; `workflow/brainstorm/SKILL.md:2-12` shows name and description.

### 3. evals.json (Skill Evaluation Data)

- **Source:** Every skill's `evals/evals.json` (e.g., `workflow/brainstorm/evals/evals.json:1-24`)
- **Structure:**
  | Field | Type | Description |
  |-------|------|-------------|
  | skill_name | String | Must match SKILL.md name |
  | evals | Array of Eval | Test cases |
  | Eval.id | Number | Sequential eval ID |
  | Eval.prompt | String | User input to test with |
  | Eval.expected_output | String | Description of expected behavior |
  | Eval.files | String[] | File paths relevant to the eval (often empty) |

### 4. Instinct Files (Learned Pattern Data)

- **Source:** `instincts/errors/*.md`, `instincts/code-patterns/*.md`, `instincts/review-patterns/*.md`
- **Structure (YAML frontmatter, auto-generated):**
  | Field | Type | Description |
  |-------|------|-------------|
  | id | String | Pattern identifier (e.g., "error-abc123def456") |
  | trigger | String | Command/pattern that triggers this instinct |
  | confidence | Float | 0.0-1.0 scale; only loaded at session start if >= 0.8 |
  | domain | String | Category (e.g., "error-handling") |
  | source | String | Origin (e.g., "auto-detected" or "manual") |
  | occurrences | Integer | How many times this pattern was observed |
  | first_seen | String (date) | Date of first occurrence |
  | last_seen | String (date) | Date of most recent occurrence |

- **Evidence:** `.claude/hooks/learn-from-errors.sh:166-175` defines the auto-generated frontmatter schema. The manually created instinct files at `instincts/errors/common-angular-errors.md:1-2` use a simpler format with just `confidence: 0.8`.

### 5. skill-catalog.md (Unified Skill Registry)

- **Source:** `skill-catalog.md:1-70`
- **Structure:** Markdown tables grouped by source, with columns:
  | Column | Type | Description |
  |--------|------|-------------|
  | Skill | String | Skill name |
  | Path | String | Relative path to skill directory |
  | Description | String | One-line description |
  | Tags | String | Hashtag-based classification (e.g., "#design #planning") |

### 6. auto-detected.md (Error Log)

- **Source:** Generated at runtime by `learn-from-errors.sh` at `docs/mistakes/auto-detected.md`
- **Structure:** Append-only Markdown with entries:
  ```
  ### YYYY-MM-DD HH:MM:SS
  **Command:** `<command>`
  **Error:** ```<output>```
  ---
  ```
- **Evidence:** `.claude/hooks/learn-from-errors.sh:86-98`
- **Size limit:** 500KB (`.claude/hooks/learn-from-errors.sh:81`)

### 7. Session Summary (Daily Log)

- **Source:** Generated at runtime by `session-summary.sh` at `docs/sessions/YYYY-MM-DD-summary.md`
- **Structure:** Append-only Markdown with entries per response:
  ```
  ### HH:MM
  **Modified files:** (list)
  **Tools:** tool(count), ...
  **Estimated tokens:** ~N,NNN (N tool calls)
  ---
  ```
- **Evidence:** `.claude/hooks/session-summary.sh:87-106`
- **Size limit:** 1MB (`.claude/hooks/session-summary.sh:35`)

## ER Summary

No relational data model exists. The data formats above are independent file-based structures with no foreign key relationships. The closest to a relationship is:

- `skill-catalog.md` **references** SKILL.md frontmatter data (generated by scanning all SKILL.md files)
- `instincts/errors/*.md` **is generated from** `docs/mistakes/auto-detected.md` (when error count >= 2, per `.claude/hooks/learn-from-errors.sh:141`)
- `load-instincts.sh` **reads** `instincts/` directory at session start and filters by `confidence >= 0.8` (`.claude/hooks/load-instincts.sh:48-49`)
