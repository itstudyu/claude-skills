---
name: devops-test-gen
description: |
  Generate tests for new/changed code with regression protection. Detects test framework
  automatically, generates unit tests + regression tests. Use after writing code.
  Trigger on "generate tests", "テスト生成", "테스트 생성", "add tests", or when code
  is written without tests.
---

# Test Generation

Generate tests for new code + regression tests for changed code.

## Step 0 — Run Existing Tests (Baseline)

Confirm current tests pass before generating new ones.

```bash
# Detect and run existing tests
npm test          # Node/TypeScript
pytest            # Python
go test ./...     # Go
```

| Result | Action |
|--------|--------|
| All pass | Baseline established. Proceed |
| Some fail | Note pre-existing failures. Exclude from comparison |
| No tests | Note. Proceed to framework setup |

## Step 1 — Detect Test Framework

| Signal File | Framework |
|---|---|
| `jest.config.*` or package.json jest field | Jest |
| `karma.conf.*` | Karma |
| `*.spec.ts` pattern | Jasmine/Karma (Angular) |
| `cypress.config.*` | Cypress |
| `playwright.config.*` | Playwright |
| `pytest.ini`, `conftest.py` | pytest |
| `*_test.go` | Go testing |

Note file naming pattern (`.spec.ts` vs `.test.ts`) and directory convention
(colocated vs separate `test/`).

## Step 2 — Identify Test Targets

```bash
git diff HEAD --name-only
```

For each changed file, determine:
- New functions/methods that need tests
- Changed functions that need regression tests
- Edge cases visible from the code

## Step 3 — Generate New Tests

For each new function/component:

**Angular components:**
```typescript
describe('ComponentName', () => {
  let component: ComponentName;
  let fixture: ComponentFixture<ComponentName>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ComponentName]
    }).compileComponents();
    fixture = TestBed.createComponent(ComponentName);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // Test each @Input variant
  // Test user interactions
  // Test edge cases
});
```

**General rules:**
- Test behavior, not implementation
- One assertion per test (where practical)
- Descriptive test names in Japanese
- Mock external dependencies, not internal services

## Step 4 — Regression Tests

For changed functions: write tests that verify the **existing behavior** still works
after the change. Focus on the function's contract, not internals.

## Step 5 — Run All Tests

```bash
npm test  # or pytest, go test, etc.
```

| Result | Action |
|--------|--------|
| All pass | Report success |
| New tests fail | Fix the test (not the implementation) |
| Old tests fail | Investigate — may indicate a regression |

## Output

```
## Test Generation

- New tests: X files, Y test cases
- Regression tests: Z test cases
- All passing: Yes/No
- Coverage: (if available)
- Target files: [list]
```
