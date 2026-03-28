---
name: pipeline-onboard
description: |
  New project onboarding pipeline. Scans the codebase to understand structure and features,
  creates design docs for every detected feature, and refreshes the skill catalog. The complete
  onboarding experience for any new project. Chains: project-scan → design-doc (for ALL detected
  features, sequentially) → skill-catalog scan. Each stage runs as an independent subagent to
  avoid context exhaustion. Uses a shared state file for progress tracking — if interrupted,
  resume from where you left off. Use this skill whenever the user says "onboard me",
  "new project setup", "프로젝트 온보딩", "プロジェクトオンボーディング", "pipeline onboard",
  "understand this project fully", or when someone opens a new repo and wants the complete
  onboarding experience from codebase understanding to full documentation.
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

# Pipeline: Onboard

Onboard onto any new project in one command: scan the codebase, create design docs for every
detected feature, and refresh the skill catalog. Three stages, fully gated.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill consumes significant context. Running them in the same session
would exhaust the context window before Stage 2 completes.

```
pipeline-onboard (orchestrator — this skill)
    │
    ├→ Agent: project-scan         (independent context)
    │   └→ output: docs/project-overview.md
    │
    ├→ Agent: design-doc × N       (independent context, per feature)
    │   └→ output: docs/specs/<feature>.md for each feature
    │
    └→ Agent: skill-catalog        (independent context)
        └→ output: skill-catalog.md
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "onboard",
  "project_root": "/absolute/path/to/project",
  "stage": "project-scan",
  "stages": {
    "project-scan": { "status": "pending", "output": null },
    "design-doc": { "status": "pending", "features": [], "completed": [], "output": [] },
    "skill-catalog": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` → `in_progress` → `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists
   - **Exists with `"pipeline": "onboard"`**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Record the project root in state

## Stage 1: Project Scan (Codebase Analysis)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /project-scan skill. Run it for the project at [project root].

Scan the entire codebase — tech stack, directory structure, features, database tables,
API endpoints, and code patterns. Save the output to docs/project-overview.md.

After the skill completes, report:
1. The project overview file path
2. The detected tech stack (frameworks, languages, databases)
3. The complete list of detected features (as a numbered list)
4. Total number of features detected"
```

When the subagent completes, update state with the output path.

**Gate:** Read `docs/project-overview.md` to extract the feature list. Present to the user:
> "Stage 1 complete — project scanned. Overview at [path].
> Tech stack: [summary]
> Detected features:
> 1. [feature 1]
> 2. [feature 2]
> ...
>
> These features will each get a design doc in Stage 2.
> Confirm the feature list, add/remove features, or skip to Stage 3?"

- Confirm → proceed to Stage 2 with confirmed feature list
- Edit → user modifies the list, then proceed
- Skip → mark design-doc as skipped, jump to Stage 3

Save the confirmed feature list to `state.stages.design-doc.features`.

## Stage 2: Design Doc (Per-Feature Documentation)

Read `docs/project-overview.md` to get context. For **each feature** in the confirmed
feature list, dispatch a subagent:

```
Agent prompt:
"You have access to the /design-doc skill. Create a design doc for the
[feature name] feature.

Context:
- Project overview: docs/project-overview.md — read this for architecture context
- Feature to document: [feature name]
- Save to: docs/specs/[feature-name].md

Analyze the codebase for existing code related to this feature — database tables,
API endpoints, UI components, business rules. Ask the user about any gaps not found
in the code."
```

Process features **sequentially** (not parallel) — each might need user input.

After each feature, update state and report progress:
> "Design doc for [feature] complete ([N]/[total]). Output: docs/specs/[feature].md
> Continue to next feature?"

Track completed features in `state.stages.design-doc.completed` and output paths
in `state.stages.design-doc.output`.

**Gate after all features:**
> "All [N] design docs created:
> 1. docs/specs/[feature-1].md
> 2. docs/specs/[feature-2].md
> ...
>
> Ready to refresh the skill catalog?"

## Stage 3: Skill Catalog (Refresh Registry)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /skill-catalog skill. Run a full scan to refresh
skill-catalog.md.

Scan all skill sources (gstack, claude-skills, custom packs) and regenerate
the unified skill registry. Report the total number of skills found and
any new skills detected."
```

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Project Onboarding

**Project:** [project root]

**Outputs:**
1. Project overview: docs/project-overview.md
2. Feature design docs:
   - docs/specs/[feature-1].md
   - docs/specs/[feature-2].md
   - ...
3. Skill catalog: skill-catalog.md

**Next:** The project is fully documented. You can now:
- Run `/write-plan` to create an implementation plan for any feature
- Run `/brainstorm` to explore design changes
- Run `/subagent-dev` to start implementation
```

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already scanned" → skip project-scan (must have docs/project-overview.md)
- "Just refresh the catalog" → skip to skill-catalog
- "Only design docs" → skip project-scan (must exist), run design-doc, skip catalog

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **Feature doc fails:** Mark that feature as failed, continue to next, offer retry at end

## Principles

- **User controls the pace.** Gates between stages. Never auto-proceed.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **Every feature gets documented.** Stage 2 runs once per feature — no shortcuts.
