# Skill Chaining Analysis

> How skills chain together in the claude-skills project.

## Chaining Mechanisms

Skills chain together through three mechanisms:

1. **Explicit pipeline orchestration** -- Pipeline skills (pipeline-build, pipeline-figma)
   dispatch subagents in sequence using the Agent tool
2. **Output-to-input file passing** -- Skills produce files that downstream skills consume
3. **Skill instructions referencing other skills** -- SKILL.md files direct Claude to
   invoke another skill as the next step

## Chain 1: Full Feature Build Pipeline

```
pipeline-build (orchestrator)
    |
    +-> project-scan         produces: docs/project-overview.md
    |                        [auto-proceed]
    |
    +-> design-doc           reads: docs/project-overview.md
    |                        produces: docs/specs/<feature>.md
    |                        [USER GATE: review spec]
    |
    +-> write-plan           reads: docs/project-overview.md + docs/specs/<feature>.md
    |                        produces: docs/plans/<feature>.md
    |                        [USER GATE: review plan]
    |
    +-> subagent-dev         reads: docs/plans/<feature>.md + docs/specs/<feature>.md
    |                        produces: implemented code + tests
    |                        [auto-proceed]
    |
    +-> review [gstack]      reads: git diff (changed files)
    |                        produces: review findings report
    |                        [USER GATE: accept or fix]
    |
    +-> verify-complete      reads: docs/specs/<feature>.md + docs/plans/<feature>.md
                             produces: verification evidence
```

**State tracking:** `.claude/pipeline-state.json` persists progress. If interrupted,
the pipeline resumes from the last incomplete stage.

**Subagent architecture:** Each stage runs in a fresh Agent context. The orchestrator
passes context via file paths, not session memory. This prevents context exhaustion --
a single session running all 6 stages would run out of context by stage 3.

## Chain 2: Figma-to-Production Pipeline

```
pipeline-figma (orchestrator)
    |
    +-> figma-to-code        reads: Figma URL (via Figma MCP)
    |                        produces: Angular component files
    |                        [USER GATE: review code]
    |
    +-> devops-test-gen      reads: generated file paths
    |                        produces: test files
    |                        [auto-proceed]
    |
    +-> qa [gstack]          reads: generated + test file paths
    |                        produces: bug report + fixes
    |                        [USER GATE: review QA results]
    |
    +-> design-review [gstack]  reads: Figma URL + generated file paths
                                produces: visual polish commits
```

## Chain 3: Figma Component Writer (Internal Pipeline)

```
figma-component-writer (orchestrator)
    |
    +-> figma-common-crawler    reads: Figma URL
    |                           produces: crawled-components.json, crawled-components.md
    |
    +-> figma-common-diff       reads: crawled-components.json + registry.json
    |                           produces: diff-report.json
    |
    +-> figma-common-mapper     reads: diff-report.json
    |                           produces: confirmed execution plan
    |                           [USER GATE: approve sync preview]
    |
    +-> (inline code generation) produces: Angular component files
    |
    +-> (registry update)       updates: angular-web-common/registry.json
```

## Chain 4: Brainstorm-to-Implementation Flow

```
brainstorm                 produces: docs/specs/YYYY-MM-DD-<topic>-design.md
    |                      [USER GATE: approve spec]
    v
write-plan                 reads: design spec
    |                      produces: docs/plans/YYYY-MM-DD-<feature>.md
    |                      [USER GATE: choose execution method]
    v
subagent-dev               reads: plan file
(or inline execution)      produces: implemented code + tests
```

This chain is encoded in the brainstorm SKILL.md itself: "The terminal state is
invoking write-plan. Do NOT invoke any implementation skill directly." And
write-plan's SKILL.md says: "After saving the plan, offer execution options:
Subagent-Driven or Inline Execution."

## Chain 5: Subagent-Dev Internal Loop

```
subagent-dev (controller)
    |
    For each task in plan:
    |
    +-> Implementer subagent     implements + tests + self-reviews
    |   |
    |   +-> (may ask questions -> controller answers -> re-dispatch)
    |
    +-> Spec reviewer subagent   checks: code matches spec?
    |   |
    |   +-> (issues found -> implementer fixes -> re-review)
    |
    +-> Code quality reviewer    checks: code quality
    |   |
    |   +-> (issues found -> implementer fixes -> re-review)
    |
    +-> Mark task complete
    |
    [next task]
    |
    +-> Final code reviewer      reviews: entire implementation
```

## Chain 6: plan-orchestrator (Dynamic Chaining)

Unlike the fixed pipelines above, plan-orchestrator dynamically selects skills
based on the task:

```
plan-orchestrator
    |
    Phase 1: Understand task
    |   +-> 1a: Context collection (ask user for missing info)
    |   +-> 1b: Load standards (CODING-STANDARDS.md, FRONTEND-STANDARDS.md)
    |   +-> 1c: Load project context (project-overview.md)
    |   +-> 1d: Load instincts (learned error patterns)
    |
    Phase 2: Skill matching
    |   +-> 2a: Read skill-catalog.md (Tier 1 -- lightweight scan)
    |   +-> 2b: Read matched SKILL.md files (Tier 2 -- full instructions)
    |
    Phase 3: Generate plan (uses EnterPlanMode)
    |
    Phase 4: Present plan + get user approval (ExitPlanMode)
    |
    Phase 5: Execute plan step by step
        +-> Invoke skills sequentially per plan steps
```

## File-Based Communication Pattern

All skill chains communicate through files, NOT through session memory:

| File | Producer | Consumer |
|------|----------|----------|
| docs/project-overview.md | project-scan | design-doc, write-plan, pipeline-build |
| docs/specs/<feature>.md | brainstorm, design-doc | write-plan, subagent-dev, verify-complete |
| docs/plans/<feature>.md | write-plan | subagent-dev, verify-complete |
| skill-catalog.md | skill-catalog | plan-orchestrator |
| .claude/pipeline-state.json | pipeline-build/figma | pipeline-build/figma (resume) |
| crawled-components.json | figma-common-crawler | figma-common-diff |
| diff-report.json | figma-common-diff | figma-common-mapper |
| angular-web-common/registry.json | figma-component-writer | figma-to-code, figma-common-diff |

This file-based approach is deliberate: subagents have independent context windows
and cannot share in-memory state. Files are the only reliable communication channel.

## User Gates

Skills use explicit user gates at critical decision points:

| Gate Location | Purpose |
|---------------|---------|
| brainstorm -> write-plan | User approves design spec |
| write-plan -> execution | User chooses execution method |
| figma-to-code Phase 3 | User approves component mapping |
| figma-common-mapper | User approves sync preview |
| pipeline-build Stage 2->3 | User reviews design doc |
| pipeline-build Stage 3->4 | User reviews implementation plan |
| pipeline-build Stage 5->6 | User accepts review findings |
| pipeline-figma Stage 1->2 | User reviews generated code |
| pipeline-figma Stage 3->4 | User reviews QA results |

No skill auto-proceeds past a user gate. This is enforced by HARD GATE markers
in the SKILL.md instructions.
