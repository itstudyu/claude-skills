---
name: pipeline-smart
description: |
  Smart pipeline that validates an idea first, then lets AI decide the best skill
  combination. Chains: office-hours (idea validation) → plan-orchestrator (AI picks
  the right skills and order based on the validated idea). Unlike fixed pipelines,
  this one adapts — plan-orchestrator reads the office-hours output and decides whether
  you need brainstorm, design-doc, write-plan, figma-to-code, or something else entirely.
  Use this skill whenever the user says "smart pipeline", "figure out what to do",
  "아이디어 검증하고 알아서 해줘", "スマートパイプライン", "validate and plan",
  or when the user has an idea but isn't sure which pipeline fits best.
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

# Pipeline: Smart (Office Hours → Plan Orchestrator)

Validate an idea, then let AI decide the best execution path. Unlike fixed
pipelines that always run the same stages, this one adapts to the idea.

## Why This Exists

Fixed pipelines (pipeline-idea, pipeline-build, etc.) are predictable but rigid.
Sometimes you don't know upfront whether the idea needs brainstorm → design-doc
→ write-plan, or figma-to-code → qa, or something else entirely.

This pipeline solves that: office-hours validates the idea and produces a design
doc, then plan-orchestrator reads it and decides the best skill combination.

## Architecture

```
pipeline-smart (orchestrator)
    │
    ├→ Agent: office-hours [gstack]     (validate the idea)
    │   └→ output: design doc
    │
    └→ Agent: plan-orchestrator [cs]    (AI picks skills + order)
        └→ output: execution plan with skill selection
        └→ then: user executes the plan step by step
```

Only 2 stages — but plan-orchestrator's output can include any number of skills.

## State File

```json
{
  "pipeline": "smart",
  "idea": "user's idea description",
  "stage": "office-hours",
  "stages": {
    "office-hours": { "status": "pending", "output": null },
    "plan-orchestrator": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

## On Start

1. Check `.claude/pipeline-state.json`
   - Exists with `"pipeline": "smart"` → "Resume from [stage] or start fresh?"
   - Doesn't exist → create new state
2. Record the user's idea

## Stage 1: Office Hours (Idea Validation)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /office-hours skill. Run it for this idea:
[user's idea description]

After completion, report:
1. The design doc file path
2. A 3-5 line summary of key findings
3. Whether the idea was validated (yes/partially/no)
4. List of features/modules identified

The user will interact with you directly for the Q&A."
```

When complete, update state.

**Gate:**
> "Idea validation complete. Design doc at [path].
> Summary: [findings]
> Features identified: [list]
>
> Continue to smart planning? Plan-orchestrator will analyze this and
> recommend the best skill combination for implementation."

- Continue → proceed to Stage 2
- Stop → end pipeline
- Redo → re-run Stage 1

## Stage 2: Plan Orchestrator (AI Picks the Path)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /plan-orchestrator skill. Run it for this project.

Context from office-hours:
- Idea: [idea]
- Design doc: [path] — read this file first
- Features identified: [list from Stage 1]

Run plan-orchestrator:
1. Read skill-catalog.md to know all available skills
2. Read the design doc from office-hours
3. Run Phase 1 (Context Collection) — ask user for missing technical details
   (table DDL, API specs, routing, etc.)
4. Run Phase 1b-1d (Standards, Project Context, Instincts)
5. Run Phase 2 (Skill Matching) — pick the best skills for this specific idea
6. Run Phase 3 (Generate Plan) — produce the execution plan

The plan should reference the design doc and include source attribution
[gstack] / [claude-skills] for each skill."
```

Plan-orchestrator interacts with the user directly for context collection
and plan approval via EnterPlanMode/ExitPlanMode.

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Smart Complete

**Idea:** [original idea]
**Validated:** [yes/partially/no]

**Outputs:**
1. Design doc (validation): [path]
2. Execution plan: [path]

**Plan-orchestrator recommended:**
[list of skills and order from the plan]

**Next:** Execute the plan — run each skill in the recommended order.
```

## Comparison with Fixed Pipelines

| Aspect | pipeline-idea (fixed) | pipeline-smart (adaptive) |
|--------|----------------------|--------------------------|
| Stages | Always 4: OH → brainstorm → design-doc → write-plan | 2 + AI decides the rest |
| Skill selection | Predetermined | AI picks based on idea |
| When to use | Standard idea-to-plan flow | Unsure which pipeline fits |
| Predictability | High | Medium (AI decides) |
| Flexibility | Low | High |

## Skipping Stages

- "I already validated the idea" → skip office-hours, provide design doc path,
  go straight to plan-orchestrator
- "I have a design doc from a previous session" → same as above

## Error Handling

- **office-hours unavailable (gstack not installed):** Warn and offer to skip
  to plan-orchestrator with manual context
- **plan-orchestrator fails:** Report error, suggest running individual skills
- **Session interrupted:** State file persists. Resume on next invocation.

## Principles

- **AI decides, user approves.** Plan-orchestrator picks skills, user reviews the plan.
- **Subagents stay independent.** Each stage gets fresh context.
- **Idea first, tools second.** Validate before planning. Don't pick tools for a bad idea.
- **State is persistent.** Crashes don't lose progress.
