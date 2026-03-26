#!/bin/bash
# session-summary.sh — Stop hook that auto-saves work summary on session end
# Stop hook: executes each time Claude Code finishes a response.
# Receives JSON (transcript_path, session_id, etc.) from stdin and saves session summary.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SESSIONS_DIR="$PROJECT_ROOT/docs/sessions"

# Create sessions directory
mkdir -p "$SESSIONS_DIR"

# Read JSON from stdin
INPUT=$(cat)

# Extract transcript_path
TRANSCRIPT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('transcript_path', ''))
except:
    print('')
" 2>/dev/null)

# Exit if transcript_path is empty
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

DATE=$(date +%Y-%m-%d)
SUMMARY_FILE="$SESSIONS_DIR/${DATE}-summary.md"

# Skip if today's summary already exceeds size limit (1MB)
if [ -f "$SUMMARY_FILE" ] && [ "$(wc -c < "$SUMMARY_FILE")" -gt 1048576 ]; then
  exit 0
fi

# Extract summary from transcript
SUMMARY=$(python3 -c "
import json, sys, os
from datetime import datetime

transcript_path = '$TRANSCRIPT'
if not os.path.exists(transcript_path):
    sys.exit(0)

files_modified = set()
tools_used = {}
errors = []

with open(transcript_path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue

        # Track tool usage
        tool = entry.get('tool_name', '')
        if tool:
            tools_used[tool] = tools_used.get(tool, 0) + 1

        # Track file modifications
        tool_input = entry.get('tool_input', {})
        if isinstance(tool_input, dict):
            fp = tool_input.get('file_path', '')
            if fp and tool in ('Edit', 'Write', 'MultiEdit'):
                # Convert to relative path from project root
                project_root = '$PROJECT_ROOT'
                if fp.startswith(project_root):
                    fp = fp[len(project_root)+1:]
                files_modified.add(fp)

        # Track errors
        tool_output = entry.get('tool_output', '')
        if isinstance(tool_output, str) and 'error' in tool_output.lower()[:100]:
            errors.append(tool_output[:200])

if not files_modified and not tools_used:
    sys.exit(0)

now = datetime.now().strftime('%H:%M')
print(f'### {now}')
print()
if files_modified:
    print('**Modified files:**')
    for f in sorted(files_modified):
        print(f'- \`{f}\`')
    print()
if tools_used:
    top_tools = sorted(tools_used.items(), key=lambda x: -x[1])[:5]
    tools_str = ', '.join(f'{t}({c})' for t, c in top_tools)
    total_calls = sum(tools_used.values())
    est_tokens = total_calls * 800  # rough estimate: ~800 tokens per tool call avg
    print(f'**Tools:** {tools_str}')
    print(f'**Estimated tokens:** ~{est_tokens:,} ({total_calls} tool calls)')
    print()
if errors:
    print(f'**Errors encountered:** {len(errors)}')
    print()
print('---')
print()
" 2>/dev/null)

# Exit if summary is empty
if [ -z "$SUMMARY" ]; then
  exit 0
fi

# File header (only for new files)
if [ ! -f "$SUMMARY_FILE" ]; then
  echo "# Session Summary — $DATE" > "$SUMMARY_FILE"
  echo "" >> "$SUMMARY_FILE"
fi

# Append summary
echo "$SUMMARY" >> "$SUMMARY_FILE"

exit 0
