---
name: doc
description: >
  문서형 정리 어댑터. distill 엔진을 호출하여 markdown 정리 후 파일로 남김. 기존 distill 저장 플로우 계승.
  Triggers: "문서로", "정리해서 저장", "doc", "기록으로", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:doc — 문서형 정리

## Prerequisites
- `scripts/preflight.sh` 통과.
- `skills/distill/` 엔진 설치됨.
- `scripts/record-asset.sh` 실행 가능.

## Step 1: Alias 감지 + Audience

`shrink` / `줄여줘` / `압축` 키워드로 진입 시:
```bash
if [ ! -f ".galmuri/tmp/.warned-shrink" ]; then
  echo "[deprecated] 'shrink' 트리거는 문맥 기반 어댑터로 라우팅됩니다. CHANGELOG 0.2.0 에서 제거 예정." >&2
  touch ".galmuri/tmp/.warned-shrink"
fi
# source_tokens ≥ 80 AND ratio > 0.1 → doc 수행, 그 외 → 재위임 안내
```

> "누구를 위한 문서인가요? (예: 팀 전체, 나중의 나, 외부 리뷰어)"
- audience 미지정 시 질의.

## Step 2: Engine Invoke
- `distill --mode reduce --ratio 0.3 --audience {X}` 호출.
- EngineOutput JSON 수신.

## Step 3: Render
- EngineOutput.units → markdown 본문:
  - 섹션 제목 = 첫 unit 의 `claim`.
  - 각 unit 의 `essence` + `evidence` 를 본문으로.
  - `dropped[]` 는 "## 생략 항목" 섹션으로 추가.

## Step 4: 저장
기본 경로: `docs/galmuri-doc-{slug}.md`
> "파일로 남길까요? `docs/galmuri-doc-{slug}.md` (y/n/edit-slug)"
- `y` → 파일 생성 후 Step 5.
- `n` → stdout 출력만.
- `edit-slug` → 파일명 입력 후 생성.

## Step 5: Asset 기록
파일 생성 후 PostToolUse 훅 또는 직접 호출:
```bash
bash scripts/record-asset.sh --type doc --tags "doc,{slug}" \
  --title "{slug}" --content "{file-path}" --base-dir "$(pwd)/.harnish"
```

## Output Schema
markdown 파일 (`docs/galmuri-doc-{slug}.md`) + asset 기록.
