#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
if echo "$PROMPT" | grep -qiE '(갈무리|galmuri|tldr|핵심만|추려서)'; then
  printf '{"context":"Consider galmuri skills: distill/shrink/decide."}\n'
fi
