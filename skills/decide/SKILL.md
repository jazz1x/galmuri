---
name: decide
description: Turns ambiguous 2-option decisions into a 6-slide Jobs-style template (JSON + markdown, no binary build) + Socratic validation. Strict D/E/V/R decomposition; use --weak-decomposition for small teams.
version: 0.0.1
---

# galmuri:decide — 의사결정 덱

## Step 0: Intent Onramp (bare invocation only)
Trigger when user calls `/galmuri:decide` with **no args**. Skip entirely if `--weak-decomposition` or a problem statement is already provided.

Ask:
> "어떤 결정인가요?
>   1) 기술 선택 — A vs B 라이브러리/아키텍처
>   2) 제품 방향 — 기능 X 를 할까 말까
>   3) 팀/프로세스 — 운영 방식 변경 여부
>   4) 자유 — 직접 설명"

Route: 1/2/3 은 Step 1 (Phenomenon) 의 기본 프레임을 해당 도메인으로 고정한 뒤 질문. 4 는 바로 Step 1.

작은 팀/조직이면 여기서 `--weak-decomposition` 자동 제안 → `[a]ccept / [i]gnore`.

After Step 0 resolves, continue from Step 1.

## Prerequisites
- 없음. 외부 스킬/바이너리 의존 없음 (template-only output).

## Step 1: Phenomenon (현상)
- 한 줄 문제 진술 고정.
- `.honne/recent-reflection.md` 있으면 관련성 체크 → 한 줄 힌트 주입.

## Step 1.5: Sibling Reflection
- distill/shrink 참조.

## Step 2: Decomposition (분해 — D/E/V/R)
- 4역할 각각 질문 → 유저 답변. 빈 칸 있으면 되묻기.
- `--weak-decomposition` 시 동일 주체의 관점 분리 허용.

## Step 3: Essence (본질)
- "누가 X하는가" 한 줄. 안 되면 Step 2 복귀.

## Step 4: Generalization (일반화)
- 다른 도메인 3개로 동일 분해 재현 검증. 동일 도메인 변형 → 재시도.

## Step 5: Reconstruction (재구성)
- Trade-off + 단일 결론. "상황에 따라" 금지.

## Step 6: Emit Template (no binary build)
- `prompt.md` 의 7 절대 규칙 + JSON 스키마(디자인 인텐트 포함) 를 LLM 에 주입.
- 슬라이드 카피 JSON 생성 → JSON 스키마 검증(options=2, rows=3, slides=6) 통과.
- **출력 포맷**: 템플릿 2 파일만.
  - `docs/galmuri-decide-{slug}.json` — spec JSON
  - `docs/galmuri-decide-{slug}.md` — presentation script + 발표자 노트

## Step 7: Socratic Probe (judge)
- `scripts/socratic_probe.md` 의 18문항 템플릿으로 생성 (슬라이드 × Definition/Difference/Attribution).
- LLM judge 2축 분류: (answerable=Y, explicit=Y) 만 통과.
- 실패 매핑: Definition 실패 → ② Decomposition, Difference 실패 → ③ Essence, Attribution 실패 → ⑤ Reconstruction 복귀.

## Step 8: Record + Save
- HITL confirm 후 2 파일 저장: `docs/galmuri-decide-{slug}.json` + `docs/galmuri-decide-{slug}.md`.
- `scripts/record-asset.sh --type decision-deck --source-ref .galmuri/tmp/source-{slug}.txt --output docs/galmuri-decide-{slug}.json` 자체 호출.
