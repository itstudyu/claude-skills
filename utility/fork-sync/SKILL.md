---
name: fork-sync
description: |
  Sync a forked GitHub repository with its upstream. Fetches upstream changes,
  fast-forwards or merges into the default branch, and pushes to origin.
  Preserves local-only files (.env, .claude/, .gitignored files are untouched).
  Use whenever the user says "fork sync", "sync fork", "sync my fork",
  "update fork", "pull upstream", "upstream 동기화", "포크 동기화",
  "fork 업데이트", "フォーク同期", "アップストリーム同期", or "/fork-sync".
  Proactively suggest when the user mentions their fork is behind upstream
  or when working in a GitHub fork that hasn't been synced recently.
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# fork-sync

Sync a forked GitHub repository with its upstream (parent) repository.

## What It Does

```
langfuse/langfuse  (upstream — original)
       │
       │  git fetch upstream
       ▼
itstudyu/langfuse  (origin — your fork)
       ▲
       │  git push origin main
       │  git merge upstream/main
       │
Local:  ~/Documents/GitHub/langfuse
```

1. Detects the upstream (parent) repo automatically via `gh` CLI
2. Fetches upstream changes
3. Merges into the default branch (fast-forward preferred)
4. Pushes to your fork on GitHub
5. Preserves local-only files (.env, .claude/, anything .gitignored)

## When to Run

- User mentions their fork is behind the original
- After upstream releases a new version you want to pick up
- Before starting new work on a long-lived fork

## Prerequisites

Before running, verify:

1. **Current directory is a git repo**
   ```bash
   git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not a git repo"; exit 1; }
   ```

2. **`origin` remote exists and points to GitHub**
   ```bash
   ORIGIN_URL=$(git remote get-url origin)
   echo "$ORIGIN_URL" | grep -q "github.com" || { echo "origin is not a GitHub repo"; exit 1; }
   ```

3. **Working tree is clean** (no uncommitted changes)
   ```bash
   if ! git diff --quiet || ! git diff --cached --quiet; then
     echo "Working tree has uncommitted changes. Commit or stash first."
     git status --short
     exit 1
   fi
   ```

If any check fails, stop and tell the user what to fix.

## Step 1: Ensure `upstream` remote exists

```bash
if git remote get-url upstream >/dev/null 2>&1; then
  echo "upstream already configured: $(git remote get-url upstream)"
else
  # Try to auto-detect parent repo via gh CLI
  if command -v gh >/dev/null 2>&1; then
    ORIGIN_URL=$(git remote get-url origin)
    # Extract owner/repo from URL (handles both https and ssh)
    OWNER_REPO=$(echo "$ORIGIN_URL" | sed -E 's#.*github\.com[:/]([^/]+/[^/.]+)(\.git)?#\1#')
    UPSTREAM_URL=$(gh api "repos/$OWNER_REPO" --jq '.parent.clone_url' 2>/dev/null)

    if [ -n "$UPSTREAM_URL" ] && [ "$UPSTREAM_URL" != "null" ]; then
      git remote add upstream "$UPSTREAM_URL"
      echo "Added upstream: $UPSTREAM_URL"
    else
      echo "Could not auto-detect parent repo. This may not be a fork."
      # Fall through to ask user
    fi
  fi
fi
```

If auto-detection fails, use **AskUserQuestion** to get the upstream URL from the user:
- Ask: "What is the upstream repository URL? (e.g., https://github.com/langfuse/langfuse.git)"
- Then: `git remote add upstream "$USER_PROVIDED_URL"`

## Step 2: Detect the default branch

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
  # Fallback: check common names
  for b in main master; do
    if git show-ref --verify --quiet "refs/remotes/origin/$b"; then
      DEFAULT_BRANCH=$b
      break
    fi
  done
fi
echo "Default branch: $DEFAULT_BRANCH"
```

## Step 3: Verify we're on the default branch

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
  echo "You are on '$CURRENT_BRANCH', but sync targets '$DEFAULT_BRANCH'."
  echo "Switch with: git checkout $DEFAULT_BRANCH"
  exit 1
fi
```

## Step 4: Fetch upstream

```bash
git fetch upstream
```

## Step 5: Show how far behind/ahead we are

```bash
BEHIND=$(git rev-list --count "HEAD..upstream/$DEFAULT_BRANCH")
AHEAD=$(git rev-list --count "upstream/$DEFAULT_BRANCH..HEAD")

echo "Your fork is $BEHIND commit(s) behind and $AHEAD commit(s) ahead of upstream."

if [ "$BEHIND" = "0" ]; then
  echo "Already up to date with upstream. Nothing to do."
  exit 0
fi

# Show what's coming
echo ""
echo "Incoming commits:"
git log --oneline "HEAD..upstream/$DEFAULT_BRANCH" | head -20
[ "$BEHIND" -gt 20 ] && echo "  ... and $((BEHIND - 20)) more"
```

If `AHEAD > 0`, warn the user their local branch has commits not in upstream — these will be preserved via merge commit (not fast-forward).

## Step 6: Merge upstream into local

```bash
# Prefer fast-forward (clean history)
if git merge --ff-only "upstream/$DEFAULT_BRANCH" 2>/dev/null; then
  echo "Fast-forwarded to upstream/$DEFAULT_BRANCH"
else
  # Fast-forward impossible — local has divergent commits
  echo "Fast-forward not possible. Creating merge commit..."
  if ! git merge --no-edit "upstream/$DEFAULT_BRANCH"; then
    echo ""
    echo "MERGE CONFLICT. Stopping."
    echo "To resolve: fix conflicts, then run:"
    echo "  git add <files> && git commit"
    echo "To abort:"
    echo "  git merge --abort"
    exit 1
  fi
fi
```

**Never use `--force`.** If merge fails, stop and let the user resolve manually.

## Step 7: Push to origin (your fork)

```bash
git push origin "$DEFAULT_BRANCH"
```

If push fails (auth, network, protected branch), report the exact error — do not retry with force.

## Step 8: Summary

Output a concise summary:

```
fork-sync complete
  Synced: N commits from upstream/<default_branch>
  Latest: <short SHA> <latest commit message>
  Fork:   <origin URL>
  Local:  in sync
```

Optionally show the top changed areas:
```bash
git diff --stat "HEAD@{1}..HEAD" | tail -10
```

## Error Recovery

| Error | Action |
|---|---|
| Not a git repo | Stop. Tell user to `cd` into a fork repo. |
| `origin` not GitHub | Stop. Skill is for GitHub forks only. |
| Dirty working tree | Stop. Show `git status`, suggest `git stash` or commit. |
| No `gh` CLI, can't detect upstream | Ask user for upstream URL via AskUserQuestion. |
| Not a fork (no parent repo) | Stop. Tell user this repo has no upstream. |
| Merge conflict | Stop. Show abort/resolve instructions. |
| Push rejected | Stop. Show exact error. Never force push. |

## Notes

- **Local files are always safe.** Files in `.gitignore` (like `.env`, local configs) are never touched by fetch/merge/push. Only tracked files are updated.
- **Only the default branch is synced.** Feature branches and tags are out of scope.
- **No force pushes, ever.** If history diverges in a way that requires force, the user must do it manually with full understanding.
- **Subsequent runs are fast.** After the first run, `upstream` remote is cached and fetch is incremental.
