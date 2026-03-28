---
name: execute-plan
description: |
  Execute a written implementation plan step by step with review checkpoints.
  Loads a plan file, reviews it critically, executes each task in order, and
  verifies results before marking complete. Use this skill whenever the user
  says "execute the plan", "implement this plan", "run the plan", "follow the
  plan", "プラン実行", "計画を実行して", "플랜 실행해줘", "이 계획 구현해",
  or references a plan file they want implemented. Proactively suggest this
  skill when a write-plan output exists and the user is ready to build.
  Note: if subagents are available, consider subagent-dev for higher quality
  parallel execution. This skill is best for sequential, single-session work.
---

# Executing Plans

Load a plan, review it critically, execute all tasks, and verify completion.
Plans come from the write-plan skill and contain bite-sized tasks with exact
file paths, code blocks, and verification commands.

## Step 1: Load and Review

Before writing any code, understand what the plan asks for and whether it
makes sense. Blind execution of a flawed plan wastes more time than catching
issues upfront.

1. Read the plan file
2. Review critically — identify questions, gaps, or concerns
3. If concerns exist: raise them with the user before starting
4. If no concerns: create a TodoWrite checklist from the plan's tasks and proceed

## Step 2: Execute Tasks

For each task in the plan:

1. **Mark as in_progress** in TodoWrite
2. **Follow each step exactly** — the plan has bite-sized steps with code blocks
3. **Run verifications** as specified in each step (test commands, build checks)
4. **Mark as completed** only after verification passes

Between tasks, briefly report what was done and what's next. This gives the
user visibility into progress without requiring them to ask.

## Step 3: Complete Development

After all tasks are done:

1. Run the full test suite — not just individual test files
2. Verify all changes work together (integration check)
3. Present a summary of what was built

## When to Stop and Ask

Stop executing immediately when:
- A dependency is missing or a test fails unexpectedly
- The plan has gaps that prevent starting a task
- An instruction is unclear or ambiguous
- Verification fails repeatedly (2+ attempts)

Ask for clarification rather than guessing. Forcing through blockers creates
more problems than pausing to ask.

## When to Revisit Step 1

Return to the review phase when:
- The user updates the plan based on your feedback
- The fundamental approach needs rethinking after discovering issues

## Output

After completion, report:

```markdown
## Execution Complete

**Plan:** [plan file path]
**Tasks completed:** X/Y
**Tests:** [pass count] / [total count]
**Files created:** [list]
**Files modified:** [list]

### Summary
[Brief description of what was built and any notable decisions made during execution]
```

## Integration

- **write-plan** — creates the plans this skill executes
- **tdd** — follow TDD cycle within each task
- **verify-complete** — verify work before claiming success
- **subagent-dev** — alternative for parallel execution with subagents
