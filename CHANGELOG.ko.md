# 변경 기록

모든 주요 변경사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 를 따릅니다.
버전 관리는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 을 준수합니다.

## [미출시]

엔진/어댑터 재설계 (0.0.1 개발 단계 내 변경, 별도 버전 릴리스 미확정).

### 추가

- **엔진/어댑터 아키텍처**: `distill` 이 EngineOutput JSON 을 생성하는 공유 엔진으로 재정의. 4개 어댑터(`explain`, `pitch`, `doc`, `deck`)가 이를 소비.

- **explain 어댑터**: 작성자용 인라인 markdown 요약. `audience=me` 자동 고정, 파일 생성 없음, 청자 질의 없음.

- **pitch 어댑터**: 지정 청자를 위한 Hook-Core-CTA 3–5줄 구조.

- **doc 어댑터**: 정제된 markdown → `docs/galmuri-doc-{slug}.md` 저장 (청자 선택 + 자산 기록).

- **deck 어댑터**: Jobs-inspired 디자인 토큰 (SF Pro, 16:9, dark-light-dark 샌드위치 패턴) 기반 슬라이드 카피 (JSON + markdown). 이진 파일 생성 없음.

- **4개 deck 프리셋**: `decision-sandwich-6` (6슬라이드 2지 결정), `pitch-deck` (3슬라이드), `concept-explain` (4–5슬라이드), `story-arc` (가변 내러티브).

- **EngineOutput JSON 스키마** (`skills/distill/references/essence-schema.json`): `EssenceUnit` 과 최상위 필드 정의 JSON Schema draft-07.

- **scripts/validate-essence.sh**: EngineOutput JSON 스키마 검증. 통과 시 exit 0, 실패 시 exit 1.

- **scripts/preflight.sh**: 런타임 선결 조건(jq, bash, bats) 확인. 미설치 시 exit 3 + 메시지.

- **Deprecation alias 라우팅**: `decide`/`shrink` 트리거 → 문맥 맞는 어댑터 라우팅. `.galmuri/tmp/.warned-{alias}` 세션당 1회 경고.

### 변경

- **distill 스킬** 순수 엔진으로 재작성: `--mode`, `--ratio`, `--audience`, `--weak-decomposition`, `--input` 플래그. EngineOutput JSON 출력; 저장/렌더 결정은 어댑터 담당.

- **distill/references/prompt.md**: shrink 의 압축 전술 5건 머지 (복문→단문, 추상화, 고유명사·수치·인용, 시간 순서, 목차·메타 서술 금지). 본질환원/제1원칙/소크라테스 메서드 섹션 추가.

- **Hooks** (`hooks/recommended.json`): 5개 스킬 개별 matcher 로 업데이트. `decide`/`shrink` 훅 항목 제거.

### Deprecated

- **shrink 스킬**: 트리거 (`shrink`, `줄여줘`, `압축`) → `explain` 또는 `doc` 라우팅. 0.2.0 에서 제거 예정.

- **decide 스킬**: 트리거 (`decide`, `결정`) → `deck --preset decision-sandwich-6` 라우팅. 0.2.0 에서 제거 예정.

### 제거

- `skills/decide/` — 내용 전체를 `skills/deck/references/preset-decision-sandwich-6.md` + `design-tokens.md` 로 이관.

- `skills/shrink/` — 압축 전술을 `skills/distill/references/prompt.md` 로 이관.

### Breaking

- **EngineOutput JSON 이 스킬 간 계약.** distill 의 raw markdown 출력을 소비하던 외부 통합은 `EngineOutput` 스키마로 전환 필요.

- **`/galmuri:shrink` 와 `/galmuri:decide` 명령 제거.** `explain`, `doc`, `deck` 을 사용. 트리거 phrase alias 는 0.1.x 세션 라우팅용으로 유지.

---

## [0.0.1] — 2026-04-22

### 추가

- **distill 스킬**: 긴 텍스트에서 특정 청자 대상의 본질만 추출. 톤, 예시, 장황함 제거 후 결정 변화 주장만 유지. LLM-as-judge 검증 + 손실 diff 리포팅 포함.

- **shrink 스킬**: 텍스트를 목표 token 비율로 압축. 재시도 설정 가능. 의미 손실 최소화하며 시간 제약 만족.

- **decide 스킬**: 2선택 의사결정을 6슬라이드 Jobs-style 결정 덱으로 변환. 엄격한 D/E/V/R (Decision/Execution/Validation/Recovery) 분해, 본질 축약, 다중 도메인 일반화, 소크라테스 검증 (18문항: 슬라이드당 3문항 — 정의/차이/귀속) 포함.

- **유틸리티 스크립트**:
  - `count-tokens.sh`: tiktoken 지원 + word count 폴백
  - `evidence-check.sh`: 정제/압축 결과 구조 검증
  - `diff-loss.sh`: 전후 텍스트 정보 손실 정량화
  - `record-asset.sh`: SHA-256 NFC 정규화 자산 기록
  - `query-assets.sh`: tag 기반 자산 검색
  - `consolidate-assets.sh`: 자산 중복 제거
  - `harnish-bridge.sh`: 외부 harnish 통합 bridge
  - `i18n-sync-check.sh`: .md / .ko.md 제목 구조 일치 검증
  - `install-hooks.sh`: 설정에 권장 훅 병합 (충돌 해결)

- **훅** (선택, `install-hooks.sh` 로 설치):
  - `PreToolUse`: 정제 내용 저장 전 검증
  - `PostToolUse`: distill/shrink 출력 저장 후 자산 기록
  - `UserPromptSubmit`: keyword 매칭 시 기술 제안
  - `SessionStart`: 과거 청자 persona 미리 로드

- **다국어 지원**: 완전한 영어/한국어 인터페이스, 스킬 문서, 프롬프트. 용어 사전 (명세 §4.8.8).

- **자산 추적**: distill/shrink 결과 자동 인덱싱 (`.galmuri/index.jsonl`) 으로 재사용 및 청자 persona 발견 가능.

- **플러그인 매니페스트**:
  - `.claude-plugin/plugin.json`: 스킬 등록
  - `.claude-plugin/marketplace.json`: Marketplace 목록

### 설계 결정

- **바이너리 렌더링 없음**: `decide` 는 JSON + markdown 템플릿만 출력. 사용자가 Keynote, PowerPoint, Figma, Slidev, Marp 등으로 렌더링 (향후 확장 기회).

- **LLM-as-judge**: distill/shrink 는 self-judge로 주장을 원본과 검증. 결정 덱은 소크라테스 검증 (18문항) 으로 슬라이드가 응답 가능/명시적/귀속되는지 확인.

- **자산 중복 제거**: SHA-256 NFC 정규화 hash로 세션 간 중복 기록 방지.

- **우아한 폴백**: tiktoken 미설치 시 word count로 폴백. 외부 의존성 미설치 시 자동 skip.

- **설정 대신 훅**: 복잡한 훅 명령은 shim 스크립트로 (settings.json 인라인 대신) 유지보수성 향상.

### 미포함 (P1+)

- PowerPoint/Keynote 슬라이드 렌더링
- 대량 문서 처리
- 대용량 출력 스트리밍
- 스킬 내 커스텀 LLM 모델 선택
- 분석/사용 대시보드
- i18n 검증 CI 통합
