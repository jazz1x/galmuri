---
name: decide
description: 모호한 2선택 의사결정을 6슬라이드 Jobs-style 템플릿(JSON + markdown, 바이너리 빌드 없음) + 소크라테스 검증으로 변환. 엄격한 D/E/V/R 분해; 소규모 팀은 --weak-decomposition 사용.
version: 0.0.1
---

# galmuri:decide — 의사결정 덱

## 선행조건
- 없음. 외부 스킬/바이너리 의존 없음 (template-only output).

## Step 1: 현상 (Phenomenon)
- 한 줄 문제 진술 고정.
- `.honne/recent-reflection.md` 있으면 관련성 체크 → 한 줄 힌트 주입.

## Step 1.5: 형제 반영
- distill/shrink SKILL.ko.md 참조.

## Step 2: 분해 (Decomposition — D/E/V/R)
- 4역할 각각 질문 → 사용자 답변. 빈 칸 있으면 되묻기.
- `--weak-decomposition` 시 동일 주체의 관점 분리 허용.

## Step 3: 본질 (Essence)
- "누가 X하는가" 한 줄. 안 되면 Step 2 복귀.

## Step 4: 일반화 (Generalization)
- 다른 도메인 3개로 동일 분해 재현 검증. 동일 도메인 변형 → 재시도.

## Step 5: 재구성 (Reconstruction)
- Trade-off + 단일 결론. "상황에 따라" 금지.

## Step 6: 템플릿 생성 (no binary build)
- `prompt.md` 의 7 절대 규칙 + JSON 스키마(디자인 인텐트 포함) 를 LLM 에 주입.
- 슬라이드 카피 JSON 생성 → JSON 스키마 검증(options=2, rows=3, slides=6) 통과.
- **출력 포맷**: 템플릿 2 파일만.
  - `docs/galmuri-decide-{slug}.json` — spec JSON
  - `docs/galmuri-decide-{slug}.md` — 발표 스크립트 + 발표자 노트

## Step 7: 소크라테스 검증 (Socratic Probe judge)
- `scripts/socratic_probe.md` 의 18문항 템플릿으로 생성 (슬라이드 × Definition/Difference/Attribution).
- LLM judge 2축 분류: (answerable=Y, explicit=Y) 만 통과.
- 실패 매핑: Definition 실패 → ② Decomposition, Difference 실패 → ③ Essence, Attribution 실패 → ⑤ Reconstruction 복귀.

## Step 8: 기록 + 저장
- HITL confirm 후 2 파일 저장: `docs/galmuri-decide-{slug}.json` + `docs/galmuri-decide-{slug}.md`.
- `scripts/record-asset.sh --type decision-deck --source-ref .galmuri/tmp/source-{slug}.txt --output docs/galmuri-decide-{slug}.json` 자체 호출.
