---
name: devops-test-gen
description: |
  Auto-generate unit tests and regression tests for new or changed code. Detects the
  project's test framework automatically and follows existing test patterns. Use this
  skill whenever the user says "generate tests", "add tests", "write tests", "テスト生成",
  "テスト追加", "테스트 생성", "테스트 추가", or when code has been written without
  accompanying test files. Proactively suggest this skill after any implementation task
  that doesn't include tests — untested code is incomplete code.
---

# Test Generation

Generate tests for new code and regression tests for changed code. The goal is to
catch bugs before they reach production, not to achieve arbitrary coverage numbers.
Good tests verify behavior and protect against regressions.

## Step 0: Establish Baseline

Before generating anything, confirm the existing test suite passes. This prevents
blaming new tests for pre-existing failures.

```bash
# Run whatever test command the project uses
npm test          # Node/TypeScript
pytest            # Python
go test ./...     # Go
bundle exec rspec # Ruby
```

| Result | Action |
|--------|--------|
| All pass | Baseline established — proceed |
| Some fail | Note pre-existing failures, exclude from comparison later |
| No tests exist | Note it. Set up framework in Step 1 if needed |

## Step 1: Detect Test Framework

Scan the project for framework indicators. Match the existing setup — don't introduce
a new framework unless there's nothing in place.

| Signal | Framework |
|--------|-----------|
| `jest.config.*` or `"jest"` in package.json | Jest |
| `karma.conf.*` or `*.spec.ts` pattern | Karma/Jasmine (Angular) |
| `vitest.config.*` | Vitest |
| `cypress.config.*` | Cypress (E2E) |
| `playwright.config.*` | Playwright (E2E) |
| `pytest.ini`, `conftest.py`, `pyproject.toml [tool.pytest]` | pytest |
| `*_test.go` | Go testing |
| `spec/` directory with `*_spec.rb` | RSpec |

Also note:
- **File naming**: `.spec.ts` vs `.test.ts` — match the project convention
- **Directory**: colocated (`foo.spec.ts` next to `foo.ts`) vs separate `test/` folder
- **Test utilities**: existing helpers, factories, fixtures to reuse

## Step 2: Identify Test Targets

```bash
git diff HEAD --name-only
```

For each changed file, categorize what needs testing:

| Change Type | Test Type | Focus |
|-------------|-----------|-------|
| New function/class | Unit test | Core behavior, edge cases, error paths |
| Modified function | Regression test | Existing contract still holds |
| New API endpoint | Integration test | Request/response, validation, error codes |
| UI component | Component test | Rendering, user interactions, props |

Skip generating tests for:
- Pure config files (tsconfig, eslint, etc.)
- Type definitions with no runtime behavior
- Simple re-exports

## Step 3: Generate Tests

Follow the project's existing test patterns. Test behavior, not implementation.

**Angular component example:**
```typescript
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserListComponent]
    }).compileComponents();
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display users when data is loaded', () => { /* ... */ });
  it('should show empty state when no users', () => { /* ... */ });
  it('should handle loading error gracefully', () => { /* ... */ });
});
```

**Python pytest example:**
```python
class TestUserService:
    def test_create_user_with_valid_data(self, db_session):
        user = UserService.create(name="Test", email="test@example.com")
        assert user.id is not None
        assert user.name == "Test"

    def test_create_user_rejects_duplicate_email(self, db_session):
        UserService.create(name="First", email="dup@example.com")
        with pytest.raises(DuplicateEmailError):
            UserService.create(name="Second", email="dup@example.com")

    def test_create_user_rejects_empty_name(self):
        with pytest.raises(ValidationError):
            UserService.create(name="", email="valid@example.com")
```

**Test writing principles:**
- One assertion per test where practical — makes failures easy to diagnose
- Descriptive test names (in Japanese if that's the project convention)
- Mock external dependencies (HTTP, DB), not internal services
- Cover the happy path, error paths, and at least one edge case per function
- Use existing test factories/fixtures — don't reinvent setup patterns

## Step 4: Regression Tests

For modified functions, write tests that verify the existing contract still holds.
The point is catching unintended side effects of the change.

Focus on:
- Return values for known inputs haven't changed
- Error handling still works as expected
- Side effects (DB writes, API calls) still happen correctly
- Edge cases at boundaries (empty input, max values, null)

## Step 5: Run and Verify

```bash
npm test   # or pytest, go test, etc.
```

| Result | Action |
|--------|--------|
| All pass | Report success with counts |
| New tests fail | Fix the test (likely a misunderstanding of the code), not the implementation |
| Old tests fail | Investigate — this may indicate a real regression |

## Output

```markdown
## Test Generation Report

- **New tests:** X files, Y test cases
- **Regression tests:** Z test cases
- **Result:** All passing / N failures
- **Coverage:** (if tool available)
- **Files created/modified:** [list]
```
