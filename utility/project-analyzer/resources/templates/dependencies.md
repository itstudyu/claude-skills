# Template — dependencies.md

Output schema for **Axis 5: Dependencies**.

Read package manifests and lock files for exact dependency information. For
the "Purpose" column, check how the package is actually imported and used in
the codebase — don't just guess from the package name.

## Output template

```markdown
# Dependencies — [Project Name]

> Analyzed on YYYY-MM-DD

## Production Dependencies
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| express | 4.18.2 | HTTP server | src/app.ts:1 |
| prisma | 5.8.0 | ORM | src/db/client.ts:1 |
| ...     | ...     | ...     | ...     |

## Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| jest | 29.7.0 | Unit testing |
| ...     | ...     | ...     |

## Dependency Health
- **Total production deps:** [count]
- **Total dev deps:** [count]
- **Lock file:** [yarn.lock / package-lock.json / pnpm-lock.yaml] present: [yes/no]
- **Outdated indicators:** [any pinned old major versions detected]

## Internal Dependencies (monorepo only)
| Package | Path | Depends On |
|---------|------|-----------|
| @app/core | packages/core | - |
| @app/web | packages/web | @app/core |
```
