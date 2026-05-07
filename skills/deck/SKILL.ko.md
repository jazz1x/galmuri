---
name: deck
description: >
  덱 생성 어댑터. preset 선택 필수. SlideSpec JSON + 발표 스크립트 markdown 2파일 출력. 바이너리 빌드 없음.
  Triggers: "덱", "슬라이드", "deck", "발표 자료", "A vs B", "뭐가 나아"
version: 0.0.3
ssl:
  scheduling:
    anti_triggers:
      - "슬라이드 의도 없는 단일 binary 결정 — harnish:forki 사용"
      - "슬라이드 없는 문서형 출력 — doc 사용"
  structural:
    scenes: [Preset selection, Engine Invoke, SlideSpec generation, Save]
    resumable: false
  logical:
    tools: [Skill, Write]
    side_effects:
      reads: ["skills/deck/references/preset-{name}.md", "skills/deck/references/design-tokens.md"]
      writes: ["docs/galmuri-deck-{slug}.json", "docs/galmuri-deck-{slug}.md"]
      deletes: []
      network: []
    idempotent: false
    rollback: "Save HITL 에서 사용자가 'n' 선택 → 파일 미생성"
---

# galmuri:deck — 덱 생성 어댑터

## Prerequisites
- `scripts/preflight.sh` 통과.
- `skills/distill/` 엔진 설치됨.

## Step 1: 프리셋 선택 (필수)

`--preset` 플래그 누락 시 HITL:
> "어떤 preset 을 사용할까요?
>  1. decision-sandwich-6 (결정 덱, 6 슬라이드)
>  2. pitch-deck (발표용, 3 슬라이드)
>  3. concept-explain (개념 설명, 4~5 슬라이드)
>  4. story-arc (가변 길이)"

선택된 preset 파일: `references/preset-{name}.md`

## Step 2: 엔진 호출
preset 에 따라 mode/ratio 결정 (preset 파일의 frontmatter 참조):
- `distill --mode {preset.mode} --ratio {preset.ratio} --audience {X}` 호출.
- EngineOutput JSON 수신.

## Step 3: SlideSpec 생성
EngineOutput.units + preset 매핑 → SlideSpec[] 생성:
- preset 파일의 슬라이드 구조 지시에 따라 각 unit 을 슬라이드에 배치.
- `references/design-tokens.md` 의 색상/폰트 토큰 적용.

## Step 4: 저장 (2파일)
1. `docs/galmuri-deck-{slug}.json` — SlideSpec JSON (기계 처리용).
2. `docs/galmuri-deck-{slug}.md` — 발표 스크립트 + 시각 지시 (사람용).

> "두 파일을 생성할까요? `docs/galmuri-deck-{slug}.{json,md}` (y/n/edit-slug)"

**바이너리 빌드 단계 없음.** 이진 파일(슬라이드 프로그램 네이티브 포맷) 생성 로직 도입 금지.

## 출력 스키마
- `docs/galmuri-deck-{slug}.json`: SlideSpec[] 배열.
- `docs/galmuri-deck-{slug}.md`: 슬라이드별 스크립트 + 시각 지시.
