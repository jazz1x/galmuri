#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
case "$FILE" in
  docs/galmuri-*.md) ;;
  *) exit 0 ;;
esac
SLUG=$(basename "$FILE" | sed 's/^galmuri-[a-z][a-z]*-//;s/\.[^.]*$//')
SRC=".galmuri/tmp/source-${SLUG}.txt"
[[ -r "$SRC" ]] || exit 0
scripts/record-asset.sh --type summary --source-ref "$SRC" --output "$FILE"
rm -f "$SRC"
