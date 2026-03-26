#!/bin/bash
# code-quality-check.sh — PostToolUse hook for automatic coding standards enforcement
# Inspired by levnikolaevich code-quality hook + Everything CC post-edit hooks.
# Matcher: Edit|Write — checks edited files against CODING-STANDARDS.md rules.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Read JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    if isinstance(tool_input, dict):
        print(tool_input.get('file_path', ''))
    elif isinstance(tool_input, str):
        print('')
except:
    print('')
" <<< "$INPUT" 2>/dev/null)

# Skip if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only check source code files
EXT="${FILE_PATH##*.}"
case "$EXT" in
  ts|tsx|js|jsx|py|java|go|rb|rs|swift|kt) ;;
  *) exit 0 ;;
esac

# Skip test files, config files, and generated files
if echo "$FILE_PATH" | grep -qE '(test_|_test\.|\.test\.|spec\.|\.config\.|\.generated\.|node_modules|__pycache__|\.git/)'; then
  exit 0
fi

VIOLATIONS=""

# Check 1: File header missing (CODING-STANDARDS Rule 1)
check_file_header() {
  local first_line
  first_line=$(head -1 "$FILE_PATH" 2>/dev/null)
  case "$EXT" in
    ts|tsx|js|jsx|java|go|rs|swift|kt)
      if ! echo "$first_line" | grep -qE '^\s*(//|/\*)'; then
        VIOLATIONS="${VIOLATIONS}  ⚠️ Rule 1: Missing file header comment (first line should be // summary)\n"
      fi
      ;;
    py|rb)
      if ! echo "$first_line" | grep -qE '^\s*#'; then
        VIOLATIONS="${VIOLATIONS}  ⚠️ Rule 1: Missing file header comment (first line should be # summary)\n"
      fi
      ;;
  esac
}

# Check 2: Function length > 30 lines (CODING-STANDARDS Rule 2)
check_function_length() {
  local max_lines=30
  local long_funcs
  long_funcs=$(python3 -c "
import re, sys

filepath = '$FILE_PATH'
ext = '$EXT'

with open(filepath, 'r', errors='replace') as f:
    lines = f.readlines()

# Language-specific function patterns
if ext in ('ts', 'tsx', 'js', 'jsx'):
    func_pat = re.compile(r'^\s*(export\s+)?(async\s+)?function\s+(\w+)|^\s*(export\s+)?(const|let|var)\s+(\w+)\s*=\s*(async\s+)?\(|^\s*(async\s+)?(\w+)\s*\(.*\)\s*\{')
elif ext == 'py':
    func_pat = re.compile(r'^\s*def\s+(\w+)')
elif ext == 'java':
    func_pat = re.compile(r'^\s*(public|private|protected|static|\s)*\s+\w+\s+(\w+)\s*\(')
elif ext == 'go':
    func_pat = re.compile(r'^func\s+(\w+|\(\w+\s+\*?\w+\)\s+\w+)')
else:
    sys.exit(0)

long = []
func_name = None
func_start = 0
code_lines = 0

for i, line in enumerate(lines):
    stripped = line.strip()
    if func_pat.match(line):
        if func_name and code_lines > $max_lines:
            long.append(f'{func_name} ({code_lines} lines, starts at line {func_start+1})')
        func_name_match = func_pat.match(line)
        groups = [g for g in func_name_match.groups() if g]
        func_name = groups[-1] if groups else 'anonymous'
        func_start = i
        code_lines = 0
    elif func_name:
        if stripped and not stripped.startswith('//') and not stripped.startswith('#') and not stripped.startswith('*'):
            code_lines += 1

# Check last function
if func_name and code_lines > $max_lines:
    long.append(f'{func_name} ({code_lines} lines, starts at line {func_start+1})')

for f in long[:3]:
    print(f)
" 2>/dev/null)

  if [ -n "$long_funcs" ]; then
    while IFS= read -r func; do
      VIOLATIONS="${VIOLATIONS}  ⚠️ Rule 2: Function too long — ${func}\n"
    done <<< "$long_funcs"
  fi
}

# Check 3: Debug output left in code
check_debug_output() {
  local count=0
  case "$EXT" in
    ts|tsx|js|jsx)
      count=$(grep -cE '^\s*console\.(log|debug|info)\(' "$FILE_PATH" 2>/dev/null || true)
      ;;
    py)
      count=$(grep -cE '^\s*print\(' "$FILE_PATH" 2>/dev/null || true)
      ;;
    java)
      count=$(grep -cE '^\s*System\.out\.print' "$FILE_PATH" 2>/dev/null || true)
      ;;
    go)
      count=$(grep -cE '^\s*fmt\.Print' "$FILE_PATH" 2>/dev/null || true)
      ;;
  esac
  count=$(echo "$count" | head -1 | tr -cd '0-9')
  count=${count:-0}
  if [ "$count" -gt 0 ]; then
    VIOLATIONS="${VIOLATIONS}  ⚠️ Rule 5: Debug output detected (${count} occurrences) — remove before commit\n"
  fi
}

# Check 4: Excessive TODOs
check_todos() {
  local count
  count=$(grep -ciE '\bTODO\b|\bFIXME\b|\bHACK\b' "$FILE_PATH" 2>/dev/null || true)
  count=$(echo "$count" | head -1 | tr -cd '0-9')
  count=${count:-0}
  if [ "$count" -ge 5 ]; then
    VIOLATIONS="${VIOLATIONS}  ⚠️ ${count} TODO/FIXME tags accumulated — consider resolving some\n"
  fi
}

# Run all checks
check_file_header
check_function_length
check_debug_output
check_todos

# Report violations
if [ -n "$VIOLATIONS" ]; then
  # Get relative path for cleaner output
  REL_PATH="${FILE_PATH#$PROJECT_ROOT/}"
  echo "" >&2
  echo "📋 CODE QUALITY — ${REL_PATH}:" >&2
  echo -e "$VIOLATIONS" >&2
  exit 2
fi

exit 0
