---
name: shrink
description: >
  Compress text to a target token ratio for a specific audience. Asks for audience and ratio in
  natural language when --audience/--target-ratio are not given (valid ratio 0.05~0.5). Up to 2
  retries; asks user on miss.
  Triggers: "shrink", "압축", "줄여", "분량", "절반으로", "compress", "shorten", "condense".
version: 0.0.1
---

# galmuri:shrink — 분량 압축

## Step 1-2: Audience + Source Capture
distill 과 동일.

## Step 1.5: Sibling Reflection
distill SKILL.md 참조.

## Step 3: Target Sizing
If `--target-ratio` absent, ask in user's language:
> "얼마나 줄일까요? 예: '절반' / '핵심만 (5분 분량)' / '한 줄 TL;DR' / 혹은 비율 (0.05 ~ 0.5)"
Map reply to a ratio (절반→0.5, 핵심→0.2, 한줄→0.05). No silent default.

- `scripts/count-tokens.sh source` → source_tokens
- target_tokens = round(source_tokens * ratio)

## Step 4: Compress Loop (max 2 retries)
1. LLM compress to target_tokens.
2. `count-tokens.sh output` → actual_ratio.
3. |actual - target| > 0.05 → retry (up to 2x).
4. Still off → HITL: `[a]ccept / [r]e-target / [c]ancel`.

## Step 5-6: Verify + HITL Save
distill §4-6 과 동일.

## Output Schema
markdown body + optional `--json`: `{compressed, token_ratio, audience}`
