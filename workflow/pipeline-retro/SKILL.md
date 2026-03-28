---
name: pipeline-retro
description: |
  Weekly retrospective and documentation refresh pipeline.
  Chains: retro (engineering retrospective) → design-doc-update (sync docs with code)
  → document-release (refresh README, CHANGELOG, etc.). Each stage runs as an independent
  subagent to avoid context exhaustion. Uses a shared state file for progress tracking —
  if interrupted, resume from where you left off. Use this skill whenever the user says
  "weekly retro", "sprint retro", "주간 회고", "週次振り返り", "pipeline retro",
  "retro and update docs", or when the team wants to run a retrospective and bring all
  project documentation up to date in one pass.
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

# Pipeline: Retro → Doc Refresh

Run a weekly retrospective, update design docs to match current code, and refresh
project documentation. One command, three stages — mostly automated after the retro.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This keeps context
fresh and prevents exhaustion across stages.

```
pipeline-retro (orchestrator — this skill)
    │
    ├→ Agent: retro              (independent context)  [gstack]
    │   └→ output: retrospective report
    │
    ├→ Agent: design-doc-update  (independent context)
    │   └→ output: updated design docs
    │
    └→ Agent: document-release   (independent context)  [gstack]
        └→ output: updated README, CHANGELOG, etc.
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents the retro gate to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "retro",
  "stage": "retro",
  "stages": {
    "retro": { "status": "pending", "output": null },
    "design-doc-update": { "status": "pending", "output": null },
    "document-release": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` → `in_progress` → `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists
   - **Exists with `"pipeline": "retro"`**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Detect the time range for the retro (default: last 7 days)

## Stage 1: Retro (Engineering Retrospective)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /retro skill. Run a weekly engineering retrospective.

Time range: [last 7 days or user-specified]
Focus areas: commit history, work patterns, code quality metrics

After the skill completes, report:
1. Key wins and shipped features
2. Issues found and improvement areas
3. Team contributions summary
4. Trend comparison with previous retros (if history exists)

The user will review the retrospective output."
```

When the subagent completes, update state with the output.

**Gate:** Ask the user:
> "Stage 1 complete — retrospective done.
> Summary: [key findings from subagent]
> Continue to update design docs?"

- Continue → proceed to Stage 2
- Stop → end pipeline
- Redo → re-dispatch Stage 1

## Stage 2: Design Doc Update (Auto-proceed)

Dispatch a subagent. **No user gate** — this stage auto-proceeds to Stage 3.

```
Agent prompt:
"You have access to the /design-doc-update skill. Run it now.

Analyze the git diff for recent changes and update all affected design docs
in docs/specs/ to reflect the current state of the code. Also update
docs/project-overview.md if the project structure changed.

After completion, report:
1. Which design docs were updated
2. Which features had code changes but no design doc (suggest creation)
3. Summary of what changed in each doc"
```

When complete, update state. Log the output and **auto-proceed** to Stage 3.

## Stage 3: Document Release (Auto-proceed)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /document-release skill. Run it now.

Context from previous stages:
- Retrospective findings: [summary from Stage 1]
- Design docs updated: [list from Stage 2]

Update README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md to match what shipped.
Polish CHANGELOG voice. Clean up resolved TODOs. Optionally bump VERSION.

After completion, report:
1. Which project docs were updated
2. CHANGELOG entries added
3. VERSION bump (if any)"
```

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Retro → Doc Refresh

**Time range:** [period covered]

**Outputs:**
1. Retrospective report: [path or summary]
2. Design docs updated: [list]
3. Project docs refreshed: [list]

**Next:** All documentation is current. Ready for the next sprint.
```

## Skipping Stages

Users can skip stages they don't need:

- "Just run the retro" → only Stage 1
- "Skip retro, update docs" → skip to Stage 2 + 3
- "Only update project docs" → skip to Stage 3

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **No design docs exist:** Stage 2 reports "no docs to update" and auto-proceeds
- **Session interrupted:** State file persists. Next run asks to resume

## Principles

- **User reviews the retro.** Gate after Stage 1 only. Doc updates auto-proceed.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **Lightweight pipeline.** Three stages, mostly automated — respect the user's time.
