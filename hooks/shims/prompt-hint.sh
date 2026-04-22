#!/usr/bin/env bash
# Keyword-based skill routing hint (UserPromptSubmit hook).
# When the user's prompt matches a skill's trigger phrases, inject a
# hint suggesting the specific skill rather than the whole trio.
# Generic keywords (galmuri, 갈무리) fall back to the full trio.
set -euo pipefail
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

emit() { printf '{"context":"%s"}\n' "$1"; }

# Skill-specific routing (check before generic)
if echo "$PROMPT" | grep -qiE '(핵심만|추려|요약해|PR 본문|tldr|tl;dr|distill|summarize|essence)'; then
  emit "Consider galmuri:distill — extract the essence for a specific audience with loss diff."
  exit 0
fi
if echo "$PROMPT" | grep -qiE '(압축|줄여|분량|절반으로|shrink|compress|shorten|condense)'; then
  emit "Consider galmuri:shrink — compress to a target ratio (절반 / 핵심 / 한 줄) with loss diff."
  exit 0
fi
if echo "$PROMPT" | grep -qiE '(결정|의사결정|A vs B|고를까|선택할까|decide|choose between)'; then
  emit "Consider galmuri:decide — turn a 2-option decision into a 6-slide deck template."
  exit 0
fi

# Generic fallback
if echo "$PROMPT" | grep -qiE '(갈무리|galmuri|deck)'; then
  emit "Consider galmuri skills: distill / shrink / decide."
fi
