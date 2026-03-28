---
name: pipeline-idea
description: |
  End-to-end pipeline that takes a product idea from validation to implementation plan.
  Chains: office-hours (idea validation) → brainstorm (design exploration) → design-doc
  (per-feature specs) → write-plan (implementation plan). Each stage runs as an independent
  subagent to avoid context exhaustion. Uses a shared state file for progress tracking —
  if interrupted, resume from where you left off. Use this skill whenever the user says
  "pipeline idea", "full pipeline", "take this idea to plan", "아이디어부터 플랜까지",
  "아이디어 파이프라인", "アイデアからプランまで", or when someone has a new product idea
  and wants the complete journey from validation to ready-to-implement plan.
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

# Pipeline: Idea → Plan

Take a product idea through the full journey: validate it, design it, document it,
and produce an implementation plan. One command, four stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill (especially office-hours at 1300+ lines) consumes significant
context. Running them in the same session would exhaust the context window by Stage 2.

```
pipeline-idea (orchestrator — this skill)
    │
    ├→ Agent: office-hours    (independent context)
    │   └→ output: design doc path
    │
    ├→ Agent: brainstorm      (independent context)
    │   └→ output: spec path
    │
    ├→ Agent: design-doc      (independent context, per feature)
    │   └→ output: docs/specs/*.md paths
    │
    └→ Agent: write-plan      (independent context)
        └→ output: plan path
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "idea",
  "idea": "user's original idea description",
  "stage": "office-hours",
  "stages": {
    "office-hours": { "status": "pending", "output": null },
    "brainstorm": { "status": "pending", "output": null },
    "design-doc": { "status": "pending", "output": null },
    "write-plan": { "status": "pending", "output": null }
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
2. Record the user's idea in state

## Stage 1: Office Hours (Idea Validation)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /office-hours skill. Run it for this idea:
[user's idea description]

The user is building: [idea]
After the skill completes, report:
1. The design doc file path
2. A 3-5 line summary of key findings
3. Whether the idea was validated (yes/partially/no)

Save all outputs to the project. The user will interact with you directly
for the office-hours questions."
```

**Important:** The subagent interacts with the user directly for the
office-hours Q&A. The orchestrator waits for completion.

When the subagent completes, update state with the output path.

**Gate:** Ask the user:
> "Stage 1 complete — idea validation done. Design doc at [path].
> Summary: [3-5 lines from subagent]
> Continue to design exploration?"

- Continue → proceed to Stage 2
- Stop → end pipeline
- Redo → re-dispatch Stage 1

## Stage 2: Brainstorm (Design Exploration)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /brainstorm skill. Run it for this project.

Context from previous stage:
- Idea: [idea]
- Design doc from office-hours: [path] — read this file first

Run brainstorm to explore design approaches. The user will interact with
you directly for clarifying questions and design approval.

After completion, report:
1. The spec file path (docs/specs/*.md)
2. The chosen approach name
3. Key design decisions made"
```

When complete, update state.

**Gate:** Brainstorm has its own user approval gate (spec review).
When the subagent reports completion, confirm with user and proceed.

## Stage 3: Design Doc (Per-Feature Specs)

Read the spec from Stage 2 to identify features. For each feature,
dispatch a subagent:

```
Agent prompt:
"You have access to the /design-doc skill. Create a design doc for the
[feature name] feature.

Context:
- Project spec: [spec path] — read this for architecture context
- Feature to document: [feature name]
- Save to: docs/specs/[feature-name].md

Analyze the codebase for existing code related to this feature.
Ask the user about any gaps not found in code."
```

Process features **sequentially** (not parallel) — each might need user input.

After each feature, report progress:
> "Design doc for [feature] complete (2/4). Continue to next?"

**Gate after all features:**
> "All feature design docs created: [list]. Ready for implementation planning?"

## Stage 4: Write Plan (Implementation Plan)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /write-plan skill. Create an implementation plan.

Context:
- Project spec: [spec path]
- Feature design docs: [list of docs/specs/*.md paths]
- Read all design docs before writing the plan

Create a comprehensive implementation plan with TDD steps.
Save to docs/plans/. Offer execution handoff at the end."
```

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Idea → Plan

**Idea:** [original idea]

**Outputs:**
1. Design doc (validation): [path]
2. Design spec (architecture): [path]
3. Feature specs: [list]
4. Implementation plan: [path]

**Next:** Run `/subagent-dev` to start implementation.
```

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already validated" → skip office-hours
- "I have a design spec" → skip office-hours + brainstorm
- "Just need the plan" → skip to write-plan

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume

## Principles

- **User controls the pace.** Gates between stages. Never auto-proceed.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
