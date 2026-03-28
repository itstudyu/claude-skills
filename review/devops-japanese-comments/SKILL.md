---
name: devops-japanese-comments
description: |
  Enforce Japanese language in all code comments, log messages, JSDoc/docstrings, and
  TODO/FIXME annotations. Converts English comments to Japanese and adds missing comments
  to complex logic blocks. Use this skill after writing or reviewing code in any language.
  Trigger whenever the user says "日本語コメント", "japanese comments", "コメント変換",
  "コメントを日本語に", "add japanese comments", "translate comments", "코멘트 일본어로",
  "일본어 코멘트", or as part of any code quality workflow. Proactively suggest this skill
  after any code writing session where comments are in English or missing — the team
  convention requires all comments and logs to be in Japanese.
---

# Japanese Comments Enforcement

Convert all code comments and log messages to Japanese, and add missing comments
to complex logic. This is a team convention — Japanese comments make the codebase
more accessible to the entire team and ensure consistent documentation language.

## What Gets Converted

| Target | Convert? | Example |
|--------|----------|---------|
| Inline comments (`//`, `#`) | Yes | `// Get user` → `// ユーザーを取得する` |
| Block comments (`/* */`) | Yes | Same treatment |
| JSDoc / docstrings | Yes | `@param userId` description → Japanese |
| TODO / FIXME / HACK | Yes | `// TODO: refactor` → `// TODO: リファクタリングする` |
| Log messages | Yes | `console.log('fetched')` → `console.log('取得しました')` |
| Error messages for monitoring | Yes | Internal logs → Japanese |

## What Stays in English

- Variable names, function names, class names
- String values returned to users/API (user-facing text follows its own i18n rules)
- Import statements and framework-specific annotations
- Test assertion messages (these are developer-facing but often tied to framework output)
- Commit messages (handled by separate git workflow)

## Before / After

```typescript
// Get user by ID
const user = await db.user.findUnique({ where: { id } });

// Check if user exists
if (!user) {
  throw new Error('User not found'); // API response stays English
}

console.log('User fetched successfully', user.id);
```

```typescript
// IDでユーザーを取得する
const user = await db.user.findUnique({ where: { id } });

// ユーザーの存在確認
if (!user) {
  throw new Error('User not found'); // APIレスポンスは英語のまま
}

console.log('ユーザーの取得に成功しました', user.id);
```

## JSDoc Example

```typescript
/**
 * ユーザーIDに基づいてプロフィール情報を取得する
 * @param userId - 対象ユーザーのID
 * @returns ユーザープロフィール、存在しない場合はnull
 */
async function getUserProfile(userId: string): Promise<UserProfile | null> {
```

## Adding Missing Comments

Add Japanese comments to code that lacks documentation:
- Functions/methods without any description
- Complex conditionals (3+ conditions, nested logic)
- Class and interface definitions
- Important constants and configuration values
- Non-obvious algorithms or business logic

Skip obvious one-liners — `return true`, simple assignments, and trivial getters
don't need comments. Over-commenting is noise.

## Scan & Fix Process

1. **Scope changed files only** — run `git diff HEAD --name-only` to get the list.
   For new projects with no git history, use Glob to scan all source files.
2. **Target file types:** `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.java`, `.go`,
   `.rb`, `.vue`, `.scss` (SCSS comments too)
3. **Find English comments** — look for `//`, `#`, `/* */`, docstrings containing
   English words. Convert each to natural Japanese.
4. **Find missing comments** — identify functions, classes, and complex blocks
   without any comments. Add concise Japanese descriptions.
5. **Apply with Edit tool** — modify files in place. Don't create separate files.

## Quality Guidelines

- Use natural Japanese, not machine-translation-style. Keep it concise.
- Technical terms can stay in katakana (リファクタリング, コンポーネント, etc.)
- Match the formality level of the existing codebase
- Don't add unnecessary particles or overly polite forms in code comments

## Output

```markdown
## Japanese Comments

- Comments converted: X
- Comments added: Y
- Files modified: [list]
```
