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

하나 또는 다수의 SKILL.md 파일에 대한 정적 SSL 분해. 진단과 패치 제안을 생성한다. **원본은 어떤 경우에도 수정되지 않는다.**

## Prerequisites
- `scripts/preflight.sh` 통과 (jq, bash, bats).
- frontmatter 파싱을 위한 PyYAML 가 설치된 Python 3.
- 대상 경로 읽기 권한.

## Step 1: Ingest

대상 경로를 받는다. 경로가 주어지지 않았다면 자연어로 묻는다.

> "무엇을 audit 할까요? 경로를 알려주세요 — 예: `skills/distill/SKILL.md` (단일 스킬) 또는 `skills/` (디렉터리 일괄)."

두 가지 형태를 지원한다.

```bash
# Single file
audit ./skills/distill/SKILL.md

# Directory (batch mode — globs skills/*/SKILL.md)
audit ./skills
```

각 대상을 검증한다.

- 파일이 존재하고 읽을 수 있다.
- frontmatter 가 존재한다 (두 개의 `---` 구분자 사이).
- 본문 길이가 500 줄 이하다 (초과 시 경고만 — 섹션 단위 분해를 권장하되 중단하지는 않는다).

디렉터리 입력의 경우 `skills/*/SKILL.md` (그리고 `*.ko.md` 가 있으면 함께) 를 글로빙한다. 각각 독립적으로 처리한다.

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

### 3-A. Scheduling
- [ ] `triggers` 가 비어 있지 않다
- [ ] 너무 일반적인 trigger 가 없다 (4자 이하, 또는 단독 접속사 / 부사)
- [ ] `anti_triggers` 가 선언되어 있다
- [ ] (batch-mode 한정) 동일 배치 내 다른 스킬과의 verbatim trigger 충돌이 없다

### 3-B. Structural
- [ ] `scenes` 가 2개 이상이다 (단일 블록 모놀리식 금지)
- [ ] 모든 분기 조건이 `branches` 에 있다 (본문 산문에 묻혀 있지 않다)
- [ ] `resumable` 이 본문 근거와 일치한다 (카운터 / 상태 마커 파일이 있으면 true, 없으면 false)

### 3-C. Logical (가중치 최대 — × 1.5)
- [ ] 본문의 모든 도구 호출이 `tools` 에 반영되어 있다
- [ ] 모든 파괴적 명령 (`rm`, `DROP`, `delete`, `--force`) 이 `side_effects.deletes` 에 반영되어 있다 (덮어쓰기라면 `writes`)
- [ ] 모든 네트워크 호출 (`curl`, `wget`, `fetch`, `http`) 이 `side_effects.network` 에 있다
- [ ] 본문이 비-idempotent 인데 `idempotent: true` 로 선언되어 있으면 불일치
- [ ] `idempotent: false` 면 `rollback` 선언 필수

크로스 체크 (이 스킬이 실제로 수행하는 grep):

```bash
grep -E '(rm -rf?|DROP|delete|--force|--no-preserve)' "$target" | head -20
# compare against frontmatter ssl.logical.side_effects.deletes
```

본문에 선언되지 않은 파괴적 명령이 드러나면 Logical ✗.

## Step 4: Score

계층별로 100점 만점.

- 누락 필드: −15
- 모호한 선언: −8
- Logical 계층 가중치: × 1.5

상태 임계값:

- ≥ 80 → ✓
- 60–79 → ⚠
- < 60 → ✗

수치 점수는 트리아지 신호다. 절대 점수보다 스킬당 Top-3 위험이 더 중요하다 — 80 점이면서 진짜 Logical ✗ 가 있는 스킬이 60 점이면서 Scheduling ⚠ 세 개인 스킬보다 위험하다.

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

Batch-mode 추가 항목:

- **Trigger 충돌 매트릭스** — 표현 × 스킬 표; verbatim 충돌은 ✗, 부분 문자열 / 어간 중복은 ⚠
- **도구 의존성 그래프** — 어떤 스킬이 어떤 도구 / 스크립트 / 훅을 공유하는지; SPOF 식별

### 출력 위치

기본 리포트 파일: `.galmuri/audit-{slug}.md` (slug 는 대상 이름에서 파생). 터미널에 출력하려면 `--stdout`. CI 에서 Logical 점수가 `N` 미만일 때 비-제로 종료하려면 `--ci --threshold-logical=N`.

## 출력 스키마

스킬별 스코어카드, Top-3 위험, 패치 제안, 그리고 (batch-mode 한정) 충돌 매트릭스와 도구 의존성 그래프를 담은 마크다운 리포트 (CLI 친화). JSON 출력 없음, 원본 수정 없음.

## 이 스킬이 하지 않는 일

- ✗ 어떤 `SKILL.md` 도 수정하지 않음 (계약상 읽기 전용)
- ✗ 어떤 스킬도 실행하지 않음 (정적 분석만)
- ✗ 신규 스킬 생성 — `skill-creator` 영역
- ✗ 일반적인 테스트 / 커버리지 점검 — `harnish:ralphi` 영역
- ✗ 결정 강제 — `harnish:forki` 영역
- ✗ 자유 형식 텍스트 요약 — `distill` / `explain` / `doc` 영역

## Reference

SSL 프레임워크 출처:

- arXiv:2604.24026 (Liang et al., 2026) — Scheduling-Structural-Logical skill decomposition
- Schank & Abelson, *Scripts, Plans, Goals and Understanding* (1977) — 이론적 토대
