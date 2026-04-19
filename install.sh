#!/usr/bin/env bash
# claude-skills installer — symlink project-specific skills + register hooks
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ─── Uninstall mode ──────────────────────────────────────────
if [ "$1" = "--uninstall" ]; then
  echo "Uninstalling claude-skills..."
  find "$SKILLS_DIR" -maxdepth 1 -type l | while read link; do
    target="$(readlink "$link")"
    if echo "$target" | grep -q "claude-skills"; then
      rm "$link"
      echo "  Removed: $(basename "$link")"
    fi
  done
  echo -e "${GREEN}Uninstalled.${NC}"
  exit 0
fi

# ─── Create directories ──────────────────────────────────────
mkdir -p "$SKILLS_DIR"
mkdir -p "$CLAUDE_DIR/hooks"

echo "Installing claude-skills from $SCRIPT_DIR"
echo ""

# ─── Symlink skills (category/skill-name/SKILL.md) ───────────
CATEGORIES="workflow review utility"
COUNT=0

for category in $CATEGORIES; do
  cat_dir="$SCRIPT_DIR/$category"
  [ ! -d "$cat_dir" ] && continue

  for skill_dir in "$cat_dir"/*/; do
    [ ! -f "$skill_dir/SKILL.md" ] && continue
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DIR/$skill_name"

    # Remove existing symlink or directory
    [ -L "$target" ] && rm "$target"
    [ -d "$target" ] && rm -rf "$target"

    ln -s "$skill_dir" "$target"
    COUNT=$((COUNT + 1))
  done
done

echo -e "${GREEN}Linked $COUNT skills to $SKILLS_DIR${NC}"

# ─── Copy hooks ──────────────────────────────────────────────
if [ -d "$SCRIPT_DIR/.claude/hooks" ]; then
  cp "$SCRIPT_DIR/.claude/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null
  chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null
  echo -e "${GREEN}Hooks installed to $CLAUDE_DIR/hooks/${NC}"
fi

# ─── Symlink standards ────────────────────────────────────────
if [ -d "$SCRIPT_DIR/standards" ]; then
  target="$CLAUDE_DIR/standards"
  [ -L "$target" ] && rm "$target"
  ln -s "$SCRIPT_DIR/standards" "$target"
  echo -e "${GREEN}Standards linked to $CLAUDE_DIR/standards${NC}"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo "  Skills: $COUNT"
echo "  Hooks: $(ls "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ')"
