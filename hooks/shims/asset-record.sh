#!/usr/bin/env bash
# PostToolUse hook: record a galmuri output file as an asset.
# Reads Claude Code hook JSON from stdin; extracts the written file path and
# looks up the corresponding source in .galmuri/tmp/ to pass to record-asset.sh.
set -euo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

case "$FILE" in
  docs/galmuri-*.md | docs/galmuri-*.json) ;;
  *) exit 0 ;;
esac

SLUG=$(basename "$FILE" | sed 's/^galmuri-[a-z][a-z]*-//;s/\.[^.]*$//')
SRC=".galmuri/tmp/source-${SLUG}.txt"
[[ -r "$SRC" ]] || exit 0

TYPE=$(basename "$FILE" | sed 's/^galmuri-//;s/-.*//')
TAGS="${TYPE},${SLUG}"

bash scripts/record-asset.sh \
  --type "$TYPE" \
  --tags "$TAGS" \
  --source-ref "$SRC" \
  --output "$FILE"

rm -f "$SRC"
