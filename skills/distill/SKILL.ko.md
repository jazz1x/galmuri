---
name: distill
description: >
  코어 엔진. 본질환원 + 제1원칙 분해 + 소크라테스 검증. 어댑터가 호출하거나 직접 호출 가능. 저장 없음 (어댑터 책임).
  Triggers: "distill", "핵심만", "본질", "distill engine"
version: 0.0.1
---

# galmuri:distill — 코어 엔진

## Prerequisites
- `scripts/preflight.sh` 통과 (jq, bats, bash 설치 필수).
- `scripts/parse-ratio.sh`, `scripts/validate-essence.sh` 실행 가능.

## 플래그

| 플래그 | 필수 | 설명 |
|--------|------|------|
| `--mode reduce\|construct` | 직접 호출 시 필수 | reduce = 본질 축소, construct = 구조 확장 |
| `--ratio 0.05–0.5` | 선택 (reduce 모드) | 자연어 가능 — `parse-ratio.sh` 로 파싱 |
| `--audience {대상}` | 선택 | 미지정 시 어댑터가 HITL 처리 |
| `--weak-decomposition` | 선택 | Weak D/E/V/R 분해 허용 |
| `--input {경로}` | 선택 | stdin 대신 파일 경로 지정 |

## Step 1: 입력 캡처 [bash]

```bash
mkdir -p .galmuri/tmp
SLUG=$(echo "$INPUT" | head -c 40 | tr -cs '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]')
cat > ".galmuri/tmp/source-${SLUG}.txt"
# retry 카운터 초기화 (이전 세션 잔존 파일 정리)
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

- 소스 텍스트를 `.galmuri/tmp/source-{slug}.txt` 에 기록.
- `--mode` 미지정 시 Step 2 로 진행. 지정 시 Step 2 skip → Step 3.

## Step 2: 모드 선택 [bash + HITL]

```bash
TOKEN_JSON=$(bash scripts/count-tokens.sh ".galmuri/tmp/source-${SLUG}.txt")
TOKEN_COUNT=$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['tokens'])")
if [ "$TOKEN_COUNT" -lt 80 ]; then
  echo "[distill] 짧은 입력 (${TOKEN_COUNT} tokens) → construct 모드 권장"
else
  echo "[distill] 긴 입력 (${TOKEN_COUNT} tokens) → reduce 모드 권장"
fi
```

- `--mode` 명시 시 이 Step skip.
- 미지정 시 토큰 수 기준으로 모드 제안 → HITL confirm.

## Step 3: 3 Methods 적용 [LLM]

`references/prompt.md` + `references/decomposition.md` + `references/socratic_probe.md` 지시를 순서대로 적용:

1. **Method 1 본질환원**: 각 claim → 주어-동사 한 줄 essence.
2. **Method 2 제1원칙 분해**: D/E/V/R 4 질문 적용 (`--weak-decomposition` 시 Weak 모드).
3. **Method 3 소크라테스 검증**: 3축 probe → 실패 unit 은 `dropped[]` 에 기록.

**Retry 명세 (결정론)**:
- Step A: essence_units 후보 생성.
- Step B: `bash scripts/validate-essence.sh` 로 스키마 검증.
- Step C: reduce 모드 시 `|actual_ratio - target_ratio| > 0.05` 이면 재적용 (최대 2회).

retry 카운터 관리 (bash):

```bash
COUNT_FILE=".galmuri/tmp/retry-count.${SLUG}"
CURRENT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
echo $((CURRENT + 1)) > "$COUNT_FILE"
```

2 초과 시 Step 5 의 HITL 분기로 이동.

## Step 4: Ratio 검증 [bash] (reduce 모드만)

```bash
bash scripts/validate-essence.sh < output.json
bash scripts/count-tokens.sh output.json
```

- Step 3 LLM 루프 만료 후 최종 판정.
- ratio 편차 > 0.05 지속 시 retry-count 확인 → 2 미만이면 Step 3 재진입, 2 이상이면 Step 5 HITL.

## Step 5: 출력 [bash]

```bash
bash scripts/validate-essence.sh < final-output.json || {
  echo "[distill] 검증 실패"
  # HITL: [a]ccept / [r]e-target / [c]ancel
  exit 1
}
cat final-output.json
# 카운터 정리
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

- `validate-essence.sh` 최종 통과 강제 → EngineOutput JSON 출력.
- 실패 시 exit 1 + HITL (`[a]ccept / [r]e-target / [c]ancel`).
- 정상/HITL 어느 경로든 종료 직전 retry 카운터 파일 정리.

## 출력 스키마
EngineOutput JSON (`essence-schema.json` 준수):
```json
{
  "units": [...],
  "mode": "reduce|construct",
  "ratio": 0.2,
  "dropped": [...],
  "source_ref": ".galmuri/tmp/source-{slug}.txt"
}
```
저장 없음. 어댑터가 EngineOutput 을 받아 저장 여부를 결정한다.
