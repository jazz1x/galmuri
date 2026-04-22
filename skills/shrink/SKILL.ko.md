---
name: shrink
description: 특정 청자 대상으로 텍스트를 목표 token 비율로 압축. --audience 와 --target-ratio (0.1~0.5) 필수. 최대 2회 재시도; 실패 시 사용자 질문.
version: 0.0.1
---

# galmuri:shrink — 분량 압축

## Step 0: 진입 가이드 (bare invocation 에만 동작)
`/galmuri:shrink` 을 **아무 인자 없이** 호출한 경우에만 실행. 인자가 하나라도 있으면 건너뜀.

질문:
> "얼마나 줄이시겠어요?
>   1) 초안 절반 (0.5) — 초안 다듬기
>   2) 리뷰용 핵심 (0.2) — 5분 읽을 분량
>   3) 한 줄 요지 (0.05) — TL;DR / 슬랙 공유
>   4) 자유 — 직접 비율 입력"

라우팅:
- `1` / `2` / `3` → 해당 `--target-ratio` 설정 후 source + audience 질문 (원본 캡처는 Step 1-2 에서)
- `4` → "목표 비율 (0.05 ~ 0.5)?" → 검증 → 진행

Step 0 해결 후 Step 1-2 로 이어감.

## Step 1-2: 청자 + 원본 캡처
distill 과 동일.

## Step 1.5: 형제 반영
distill SKILL.ko.md 참조.

## Step 3: 목표 크기 결정
- `scripts/count-tokens.sh source` → source_tokens
- target_tokens = round(source_tokens * ratio)

## Step 4: 압축 루프 (최대 2회 재시도)
1. LLM 을 사용해 target_tokens 로 압축.
2. `count-tokens.sh output` → actual_ratio.
3. |actual - target| > 0.05 → 재시도 (최대 2회).
4. 여전히 벗어남 → HITL: `[a]ccept / [r]e-target / [c]ancel`.

## Step 5-6: 검증 + HITL 저장
distill 의 §4-6 과 동일.

## 출력 스키마
markdown 본문 + optional `--json`: `{compressed, token_ratio, audience}`
