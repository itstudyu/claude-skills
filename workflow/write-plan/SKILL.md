---
name: write-plan
description: |
  Create comprehensive, step-by-step implementation plans from specs or requirements
  before writing any code. Plans include exact file paths, complete code blocks, test
  commands, and verification steps — no placeholders, no hand-waving. Use this skill
  whenever the user says "write a plan", "make a plan", "create implementation plan",
  "plan this out", "break this into tasks", "プラン作成", "計画を書いて", "플랜 작성해줘",
  "구현 계획 세워줘", or before any implementation that involves more than a single file
  change. Proactively suggest this skill when a spec is ready — implementation
  without a plan leads to rework.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
---

# Writing Plans

Write implementation plans that assume the executing engineer has zero codebase
context and needs every detail spelled out. Document which files to touch, what code
to write, how to test it, and when to commit. Plans use bite-sized tasks (2-5 minutes
each) following TDD.

## Scope Check

If the spec covers multiple independent subsystems, it should have been decomposed
during spec definition. If not, suggest breaking it into separate plans — one per
subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified. This is where
decomposition decisions get locked in.

- Each file has one clear responsibility
- Prefer smaller, focused files over large ones doing too much
- Files that change together should live together
- In existing codebases, follow established patterns
- If a file has grown unwieldy, including a split in the plan is reasonable

## Bite-Sized Tasks

Each step is one action (2-5 minutes):
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to pass" — step
- "Run tests and confirm they pass" — step
- "Commit" — step

This granularity makes progress visible and failures easy to diagnose.

## Plan Document Header

Every plan starts with:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** Use subagent-dev (recommended) or execute-plan
> to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are plan
failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — tasks may be read out of order)
- Steps that describe what to do without showing how
- References to types, functions, or methods not defined in any task

## Self-Review

After writing the complete plan, review it with fresh eyes:

1. **Spec coverage:** Skim each requirement in the spec. Can you point to a task
   that implements it? List any gaps.
2. **Placeholder scan:** Search for any red flags from the "No Placeholders" section.
   Fix them.
3. **Type consistency:** Do types, method signatures, and property names match across
   tasks? `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

Fix issues inline. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution options:

> **Plan complete and saved to `<path>`. Two execution options:**
>
> **1. Subagent-Driven (recommended)** — fresh subagent per task, review between
> tasks, fast parallel iteration
>
> **2. Inline Execution** — execute tasks in this session with checkpoints
>
> **Which approach?**

- Subagent-Driven → use the subagent-dev skill
- Inline Execution → use the execute-plan skill

## Save Location

Save plans to a plans directory: `docs/plans/YYYY-MM-DD-<feature-name>.md`
or per project conventions.
