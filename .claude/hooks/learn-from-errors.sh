#!/bin/bash
# learn-from-errors.sh — PostToolUse hook that auto-records Bash execution errors
# PostToolUse hook (matcher: Bash): detects exit_code != 0 after Bash tool execution and logs it.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MISTAKES_DIR="$PROJECT_ROOT/docs/mistakes"

# Read JSON from stdin
INPUT=$(cat)

# Extract exit_code and command info
RESULT=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    tool_output = data.get('tool_output', {})

    # Get exit_code (from tool_output)
    exit_code = 0
    if isinstance(tool_output, dict):
        exit_code = tool_output.get('exit_code', 0)
    elif isinstance(tool_output, str):
        # Check if output contains error
        if 'error' in tool_output.lower()[:200] or 'failed' in tool_output.lower()[:200]:
            exit_code = 1

    if exit_code == 0:
        print('OK')
        sys.exit(0)

    # Get command
    command = ''
    if isinstance(tool_input, dict):
        command = tool_input.get('command', '')
    elif isinstance(tool_input, str):
        command = tool_input

    # Get output (first 500 chars)
    output = ''
    if isinstance(tool_output, str):
        output = tool_output[:500]
    elif isinstance(tool_output, dict):
        output = json.dumps(tool_output)[:500]

    print(f'ERROR|{command}|{output}')
except Exception as e:
    print('OK')
" <<< "$INPUT" 2>/dev/null)

# Exit if not an error
if [ "$RESULT" = "OK" ] || [ -z "$RESULT" ]; then
  exit 0
fi

# Decompose error info
IFS='|' read -r STATUS COMMAND OUTPUT <<< "$RESULT"

# Create directory
mkdir -p "$MISTAKES_DIR"

AUTO_FILE="$MISTAKES_DIR/auto-detected.md"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

# File header (only for new files)
if [ ! -f "$AUTO_FILE" ]; then
  cat > "$AUTO_FILE" << 'HEADER'
# Auto-Detected Errors

Automatically recorded by `learn-from-errors.sh` PostToolUse hook.
Use these patterns to avoid repeating the same mistakes.

---

HEADER
fi

# File size limit (500KB)
if [ -f "$AUTO_FILE" ] && [ "$(wc -c < "$AUTO_FILE")" -gt 524288 ]; then
  exit 0
fi

# Append error
cat >> "$AUTO_FILE" << EOF
### $DATE $TIME

**Command:** \`${COMMAND:0:200}\`

**Error:**
\`\`\`
${OUTPUT:0:300}
\`\`\`

---

EOF

# === Instincts auto-extraction — promote recurring errors to learned patterns ===
INSTINCTS_DIR="$PROJECT_ROOT/instincts/errors"
mkdir -p "$INSTINCTS_DIR"

python3 -c "
import os, sys, re, hashlib
from datetime import date

auto_file = '$AUTO_FILE'
instincts_dir = '$INSTINCTS_DIR'
command = '''${COMMAND:0:200}'''
today = str(date.today())

if not os.path.isfile(auto_file):
    sys.exit(0)

# Create error signature from normalized command
cmd_normalized = re.sub(r'[0-9a-f]{6,}', 'HASH', command.strip())
cmd_normalized = re.sub(r'/[^ ]*/', 'PATH/', cmd_normalized)
cmd_normalized = re.sub(r'\s+', ' ', cmd_normalized).strip()[:100]
sig = hashlib.sha256(cmd_normalized.encode()).hexdigest()[:12]

# Count similar error occurrences in auto-detected.md
try:
    with open(auto_file, 'r') as f:
        content = f.read(524288)
except:
    sys.exit(0)

# Extract key error words from command for matching
cmd_words = set(re.findall(r'[a-zA-Z_]{4,}', command.lower()))
error_blocks = content.split('### 20')
occurrence_count = 0

for block in error_blocks[1:]:  # skip header
    block_words = set(re.findall(r'[a-zA-Z_]{4,}', block.lower()))
    overlap = len(cmd_words & block_words)
    if overlap >= max(2, len(cmd_words) // 2):
        occurrence_count += 1

# Only create instinct if 2+ similar occurrences
if occurrence_count < 2:
    sys.exit(0)

# Calculate confidence: min(0.9, 0.3 + (occurrences - 1) * 0.2)
confidence = min(0.9, 0.3 + (occurrence_count - 1) * 0.2)

instinct_id = f'error-{sig}'
instinct_file = os.path.join(instincts_dir, f'{instinct_id}.md')

# Update existing or create new instinct
if os.path.isfile(instinct_file):
    try:
        with open(instinct_file, 'r') as f:
            existing = f.read()
        # Update confidence and occurrences
        existing = re.sub(r'confidence:\s*[\d.]+', f'confidence: {confidence}', existing)
        existing = re.sub(r'occurrences:\s*\d+', f'occurrences: {occurrence_count}', existing)
        existing = re.sub(r'last_seen:\s*\"[^\"]+\"', f'last_seen: \"{today}\"', existing)
        with open(instinct_file, 'w') as f:
            f.write(existing)
    except:
        pass
else:
    # Create new instinct file
    trigger = cmd_normalized[:80]
    content_md = f'''---
id: {instinct_id}
trigger: \"{trigger}\"
confidence: {confidence}
domain: \"error-handling\"
source: \"auto-detected\"
occurrences: {occurrence_count}
first_seen: \"{today}\"
last_seen: \"{today}\"
---

# Recurring Error Pattern: {instinct_id}

## Pattern
Similar command errors detected {occurrence_count} times.
Command pattern: \`{trigger}\`

## Prevention
Check command syntax and dependencies before execution.
Review docs/mistakes/auto-detected.md for full error context.

## Source
docs/mistakes/auto-detected.md (auto-extracted by learn-from-errors.sh)
'''
    try:
        with open(instinct_file, 'w') as f:
            f.write(content_md)
    except:
        pass
" 2>/dev/null

exit 0
