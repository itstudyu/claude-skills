#!/bin/bash
# load-instincts.sh — SessionStart hook that loads high-confidence instincts into context
# Inspired by Everything Claude Code's instincts system with confidence-based filtering.
# Only loads patterns with confidence >= 0.8 to minimize token usage.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTINCTS_DIR="$PROJECT_ROOT/instincts"

# Skip if no instincts directory
if [ ! -d "$INSTINCTS_DIR" ]; then
  exit 0
fi

# Extract high-confidence instincts (confidence >= 0.8)
OUTPUT=$(python3 -c "
import os, sys, re

instincts_dir = '$INSTINCTS_DIR'
max_chars = 2000
results = []

for subdir in ['errors', 'code-patterns', 'review-patterns']:
    dirpath = os.path.join(instincts_dir, subdir)
    if not os.path.isdir(dirpath):
        continue
    for fname in sorted(os.listdir(dirpath)):
        if not fname.endswith('.md') or fname.startswith('.'):
            continue
        filepath = os.path.join(dirpath, fname)
        try:
            with open(filepath, 'r') as f:
                content = f.read()
        except:
            continue

        # Parse YAML frontmatter for confidence
        fm_match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
        if not fm_match:
            continue

        frontmatter = fm_match.group(1)
        conf_match = re.search(r'confidence:\s*([\d.]+)', frontmatter)
        if not conf_match:
            continue

        confidence = float(conf_match.group(1))
        if confidence < 0.8:
            continue

        # Extract id and trigger
        id_match = re.search(r'id:\s*(.+)', frontmatter)
        trigger_match = re.search(r'trigger:\s*\"?(.+?)\"?\s*$', frontmatter, re.MULTILINE)

        instinct_id = id_match.group(1).strip() if id_match else fname[:-3]
        trigger = trigger_match.group(1).strip() if trigger_match else ''

        # Extract action section (first ## after frontmatter)
        sections = content.split('##')
        action = ''
        for section in sections[1:]:
            if '예방' in section or 'Prevention' in section or 'Action' in section or '패턴' in section:
                action = section.split('\n', 1)[1].strip()[:200] if '\n' in section else ''
                break

        if trigger or action:
            results.append(f'- [{instinct_id}] {trigger}: {action[:150]}')

if not results:
    sys.exit(0)

output = '=== [INSTINCTS — Learned Patterns (auto-loaded)] ===\n'
output += '\n'.join(results[:10])  # Max 10 instincts
output += '\n=== [END INSTINCTS] ==='

# Enforce character limit
if len(output) > max_chars:
    output = output[:max_chars-20] + '\n... (truncated)'

print(output)
" 2>/dev/null)

# Output to stdout (injected into Claude context)
if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
fi

exit 0
