---
name: plan-orchestrator
description: |
  Automatically scan all available skills, match the relevant ones to the user's task,
  and generate a structured execution plan with dependency ordering and checkpoints.
  Use when the user says "/plan-orchestrator", "plan this for me", "which skills should
  I use", "make a plan", "플랜 세워줘", or when a complex task would benefit from
  coordinated multi-skill execution. This skill is explicitly invoked — it does not
  auto-trigger.
---

# Plan Orchestrator

Scan all available skills, match the right ones to the task, generate a plan, and
execute it step by step after user approval.

## When to Use

Only when the user explicitly invokes this skill. It does not auto-trigger.
For simple tasks, direct `/skill-name` invocation is faster and preferred.

Use plan-orchestrator when:
- The task spans multiple concerns (design + code + test + review)
- The user isn't sure which skills to use
- The task needs coordinated execution across several skills

## Two-Tier Skill Loading (Token Efficiency)

### Tier 1: Skill Catalog (always loaded)

`skill-catalog.md` (project root) is the unified skill registry. It lists ALL
skills from ALL sources (gstack, claude-skills, custom packs) with one line each:

```
## gstack (source: ~/.claude/skills/gstack/)
| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| review | review/ | Pre-landing PR review | #review #quality |
| qa | qa/ | QA test web app + fixes | #testing #browser |

## claude-skills (source: ./)
| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| brainstorm | workflow/brainstorm/ | Socratic design process | #design #planning |
| figma-to-code | figma/figma-to-code/ | Figma → Angular code | #figma #agent |
```

This costs ~500 tokens for 30 skills. Even at 100 skills, ~1500 tokens.
Each skill has a **source** (gstack, claude-skills, etc.) for clear attribution.

If `skill-catalog.md` is missing, run `/skill-catalog scan` first.

### Tier 2: SKILL.md (loaded on demand)

After filtering candidates from Tier 1, read only the matched SKILL.md files
to understand their full capabilities. Use the **Path** column to locate each
SKILL.md. For gstack skills: `~/.claude/skills/gstack/<path>/SKILL.md`.
For project skills: `./<path>/SKILL.md`. Typically 5-7 skills per plan.

## Pipeline

### Phase 1: Understand the Task

Read the user's request carefully. Identify:
- **What** they want to build/fix/analyze
- **Scope** — single file, feature, full page, system-wide
- **Inputs** — Figma URL, error message, requirements doc, etc.
- **Constraints** — timeline, technology, quality requirements

If `project-context.md` exists, read it for project-specific context.

### Phase 2: Skill Matching

#### Step 2a — Tier 1 Scan (Skill Catalog)

Read `skill-catalog.md`. For each skill across ALL sources, check:
1. Do the tags match the task domain?
2. Does the description match the task intent?
3. Is the skill relevant to the identified scope?
4. Note the **source** for each candidate.

List all matched candidates WITH source:

```
Tier 1 Matches:
  ✓ [gstack] project-analyzer — #analysis — new project needs context
  ✓ [gstack] review — #review — PR diff analysis needed
  ✓ [claude-skills] figma-to-code — #figma #agent — Figma URL provided
  ✓ [claude-skills] brainstorm — #design #planning — explore design options
  ✗ [claude-skills] tdd — #testing — matched but figma-to-code has built-in validation
```

**Matching heuristics (starting points only):**

| Task Signal | Likely Skills (source) |
|---|---|
| New feature / page | project-analyzer [g] → brainstorm [cs] → write-plan [cs] → tdd [cs] → verify-complete [cs] |
| Figma URL + page | project-analyzer [g] → figma-to-code [cs] → review [g] |
| Figma URL + common | figma-component-writer [cs] |
| Bug / error | systematic-debug [cs] → tdd [cs] → verify-complete [cs] |
| Code review | review [g] → cso [g] |
| Performance issue | benchmark [g] → investigate [g] |
| New project | project-analyzer [g] → brainstorm [cs] → write-plan [cs] |
| Refactoring | brainstorm [cs] → write-plan [cs] → review [g] → verify-complete [cs] |

Legend: [g] = gstack, [cs] = claude-skills

Adjust based on the actual SKILL.md capabilities confirmed in Step 2b.

#### Step 2b — Tier 2 Read (HARD GATE)

**⛔ MANDATORY — DO NOT SKIP THIS STEP.**

You MUST read the full SKILL.md of every Tier 1 matched candidate.
This step cannot be skipped for ANY reason — not "simple task", not "obvious
match", not "I already know what this skill does". No exceptions.

For each Tier 1 match:
1. **Read** the full SKILL.md file (use the Read tool)
2. **Confirm** the skill's Pipeline/Phases match the task
3. **Check** prerequisite skills (e.g., figma-to-code requires project-context.md)
4. **Note** inputs/outputs for dependency chaining in Phase 3

Report what you read:

```
Tier 2 Confirmed:
  ✓ project-analyzer — SKILL.md read ✓ — Generates project-context.md
  ✓ figma-to-code — SKILL.md read ✓ — Phase 1-6, requires project-context.md
  ✗ brainstorm — SKILL.md read ✓ — Not needed: Figma design already defines the UI
```

**If this step is skipped, the entire plan is INVALID. Do not proceed to Phase 3.**

