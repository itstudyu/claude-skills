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

## Self-Review Before Presenting Plan

1. Skim each requirement in the refined spec — can you point to a task that implements it?
2. Search for placeholders (TBD, TODO, "implement later", "add appropriate")
3. Check type/method name consistency across tasks
4. Fix issues inline
