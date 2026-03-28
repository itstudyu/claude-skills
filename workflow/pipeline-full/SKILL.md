---
name: pipeline-full
description: |
  Full lifecycle pipeline from idea to deployment. Validates the idea, explores design,
  creates specs, writes implementation plan, builds with subagents, and ships. The ultimate
  end-to-end workflow. Chains: pipeline-idea stages (office-hours → brainstorm → design-doc
  → write-plan) → subagent-dev → ship [gstack]. Each stage runs as an independent subagent
  to avoid context exhaustion. Uses a shared state file for progress tracking — if interrupted,
  resume from where you left off. Use this skill whenever the user says "full pipeline",
  "idea to deploy", "아이디어부터 배포까지", "フルパイプライン", "pipeline full",
  "take this all the way", or when someone wants the complete journey from idea to production.
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

# Pipeline: Idea → Deploy

Take a product idea through the full lifecycle: validate it, design it, document it,
plan it, build it with subagents, and ship it. One command, six stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill (especially office-hours at 1300+ lines) consumes significant
context. Running them in the same session would exhaust the context window by Stage 2.

```
pipeline-full (orchestrator — this skill)
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
    ├→ Agent: write-plan      (independent context)
    │   └→ output: plan path
    │
    │   *** GATE: User approves before implementation ***
    │
    ├→ Agent: subagent-dev    (independent context, per task)
    │   └→ output: implemented code + test results
    │
    │   *** GATE: User approves before shipping ***
    │
    └→ Agent: ship [gstack]   (independent context)
        └→ output: PR URL / deploy status
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "full",
  "idea": "user's original idea description",
  "stage": "office-hours",
  "stages": {
    "office-hours": { "status": "pending", "output": null },
    "brainstorm": { "status": "pending", "output": null },
    "design-doc": { "status": "pending", "output": null },
    "write-plan": { "status": "pending", "output": null },
    "subagent-dev": { "status": "pending", "output": null },
    "ship": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` → `in_progress` → `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists
   - **Exists with `"pipeline": "idea"` and all idea stages completed**: Skip directly
     to subagent-dev stage — the idea pipeline already did the planning work.
   - **Exists with `"pipeline": "full"`, same idea**: "Resume from [stage] or start fresh?"
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

**GATE (Major — User must approve before implementation):**
> "Stages 1-4 complete — idea validated, designed, documented, and planned.
> Plan at [path]. Review the plan before I start building.
>
> Options:
> - **Approve** → proceed to implementation with subagent-dev
> - **Revise** → re-run write-plan with feedback
> - **Stop** → end pipeline here (you can run /subagent-dev manually later)"

This is a hard gate. Do NOT auto-proceed to implementation.

## Stage 5: Subagent Dev (Implementation)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /subagent-dev skill. Execute the implementation plan.

Context:
- Implementation plan: [plan path] — read this first
- Feature design docs: [list of docs/specs/*.md paths]
- Project spec: [spec path]

Execute the plan using subagent-dev. Dispatch fresh subagents per task.
Run two-stage review (spec compliance + code quality) after each task.
Report progress after each task completion."
```

**Important:** The subagent handles its own task dispatch and review.
The orchestrator monitors for completion.

When complete, update state.

**GATE (Major — User must approve before shipping):**
> "Implementation complete. All tasks done, reviewed, and tested.
> Summary: [task count, test results, review outcomes]
>
> Options:
> - **Ship** → proceed to create PR and deploy
> - **Review** → let me walk you through what was built
> - **Fix** → address specific issues before shipping
> - **Stop** → end pipeline here (you can run /ship manually later)"

This is a hard gate. Do NOT auto-proceed to shipping.

## Stage 6: Ship (PR + Deploy)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /ship skill. Ship the implemented code.

Context:
- Original idea: [idea]
- Implementation plan: [plan path]
- All code has been implemented and reviewed

Run ship to: detect base branch, run tests, review diff, bump VERSION,
update CHANGELOG, commit, push, and create PR. Follow the standard
ship workflow."
```

When complete, update state with PR URL.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Idea → Deploy

**Idea:** [original idea]

**Outputs:**
1. Design doc (validation): [path]
2. Design spec (architecture): [path]
3. Feature specs: [list]
4. Implementation plan: [path]
5. Implementation: [task count] tasks completed
6. PR/Deploy: [PR URL or deploy status]

**Timeline:** Started [time] → Completed [time]
```

## Resuming from pipeline-idea

If `.claude/pipeline-state.json` already exists with `"pipeline": "idea"` and all
four idea stages (office-hours, brainstorm, design-doc, write-plan) show `"completed"`:

1. Read existing outputs from state
2. Convert state to full pipeline format (add subagent-dev and ship stages)
3. Skip directly to Stage 5 (subagent-dev)
4. Present the pre-implementation gate using existing plan

This avoids re-running validated, designed, and planned work.

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already validated" → skip office-hours
- "I have a design spec" → skip office-hours + brainstorm
- "Just need implementation" → skip to subagent-dev (needs plan path)
- "Code is ready, just ship" → skip to ship

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **Tests fail in subagent-dev:** Report failures, offer fix or skip
- **Ship fails:** Report error, offer to retry or fix manually

## Principles

- **User controls the pace.** Gates between stages. Never auto-proceed.
- **Two hard gates.** Must get explicit approval before implementation and before shipping.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **Resume-aware.** Detects completed pipeline-idea runs and skips ahead.
