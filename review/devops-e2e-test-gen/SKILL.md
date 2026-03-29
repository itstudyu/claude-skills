---
name: devops-e2e-test-gen
description: |
  Generate Playwright or Cypress E2E test files (.spec.ts) for web applications that run
  in CI. Detects the project's E2E framework automatically and follows existing test patterns.
  Produces Page Object Models and user-flow test scenarios covering navigation, forms,
  authentication, CRUD operations, error handling, and responsive viewports.
  Use this skill whenever the user says "e2e test", "E2E", "end-to-end test", "playwright test",
  "cypress test", "E2Eテスト", "E2E 테스트", "통합 테스트 코드", "ブラウザテスト",
  "browser test", or when a web application has pages/routes without corresponding E2E coverage.
  Proactively suggest this skill after implementing UI features or pages that lack E2E tests —
  unit tests verify functions, but only E2E tests verify the user actually experiences what
  you built.
---

# E2E Test Generation

Generate Playwright or Cypress end-to-end test files for web applications. These tests
run in CI against a real browser, verifying that user flows work from start to finish.
Unit tests catch broken functions; E2E tests catch broken experiences.

## Step 0: Establish Baseline

Before generating anything, confirm the existing E2E suite (if any) passes.

```bash
# Playwright
npx playwright test
# Cypress
npx cypress run
```

| Result | Action |
|--------|--------|
| All pass | Baseline established — proceed |
| Some fail | Note pre-existing failures, exclude from comparison later |
| No E2E tests exist | Note it. Set up framework in Step 1 |

## Step 1: Detect E2E Framework

Scan the project for E2E framework indicators. Match the existing setup — don't
introduce a new framework unless there's nothing in place.

| Signal | Framework |
|--------|-----------|
| `playwright.config.ts` or `@playwright/test` in package.json | Playwright |
| `cypress.config.ts` or `cypress/` directory | Cypress |
| `protractor.conf.js` | Protractor (legacy — suggest migration to Playwright) |

**If no E2E framework exists**, recommend Playwright — it's faster, has auto-wait built
in, and supports all modern browsers out of the box. Set up with:

```bash
npm init playwright@latest
```

Also note:
- **File naming**: `.spec.ts` vs `.e2e.ts` vs `.cy.ts` — match the project convention
- **Directory**: `e2e/`, `tests/`, `cypress/e2e/` — use whatever exists
- **Test utilities**: existing helpers, fixtures, auth state to reuse
- **Base URL**: check config for `baseURL` / `baseUrl` setting

## Step 2: Analyze Pages & Routes

Scan the application to identify testable pages and user flows.

```bash
# Angular
grep -r "path:" src/app/ --include="*routing*"
# React
grep -r "Route\|path=" src/ --include="*.tsx"
# Next.js
ls -R app/ pages/ 2>/dev/null
# Vue
grep -r "path:" src/router/
```

For each discovered route, categorize:

| Page Type | Test Priority | Scenarios |
|-----------|--------------|-----------|
| Auth pages (login, register, forgot-password) | Critical | Valid login, invalid credentials, session persistence |
| CRUD pages (list, detail, create, edit) | High | Create item, read list, update fields, delete with confirm |
| Forms (multi-step, search, filters) | High | Valid submission, validation errors, field interactions |
| Navigation (sidebar, header, breadcrumbs) | Medium | Link targets, active states, responsive collapse |
| Error pages (404, 500, unauthorized) | Medium | Direct navigation, triggered by invalid routes |
| Static pages (about, terms, landing) | Low | Renders without errors, key content visible |

## Step 3: Generate Page Objects

Create Page Object Model classes to encapsulate page interactions. This makes tests
readable and maintainable — when UI changes, you update one page object instead of
every test.

**Playwright example:**
```typescript
// e2e/pages/login.page.ts
import { type Page, type Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

**Page Object principles:**
- Use semantic locators: `getByRole`, `getByLabel`, `getByText` over CSS selectors
- Encapsulate multi-step interactions as methods (e.g., `login()`, `createItem()`)
- Keep assertions in test files, not page objects
- One page object per page or major component

## Step 4: Generate E2E Tests

Write test files covering user flows. Tests should read like user stories — a sequence
of actions a real person would take.

**Playwright example:**
```typescript
// e2e/tests/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';

