---
name: audit
description: >
  SKILL.md SSL (Scheduling-Structural-Logical) 감사기. 대상 SKILL.md (또는 스킬 디렉터리) 를 3계층 프레임으로 분해하고, 누락 / 모호 / 위험한 선언을 드러내 진단 리포트로 출력한다. 읽기 전용 — 원본은 절대 수정하지 않는다. PR 직전 셀프 리뷰, 리팩터 회귀 점검, 리포지토리 일괄 감사에 사용한다.
  Triggers: "skill audit", "ssl audit", "audit skill", "ssl 분해", "skill auditor", "audit-skill"
version: 0.0.3
ssl:
  scheduling:
    anti_triggers:
      - "일반적인 테스트/커버리지 점검 — harnish:ralphi 사용"
      - "결정 강제 — harnish:forki 사용"
      - "자유 형식 텍스트 요약 — distill / explain / doc 사용"
      - "SKILL.md 내용 자동 수정 — 이 스킬은 읽기 전용"
  structural:
    scenes: [Ingest, Decompose, Audit, Score, Report]
    resumable: false
    branches:
      - "단일 파일 경로 → single-mode (스코어카드 1개)"
      - "디렉터리 경로 → batch-mode (파일별 스코어카드 + 충돌 매트릭스)"
      - "Logical 점수 < 60 → 진단과 함께 frontmatter 패치 제안"
  logical:
    tools: [Read, Bash]
    side_effects:
      reads: ["{target_path}"]
      writes: ["{report_path} — default .galmuri/audit-{slug}.md, or stdout under --stdout"]
      deletes: []
      network: []
    idempotent: true
    rollback: null
---

# galmuri:audit — SKILL.md SSL 감사기

## Prerequisites
- `scripts/preflight.sh` 통과 (jq, bash, bats).
- frontmatter 파싱을 위한 PyYAML 가 설치된 Python 3.
- 대상 경로 읽기 권한.

## Step 1: Ingest

대상 경로 수령. 누락 시 질문: *"무엇을 audit 할까요? 예: `skills/distill/SKILL.md` (단일) 또는 `skills/` (배치)."*

```bash
audit ./skills/distill/SKILL.md   # single-mode
audit ./skills                    # batch-mode → skills/*/SKILL.md 글로빙 (있으면 *.ko.md 포함), 각각 독립 처리
```

대상별 검증: 파일 읽기 가능 · frontmatter 존재 (두 `---` 사이) · 본문 ≤ 500 줄 (초과 시 경고만, 중단 X).

## Step 2: Decompose

YAML frontmatter 와 본문을 분리해 파싱한 뒤 SSL 표현을 구성한다. LLM 헬퍼에 위임할 때는 다음 프롬프트를 그대로 사용한다.

```
Read the SKILL.md and emit JSON only — no markdown fences.

{
  "scheduling": {
    "triggers": [list of phrases from the description "Triggers:" line],
    "anti_triggers": [from frontmatter ssl.scheduling.anti_triggers, or null],
    "ambiguity_notes": "any trigger ≤ 4 chars, or generic adverb / conjunction"
  },
  "structural": {
    "scenes": [from frontmatter, or inferred from "## Step N:" body headings],
    "branches": [explicit branch conditions in body],
    "resumable": bool
  },
  "logical": {
    "tools": [from frontmatter ssl.logical.tools],
    "side_effects": {
      "reads": [], "writes": [], "deletes": [], "network": []
    },
    "idempotent": bool,
    "rollback": string | null
  }
}

Fields not justified by the body or frontmatter must be null or empty array. Do not infer.
```

추론을 피하는 것이 핵심이다. 그럴듯한 추측은 감사 신호를 가린다.

## Step 3: Audit (계층별)

| 계층 | 점검 항목 | 실패 유형 |
|---|---|---|
| Scheduling | `triggers` 비어 있지 않음 | missing |
| Scheduling | 4자 이하 / 단독 접속사·부사 trigger 없음 | ambiguous |
| Scheduling | `anti_triggers` 선언됨 | missing |
| Scheduling | (batch 한정) 동일 배치 내 verbatim trigger 충돌 없음 | collision |
| Structural | `scenes` ≥ 2 항목 (모놀리식 금지) | missing |
| Structural | 모든 분기 조건이 `branches` 에 선언됨 (산문 매장 X) | implicit |
| Structural | `resumable` 이 본문 근거와 일치 (카운터·상태 마커 ⇒ true) | mismatch |
| **Logical** ×1.5 | 본문의 모든 도구 호출이 `tools` 에 반영됨 | undeclared |
| **Logical** ×1.5 | 파괴적 명령 (`rm` / `DROP` / `delete` / `--force`) 이 `side_effects.deletes` (덮어쓰기는 `writes`) 에 반영됨 | undeclared |
| **Logical** ×1.5 | 네트워크 호출 (`curl` / `wget` / `fetch` / `http`) 이 `side_effects.network` 에 있음 | undeclared |
| **Logical** ×1.5 | 본문이 비-idempotent 인데 `idempotent: true` 선언됨 | mismatch |
| **Logical** ×1.5 | `idempotent: false` 면 `rollback` 선언 필수 | missing |

크로스 체크 grep — 본문에 미선언 파괴 명령 드러나면 Logical ✗:

```bash
grep -E '(rm -rf?|DROP|delete|--force|--no-preserve)' "$target" | head -20
# diff vs. frontmatter ssl.logical.side_effects.deletes
```

## Step 4: Score

계층별 100점 만점. 누락 −15 · 모호 −8 · Logical 차감 × 1.5.

상태: ≥ 80 ✓ · 60–79 ⚠ · < 60 ✗.

점수는 트리아지 신호 — 절대 점수보다 Top-3 위험이 더 중요하다. 80점이지만 진짜 Logical ✗ 가 있는 스킬이 60점이면서 Scheduling ⚠ 셋인 스킬보다 위험하다.

## Step 5: Report

CLI 친화 마크다운. 막대 차트, Top-3 위험, frontmatter 패치 제안을 포함한다.

Single-mode 형태:

```
┌─ <relative SKILL.md path> ─────────────┐
│ Scheduling   ████████░░  77  ⚠         │
│ Structural   ██████████ 100  ✓         │
│ Logical      ████░░░░░░  43  ✗         │
└────────────────────────────────────────┘

Top 3 Risks:
1. ✗ [Logical] body has `rm -rf {tmp}` but side_effects.deletes is empty
2. ✗ [Logical] idempotent flag missing
3. ⚠ [Structural] Step 2 branch condition is in prose only

[Suggested patch — frontmatter]
ssl:
  logical:
    side_effects:
      deletes: ["{tmp_dir} contents"]
    idempotent: false
    rollback: "Manual restore from .bak directory"
```

Batch-mode 추가 항목: **trigger 충돌 매트릭스** (표현 × 스킬; verbatim ✗ / 부분 문자열·어간 ⚠) 과 **도구 의존성 그래프** (공유 도구·스크립트·훅 → SPOF).

### 출력 위치

기본: `.galmuri/audit-{slug}.md` (slug 는 대상 이름에서 파생). `--stdout` 은 터미널 출력. `--ci --threshold-logical=N` 은 Logical 점수 < N 인 스킬이 있을 때 비-제로 종료.

## Reference

SSL 프레임워크: arXiv:2604.24026 (Liang et al., 2026); Schank & Abelson, *Scripts, Plans, Goals and Understanding* (1977).
