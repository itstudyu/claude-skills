# Template — code-patterns.md

Output schema for **Axis 4: Code Patterns**.

Read 5-10 representative files across different layers (routes, controllers,
services, repositories, tests, middleware) and document actual patterns.
Include actual code snippets from the file, not paraphrases.

## Output template

```markdown
# Code Patterns — [Project Name]

> Analyzed on YYYY-MM-DD

## Naming Conventions
| Context | Pattern | Example | Source |
|---------|---------|---------|--------|
| Variables | camelCase | `userName` | src/services/user.ts:15 |
| Classes | PascalCase | `UserService` | src/services/user.ts:3 |
| Files | kebab-case | `user-service.ts` | src/services/ |
| DB columns | snake_case | `created_at` | prisma/schema.prisma:20 |

## Import Patterns
- Path aliases: `@/` maps to `src/` (tsconfig.json:8)
- Style: named imports preferred (`import { X } from '...'`)
- Example: `src/controllers/auth.controller.ts:1-5`

## Error Handling
- Pattern: [describe what you found]
- Example: `src/middleware/error.ts:10-25`
  ```typescript
  [actual code snippet from the file]
  ```

## File Organization
- [describe the actual structure you observed]
- Components: [colocated/separated] — evidence: [path]
- Tests: [colocated/separated] — evidence: [path]

## State Management (if frontend)
- Pattern: [what you found]
- Source: [file:line]

## Logging
- Library: [detected from imports]
- Pattern: [describe]
- Source: [file:line]
```
