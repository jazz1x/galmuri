# 변경 기록

모든 주요 변경사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 를 따릅니다.
버전 관리는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 을 준수합니다.

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
