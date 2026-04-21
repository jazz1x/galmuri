#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
case "$FILE" in
  docs/galmuri-*.md) ;;
  *) exit 0 ;;
esac
SLUG=$(basename "$FILE" .md | sed 's/^galmuri-//')
SRC=".galmuri/tmp/source-${SLUG}.txt"
[[ -r "$SRC" ]] || exit 0
printf '%s' "$CONTENT" | scripts/evidence-check.sh --source "$SRC" --output -
