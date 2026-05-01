---
name: explain
description: >
  나 이해용 inline 어댑터. distill 엔진을 호출하여 긴 텍스트의 본질을 뽑고 inline markdown 으로 렌더.
  audience=me 자동 고정. 출력만 하며 파일 생성 없음.
  Triggers: "설명해", "이해하게", "explain", "정리해서 보여줘", "readme 읽고", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:explain — 나 이해용 정리

## Prerequisites
- `scripts/preflight.sh` 통과 (jq, bats, bash).
- `skills/distill/` 엔진 설치됨.

## Step 1: Alias 감지 + 입력 캡처

`shrink` / `줄여줘` / `압축` 키워드로 진입 시:
```bash
if [ ! -f ".galmuri/tmp/.warned-shrink" ]; then
  echo "[deprecated] 'shrink' 트리거는 문맥 기반 어댑터로 라우팅됩니다. 향후 릴리스에서 제거 예정." >&2
  touch ".galmuri/tmp/.warned-shrink"
fi
# source_tokens < 80 → explain 수행, 그 외 → 재위임 안내
```

- 사용자 입력 (파일 경로 또는 stdin) 을 `.galmuri/tmp/source-{slug}.txt` 에 넣음.
- audience 는 `me` 자동 고정 (별도 질의 없음).

## Step 2: 엔진 호출

**Skill tool** 로 `galmuri:distill` 스킬을 아래 인자로 호출합니다:

```
--mode reduce --ratio 0.2 --audience me --input {Step 1 의 tmp 파일 경로}
```

엔진이 반환하는 EngineOutput JSON 을 Step 3 에 바로 전달합니다.

distill 로직을 여기서 인라인으로 실행하지 않습니다 — 항상 스킬에 위임합니다.

## Step 3: 렌더
- EngineOutput.units → inline markdown:
  - 첫 unit 의 `claim` 을 상단 요약으로.
  - 각 unit 의 `essence` 를 bullet 로 나열.

## Step 4: 출력
- stdout 에 markdown 출력. **파일 생성 단계 없음** (설계 의도).
- 세션 종료 시 `.galmuri/tmp/source-{slug}.txt` 자동 정리 (훅).

## 출력 스키마
markdown body only. JSON 출력 없음.
