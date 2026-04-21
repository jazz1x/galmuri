# 변경 기록

모든 주요 변경사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 를 따릅니다.
버전 관리는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 을 준수합니다.

## [0.1.0] — 2026-04-22

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

---

## [미출시]

(향후 버전 계획. 사용자 피드백 기반 범위 확정.)
