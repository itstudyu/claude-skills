# Hooks and Automation Analysis

> Analysis of the hook system in claude-skills.

## Hook Architecture

The project uses Claude Code's hook system configured in `.claude/settings.json`.
Hooks fire at three lifecycle points: SessionStart, PreToolUse, PostToolUse.

All hooks are gated by a **profile system** (`run-with-profile.sh`) that allows
enabling/disabling hooks via environment variables.

## Profile System

```bash
export HOOK_PROFILE=standard    # minimal | standard | strict
export DISABLED_HOOKS="code-quality-check"  # comma-separated
```

| Profile | Hooks Active |
|---------|-------------|
| minimal | inject-instructions, load-instincts, learn-from-errors |
| standard (default) | minimal + secret-scanner, code-quality-check |
| strict | standard + (future hooks) |

The `run-with-profile.sh` script (wrapper for all hooks):
1. Checks if the hook ID is in DISABLED_HOOKS -- if so, no-op exit
2. Checks if HOOK_PROFILE matches the hook's allowed profiles -- if not, no-op exit
3. If allowed, `exec`s the actual hook script

## Hook Inventory

### SessionStart Hooks

**inject-instructions.sh** (profiles: minimal, standard, strict)
- Fires on: startup, compact, resume
- Action: Reads CLAUDE.md from project root and outputs it to Claude's context
- Purpose: Ensures project instructions survive context compaction and session resumption
- This is how the routing table, behavioral modes, and skill catalog reference
  get loaded into every session

**load-instincts.sh** (profiles: minimal, standard, strict)
- Fires on: startup, compact, resume
- Action: Scans `instincts/` directory for patterns with confidence >= 0.8
- Uses Python to parse YAML frontmatter from instinct .md files
- Outputs max 10 instincts, max 2000 chars total
- Purpose: Auto-loads learned error patterns into Claude's context so past mistakes
  are avoided without being explicitly remembered

### PreToolUse Hooks

**secret-scanner.sh** (profiles: standard, strict)
- Fires on: Bash tool use
- Action: Intercepts `git commit` and `git add` commands, scans staged diff for
  11 secret patterns (AWS keys, JWTs, GitHub PATs, private keys, etc.)
- Exit code 2 = **blocks the commit** (PreToolUse exit 2 = hard block)
- Purpose: Prevents accidental secret commits

### PostToolUse Hooks

**learn-from-errors.sh** (profiles: minimal, standard, strict)
- Fires on: Bash tool use
- Action: Reads JSON from stdin containing tool_input and tool_output
- If exit_code != 0, appends error details to `docs/mistakes/auto-detected.md`
- **Instinct auto-extraction:** After logging, counts similar errors. If 2+ similar
  errors are found, creates/updates an instinct file in `instincts/errors/` with
  a calculated confidence score: `min(0.9, 0.3 + (occurrences - 1) * 0.2)`
- This creates a **feedback loop**: errors -> mistakes log -> instinct files ->
  auto-loaded at session start -> prevents future errors

**code-quality-check.sh** (profiles: standard, strict)
- Fires on: Edit, Write tool use
- Action: Checks edited source files against coding standards
- Checks performed:
  1. File header comment exists (CODING-STANDARDS Rule 1)
  2. No functions exceed 30 lines (CODING-STANDARDS Rule 2)
  3. No debug output left in code (console.log, print, etc.)
  4. Not too many TODO/FIXME tags (threshold: 5+)
- Exit code 2 = **feedback to Claude** (PostToolUse exit 2 = feedback, not block)
- Skips test files, config files, and generated files

### Not Registered in settings.json

**session-summary.sh** -- Exists in hooks/ but is NOT registered in settings.json.
It would fire on Stop events and save session summaries to `docs/sessions/`.
It parses transcript JSON to extract modified files, tool usage stats, and errors.

**pre-commit-validate.sh** -- A git pre-commit hook (not a Claude Code hook).
Runs `make validate` before git commits. Would need to be installed via
`make hook-install` or similar.

## The Learning Loop

The hooks create an automated learning cycle:

```
1. Error occurs during Bash execution
   |
2. learn-from-errors.sh detects non-zero exit code
   |
3. Error logged to docs/mistakes/auto-detected.md
   |
4. If 2+ similar errors detected:
   |   Creates instinct file in instincts/errors/
   |   Initial confidence: 0.5 (2 occurrences)
   |
5. If 3+ similar errors:
   |   Confidence reaches 0.7
   |
6. If confidence >= 0.8 (typically 4+ occurrences):
   |   load-instincts.sh auto-loads at next SessionStart
   |   Pattern is now part of Claude's context
   |
7. If 5+ occurrences:
       CLAUDE.md suggests promotion to standards/
       Pattern becomes a permanent coding standard
```

This is a progression from **transient error** -> **recorded mistake** ->
**learned instinct** -> **enforced standard**.

## Exit Code Semantics

The hook system uses exit codes with specific meanings:

| Exit Code | Meaning in PreToolUse | Meaning in PostToolUse |
|-----------|----------------------|----------------------|
| 0 | Allow tool execution | No feedback |
| 1 | Error (graceful continue) | Error (graceful continue) |
| 2 | **Hard block** (prevent tool execution) | **Feedback to Claude** (injected into context) |

This means:
- `secret-scanner.sh` returning 2 on PreToolUse **prevents the git commit from executing**
- `code-quality-check.sh` returning 2 on PostToolUse **tells Claude about the violation**
  so it can fix it, but does not undo the edit
