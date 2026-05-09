# 변경 기록

모든 주요 변경사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 를 따릅니다.
버전 관리는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 을 준수합니다.

## [0.0.4] — 2026-05-10

0.0.3 에서 도입된 SSL 계약에 대한 셀프 감사 패스. `audit` 스킬을 나머지 5개에 적용해 Logical ✗ 1건 (`explain` 이 `idempotent: false` 인데 `rollback` 미선언) 과 Scheduling ⚠ 1건 (`deck` 의 1자 트리거 `덱` + generic `A vs B`) 을 발견·해소. 3개 스킬의 implicit branch 를 산문에서 frontmatter `branches:` 로 승격. `audit` / `distill` / `deck` 본문을 테이블·인라인 조건문으로 dense 화 — 정보 보존, EN −128 줄 (≈ 10 %).

### 수정

- **`explain` Logical ✗**: `idempotent: false` 선언 + `rollback: null` 이라 계약 위반. 세션 종료 hook 의 tmp 파일 정리를 참조하는 `rollback` 추가.
- **`deck` Scheduling ⚠**: 1자 트리거 `덱` 과 generic `A vs B` 가 false-fire 위험이 너무 컸음. 멀티워드 형태 (`덱 만들어`, `슬라이드 만들어`, `발표 자료`, `deck 생성`, `deck 만들어`, `A vs B 슬라이드`, `뭐가 나은지 슬라이드`) 로 교체해 ≤ 4자 룰을 통과.
- **`explain` / `doc` / `distill` Structural ⚠**: 라우팅 분기가 본문 산문에만 존재. frontmatter `branches:` 로 승격시켜 정적 감사 가능하게 함. `pitch` 는 이미 `branches:` 로 라우팅을 선언 중 — `explain` / `doc` 가 이를 미러해 `shrink` / `줄여줘` / `압축` 3-way alias 가 세 어댑터에 걸쳐 대칭 계약을 갖게 됨.

### 변경

- **`audit` 본문 dense화 (197 → 150 줄)**: 세 평행 체크리스트 (Scheduling / Structural / Logical, 줄 단위) 를 단일 Layer × Check × Failure 테이블로 통합. 점수 규칙 + 상태 임계값을 산문 두 줄로 압축. "두 가지 형태 지원" + 대상별 검증을 한 bash 블록 + 한 줄 기준으로 합침. batch-mode 추가 항목과 출력 위치 플래그는 인라인화. Step 5 와 `anti_triggers` 를 그대로 복제하던 `Output Schema` / `이 스킬이 하지 않는 일` 섹션 제거. Reference 는 한 줄로 축약.
- **`distill` 본문 dense화 (135 → 120 줄)**: "3 Methods" 번호 목록을 # × Method × Reference × Output 테이블로 변환. Step 1 / 2 / 4 / 5 의 bash 직후 bullet recap (bash 내용을 그대로 다시 설명하던 것) 을 lead-in 한 줄씩으로 통합. Step 2 의 if/else 는 `&& / ||` 한 줄로 축약.
- **`deck` 본문 dense화 (64 → 62 줄)**: preset HITL 리스트를 # × Preset × Shape 테이블로. 2-파일 저장 리스트를 File × Content 테이블로. Step 4 를 다시 풀어 쓰던 `Output Schema` 섹션은 Step 4 안으로 흡수.

### 추가

- **`.gitignore` 에 `.galmuri/audit-*.md` 추가**: audit 스킬의 기본 리포트 출력 위치가 `.galmuri/audit-{slug}.md` 라 진단 결과물이 추적되지 않도록 패턴 추가.

## [0.0.3] — 2026-05-07

두 변경이 함께 출시: 모든 스킬이 SSL(Scheduling-Structural-Logical) frontmatter 계약을 채택했고, 그 계약을 임의의 SKILL.md 에 적용하는 새 6번째 스킬 — `audit` — 가 추가됐다. deck 트리거를 좁혀 `harnish:forki` 와의 충돌 해소. pitch 라우팅 룰의 `ratio` 가 사용자 입력 변수가 아님을 명시.

### 추가

