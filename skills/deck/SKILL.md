---
name: deck
description: >
  덱 생성 어댑터. preset 선택 필수. SlideSpec JSON + 발표 스크립트 markdown 2파일 출력. 바이너리 빌드 없음.
  Triggers: "덱", "슬라이드", "deck", "발표 자료", "decide", "의사결정", "A vs B", "결정해", "뭐가 나아"
version: 0.0.1
---

# galmuri:deck — 덱 생성 어댑터

## Prerequisites
- `scripts/preflight.sh` 통과.
- `skills/distill/` 엔진 설치됨.

## Step 1: Alias 감지 + Preset 선택 (필수)

`decide` / `의사결정` / `A vs B` / `결정해` / `뭐가 나아` 키워드로 진입 시:
```bash
# deprecation 경고 (세션당 1회)
if [ ! -f ".galmuri/tmp/.warned-decide" ]; then
  echo "[deprecated] 'decide' 트리거는 deck --preset decision-sandwich-6 으로 라우팅됩니다. 향후 릴리스에서 제거 예정." >&2
  touch ".galmuri/tmp/.warned-decide"
fi
```
alias 감지 시 `--preset decision-sandwich-6` 자동 주입.

`--preset` 플래그 누락 시 HITL:
> "어떤 preset 을 사용할까요? 예: `decision-sandwich-6`, `pitch-deck`, `concept-explain`, `story-arc`
>  1. decision-sandwich-6 (결정 덱, 6 슬라이드)
>  2. pitch-deck (발표용, 3 슬라이드)
>  3. concept-explain (개념 설명, 4~5 슬라이드)
>  4. story-arc (가변 길이)"

선택된 preset 파일: `references/preset-{name}.md`

## Step 2: Engine Invoke
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

## Output Schema
- `docs/galmuri-deck-{slug}.json`: SlideSpec[] 배열.
- `docs/galmuri-deck-{slug}.md`: 슬라이드별 스크립트 + 시각 지시.
