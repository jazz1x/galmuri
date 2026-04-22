---
name: shrink
description: Compress text to a target token ratio for a specific audience. Requires --audience and --target-ratio (0.1~0.5). Up to 2 retries; asks user on miss.
version: 0.0.1
---

# galmuri:shrink — 분량 압축

## Step 0: Intent Onramp (bare invocation only)
Trigger when user calls `/galmuri:shrink` with **no args** (no file, no `--target-ratio`). Skip entirely if any arg is present.

Ask:
> "얼마나 줄이시겠어요?
>   1) 초안 절반 (0.5) — 초안 다듬기
>   2) 리뷰용 핵심 (0.2) — 5분 읽을 분량
>   3) 한 줄 요지 (0.05) — TL;DR / 슬랙 공유
>   4) 자유 — 직접 비율 입력"

Route:
- `1` / `2` / `3` → set `--target-ratio` accordingly, then ask source + audience (source capture via Step 1-2)
- `4` → ask "목표 비율 (0.05 ~ 0.5)?" → validate → proceed

After Step 0 resolves, continue from Step 1-2.

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
