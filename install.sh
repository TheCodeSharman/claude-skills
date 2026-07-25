#!/usr/bin/env bash
#
# Install these skills into ~/.claude/skills/ by symlinking each skill folder.
# Idempotent: safe to re-run. `git pull` then updates the live skills instantly,
# since ~/.claude/skills/<name> points straight at this repo.
#
# Usage: ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"
DEST_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$DEST_DIR"

for skill_path in "$SRC_DIR"/*/; do
  [ -d "$skill_path" ] || continue
  name="$(basename "$skill_path")"
  target="$skill_path"
  link="$DEST_DIR/$name"

  # If a real (non-symlink) directory already lives there, back it up rather than clobber.
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    backup="$link.local.$(date +%Y%m%d%H%M%S)"
    echo "! $name exists as a real directory — moving it to $(basename "$backup")"
    mv "$link" "$backup"
  fi

  ln -sfn "$target" "$link"
  echo "linked  $name -> $target"
done

echo "Done. Skills installed to $DEST_DIR"
