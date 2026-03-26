# Coding Standards

> All files in the project must follow these rules. Enforced by code-quality-check hook.

## Rules

### 1. File Header
Every source file starts with a one-line English summary comment.
```
// Auth service — handles JWT token issuance and verification
```

### 2. Function Max 30 Lines
Split if exceeded. Add comment if logically unavoidable.

### 3. One File, One Responsibility
No unrelated logic in the same file.

### 4. Commit Confirmation
Always show branch / files / message and wait for user approval before `git commit`.

### 5. Comments in Japanese
All code comments and log messages in Japanese (日本語).

### 6. Commit Messages in Japanese
1-4 lines, key content only. Japanese.

### 7. Branch Naming
`feature/{TaskNumber}/{Name}` — never auto-commit to master/main.

### 8. No Hardcoded Values
Use design tokens, constants, or config for colors, spacing, URLs, etc.

### 9. Import Ordering
1. Framework imports (Angular, React, etc.)
2. Third-party libraries
3. Internal modules (absolute paths)
4. Relative imports

### 10. Error Handling
- Catch specific exceptions, not generic
- Always log errors with context
- User-facing errors in the UI language, internal logs in Japanese