- **`audit` 스킬** (`skills/audit/SKILL.md` + `SKILL.ko.md`) — galmuri 의 6번째 스킬. 단일 또는 다수 SKILL.md 에 대한 정적 SSL 분해. 5개 씬 — Ingest → Decompose → Audit → Score → Report. CLI 친화적 markdown 출력 (기본 `.galmuri/audit-{slug}.md`, `--stdout` 시 터미널, `--ci --threshold-logical=N` 시 임계값 미달 스킬이 있으면 non-zero exit). 트리거: `skill audit`, `ssl audit`, `audit skill`, `ssl 분해`, `skill auditor`, `audit-skill`. contract 상 읽기 전용 — 원본을 수정하지 않음. 영문 기반 트리거로 `harnish:ralphi` 와의 한국어 stem 충돌 회피.
- **6개 스킬 전체 SSL frontmatter**: 모든 `SKILL.md` 와 `SKILL.ko.md` 가 `scheduling.anti_triggers`, `structural.scenes`, `structural.resumable`, `logical.tools`, `logical.side_effects` (reads/writes/deletes/network), `logical.idempotent`, `logical.rollback` 을 포함한 `ssl:` 블록 선언. 정적 auditor 와 하류 consumer 를 위한 부작용 계약을 표면화. `audit` 스킬 자체도 이 계약을 따름 (dogfood).
- **회귀 테스트 +13건** (83 → 96): `ssl:` 블록 존재, idempotent 가 boolean 타입, `scheduling.anti_triggers` 존재, 기술 필드 en/ko 동치 (scenes/tools/side_effects/idempotent), deck 트리거에 `decide`/`의사결정`/`결정해` 없음, pitch ratio 추론 disclaimer 본문 고정, audit 디렉터리 + .md/.ko.md 양쪽 존재, audit description 에 ralphi 트리거 없음, audit description 에 `ssl audit`/`skill audit` positive 트리거 존재, audit `anti_triggers` 가 `ralphi` 와 `forki` 를 명시, audit `idempotent: true` (정적 분석은 결정적이어야 함).

### 변경

- **deck 트리거 narrowing**: deck 어댑터의 description 에서 `decide`, `의사결정`, `결정해` 제거. `harnish:forki` 와 모호 (`decide` verbatim 일치 + `결정해⊃결정` substring 매치) 했던 항목들. 잔여 트리거: `덱`, `슬라이드`, `deck`, `발표 자료`, `A vs B`, `뭐가 나아`.
- **deck Step 1 간소화**: deprecated 트리거가 사라졌으므로 deprecation 경고 bash 블록 제거. 헤딩을 `Step 1: 프리셋 선택 (필수)` 로 변경.
- **pitch Step 1 본문**: 라우팅 룰의 `ratio` 는 자연어 신호 (`한 줄` / `TL;DR` / `one line`) 로부터 **추론**되는 값이지 사용자 입력 변수가 아님을 한 줄로 명시. 실제 `--ratio 0.08` 은 Step 2 에서 하드코딩.
- **explain forbidden-words 테스트 본문 한정**: 두 번째 `---` 이후 본문만 grep. frontmatter 의 `ssl:` 블록이 `side_effects` 스키마의 일부로 `writes:` 를 정당하게 언급할 수 있도록.
- **README 아키텍처 다이어그램**: "엔진 1 + 어댑터 4" 에서 "엔진 1 + 어댑터 4 + 메타 스킬 1" 로 갱신, skills 표에 audit 행 추가, 슬래시 명령 verify 목록에 `/galmuri:audit` 추가. 설치 출력은 `6 skills registered (..., audit)` 로 변경.

### 제거

- **deck 의 `decide` / `의사결정` / `결정해` deprecation alias**. 0.0.1 부터 세션당 1회 경고와 함께 `deck --preset decision-sandwich-6` 으로 라우팅되던 동작이다. 결정형 프롬프트는 이제 binary 결정에 `harnish:forki` 를, 슬라이드가 필요하면 `deck --preset decision-sandwich-6` 을 명시 호출. README · CHANGELOG 참조 갱신.

### 수정

