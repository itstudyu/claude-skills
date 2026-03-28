---
name: pipeline-build
description: |
  End-to-end feature implementation pipeline. Chains: project-scan (codebase analysis) →
  design-doc (feature specs) → write-plan (implementation plan) → subagent-dev (parallel
  execution) → review [gstack] (code review) → verify-complete (evidence-based verification).
  Each stage runs as an independent subagent to avoid context exhaustion. Uses a shared state
  file for progress tracking — if interrupted, resume from where you left off. Use this skill
  whenever the user says "build feature", "implement this", "새 기능 구현", "機能実装",
  "pipeline build", or when the user has a feature request and wants the complete journey
  from codebase understanding to verified, reviewed implementation.
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

# Pipeline: Build Feature

Take a feature from understanding to verified implementation. Scan the project, write specs,
plan, execute via subagents, review, and verify. One command, six stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill (especially subagent-dev and review) consumes significant context.
Running them in the same session would exhaust the context window by Stage 3.

```
pipeline-build (orchestrator — this skill)
    │
    ├→ Agent: project-scan       (independent context)
    │   └→ output: docs/project-overview.md
    │
    ├→ Agent: design-doc         (independent context, per feature)
    │   └→ output: docs/specs/*.md paths
    │
    ├→ Agent: write-plan         (independent context)
    │   └→ output: docs/plans/*.md path
    │
    ├→ Agent: subagent-dev       (independent context, dispatches sub-subagents)
    │   └→ output: implemented code + test results
    │
    ├→ Agent: review [gstack]    (independent context)
    │   └→ output: review findings
    │
    └→ Agent: verify-complete    (independent context)
        └→ output: verification evidence
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "build",
  "feature": "user's feature description",
  "stage": "project-scan",
  "stages": {
    "project-scan": { "status": "pending", "output": null },
    "design-doc": { "status": "pending", "output": null },
    "write-plan": { "status": "pending", "output": null },
    "subagent-dev": { "status": "pending", "output": null },
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
   - **Exists, pipeline is "build"**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Record the user's feature description in state

## Stage 1: Project Scan (Codebase Analysis)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /project-scan skill. Run it for this project.

The user wants to build: [feature description]

Scan the codebase and generate docs/project-overview.md. After the skill
completes, report:
1. The project overview file path
2. Tech stack summary (language, framework, DB, test framework)
3. Existing features related to [feature]
4. Relevant code patterns detected"
```

When the subagent completes, update state with the output path.

No gate after this stage — auto-proceed to Stage 2.

## Stage 2: Design Doc (Feature Specs)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /design-doc skill. Create a design doc for the
[feature name] feature.

Context from previous stage:
- Project overview: [path to docs/project-overview.md] — read this first
- Feature to document: [feature description]
- Save to: docs/specs/[feature-name].md

Analyze the codebase for existing code related to this feature.
Ask the user about any gaps not found in code.

After completion, report:
1. The design doc file path
2. Key design decisions made
3. Any open questions"
```

When complete, update state.

**Gate:** Ask the user:
> "Stage 2 complete — design doc created at [path].
> Key decisions: [summary]
> Review the spec and confirm: Continue to implementation planning?"

- Continue → proceed to Stage 3
- Stop → end pipeline
- Redo → re-dispatch Stage 2

## Stage 3: Write Plan (Implementation Plan)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /write-plan skill. Create an implementation plan.

Context:
- Project overview: [path to docs/project-overview.md]
- Feature design doc: [path to docs/specs/*.md]
- Read the design doc before writing the plan

Create a comprehensive implementation plan with TDD steps, exact file paths,
and verification commands. Save to docs/plans/."
```

When complete, update state.

**Gate:** Ask the user:
> "Stage 3 complete — implementation plan at [path].
> Tasks: [count] tasks estimated at [total time].
> Review the plan and confirm: Start implementation?"

- Continue → proceed to Stage 4
- Stop → end pipeline
- Redo → re-dispatch Stage 3

## Stage 4: Subagent Dev (Parallel Execution)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /subagent-dev skill. Execute the implementation plan.

Context:
- Implementation plan: [path to docs/plans/*.md] — read this first
- Design doc: [path to docs/specs/*.md]
- Project overview: [path to docs/project-overview.md]

Execute each task in the plan using fresh subagents. Run two-stage review
(spec compliance + code quality) after each task. Report progress and any
blockers."
```

**Important:** The subagent-dev skill dispatches its own sub-subagents for
each task. The orchestrator waits for the full execution to complete.

When complete, update state.

No gate after this stage — auto-proceed to review.

## Stage 5: Review (Code Review via gstack)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /review skill. Review the code changes made in the
previous implementation stage.

Context:
- Design doc: [path to docs/specs/*.md] — the spec to review against
- Implementation plan: [path to docs/plans/*.md]

Run a thorough code review covering:
1. Spec compliance — does the code match the design doc?
2. Code quality — patterns, naming, error handling
3. Test coverage — are all behaviors tested?
4. Security — any vulnerabilities introduced?

Report all findings with severity (critical/high/medium/low)."
```

When complete, update state.

**Gate:** Ask the user:
> "Stage 5 complete — review findings:
> Critical: [count], High: [count], Medium: [count], Low: [count]
> [Summary of critical/high findings]
> Accept review and proceed to verification, or fix issues first?"

- Accept → proceed to Stage 6
- Fix → dispatch subagent-dev to fix critical/high issues, then re-review
- Stop → end pipeline

## Stage 6: Verify Complete (Evidence-Based Verification)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /verify-complete skill. Verify that the feature
implementation is complete and correct.

Context:
- Feature: [feature description]
- Design doc: [path] — expected behavior
- Implementation plan: [path] — expected deliverables

Run all verification checks:
1. All tests pass
2. Build succeeds
3. Each planned deliverable exists
4. No regressions in existing tests

Provide evidence for every claim. No assertion without proof."
```

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Build Feature

**Feature:** [original feature description]

**Outputs:**
1. Project overview: [path]
2. Design doc: [path]
3. Implementation plan: [path]
4. Code changes: [summary of files changed]
5. Review: [pass/fail + finding counts]
6. Verification: [pass/fail + evidence summary]

**Next:** Run `/ship` to create a PR and land the changes.
```

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already scanned the project" → skip project-scan
- "I have a design doc" → skip project-scan + design-doc
- "I have a plan already" → skip to subagent-dev
- "Just review and verify" → skip to review

Mark skipped stages as `skipped` in state. When skipping, ask the user for
the paths to existing outputs so downstream stages have the context they need.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **Test failures in verify:** Report which tests fail, offer to dispatch fix subagent
- **Review critical findings:** Block progression until user explicitly accepts or fixes

## Principles

- **User controls the pace.** Gates between key stages. Never auto-proceed past a gate.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **Evidence before assertions.** Verify-complete requires proof, not claims.
- **Review before ship.** Code review is mandatory, not optional.
