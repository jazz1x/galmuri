---
name: galmuri:distill
description: 긴 텍스트에서 특정 청자 대상의 본질을 추려낸다. 핵심 주장 + 손실 diff 반환. --audience 필수. .harnish/.honne 자산 존재 시 활용 (미존재 시 자동 skip).
version: 0.0.1
---

# galmuri:distill — 핵심 추리기

## Step 1: 청자 문맥
1. `--audience` 인자 확인. 미제공 시 → `scripts/query-assets.sh --tags audience --limit 3` 실행 → 과거 청자 제안. 여전히 미제공 시 → 사용자 질문. 기본값 없음.
2. `.harnish/persona.json` + `.honne/persona.json` 있으면 읽기 (형식/장황함만, §master.3.4).

## Step 1.5: 형제 반영
- `.harnish/persona.json` 있으면 형식성/장황함 읽기
- 사용자에게: "harnish persona 에 따라 <제안 청자> 로 제안합니다 — [a]ccept / [c]hange / [i]gnore"
- a → 청자 확정, c → Step 1 복귀, i → persona 무시
- 명시된 --audience 있으면 해당 스텝 skip

## Step 2: 원본 캡처
원본을 `.galmuri/tmp/source-{slug}.txt` 에 기록 (PreToolUse 훅용).

## Step 3: 본질 추출
LLM 프롬프트 (`references/prompt.md` 참조): "톤, 예시, 장황함 제거. {청자} 의 결정을 바꾸는 주장만 유지."

## Step 4: 검증
- `scripts/evidence-check.sh --source .galmuri/tmp/source-{slug}.txt --output -` (구조 gate)
- LLM-as-judge 통과 (§master.4.2): 각 주장이 원문의 의미적 근거를 갖는가? 실패 주장 삭제/재생성.

## Step 5: 손실 Diff
- `scripts/diff-loss.sh --before source --after output` → bullet 리스트 (상위 3~5).

## Step 6: HITL 저장
> "Save to `docs/galmuri-{suggested-slug}.md`? (y/n/edit-slug)"
- On `y`: Write → PostToolUse 훅이 자산 기록 → temp source 삭제.

## 출력 스키마
markdown 본문 + optional `--json`: `{essence, dropped[], audience, evidence[]}`
