#!/usr/bin/env bash
# PreToolUse hook: capture source text before a galmuri skill runs.
# Reads Claude Code hook JSON from stdin; extracts the user prompt and saves it
# to .galmuri/tmp/source-{slug}.txt so downstream evidence-check and
# record-asset scripts can reference the original input.
set -euo pipefail

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // .tool_input.prompt // .tool_input.content // empty')
[[ -n "$PROMPT" ]] || exit 0

mkdir -p .galmuri/tmp
SLUG=$(printf '%s' "$PROMPT" | head -c 40 | tr -cs '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]' | sed 's/^-//;s/-$//')
[[ -n "$SLUG" ]] || SLUG="capture-$(date +%s)"

DEST=".galmuri/tmp/source-${SLUG}.txt"
printf '%s' "$PROMPT" > "$DEST"
