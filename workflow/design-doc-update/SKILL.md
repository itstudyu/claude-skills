---
name: design-doc-update
description: |
  Update existing design documents and project overview after code changes. Analyzes
  git diff to detect which features changed, finds the corresponding design docs in
  docs/specs/, and updates them to reflect the current state of the code. Also updates
  docs/project-overview.md if the project structure changed. Use this skill whenever
  the user says "update design docs", "sync docs with code", "refresh specs",
  "설계서 업데이트", "설계서 최신화", "ドキュメント更新", "設計書更新", or after
  completing a feature implementation or significant code change. Proactively suggest
  this skill after any PR merge, feature completion, or when the user says "I'm done
  with this feature" and design docs exist in the project.
---

# Design Doc Update

Keep design documents in sync with the actual code. After code changes, this skill
detects what changed, finds the affected design docs, and updates them so the
documentation always reflects reality.

Stale docs are worse than no docs — they mislead both humans and AI.

## When to Use

- After completing a feature implementation
- After a PR merge that changes feature behavior
- After modifying database schema, API endpoints, or business logic
- When the user notices docs are out of date
- Periodically (e.g., end of sprint) for a docs refresh

## Step 1: Detect Changes

Identify what changed since the design docs were last updated:

```bash
# Find all design doc files and their last update timestamps
ls docs/specs/*.md docs/project-overview.md 2>/dev/null

# Get changed files since the most recently updated doc
LAST_DOC=$(ls -t docs/specs/*.md docs/project-overview.md 2>/dev/null | head -1)
git diff --name-only $(git log -1 --format=%H -- "$LAST_DOC")..HEAD 2>/dev/null
```

If no git history is available, compare the current code against what's described
in the design docs by reading both and finding discrepancies.

## Step 2: Map Changes to Features

For each changed file, determine which feature it belongs to:

1. Check `docs/specs/*.md` — each design doc has a "Files" section listing related paths
2. Match changed files against those file lists
3. Group changes by feature

```
Changed files → Feature mapping:
  src/auth/auth.service.ts → docs/specs/user-authentication.md
  src/auth/auth.controller.ts → docs/specs/user-authentication.md
  src/features/qna/qna.model.ts → docs/specs/qna.md
  src/app.module.ts → docs/project-overview.md (structural change)
```

If a changed file doesn't map to any existing design doc, note it as an
undocumented feature and suggest creating one with `/design-doc`.

## Step 3: Analyze What Changed

For each affected design doc, read the current doc and compare against the code:

**Data Model changes:**
- New columns, renamed columns, dropped columns
- New tables or removed tables
- Changed relationships or constraints

**API changes:**
- New endpoints, removed endpoints
- Changed request/response shapes
- Changed authentication requirements

**Business Logic changes:**
- New validation rules or modified rules
- Changed state transitions or workflows
- New error handling patterns

**UI/Screen changes:**
- New components, removed components
- Changed routing paths
- New shared components used

**File changes:**
- New files added to the feature
- Files moved or renamed
- Files deleted

## Step 4: Update Documents

For each affected design doc, apply the changes:

1. Read the current design doc
2. Update only the sections that changed — don't rewrite unchanged sections
3. Update the "Last updated" date in the header
4. If a section was N/A and now has content, fill it in
5. If content was removed (table dropped, endpoint deleted), remove it

For `docs/project-overview.md`:
- Update Feature List if features were added/removed
- Update Data Model if tables changed
- Update Directory Structure if new directories were created
- Update Dependencies if packages were added/removed

## Step 5: Report Changes

Present a summary of what was updated:

```markdown
## Design Doc Update Report

**Trigger:** [git diff / manual request / post-merge]
**Date:** YYYY-MM-DD

### Updated Documents
| Document | Changes |
|----------|---------|
| docs/specs/user-authentication.md | Added password reset API endpoint, updated users table (added reset_token column) |
| docs/specs/qna.md | New answer voting business rule, added votes table |
| docs/project-overview.md | Updated feature list (added "Password Reset"), updated data model |

### New Undocumented Features
- src/features/notifications/ — no design doc exists. Run `/design-doc` to create one.

### No Changes Needed
- docs/specs/tour-application.md — no related code changes detected
```

## Step 6: Commit

Offer to commit the updated documents:

> "Design docs updated. Want me to commit these changes?"

## Handling Edge Cases

**Deleted feature:** If all files in a feature's "Files" section are deleted,
ask the user: "The [feature] appears to have been removed. Should I delete
docs/specs/[feature].md or mark it as deprecated?"

**Major refactor:** If more than 50% of a design doc's content needs changing,
suggest regenerating from scratch with `/design-doc` instead of patching.

**No design docs exist:** If `docs/specs/` is empty or doesn't exist, suggest
running `/project-scan` followed by `/design-doc` instead of this skill.

## Principles

- **Update, don't rewrite.** Change only what changed. Preserve unchanged sections
  exactly as they are.
- **Evidence-based.** Read the actual code diff, don't guess what changed.
- **Flag unknowns.** If you can't determine what changed, ask rather than assume.
- **Both levels.** Update both feature-level specs AND project-overview.md when relevant.