### Phase 3: Generate Plan

**⛔ MANDATORY:** Call the `EnterPlanMode` tool before writing the plan.
The plan MUST be written to the plan file, NOT as chat text.
This ensures the user can structurally review, edit, and approve the plan.

If EnterPlanMode is denied by the user, write the plan as structured markdown
in the chat — but always attempt plan mode first.

Produce a plan using this template:

```markdown
# Plan: [Task Title]

## Context
[Why this needs to be done — 2-3 lines]

## Skill Selection (from Tier 2 verification)

| Source | Skill | Selected | Reason |
|--------|-------|----------|--------|
| gstack | project-analyzer | ✓ | New project — context needed for downstream skills |
| claude-skills | figma-to-code | ✓ | Figma URL provided, Phase 1-6 pipeline matches task |
| claude-skills | brainstorm | ✗ | Figma design already defines UI — no need to explore options |
| claude-skills | verify-complete | ✓ | Final verification gate after code generation |
| ... | ... | ... | ... |

## Dependency
Step1 → Step2 → Step3
(use ∥ for parallel steps: Step2 ∥ Step3)

## Steps

### Step 1: [Goal]
- **Skills:** project-analyzer [gstack]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Files:** (discovered during execution)
- **Output:** project-context.md
- **Checkpoint:** ⬜ Auto

### Step 2: [Goal]
- **Skills:** brainstorm [claude-skills]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Files:** docs/specs/
- **Output:** Design spec with user approval
- **Checkpoint:** ✅ User confirmation required

### Step 3: [Goal]
- **Skills:** write-plan [claude-skills], tdd [claude-skills]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Files:** src/features/login/
- **Output:** Implementation + tests
- **Checkpoint:** ✅ User confirmation required

### Step 4: [Goal]
- **Skills:** review [gstack], cso [gstack]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Files:** (all changed files)
- **Output:** Review report
- **Checkpoint:** ⬜ Auto

### Step 5: [Goal]
- **Skills:** verify-complete [claude-skills]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Files:** (all outputs)
- **Output:** Verification report
- **Checkpoint:** ⬜ Auto

## Scope
- Out of scope: [what we're NOT doing]

## Verification
- [How to verify the plan succeeded]
```

### Phase 4: Present Plan & Get Approval

**Pre-presentation checklist (self-verify before presenting):**
- [ ] Phase 2b: Did I actually Read every matched candidate's SKILL.md?
- [ ] Each Step's skills were confirmed in Tier 2 (not just Tier 1 guesses)?
- [ ] Skill input/output dependencies are chained correctly?

If any check fails → go back to Phase 2b. Do not present an unverified plan.

Show the plan to the user in a clear format:

```
┌──────────────────────────────────────────────────────────────────────┐
│ Plan: 로그인 화면 구현                                                │
├────────────────────────────────────────────────────────────────────── │
│ Step 1: project-analyzer [g]        (프로젝트 파악)          ⬜ Auto │
│ Step 2: brainstorm [cs]             (설계 옵션)              ✅ 확인 │
│ Step 3: write-plan + tdd [cs]       (구현 + 테스트)          ✅ 확인 │
│ Step 4: review + cso [g]            (리뷰 + 보안)            ⬜ Auto │
│ Step 5: verify-complete [cs]        (검증)                   ⬜ Auto │
├──────────────────────────────────────────────────────────────────────│
│ Sources: [g] gstack  [cs] claude-skills                              │
└──────────────────────────────────────────────────────────────────────┘

Dependency: Step1 → Step2 → Step3 → Step4 → Step5
Estimated skills: 7 (3 gstack + 4 claude-skills)
Checkpoints: 2 (user confirmation at Steps 2, 3)
```

**⛔ HARD GATE:** Call `ExitPlanMode` to request user approval.
Do NOT ask "Proceed? [Y/n]" in chat text — ExitPlanMode handles the approval
workflow and lets the user review/edit the plan file before approving.
Do not start execution without explicit user approval via ExitPlanMode.

Allow the user to:
- Remove steps
- Add skills to steps
- Change checkpoint types
- Reorder steps
- Cancel entirely

### Phase 5: Execute

After approval, execute each step sequentially:

1. **Before each step:** Announce what's about to happen
2. **Invoke the skill(s):** Run the skill as if the user typed `/skill-name`
3. **At checkpoints (✅):** Pause and ask for user confirmation before continuing
4. **After each step:** Report what was produced, mark as complete
5. **On failure:** Stop, report what failed, ask user how to proceed

Track progress visually:

```
Step 1: project-analyzer ✓ (completed — project-context.md generated)
Step 2: brainstorm ✓ (completed — design approved)
Step 3: write-plan + tdd ◉ (in progress...)
Step 4: review + cso ○ (pending)
Step 5: verify-complete ○ (pending)
```

## Important Principles

1. **Explicit invocation only.** This skill never auto-triggers.
2. **Show before doing.** Always present the plan and get approval.
3. **Respect checkpoints.** Never skip a ✅ checkpoint.
4. **Minimum viable plan.** Don't suggest 10 steps when 3 will do. Match complexity
   to the task.
5. **Token-aware.** Use 2-tier loading. Don't read every SKILL.md upfront.
