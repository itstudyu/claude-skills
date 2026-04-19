# Template — data-model.md

Output schema for **Axis 3: Data Model**.

Read schema files, migration files, and ORM model definitions.

If no schema files exist, check for:
- Raw SQL in migration files
- ORM model decorators / annotations
- NoSQL collection usage in code

If nothing is found, write: "No database schema detected in source files."

## Output template

```markdown
# Data Model — [Project Name]

> Analyzed on YYYY-MM-DD

## Tables / Collections

### users
- **Source:** `prisma/schema.prisma:15-28`
- **Columns:**
  | Column | Type | Constraints | Notes |
  |--------|------|-------------|-------|
  | id | UUID | PK, auto-generated | |
  | email | String | unique, not null | indexed (line 20) |
  | password | String | not null | bcrypt hash |
  | role_id | UUID | FK → roles.id | cascade delete |
  | created_at | DateTime | default: now() | |

- **Relationships:**
  - belongs_to: `roles` via `role_id` (line 25)
  - has_many: `posts` (line 27)

- **Indexes:**
  - `@@index([email])` (line 28)

### [next table]
...

## ER Summary
[Describe relationships between tables as detected from FK constraints and
ORM relation decorators. Only include relationships you found in code.]
```
