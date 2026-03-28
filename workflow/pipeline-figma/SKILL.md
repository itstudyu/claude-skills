---
name: pipeline-figma
description: |
  Figma design to production code pipeline. Generates Angular code from Figma URL,
  adds tests, runs QA testing, and performs design review. Chains: figma-to-code
  (Angular generation) -> devops-test-gen (unit/regression tests) -> qa [gstack]
  (bug detection + fix) -> design-review [gstack] (visual polish). Each stage runs
  as an independent subagent to avoid context exhaustion. Uses a shared state file
  for progress tracking — if interrupted, resume from where you left off. Use this
  skill whenever the user says "figma pipeline", "Figma로 구현", "Figmaから実装して全部",
  "build from figma and test", or when someone has a Figma URL and wants the complete
  journey from design to production-ready, tested, reviewed code.
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

# Pipeline: Figma -> Production Code

Take a Figma design through the full journey: generate Angular code, add tests,
run QA, and perform design review. One command, four stages.

## Architecture: Subagent Dispatch

Each stage runs as an **independent subagent** via the Agent tool. This is critical
because each skill (especially figma-to-code with Figma MCP calls) consumes significant
context. Running them in the same session would exhaust the context window by Stage 2.

```
pipeline-figma (orchestrator — this skill)
    |
    |-> Agent: figma-to-code     (independent context)
    |   => output: generated Angular component paths
    |
    |-> Agent: devops-test-gen   (independent context)
    |   => output: test file paths
    |
    |-> Agent: qa [gstack]       (independent context)
    |   => output: bug report + fixes
    |
    => Agent: design-review [gstack] (independent context)
        => output: visual polish commits
```

The orchestrator stays lightweight — it only manages state, dispatches subagents,
collects outputs, and presents gates to the user.

## State File

Progress is tracked in `.claude/pipeline-state.json`:

```json
{
  "pipeline": "figma",
  "figma_url": "https://figma.com/design/...",
  "stage": "figma-to-code",
  "stages": {
    "figma-to-code": { "status": "pending", "output": null },
    "devops-test-gen": { "status": "pending", "output": null },
    "qa": { "status": "pending", "output": null },
    "design-review": { "status": "pending", "output": null }
  },
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp"
}
```

Status values: `pending` -> `in_progress` -> `completed` | `skipped`

## On Start

1. Check if `.claude/pipeline-state.json` exists
   - **Exists with `"pipeline": "figma"`**: "Resume from [stage] or start fresh?"
   - **Doesn't exist**: create new state file
2. Get the Figma URL from the user — if not provided in the original message, ask:
   > "Please provide the Figma URL for the design you want to implement."
3. Record the Figma URL in state

## Stage 1: Figma to Code (Angular Generation)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /figma-to-code skill. Run it for this Figma URL:
[figma_url]

Generate production-ready Angular code from the design. Check angular-web-common
for reusable components first. Show the user the component mapping preview
before generating code.

After the skill completes, report:
1. All generated file paths (components, templates, styles)
2. Which common components were reused vs styled individually
3. A 3-5 line summary of what was generated

The user will interact with you directly for mapping confirmation."
```

**Important:** The subagent interacts with the user directly for the component
mapping preview and approval. The orchestrator waits for completion.

When the subagent completes, update state with the output paths.

**Gate:** Ask the user:
> "Stage 1 complete — Angular code generated. Files: [list].
> Summary: [3-5 lines from subagent]
> Review the generated code before continuing to test generation?"

- Continue -> proceed to Stage 2
- Stop -> end pipeline
- Redo -> re-dispatch Stage 1

## Stage 2: Test Generation (devops-test-gen)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /devops-test-gen skill. Generate tests for these files:
[list of generated file paths from Stage 1]

Context:
- These files were generated from a Figma design
- Detect the project's test framework automatically
- Follow existing test patterns in the codebase

After completion, report:
1. All test file paths created
2. Number of test cases per file
3. Test coverage summary"
```

When complete, update state. No user gate — proceed directly to Stage 3.

## Stage 3: QA Testing (gstack qa)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /qa skill. Run QA testing on the application.

Context from previous stages:
- Figma URL: [figma_url]
- Generated code: [file paths from Stage 1]
- Test files: [file paths from Stage 2]

Focus on the newly generated components. Run Standard tier QA.
Fix any bugs found, committing each fix atomically.

After completion, report:
1. Health score (before/after)
2. Bugs found and fixed (count + summary)
3. Any remaining issues that need manual attention"
```

When complete, update state.

**Gate:** Ask the user:
> "Stage 3 complete — QA testing done.
> Health: [before] -> [after]. Bugs fixed: [count].
> Remaining issues: [list or 'none'].
> Continue to design review?"

- Continue -> proceed to Stage 4
- Stop -> end pipeline
- Redo -> re-dispatch Stage 3

## Stage 4: Design Review (gstack design-review)

Dispatch a subagent:

```
Agent prompt:
"You have access to the /design-review skill. Run visual QA on the application.

Context:
- Original Figma design: [figma_url]
- Generated components: [file paths from Stage 1]

Compare the implementation against the Figma design. Check for visual
inconsistencies, spacing issues, hierarchy problems. Fix issues found,
committing each fix atomically with before/after screenshots.

After completion, report:
1. Visual issues found and fixed (count + summary)
2. Fidelity score vs original Figma design
3. Any remaining visual gaps"
```

When complete, update state.

## On Complete

```json
{ "stage": "done", "completed_at": "ISO timestamp" }
```

Report:
```markdown
## Pipeline Complete: Figma -> Production Code

**Figma URL:** [url]

**Outputs:**
1. Angular components: [file paths]
2. Test files: [file paths]
3. QA report: [health score, bugs fixed]
4. Design review: [visual issues fixed, fidelity score]

**Next:** Run `/ship` to create a PR, or `/verify-complete` for final checks.
```

## Skipping Stages

Users can skip stages they already have outputs for:

- "I already have the code" -> skip figma-to-code
- "Tests exist already" -> skip devops-test-gen
- "Just need design review" -> skip to design-review

Mark skipped stages as `skipped` in state.

## Error Handling

- **Subagent timeout:** Report what completed, offer to retry or skip
- **Skill not available:** Warn and offer to skip that stage
- **Session interrupted:** State file persists. Next run asks to resume
- **Figma MCP unavailable:** Alert user, cannot proceed with Stage 1

## Principles

- **User controls the pace.** Gates after code generation and QA. Never auto-proceed past gates.
- **Subagents stay independent.** Each gets fresh context. No context bleed.
- **State is persistent.** Crashes don't lose progress.
- **Context flows via files.** Stages share data through saved documents, not session memory.
- **Figma URL is required.** Always obtain it before starting Stage 1.