- **distill `rm -f` 가 미선언**: Step 1 + Step 5 가 `.galmuri/tmp/retry-count.{slug}` 를 삭제하는데 frontmatter 에 선언이 없었음. 이제 `ssl.logical.side_effects.deletes` 에 있음.
- **doc/deck 비멱등이 미선언**: 재실행 시 자산 기록이 중복 append (`e2e.bats:433` 의 "dedup is intentionally not enforced at record time" 으로 확정). 이제 `ssl.logical.idempotent: false` 로 선언, 수동 `record-asset.sh` 복구 경로를 `rollback` 에 문서화.

## [0.0.2] — 2026-05-01

문서화, 설치 경로, 어댑터 명확성. 동작 변화 없음.

### 추가

- **skills.sh 설치 경로**: `npx skills add jazz1x/galmuri` 가 기존 `/plugin marketplace add` 플로우와 함께 동작 (Claude Code, Cursor, Codex, Windsurf 등 40+ 에이전트). 두 README 에 반영.
- **회귀 테스트** (73 → 83): Skill-tool 위임 고정, prose 라우팅 고정 (`bc` 미사용), PostToolUse 자동 실행 고정, 그리고 e2e 엣지 케이스 6개 (빈 파일, 동일 해시 중복 기록, 빈 인덱스, diff-loss 경계).

### 변경

- **영문 베이스 SKILL.md**: 5개 SKILL.md 의 frontmatter description 과 본문이 모두 영문. 한국어 트리거 어구는 description 에 남겨 자동 호출이 그대로 동작. 한국어 본문은 `SKILL.ko.md` 에 유지.
- **pitch 라우팅**: Step 1 의 `count-tokens.sh + bc` 인라인 서브프로세스를 prose 규칙으로 대체. 어댑터 라우팅에 외부 의존성 없음.
- **explain Step 2**: Skill-tool 위임을 일급 지시로 승격 (기존엔 blockquote note).
- **doc Step 5**: `PostToolUse` 훅 (`asset-record.sh`) 이 자동 실행됨을 명시; 수동 `record-asset.sh` 호출은 폴백 경로로만 사용.

### 수정

- **marketplace.json description**: `plugin.json` 은 영문이지만 marketplace.json 만 한국어였던 불일치를 영문으로 통일.

## [0.0.1] — 2026-04-28

최초 릴리스. 엔진/어댑터 아키텍처, 이중 언어 지원, 훅 파이프라인, 자산 추적, 전체 테스트 스위트.

### 추가

- **엔진/어댑터 아키텍처**: `distill` 이 EngineOutput JSON 을 생성하는 공유 엔진으로, 네 어댑터(`explain`, `pitch`, `doc`, `deck`)가 소비.

- **explain 어댑터**: 작성자용 인라인 markdown 요약. `audience=me` 자동 고정, 파일 생성 없음, 청자 질의 없음.

- **pitch 어댑터**: 지정 청자를 위한 Hook-Core-CTA 3–5줄. `shrink` 트리거 입력 시 토큰 수 기반으로 자동 라우팅.

- **doc 어댑터**: 청자 선택 후 `docs/galmuri-doc-{slug}.md` 저장 및 자산 기록.

- **deck 어댑터**: Jobs-inspired 디자인 토큰(SF Pro, 16:9, dark-light-dark 샌드위치 패턴) 기반 슬라이드 카피(JSON + markdown). 이진 파일 생성 없음.

- **덱 프리셋 4종**: `decision-sandwich-6`(6슬라이드 2지 결정), `pitch-deck`(3슬라이드), `concept-explain`(4–5슬라이드), `story-arc`(가변 내러티브).

- **EngineOutput JSON 스키마** (`skills/distill/references/essence-schema.json`): `EssenceUnit` 과 최상위 필드 정의 JSON Schema draft-07.

