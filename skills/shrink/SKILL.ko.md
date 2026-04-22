---
name: shrink
description: 특정 청자 대상으로 텍스트를 목표 token 비율로 압축. --audience / --target-ratio 미제공 시 자연어로 물어본다 (유효 비율 0.05~0.5). 최대 2회 재시도; 실패 시 사용자 질문.
version: 0.0.1
---

# galmuri:shrink — 분량 압축

## Step 1-2: 청자 + 원본 캡처
distill 과 동일.

## Step 1.5: 형제 반영
distill SKILL.ko.md 참조.

## Step 3: 목표 크기 결정
`--target-ratio` 미제공 시 사용자 언어로 질문:
> "얼마나 줄일까요? 예: '절반' / '핵심만 (5분 분량)' / '한 줄 TL;DR' / 혹은 비율 (0.05 ~ 0.5)"
답변을 비율로 매핑 (절반→0.5, 핵심→0.2, 한줄→0.05). 묵시적 기본값 없음.

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
