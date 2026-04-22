---
preset_name: decision-sandwich-6
core_length: 4
mode: reduce
ratio: 0.3
required_plugins: ["generalization-check"]
---

# Preset: decision-sandwich-6

결정 덱 preset. 6 슬라이드 구조 (Open / Concept / Comparison / Examples / Trade-off / Close).
dark-light-light-light-light-dark sandwich 패턴.

## 슬라이드 1 · Open (dark)
- **역할**: 결정 질문 선언.
- **제목**: 결정의 핵심 질문 (의문형, 30자 이내).
- **배경**: dark
- **Copy elements**: 큰 질문 (chip 라벨 허용) + A/B 옵션 라벨.
- **시각 지시**: 제목만 큰 활자 중앙 정렬. Parallel rule: Close 제목과 품사·길이 맞춤.

## 슬라이드 2 · Concept (light)
- **역할**: D/E/V/R 역할 정의. `essence_units[0]` 배치.
- **제목**: 역할 A 또는 핵심 개념 명칭.
- **배경**: light
- **Copy elements**: cards × 2 (기본 원리 + 배경).
- **시각 지시**: 좌측 제목, 우측 D/E/V/R 테이블.

## 슬라이드 3 · Comparison (light)
- **역할**: 옵션 비교. `essence_units[1]` 배치.
- **제목**: 무게 축 (비교 기준).
- **배경**: light
- **Copy elements**: columns × 2 (A 장점·단점 vs B 장점·단점).
- **시각 지시**: 2열 비교 표. 선택 열 강조.

## 슬라이드 4 · Examples (light)
- **역할**: 구체 사례 1~2건. `essence_units[2]` 배치.
- **제목**: 사례 도메인명.
- **배경**: light
- **Copy elements**: rows × 3 (A 예시 + B 예시 + 공통 패턴).
- **시각 지시**: 사례 bullet + 근거 1개씩.

## 슬라이드 5 · Trade-off (light)
- **역할**: 포기하는 것 명시. `essence_units[3]` 배치.
- **제목**: 포기 항목 (명사형).
- **배경**: light
- **Copy elements**: cards × 2 + callout (최우선·이차 가치 + 선택 근거).
- **시각 지시**: 잃는 것 ↔ 얻는 것 두 열.

## 슬라이드 6 · Close (dark)
- **역할**: 결론 선언 + Recovery 책임자.
- **제목**: 결론 한 문장 (평서형, 30자 이내).
- **배경**: dark
- **Copy elements**: operating_rule (단일 선택 명제) + diagram_hint (Recovery 흐름).
- **시각 지시**: 제목만 중앙 정렬. Parallel rule: Open 제목과 맞춤.

## 체크리스트
- [ ] Open ↔ Close parallel rule 준수.
- [ ] `required_plugins: ["generalization-check"]` — Generalization plugin 활성화 필수.
- [ ] dark-light-light-light-light-dark 순서 불변.
- [ ] 디자인 토큰은 `design-tokens.md` 참조 (본 파일에 색상값 복제 금지).
