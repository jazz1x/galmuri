---
name: shrink
description: Compress text to a target token ratio for a specific audience. Requires --audience and --target-ratio (0.1~0.5). Up to 2 retries; asks user on miss.
version: 0.0.1
---

# galmuri:shrink — 분량 압축

## Step 1-2: Audience + Source Capture
distill 과 동일.

## Step 1.5: Sibling Reflection
distill SKILL.md 참조.

## Step 3: Target Sizing
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
