---
name: devops-safety-check
description: |
  Lightweight code security check. Scans for hardcoded secrets, SQL injection, XSS patterns,
  and vulnerable dependencies. Reports only critical issues. Use after writing code or before
  committing. Trigger on "security check", "safety scan", "セキュリティチェック", "보안 검사".
---

# Code Safety Check

Lightweight security scan — report only critical issues, don't rewrite code.

## Rules
- Keep output SHORT. No verbose explanations.
- Report only CRITICAL and WARNING level issues.
- Do NOT fix code here — just flag issues.

## Scan 1 — Secrets & Env Variables

```bash
# Hardcoded secrets (whole-word match to reduce false positives)
grep -rn -w "api_key\|apikey\|API_KEY\|secret\|SECRET\|password\|PASSWORD\|private_key" --include="*.ts" --include="*.js" --include="*.py" --include="*.env" .
# Known secret prefixes
grep -rn "=\s*['\"]sk-\|=\s*['\"]ghp_\|=\s*['\"]xox[bprs]-\|=\s*['\"]AKIA" --include="*.ts" --include="*.js" --include="*.py" .
```

Check:
- No hardcoded API keys, passwords, tokens in source code
- `.env` files are in `.gitignore`
- No credentials in comments

## Scan 2 — Dependency Vulnerabilities

If `package.json` exists → check recently added packages against known CVE patterns.
If `requirements.txt` or `pyproject.toml` exists → same.

Flag any package pinned to a version known to have CVEs.

## Scan 3 — Injection Patterns

```bash
# SQL Injection — string concatenation in queries
grep -rn 'query\s*(\s*["`'"'"'].*+\|execute(\s*f"\|\.format(' --include="*.py" --include="*.ts" --include="*.js" .
# XSS patterns
grep -rn 'innerHTML\s*=\|dangerouslySetInnerHTML\|document\.write(' --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" .
```

Review each match in context — static strings are safe.

## Scan 4 — Load Custom Standards

If `standards/` exists, load and apply additional security rules:
1. `standards/common/*.md` — always
2. `standards/frontend/*.md` — for frontend files
3. `standards/backend/*.md` — for backend files

## Output

```
## Safety Check

| Level | Issue | File | Line |
|-------|-------|------|------|
| CRITICAL | Hardcoded API key | src/api.ts | 23 |
| WARNING | innerHTML usage | components/Card.tsx | 45 |

No issues found (if clean)
```
