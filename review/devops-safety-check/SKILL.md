---
name: devops-safety-check
description: |
  Lightweight code security scanner that checks for hardcoded secrets, SQL injection,
  XSS vulnerabilities, and dependency issues. Produces a concise report of critical
  findings without modifying any code. Use this skill whenever the user asks for a
  "security check", "safety scan", "vulnerability scan", "secret scan", "code audit
  for security", or mentions concerns about credentials in code, injection risks, or
  dependency vulnerabilities — even if they don't use the exact phrase "safety check".
  Also trigger when the user says "セキュリティチェック", "보안 검사", "보안 스캔",
  or "check for secrets". Proactively suggest this skill before committing code that
  touches authentication, API integrations, database queries, or user input handling.
---

# Code Safety Check

Quick security scan that flags critical vulnerabilities without modifying code.
The goal is a fast, focused report — not a comprehensive penetration test.

## Principles

- **Report, don't fix.** Flag issues with location and severity. Never rewrite code.
- **Critical issues only.** Skip style nits and minor warnings. Focus on things that
  could lead to data leaks, unauthorized access, or injection attacks.
- **Context matters.** A grep match isn't automatically a vulnerability — read the
  surrounding code before flagging. Static strings and test fixtures are safe.
- **Keep output short.** The report should fit on one screen. If there are many issues,
  group by severity and show the top 10 with a count of remaining.

## Scan 1: Secrets & Credentials

Look for hardcoded secrets, API keys, tokens, and passwords in source code.

```bash
# Hardcoded secret keywords (whole-word match to reduce false positives)
grep -rn -w "api_key\|apikey\|API_KEY\|secret\|SECRET\|password\|PASSWORD\|private_key" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.java" \
  --include="*.go" --include="*.rb" --include="*.env" .

# Known secret prefixes (AWS, GitHub, Slack, OpenAI, Stripe, etc.)
grep -rn "=\s*['\"]sk-\|=\s*['\"]ghp_\|=\s*['\"]xox[bprs]-\|=\s*['\"]AKIA\|=\s*['\"]sk_live_\|=\s*['\"]pk_live_\|=\s*['\"]AIza" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.java" \
  --include="*.go" --include="*.rb" .
```

**What to check:**
- No hardcoded API keys, passwords, or tokens in source files
- `.env` and `.env.*` files listed in `.gitignore`
- No credentials visible in comments or documentation
- Environment variable references (`process.env.X`, `os.environ["X"]`) are safe — skip those

**Severity guide:**
- CRITICAL: Actual secret value in source (e.g., `apiKey = "sk-abc123..."`)
- WARNING: Suspicious pattern that needs manual review (e.g., `password` in a config struct)

## Scan 2: Dependency Vulnerabilities

Check recently added or changed packages for known security issues.

**For Node.js** (`package.json`):
- Run `npm audit --json 2>/dev/null` or `yarn audit --json 2>/dev/null` if lockfile exists
- If no lockfile, check package versions against known CVE patterns manually
- Flag packages with critical or high severity vulnerabilities

**For Python** (`requirements.txt`, `pyproject.toml`, `Pipfile`):
- Run `pip audit --format json 2>/dev/null` if available
- Otherwise check pinned versions against known vulnerable ranges
- Flag any package with known critical CVEs

**For other ecosystems:** Check the relevant lockfile if it exists and flag outdated
packages with known vulnerabilities.

Only report critical and high severity issues. Low/moderate can be noted as a count
at the end ("12 moderate issues omitted").

## Scan 3: Injection Patterns

Look for SQL injection, XSS, and command injection vulnerabilities.

```bash
# SQL Injection — string concatenation or interpolation in queries
grep -rn 'query\s*(\s*["`'"'"'].*+\|execute(\s*f"\|\.format(\|\.raw(\s*`' \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.java" .

# XSS — direct DOM manipulation with user content
grep -rn 'innerHTML\s*=\|dangerouslySetInnerHTML\|document\.write(\|v-html\s*=' \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.vue" .

# Command Injection — user input in shell commands
grep -rn 'exec(\|spawn(\|system(\|popen(\|subprocess\.\(call\|run\|Popen\)' \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.java" .
```

**Important:** Read each match in context before flagging.
- Parameterized queries (`query($1, values)`) are safe
- Static HTML strings in innerHTML are usually safe
- Template literals without user input are safe
- Subprocess calls with hardcoded commands are lower risk

**Severity guide:**
- CRITICAL: User input directly concatenated into SQL/command/HTML
- WARNING: Dynamic content in query/exec that might come from user input (needs review)

## Scan 4: Project Standards

If the project has a `standards/` directory, load and cross-reference:

1. `standards/common/*.md` — always apply
2. `standards/frontend/*.md` — for `.ts`, `.tsx`, `.js`, `.jsx`, `.vue`, `.scss` files
3. `standards/backend/*.md` — for `.py`, `.java`, `.go`, `.rb` files

Only flag violations that have security implications (e.g., error handling rules
that could leak stack traces, hardcoded URL rules).

## Output Format

Always produce a structured report:

```markdown
## Safety Check Report

**Scanned:** <N> files in <directory>
**Time:** <timestamp>

| # | Level | Issue | File | Line | Details |
|---|-------|-------|------|------|---------|
| 1 | CRITICAL | Hardcoded API key | src/api.ts | 23 | `apiKey = "sk-..."` |
| 2 | CRITICAL | SQL injection risk | src/db.ts | 45 | String concatenation in query |
| 3 | WARNING | innerHTML usage | components/Card.tsx | 67 | Dynamic content — verify source |

**Summary:** 2 critical, 1 warning
**Dependencies:** 0 critical (12 moderate omitted)

### Recommended Actions
1. Move API key to environment variable (line 23)
2. Use parameterized query (line 45)
3. Verify innerHTML source is sanitized (line 67)
```

If no issues are found:

```markdown
## Safety Check Report

**Scanned:** <N> files in <directory>
**Time:** <timestamp>

✅ No critical or warning-level issues found.
```
