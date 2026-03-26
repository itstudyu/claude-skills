# Common Git Error Patterns
confidence: 0.8

## pre-commit hook failed
- **Cause:** Linter/formatter/secret-scanner found issues
- **Fix:** Read hook output, fix reported issues, re-stage and commit
- **Prevention:** Run linter before committing. NEVER use --no-verify

## merge conflict in lock file
- **Cause:** Package lock diverged between branches
- **Fix:** Accept either version, then run `npm install` to regenerate
- **Prevention:** Merge main into feature branch before touching dependencies

## detached HEAD
- **Cause:** Checked out a commit hash or tag instead of branch
- **Fix:** `git checkout -b <new-branch>` to create branch from current state
- **Prevention:** Always work on named branches
