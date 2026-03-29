---
name: devops-e2e-fix
description: |
  Analyze failing Playwright or Cypress E2E tests and fix them with minimal impact on
  production code. Captures DOM snapshots, console logs, and network state at failure
  points to precisely classify root cause into one of four categories: test code bug,
  missing test step, application bug, or dirty state. Fixes test files only when
  possible. When production code must change, explains why and asks the user before
  touching anything.
  Use this skill whenever the user says "e2e test failing", "fix e2e", "playwright
  failing", "cypress error", "E2Eが落ちてる", "E2E 테스트 실패", "테스트 고쳐줘",
  "E2Eテスト修正", or when CI reports E2E test failures. Proactively suggest this
  skill whenever a user pastes a Playwright/Cypress error output — test failures left
  unfixed become noise that hides real regressions.
---

# E2E Test Failure Analysis & Fix

Diagnose why E2E tests are failing, fix what can be fixed in test files only, and
surface production code issues clearly so nothing gets broken silently.

**Core principle:** Fix the right problem. Test failures caused by UI changes need
test fixes; test failures caused by real bugs need production fixes. Confusing the two
leads to tests that pass but lie.

**No hacks:** Never use `page.evaluate()` injection, route mocking, or artificial
waits to make a failing test pass. If the only fix requires those, the test is
exposing a real problem that needs a real solution.

## Step 0: Collect Failure Evidence

Before touching any code, gather all available evidence.

```bash
# Playwright — run with full trace
npx playwright test --reporter=list 2>&1

# If trace not captured yet, enable it
npx playwright test --trace on 2>&1

# Specific failing test
npx playwright test path/to/failing.spec.ts --reporter=list 2>&1
```

Collect:
- Full error message and stack trace
- Screenshot at failure point (Playwright auto-captures on failure)
- Console errors from the browser during the run
- Network requests that failed (4xx, 5xx, timeouts)
- Which line in the test file triggered the failure

If the user already has error output, read it carefully before running anything.

## Step 1: Classify Root Cause

Map the failure to exactly one of four categories. Getting this right determines
everything — the wrong classification leads to the wrong fix.

| Category | Symptoms | Fix Target |
|----------|----------|-----------|
| **Test code bug** | Selector not found, wrong assertion value, bad test data, stale locator after UI rename | Test file only |
| **Missing test step** | Test assumes a state that was never set up (e.g., assumes user is logged in, item exists in list) | Test file only |
| **Dirty state** | Tests pass in isolation but fail when run together; order-dependent failures; leftover data from previous test | Test file only (isolation fix) |
| **Application bug** | Feature genuinely broken — correct selector, correct assertion, but app behaves wrong | Production code (ask user first) |

### Classification Heuristics

**Test code bug:**
- Error: `locator.click: Element not found` → check if selector matches current DOM
- Error: `expect(received).toBe(expected)` with wrong value → check if assertion matches current behavior
- Run the same test against the live app manually — if the feature works, it's a test bug

**Missing test step:**
- Test navigates to a protected route without logging in first
- Test expects a list item that was never created in `beforeEach`
- Test references data from a previous test that may not have run
- Auth setup file exists but the fix is deeper — check if `.auth/` directory exists,
  if `storageState` path is correct, and if the setup project runs before tests.
  Don't add inline login as a workaround if `storageState` is the intended pattern.

**Dirty state:**
- Test passes alone: `npx playwright test --grep "test name"` → PASS
- Test fails in full suite → FAIL
- Cause: shared database, shared localStorage, or previous test didn't clean up

**Application bug:**
- Selector is correct (matches current DOM), assertion is correct, but app returns wrong data
- Feature worked before and a recent commit broke it
- Run `git log --oneline -10` to check if a recent change is the culprit

### When Unsure

Read the production component/service code. If the current implementation would
satisfy the test's assertion under correct conditions, it's a test bug. If not,
it's an application bug.

## Step 2: Scan for Context

Before writing any fix, understand the existing patterns.

```bash
# Find page objects
find . -name "*.page.ts" -o -name "*.po.ts" 2>/dev/null | head -20

# Find fixtures and helpers
find . -path "*/e2e/*" -name "*.ts" | grep -v spec 2>/dev/null

# Find auth setup
find . -name "*.setup.ts" 2>/dev/null
```