test.describe('Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome')).toBeVisible();
  });

  test('invalid credentials show error message', async () => {
    await loginPage.login('user@example.com', 'wrong');
    await expect(loginPage.errorMessage).toContainText('Invalid');
  });

  test('empty form shows validation errors', async () => {
    await loginPage.submitButton.click();
    await expect(loginPage.emailInput).toHaveAttribute('aria-invalid', 'true');
  });
});
```

### Test Scenarios by Category

**Authentication flows (aim for 8+ tests):**
- Valid login → redirect to protected page (e.g., dashboard)
- Valid login → user info displayed on destination page
- Invalid password → error message, stays on login page
- Non-existent email → error message
- Empty email → field-level validation (aria-invalid or visual cue)
- Empty password → field-level validation
- Both fields empty → validation, no network request
- Logout → session cleared, redirect to login
- After logout → direct URL to protected page redirects to login
- Auth guard → unauthenticated access to each protected route redirects to login
- Session expiry → graceful re-authentication prompt (if applicable)

**CRUD operations (aim for 5+ tests per entity):**
- Create item with valid data → appears in list, form closes/resets
- Create with empty required fields → validation error shown, form stays open
- Create with each invalid field individually → specific error per field
- Cancel create → form closes, no new item in list
- Read list → items displayed with correct columns
- Read list → pagination controls work (if applicable)
- Search/filter → results narrow, clear filter restores full list
- Search with no matches → empty state message shown
- Update item → changes reflected in list immediately
- Delete item → confirmation dialog appears with item name
- Confirm delete → item removed from list
- Cancel delete → item still in list, dialog closes

**Form interactions (aim for 5+ tests per form):**
- Required field validation on submit (each required field individually)
- Field-level validation on blur (if applicable)
- Valid submission → success feedback, form resets or closes
- Multi-step form navigation (next/back/submit) (if applicable)
- File upload: valid file, oversized, wrong MIME type (if applicable)
- Search/filter → results update in real time
- Search with no results → empty state visible
- Clear search → full list restored

**Navigation & layout (always generate a separate navigation spec):**
- All nav links resolve to correct pages
- Active state reflects current route
- Breadcrumbs show correct hierarchy (if applicable)
- Back/forward browser navigation preserves state
- Root path redirects to correct default page
- Wildcard/unknown routes redirect to 404 or login
- Cross-page navigation via UI links (not just direct URL)

**Responsive viewports:**
```typescript
const viewports = [
  { name: 'mobile', width: 375, height: 812 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1280, height: 800 },
];

for (const vp of viewports) {
  test(`renders correctly on ${vp.name}`, async ({ page }) => {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto('/');
    // Mobile: hamburger menu visible, sidebar collapsed
    // Tablet: sidebar visible, layout adjusted
    // Desktop: full layout
  });
}
```

**Error handling:**
- 404 page for invalid routes
- Network error → retry or fallback UI
- Server error (500) → user-friendly message

### Auth State Reuse

For apps with authentication, create a setup file that persists auth state so tests
don't waste time logging in through the UI repeatedly. This is faster and more reliable.

```typescript
// e2e/tests/auth.setup.ts
import { test as setup, expect } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL('/dashboard');
  await page.context().storageState({ path: '.auth/user.json' });
});
```

Then in `playwright.config.ts`, set up a dependency chain:
```typescript
projects: [
  { name: 'setup', testMatch: /.*\.setup\.ts/ },
  {
    name: 'tests',
    dependencies: ['setup'],
    use: { storageState: '.auth/user.json' },
  },
]
```

Auth-specific tests (login, logout, guard) should NOT use the stored state — they test
the auth flow itself and need a fresh unauthenticated session.

### Test Writing Principles

- **Wait for network idle** before asserting content on dynamic pages:
  `await page.waitForLoadState('networkidle')`
- **Use Playwright auto-wait** — don't add manual `waitForTimeout` unless absolutely
  necessary (API polling, animations). Playwright locators auto-retry until timeout.
- **Isolate tests** — each test should work independently. Use `beforeEach` for setup,
  don't rely on execution order between tests.
- **Use test fixtures** for authenticated state — avoid logging in through the UI in
  every test. Save auth state to a file and reuse:
  ```typescript
  // playwright.config.ts
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    { name: 'tests', dependencies: ['setup'], use: { storageState: '.auth/user.json' } },
  ]
  ```
- **Descriptive test names** — test names should describe the user's intent, not the
  implementation detail.

## Step 5: Run and Verify

```bash
# Playwright
npx playwright test
npx playwright show-report

# Cypress
npx cypress run
```

| Result | Action |
|--------|--------|
| All pass | Report success with counts |
| Tests fail — selector not found | Update locator in page object to match actual UI |
| Tests fail — timing issue | Add appropriate waits (networkidle, specific element) |
| Tests fail — auth issue | Verify test user credentials and auth setup |
| Flaky (passes sometimes) | Investigate race condition, add explicit waits |

## Completeness Checklist

Before reporting results, verify every item:

- [ ] Page Object created for every page under test
- [ ] Semantic locators used (`getByRole`, `getByLabel`, `getByText`) — no raw CSS unless no alternative
- [ ] Auth setup file created (if app has authentication)
- [ ] Auth guard tested for every protected route
- [ ] CRUD tests cover create-valid, create-invalid-per-field, cancel, search, filter-clear, delete-confirm, delete-cancel
- [ ] Responsive viewport tests included (mobile 375px, tablet 768px, desktop 1280px)
- [ ] Navigation spec covers redirects, wildcard routes, back/forward
- [ ] Every test is isolated — no dependency on execution order
- [ ] Multi-browser config (Chromium + Firefox + WebKit minimum)

If any item is missing, add it before finalizing. Partial coverage defeats the purpose
of E2E testing — the untested flow is the one that breaks in production.

## Output

```markdown
## E2E Test Generation Report

- **Framework:** Playwright / Cypress
- **Page objects:** X files
- **Test files:** Y files, Z test cases
- **Coverage by category:**
  - Auth flows: N tests
  - CRUD operations: N tests
  - Forms: N tests
  - Navigation: N tests
  - Responsive: N tests
  - Error handling: N tests
- **Result:** All passing / N failures
- **Files created/modified:** [list]
```
