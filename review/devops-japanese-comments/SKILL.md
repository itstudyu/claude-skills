---
name: devops-japanese-comments
description: |
  Enforce Japanese language in code comments and log messages. Converts English comments
  to Japanese and adds missing comments to complex logic. Use after writing or reviewing
  code. Trigger on "日本語コメント", "japanese comments", "コメント変換", or as part of
  code quality workflow.
---

# Japanese Comments Enforcement

Enforce Japanese for all code comments and log messages.

## Rules

1. **ALL comments must be in Japanese** — no English comments in source code
2. **Log messages** (console.log, logger.info, print, etc.) → Japanese
3. **JSDoc / docstring** → Japanese
4. **TODO / FIXME comments** → Japanese
5. **Inline comments** → Japanese
6. **Do NOT translate:** variable names, function names, string values returned to users/API

## What to Convert

### Before
```typescript
// Get user by ID
const user = await db.user.findUnique({ where: { id } });

// Check if user exists
if (!user) {
  throw new Error('User not found'); // This stays in English (API response)
}

console.log('User fetched successfully', user.id);
```

### After
```typescript
// IDでユーザーを取得する
const user = await db.user.findUnique({ where: { id } });

// ユーザーの存在確認
if (!user) {
  throw new Error('User not found'); // APIレスポンスは英語のまま
}

console.log('ユーザーの取得に成功しました', user.id);
```

## Adding Missing Comments

Add Japanese comments to:
- Functions/methods without any description comment
- Complex logic blocks (conditions with 3+ conditions, non-obvious algorithms)
- Class definitions
- Important constants

**Do NOT add comments to obvious one-liners** (e.g., `return true`, simple assignments).

## JSDoc Example

```typescript
/**
 * ユーザーIDに基づいてプロフィール情報を取得する
 * @param userId - 対象ユーザーのID
 * @returns ユーザープロフィール、存在しない場合はnull
 */
async function getUserProfile(userId: string): Promise<UserProfile | null> {
```

## Scan & Fix Process

**Scope:** Only target files changed in this session, not a full-file scan.

1. Get changed files with `git diff --name-only HEAD`
2. Read only changed files
3. Find English comments → convert to Japanese
4. Find complex logic without comments → add Japanese comments
5. Apply changes with Edit

For new projects (no git history), scan all source files with Glob.

## Output

```
## Japanese Comments

- Comments converted: X
- Comments added: Y
- Target files: [list]
```
