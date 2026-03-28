---
name: pipeline-quality
description: |
  Pre-commit quality check pipeline. Generates missing tests, enforces Japanese comments,
  runs code review, and performs security audit. Run before committing or creating a PR.
  Chains: devops-test-gen → devops-japanese-comments → review [gstack] → cso [gstack].
  Each stage runs as an independent subagent to avoid context exhaustion. Uses a shared
  state file for progress tracking — if interrupted, resume from where you left off.
  Use this skill whenever the user says "quality check", "PR전 체크", "品質チェック",
  "pipeline quality", "check everything before commit", "커밋 전 체크", "コミット前チェック",
  "pre-commit pipeline", or when code is ready for commit/PR and needs a full quality sweep.
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

# Pipeline: Quality Check

Run a full pre-commit quality sweep: generate missing tests, enforce Japanese comments,
review the diff, and audit for security issues. One command, four stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This keeps the
orchestrator lightweight and prevents context exhaustion from large diffs.

```
pipeline-quality (orchestrator — this skill)
    │
    ├→ Agent: devops-test-gen         (independent context)
    │   └→ output: test files created/updated
    │
    ├→ Agent: devops-japanese-comments (independent context)
    │   └→ output: comments converted count
    │
    ├→ Agent: review [gstack]          (independent context)
    │   └→ output: review findings
    │
    └→ Agent: cso [gstack]             (independent context)
        └→ output: security findings
```

The orchestrator manages state, dispatches subagents, collects results, and only
stops if a stage finds critical issues.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "quality",
  "stage": "devops-test-gen",
  "stages": {
    "devops-test-gen": { "status": "pending", "output": null },
    "devops-japanese-comments": { "status": "pending", "output": null },
    "review": { "status": "pending", "output": null },
    "cso": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` → `in_progress` → `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists with `"pipeline": "quality"`
   - **Exists, incomplete**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Detect changed files via `git diff --name-only` (staged + unstaged)
3. If no changes detected, warn and ask whether to run on all files instead

## Stage 1: Test Generation (devops-test-gen)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /devops-test-gen skill. Run it on the current changes.

Changed files: [list from git diff]

Generate missing unit tests and regression tests for all changed code.
Follow existing test patterns in the project.

After completion, report:
1. Number of test files created or updated
2. List of test file paths
3. Whether all changed code now has test coverage (yes/partially/no)"
```

Update state. **Auto-proceed** to Stage 2 unless the subagent reports failure.

Report: "Stage 1 complete — [N] test files generated. Proceeding to Japanese comments."

## Stage 2: Japanese Comments (devops-japanese-comments)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /devops-japanese-comments skill. Run it on the current changes.

Changed files: [list from git diff, including new test files from Stage 1]

Convert all English comments to Japanese. Add missing comments to complex logic.

After completion, report:
1. Number of files modified
2. Number of comments converted/added
3. Any files that were skipped and why"
```

Update state. **Auto-proceed** to Stage 3.

Report: "Stage 2 complete — [N] comments converted. Proceeding to code review."

## Stage 3: Code Review (review — gstack)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /review skill. Run a pre-landing review on the current diff.

Analyze staged and unstaged changes against the base branch. Check for:
- SQL safety issues
- LLM trust boundary violations
- Conditional side effects
- Structural issues
- Code quality concerns

After completion, report:
1. Total findings count by severity (critical/high/medium/low)
2. Summary of each critical or high finding
3. Whether the code is ready to land (yes/needs-fixes/blocked)"
```

Update state. **Gate:** If review finds critical issues, stop and report.
Otherwise auto-proceed to Stage 4.

## Stage 4: Security Audit (cso — gstack)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /cso skill. Run a daily-mode security audit focused on
the current changes.

Check for:
- Secrets or credentials in code
- Dependency vulnerabilities in changed files
- OWASP Top 10 issues
- Input validation gaps

After completion, report:
1. Total findings count by severity
2. Summary of each critical or high finding
3. Overall security posture (pass/warn/fail)"
```

Update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:

```markdown
## Pipeline Complete: Quality Check

**Changed files:** [count]

**Results:**
1. Test generation: [N] test files created/updated
2. Japanese comments: [N] comments converted
3. Code review: [findings summary]
4. Security audit: [findings summary]

**Verdict:** [PASS / NEEDS FIXES / BLOCKED]

**Next:** Ready to commit and create PR, or fix reported issues first.
```

## Auto-Proceed Logic

This pipeline auto-proceeds between stages unless:
- A stage finds **critical** issues (review or cso)
- A stage **fails** to run (skill not available, error)

Non-critical findings are collected and reported at the end.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **No git changes:** Ask user whether to run on all files or abort

## Principles

- **Auto-proceed by default.** Only gate on critical findings. Speed matters pre-commit.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via git diff.** Stages share scope through changed file lists.
