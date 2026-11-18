#!/bin/sh
# Link the CLI onto PATH and the skill into Claude Code. Safe to run again.
set -e
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$HOME/.local/bin" "$HOME/.claude/skills"
ln -sfn "$here/journeymaxx" "$HOME/.local/bin/journeymaxx"
ln -sfn "$here/skill" "$HOME/.claude/skills/journeymaxx"
echo "journeymaxx -> $HOME/.local/bin/journeymaxx"
echo "skill       -> $HOME/.claude/skills/journeymaxx"
