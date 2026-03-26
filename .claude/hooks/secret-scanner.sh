#!/bin/bash
# secret-scanner.sh — PreToolUse hook that blocks git commits containing secrets
# Inspired by levnikolaevich/claude-code-skills secret-scanner pattern.
# Matcher: Bash — scans staged content before git commit/add for 11 secret patterns.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Read JSON from stdin
INPUT=$(cat)

# Extract command from tool_input
COMMAND=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    if isinstance(tool_input, dict):
        print(tool_input.get('command', ''))
    elif isinstance(tool_input, str):
        print(tool_input)
except:
    print('')
" <<< "$INPUT" 2>/dev/null)

# Only scan on git commit or git add commands
if ! echo "$COMMAND" | grep -qE 'git\s+(commit|add)'; then
  exit 0
fi

# Get staged file contents
STAGED_DIFF=$(cd "$PROJECT_ROOT" && git diff --cached --diff-filter=ACMR 2>/dev/null)

if [ -z "$STAGED_DIFF" ]; then
  exit 0
fi

# 11 secret patterns (levnikolaevich-compatible)
FOUND_SECRETS=""

check_pattern() {
  local name="$1"
  local pattern="$2"
  local matches
  matches=$(echo "$STAGED_DIFF" | grep -cE "$pattern" 2>/dev/null || true)
  if [ "$matches" -gt 0 ]; then
    FOUND_SECRETS="${FOUND_SECRETS}  ⛔ ${name} (${matches} match)\n"
  fi
}

check_pattern "AWS Access Key ID"      'AKIA[0-9A-Z]{16}'
check_pattern "AWS Secret Key"         'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}'
check_pattern "JWT Token"              'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.'
check_pattern "GitHub PAT"             'ghp_[A-Za-z0-9]{36}'
check_pattern "GitHub OAuth"           'gho_[A-Za-z0-9]{36}'
check_pattern "Private Key"            '-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----'
check_pattern "Generic API Key"        '[Aa][Pp][Ii][_-]?[Kk][Ee][Yy]\s*[:=]\s*["\x27][A-Za-z0-9_\-]{20,}'
check_pattern "Generic Secret"         '[Ss][Ee][Cc][Rr][Ee][Tt]\s*[:=]\s*["\x27][A-Za-z0-9_\-]{10,}'
check_pattern "Database URL"           '(postgres|mysql|mongodb(\+srv)?):\/\/[^\s]{10,}'
check_pattern "Slack Token"            'xox[bpas]-[A-Za-z0-9\-]{10,}'
check_pattern "Google API Key"         'AIza[0-9A-Za-z_\-]{35}'

if [ -n "$FOUND_SECRETS" ]; then
  echo "" >&2
  echo "🔒 SECRET SCANNER — Potential secrets detected in staged changes:" >&2
  echo "" >&2
  echo -e "$FOUND_SECRETS" >&2
  echo "Commit blocked. Remove secrets before committing." >&2
  echo "If these are false positives, review and re-stage." >&2
  echo "" >&2
  exit 2
fi

exit 0
