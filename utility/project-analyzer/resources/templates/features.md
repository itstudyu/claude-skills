# Template — features.md

Output schema for **Axis 2: Features**.

Identify features by reading route definitions, API endpoints, service files,
and module structures. For each feature, trace the code path: entry point →
handler/controller → service/business logic → data access layer.

Read the actual function bodies. Report what the code does, not what you think
it should do.

## Output template

```markdown
# Features — [Project Name]

> Analyzed on YYYY-MM-DD

## Feature: [Name]
- **Entry point:** `src/routes/auth.ts:12` — POST /api/auth/login
- **Controller:** `src/controllers/auth.controller.ts:25` — `login()`
- **Service:** `src/services/auth.service.ts:18` — `authenticate()`
- **Data access:** `src/repositories/user.repository.ts:10` — `findByEmail()`
- **Dependencies:** bcrypt (password hashing), jsonwebtoken (JWT generation)
- **Key logic:**
  - Validates email format (line 20-22)
  - Hashes password comparison (line 28)
  - Generates JWT with 24h expiry (line 35)
  - Stores refresh token in DB (line 42)

## Feature: [Name]
...
```