- **유틸리티 스크립트**:
  - `count-tokens.sh`: tiktoken 지원 + word count 폴백; `{"tokens": N, "chars": N, "lines": N}` 출력
  - `evidence-check.sh`: `wc -c` 바이트 단위 소스/출력 크기 비교; `--require-smaller` 모드
  - `diff-loss.sh`: 정보 손실 정량화; 서양어 및 한국어 문장 경계(`다/요/죠/네/군` 종결 어미) 모두 커버
  - `record-asset.sh`: SHA-256 NFC 정규화 자산 기록
  - `query-assets.sh`: `assets/*.jsonl` 직접 읽기; `index.jsonl` 폴백
  - `consolidate-assets.sh`: 자산 중복 제거 후 `index.jsonl` 생성
  - `parse-ratio.sh`: 자연어 + 수치 ratio 파싱; `0.50`→`0.5` 정규화; `"core only"`, `"one line"`, `"tl;dr"` 지원
  - `validate-essence.sh`: EngineOutput JSON 스키마 검증 및 ratio 범위(0.05–0.5) 확인
  - `preflight.sh`: 런타임 선결 조건(jq, bash, bats) 확인; 미설치 시 exit 3
  - `i18n-sync-check.sh`: 코드 펜스 인식 헤딩 동기화 확인 (`.md` ↔ `.ko.md`)
  - `install-hooks.sh`: HITL 충돌 해결과 함께 recommended.json 훅을 settings.json 에 병합

- **훅** (선택, `install-hooks.sh` 로 설치):
  - `PreToolUse/Write` → `pre-write.sh`: galmuri 출력 파일 저장 전 소스 증거 검증
  - `PostToolUse/Write|Edit` → `post-write.sh`, `asset-record.sh`: 출력을 자산으로 기록; `.galmuri/tmp/` 소스 정리
  - `UserPromptSubmit` → `prompt-hint.sh`, `source-capture.sh`: 스킬 트리거 어구를 해당 어댑터로 라우팅; 사용자 프롬프트를 `.galmuri/tmp/` 에 캡처
  - `SessionStart` → `session-start.sh`: 최근 자산 3건을 세션 컨텍스트로 주입

- **Deprecation alias 라우팅**: `decide`/`shrink` 트리거 → 문맥에 맞는 어댑터로 라우팅. `.galmuri/tmp/.warned-{alias}` 세션당 1회 경고.

- **다국어 지원**: 완전한 영어/한국어 인터페이스, 스킬 문서, 프롬프트.

- **자산 추적**: `.galmuri/assets/*.jsonl` 에 자동 기록; SHA-256 NFC 정규화 해시로 세션 간 중복 방지.

- **플러그인 매니페스트**:
  - `.claude-plugin/plugin.json`: 스킬 등록
  - `.claude-plugin/marketplace.json`: Marketplace 목록

- **테스트 스위트** (`tests/`):
  - `e2e.bats`: LLM 없이 전체 파이프라인을 검증하는 e2e 테스트 26개
  - `manifest.bats`: hook shim 파일 존재, count-tokens JSON 형식, hook 매처 유효성
  - `scripts.bats`: parse-ratio, validate-essence, preflight 단위 테스트
  - `skills.bats`: SKILL.md 구조, i18n 헤딩 동기화, 스킬 계약 확인

### 설계 결정

- **바이너리 렌더링 없음**: `deck` 은 JSON + markdown 템플릿만 출력. 사용자가 Keynote, PowerPoint, Figma, Slidev, Marp 등으로 렌더링.

- **LLM-as-judge**: distill 은 self-judge 로 주장을 원본과 검증. 결정 덱은 소크라테스 검증(18문항: 슬라이드당 3문항 — 정의/차이/귀속) 적용.

- **자산 중복 제거**: SHA-256 NFC 정규화 hash 로 세션 간 중복 기록 방지.

- **우아한 폴백**: tiktoken 미설치 시 word count 폴백. 외부 의존성 미설치 시 자동 skip.

- **설정 대신 훅**: 복잡한 훅 명령은 shim 스크립트로 유지(settings.json 인라인 대신).

### 미포함 (P1+)

- PowerPoint/Keynote 슬라이드 렌더링
- 대량 문서 처리
- 대용량 출력 스트리밍
- 스킬 내 커스텀 LLM 모델 선택
- 분석/사용 대시보드
- i18n 검증 CI 통합
