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

### Tier 1: CLAUDE.md Skill Index (always loaded)

CLAUDE.md contains a lightweight skill index — one line per skill:

```
| Skill | Description | Tags |
|-------|-------------|------|
| brainstorm | Socratic design, 3 options before implementation | #design #planning |
| write-plan | Bite-sized 2-5min tasks, zero-context assumption | #planning #tasks |
| tdd | RED-GREEN-REFACTOR, no code without failing test | #testing #quality |
| ...  | ... | ... |
```

This costs ~500 tokens for 30 skills. Even at 100 skills, ~1500 tokens.

### Tier 2: SKILL.md (loaded on demand)

After filtering candidates from Tier 1, read only the matched SKILL.md files
to understand their full capabilities. Typically 5-7 skills per plan.

## Pipeline

### Phase 1: Understand the Task

Read the user's request carefully. Identify:
- **What** they want to build/fix/analyze
- **Scope** — single file, feature, full page, system-wide
- **Inputs** — Figma URL, error message, requirements doc, etc.
- **Constraints** — timeline, technology, quality requirements

If `project-context.md` exists, read it for project-specific context.

### Phase 2: Skill Matching

Scan the CLAUDE.md skill index (Tier 1). For each skill, check:
1. Do the tags match the task domain?
2. Does the description match the task intent?
3. Is the skill relevant to the identified scope?

Then read the SKILL.md (Tier 2) of matched candidates to confirm they're
appropriate and understand their inputs/outputs.

**Matching heuristics:**

| Task Signal | Likely Skills |
|---|---|
| New feature / page | project-analyzer → brainstorm → write-plan → tdd → verify-complete |
| Figma URL + page | project-analyzer → figma-to-code → review |
| Figma URL + common | figma-component-writer |
| Bug / error | systematic-debug → tdd → verify-complete |
| Code review | review → cso |
| Performance issue | benchmark → investigate |
| New project | project-analyzer → brainstorm → write-plan |
| Refactoring | brainstorm → write-plan → review → verify-complete |

These are starting points — adjust based on the actual SKILL.md capabilities.

### Phase 3: Generate Plan

Produce a plan using this template:

```markdown
# Plan: [Task Title]

## Context
[Why this needs to be done — 2-3 lines]

## Dependency
Step1 → Step2 → Step3
(use ∥ for parallel steps: Step2 ∥ Step3)

## Steps

### Step 1: [Goal]
- **Skills:** project-analyzer
- **Files:** (discovered during execution)
- **Output:** project-context.md
- **Checkpoint:** ⬜ Auto

### Step 2: [Goal]
- **Skills:** brainstorm
- **Files:** docs/specs/
- **Output:** Design spec with user approval
- **Checkpoint:** ✅ User confirmation required

### Step 3: [Goal]
- **Skills:** write-plan, tdd
- **Files:** src/features/login/
- **Output:** Implementation + tests
- **Checkpoint:** ✅ User confirmation required

### Step 4: [Goal]
- **Skills:** review, cso
- **Files:** (all changed files)
- **Output:** Review report
- **Checkpoint:** ⬜ Auto

### Step 5: [Goal]
- **Skills:** verify-complete
- **Files:** (all outputs)
- **Output:** Verification report
- **Checkpoint:** ⬜ Auto

## Scope
- Out of scope: [what we're NOT doing]

## Verification
- [How to verify the plan succeeded]
```

### Phase 4: Present Plan & Get Approval

Show the plan to the user in a clear format:

```
┌──────────────────────────────────────────────────────────┐
│ Plan: 로그인 화면 구현                                    │
├────────────────────────────────────────────────────────── │
│ Step 1: project-analyzer      (프로젝트 파악)     ⬜ Auto │
│ Step 2: brainstorm            (설계 옵션)         ✅ 확인 │
│ Step 3: write-plan + tdd      (구현 + 테스트)     ✅ 확인 │
│ Step 4: review + cso          (리뷰 + 보안)       ⬜ Auto │
│ Step 5: verify-complete       (검증)              ⬜ Auto │
└──────────────────────────────────────────────────────────┘

Dependency: Step1 → Step2 → Step3 → Step4 → Step5
Estimated skills: 7
Checkpoints: 2 (user confirmation at Steps 2, 3)

Proceed? [Y/n]
```

**HARD GATE:** Do not start execution without explicit user approval.

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
