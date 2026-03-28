---
name: pipeline-debug
description: |
  Bug fix pipeline. Investigates root cause, writes regression test, fixes the bug using TDD,
  reviews the fix, and verifies everything passes. Chains: investigate [gstack] → tdd →
  review [gstack] → verify-complete. Each stage runs as an independent subagent to avoid
  context exhaustion. Uses a shared state file for progress tracking — if interrupted, resume
  from where you left off. Use this skill whenever the user says "debug pipeline",
  "fix this bug end to end", "バグ修正パイプライン", "버그 수정 파이프라인",
  "find and fix this bug", or when someone has a bug report and wants the complete journey
  from investigation to verified fix.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - AskUserQuestion
  - Agent
---

# Pipeline: Bug Report → Verified Fix

Take a bug from report to verified fix: investigate the root cause, write a regression test,
fix it with TDD, review the fix, and verify everything passes. One command, four stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill (especially investigate) consumes significant context. Running them
in the same session would exhaust the context window by Stage 2.

```
pipeline-debug (orchestrator — this skill)
    │
    ├→ Agent: investigate       (independent context)  [gstack]
    │   └→ output: root cause analysis, affected files
    │
    ├→ Agent: tdd               (independent context)
    │   └→ output: regression test + fix
    │
    ├→ Agent: review            (independent context)  [gstack]
    │   └→ output: review verdict (pass/fail + issues)
    │
    └→ Agent: verify-complete   (independent context)
        └→ output: verification evidence
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "debug",
  "bug": "user's bug description or error message",
  "stage": "investigate",
  "stages": {
    "investigate": { "status": "pending", "output": null },
    "tdd": { "status": "pending", "output": null },
    "review": { "status": "pending", "output": null },
    "verify-complete": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` → `in_progress` → `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists
   - **Exists, same pipeline**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Record the user's bug description or error message in state
   - If the user did not provide a bug description, **ask for it** before proceeding

## Stage 1: Investigate (Root Cause Analysis)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /investigate skill. Run it for this bug:
[user's bug description / error message]

Investigate the root cause systematically. Do NOT fix anything yet.
After the skill completes, report:
1. The root cause (one sentence)
2. Affected files and line numbers
3. Confidence level (high/medium/low)
4. A brief explanation of why this causes the bug

The user will interact with you directly for investigation questions."
```

**Important:** The subagent interacts with the user directly for the
investigation Q&A. The orchestrator waits for completion.

When the subagent completes, update state with the output.

**Gate:** Ask the user:
> "Stage 1 complete — root cause identified.
> Root cause: [one sentence]
> Affected: [files]
> Confidence: [level]
> Does this root cause look correct? Continue to TDD fix?"

- Continue → proceed to Stage 2
- Stop → end pipeline
- Redo → re-dispatch Stage 1

## Stage 2: TDD (Regression Test + Fix)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /tdd skill. Fix this bug using TDD.

Bug: [bug description]
Root cause: [from Stage 1]
Affected files: [from Stage 1]

Steps:
1. Write a regression test that reproduces the bug (RED — test must fail)
2. Fix the bug with minimal code changes (GREEN — test must pass)
3. Refactor if needed (REFACTOR)

After completion, report:
1. Test file path and test name
2. Files changed for the fix
3. Test results (all passing? any regressions?)"
```

When the subagent completes, update state with the output.

**Gate:** Ask the user:
> "Stage 2 complete — regression test written and bug fixed.
> Test: [test file and name]
> Changed: [files]
> All tests passing: [yes/no]
> Continue to code review?"

- Continue → proceed to Stage 3
- Stop → end pipeline
- Redo → re-dispatch Stage 2

## Stage 3: Review (Code Review)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /review skill. Review the changes from the bug fix.

Bug: [bug description]
Root cause: [from Stage 1]
Files changed: [from Stage 2]

Review the diff for:
- Correctness: does the fix actually address the root cause?
- Safety: any SQL issues, trust boundary violations, side effects?
- Quality: code style, naming, comment quality
- Test coverage: is the regression test sufficient?

After completion, report:
1. Verdict: PASS or FAIL
2. Issues found (if any)
3. Suggestions (if any)"
```

When the subagent completes, update state with the output.

- **PASS** → proceed to Stage 4 (no gate needed)
- **FAIL** → show issues to user, ask: "Review found issues. Fix and re-review, or proceed anyway?"

## Stage 4: Verify Complete (Final Verification)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /verify-complete skill. Verify the bug fix is complete.

Bug: [bug description]
Fix: [summary from Stage 2]

Run all verification:
1. Run the full test suite — all tests must pass
2. Run the specific regression test — must pass
3. Verify the original bug is fixed (reproduce the original error scenario)
4. Check for regressions in related functionality

Report evidence for each check."
```

When the subagent completes, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Bug → Verified Fix

**Bug:** [original description]
**Root cause:** [from Stage 1]

**Outputs:**
1. Investigation: [root cause summary]
2. Regression test: [test file path]
3. Fix: [changed files]
4. Review: [verdict]
5. Verification: [all checks passed]

**Next:** Run `/ship` to create a PR for this fix.
```

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already know the root cause" → skip investigate, record the root cause
- "I have a failing test" → skip investigate + tdd test writing, go to fix
- "Just verify" → skip to verify-complete

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **Tests fail after fix:** Loop back to Stage 2 (TDD) automatically

## Principles

- **User controls the pace.** Gates between stages. Never auto-proceed past a gate.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **No fix without root cause.** Stage 1 must identify the cause before Stage 2 attempts a fix.
