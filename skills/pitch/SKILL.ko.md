---
name: pitch
description: >
  타인 전달용 3~5줄 메시지 어댑터. Hook-Core-CTA 구조. audience 필수 질의. 파일 선택 저장.
  Triggers: "꽂아줘", "전달할 메시지", "pitch", "슬랙에 붙일", "DM 보낼", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:pitch — 전달용 메시지

## Prerequisites
- `scripts/preflight.sh` 통과.
- `skills/distill/` 엔진 설치됨.

## Step 1: Alias 감지 + Audience (필수)

**`shrink` / `줄여줘` / `압축` 키워드로 진입 시:** shrink alias 가 deprecated 됐다고 한 번 안내한 후, 아래 라우팅 규칙으로 pitch 가 적합한 어댑터인지 판단합니다.

라우팅 규칙 (순서대로 적용):
- 입력이 **길고 (≥ 80 토큰) AND ratio ≤ 0.1** (또는 사용자가 "한 줄로" / "TL;DR" 요청) → pitch 수행, 계속 진행.
- 입력이 **길고 AND ratio > 0.1** → 사용자에게 안내: "이 분량은 `/doc`이 더 적합합니다. `/doc`으로 재호출해 주세요." 후 종료.
- 입력이 **짧음 (< 80 토큰)** → 사용자에게 안내: "짧은 입력은 `/explain`이 더 적합합니다. `/explain`으로 재호출해 주세요." 후 종료.

**`pitch` 로 직접 진입 시:** 라우팅 건너뛰고 바로 진행.

> "누구에게 보낼 메시지인가요? (예: 팀장, 고객, 슬랙 채널)"
- audience 미지정 시 반드시 질의. 기본값 없음.

## Step 2: 엔진 호출
- `distill --mode reduce --ratio 0.08 --audience {X}` 호출.
- EngineOutput JSON 수신.

## Step 3: 렌더 (Hook-Core-CTA)
`references/prompt.md` 지시로 3~5줄 렌더:
- **Hook (1줄)**: 청자의 현재 상황을 찌르는 질문 또는 반전. 30자 이내. 평서문 금지.
- **Core (1~2줄)**: 단일 claim + 근거 1개. 각 줄 50자 이내. 나열형 금지 (1개 핵심만).
- **CTA (1줄)**: 행동 또는 판단 요청. 명령형 또는 의문형. 30자 이내.
- 전체 3~5줄.

## Step 4: 저장 HITL
> "`docs/galmuri-pitch-{slug}.md` 에 파일 생성할까요? (y/n/edit-slug)"
- 기본값: prompt (자동 생성 없음, 자동 거부 없음).
- `y` → 파일 생성. `n` → 출력만. `edit-slug` → 파일명 변경 후 생성.

## 출력 스키마
3~5줄 plain text (Hook + Core + CTA) + optional 파일.
