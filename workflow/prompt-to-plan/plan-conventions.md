# Plan Conventions

## Plan Document Header

```markdown
# [Feature Name] Implementation Plan

> **Refined from user prompt via /prompt-to-plan**

**Goal:** [One sentence from refined spec's <task>]
**Architecture:** [2-3 sentences from <context> and <constraints>]
**Tech Stack:** [Key technologies from <constraints>]

---
```

## Task Dependency Map

After the header and before the first task, include a dependency map when tasks
have non-sequential dependencies:

````markdown
## Dependencies

```
Task 1 (setup)
├── Task 2 (model) ──── can run parallel with Task 3
├── Task 3 (service) ── can run parallel with Task 2
│   └── Task 5 (integration) ── depends on Task 3
└── Task 4 (UI) ──────── depends on Task 2
```
````

**Parallel markers:** Tasks with no dependency between them get a `[parallel]`
tag in their heading:

```markdown
### Task 2: User Model [parallel: Task 3]
### Task 3: Auth Service [parallel: Task 2]
```

This enables subagent-dev to dispatch independent tasks simultaneously.
When all tasks are sequential, omit the dependency map — the task order
is the dependency order.

## Task Structure

Each task is bite-sized (2-5 minutes), following TDD:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext`
- Test: `tests/exact/path/to/test.ext`

- [ ] **Step 1: Write the failing test**
```code
// 実際のテストコード
```

- [ ] **Step 2: Run test to verify it fails**
Run: `test command`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**
```code
// 実際の実装コード
```

- [ ] **Step 4: Run test to verify it passes**
Run: `test command`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add <files>
git commit -m "feat: description"
```
````

## Plan Rules

- **No placeholders**: Every step contains actual code, commands, file paths
- **No "TBD"**: If you cannot specify something, investigate first
- **No "Similar to Task N"**: Repeat the code — tasks may be read in isolation
- **Spec coverage**: Every requirement from the refined spec maps to at least one task
- **Acceptance criteria**: Include verification steps that match `<acceptance_criteria>`
- **Task size**: Each task's instructions (excluding code blocks) stay under
  ~300 words. If a task description exceeds this, it likely needs splitting.
  Code blocks have no word limit — show the full implementation.

## Self-Review Before Presenting Plan

1. Skim each requirement in the refined spec — can you point to a task that implements it?
2. Search for placeholders (TBD, TODO, "implement later", "add appropriate")
3. Check type/method name consistency across tasks
4. **Acceptance criteria mapping** (Deep tier only): For each acceptance criterion
   in the refined spec, identify which task's verification step proves it is met.
   If an acceptance criterion has no corresponding verification, add one.
5. **Completeness question**: Re-read the refined spec one final time and ask
   "what did I miss?" If anything surfaces, add a task or expand an existing one.
6. Fix issues inline

## Execution Handoff

After the plan is complete:

> **Plan complete.** Saved to `docs/plans/<feature>.md`.
>
> **Two execution options:**
>
> **1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks.
>    Run: `/subagent-dev docs/plans/<feature>.md`
>
> **2. Inline Execution** — execute tasks in this session with checkpoints.
>
> **Which approach?**

- Subagent-Driven → User runs `/subagent-dev <plan-path>` (ensures clean context)
- Inline Execution → Execute tasks sequentially in current session

> **Note**: For parallel implementation tasks, subagents can use `isolation: worktree`
> to get isolated repo copies, avoiding file conflicts.