- Read the Page Object for the failing page — use existing methods, don't add raw Playwright calls
- Check if an auth setup file exists — if tests need auth, use `storageState` not inline login
- Follow the naming and structure conventions of existing test files

## Step 3: Fix

### Test code bug / Missing test step / Dirty state → Fix test file only

Apply the minimum change that makes the test correctly reflect what the app actually does.

**Selector fix:**
```typescript
// Before — stale selector after button text changed
await page.click('button:has-text("Submit")');

// After — match current DOM
await page.click('button:has-text("Save changes")');

// Better — update page object so all tests benefit
// users.page.ts
readonly saveButton = this.page.getByRole('button', { name: 'Save changes' });
```

**Missing test step fix:**
```typescript
// Before — assumes auth state that may not exist
test('can create user', async ({ page }) => {
  await page.goto('/users');  // redirects to login!
  ...
});

// After — use stored auth state or explicit login
test('can create user', async ({ page }) => {
  await page.context().addInitScript(() => { /* restore state */ });
  // or: use storageState via playwright.config.ts project dependency
  await page.goto('/users');
  ...
});
```

**Dirty state fix — `beforeEach` vs `afterEach`:**

Prefer `beforeEach` (seed data) over `afterEach` (cleanup) — if a test fails midway,
`afterEach` cleanup may not run, leaving dirty state for the next test. `beforeEach`
guarantees a clean start regardless of what happened before.

```typescript
// Preferred: seed required data in beforeEach
test.beforeEach(async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.goto();
  await usersPage.createUser('Bob', 'bob@example.com');
});

// Also ensure test targets its own data, not shared data
test('removes user after confirmation', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.goto();
  // target the last row (just created in beforeEach), not the first (shared Alice)
  await page.locator('.delete-btn').last().click();
  await usersPage.confirmDeleteButton.click();
  await expect(page.locator('.user-name')).not.toContainText('Bob');
});
```

### Application bug → Ask user before touching production code

Do NOT modify production code without explicit user approval. Instead:

1. State the root cause clearly:
   > "The test is correct. `UsersComponent.createUser()` doesn't reset `formError`
   > after a successful save, so the error message stays visible. This is a bug in
   > the component, not the test."

2. Show exactly what needs to change:
   ```typescript
   // users.component.ts — createUser() method
   // Add this line after successful save:
   this.formError = '';  // ← reset error on success
   ```

3. Ask:
   > "Should I apply this fix to `users.component.ts`? It only touches the `createUser()`
   > method and won't affect other functionality."

4. On approval → apply minimal fix, re-run tests
5. On rejection → mark the test with `test.fixme()` and add a comment explaining the bug:
   ```typescript
   test.fixme('form error clears after successful save', async () => {
     // BUG: formError not reset in createUser() — tracked in #123
   });
   ```

## Step 4: Verify Fix

After every fix, run the previously failing test in isolation first, then the full suite.

```bash
# Isolation run
npx playwright test path/to/fixed.spec.ts

# Full suite
npx playwright test
```

| Result | Action |
|--------|--------|
| Fixed test passes, suite passes | Done |
| Fixed test passes, other tests fail | New regression introduced — investigate |
| Fixed test still fails | Re-classify — may have been wrong category |
| All tests pass but a new warning appears | Note it — may indicate fragile test |

## Step 5: Confirm No Production Impact

After fixing, explicitly verify production code is unchanged (unless user approved a fix).

```bash
git diff --name-only
```

Expected output for test-only fixes:
```
e2e/tests/users.spec.ts
e2e/pages/users.page.ts
```

If production files appear in the diff without user approval — revert them:
```bash
git checkout -- src/
```

## Output

```markdown
## E2E Fix Report

### Failures analyzed: N
| Test | Root Cause Category | Fix Applied | Status |
|------|--------------------|----|--------|
| "can create user" | Test code bug — stale selector | Updated locator in users.page.ts | ✅ Fixed |
| "form error clears" | Application bug | Proposed fix to users.component.ts | ⏳ Awaiting approval |
| "delete confirm" | Dirty state — missing afterEach cleanup | Added afterEach cleanup | ✅ Fixed |

### Production code changes
- None (test-only fixes) / [list files if approved]

### Remaining failures
- [list any test.fixme() items with reason]
```
