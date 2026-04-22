---
preset_name: concept-explain
core_length: 2
mode: reduce
ratio: 0.25
required_plugins: []
---

# Preset: concept-explain

개념 설명용 4~5 슬라이드 덱. Open + Core-2~3 + Close 구조. dark-light-dark 패턴.

## Slide 1 · Open (dark)
- **역할**: 개념의 핵심 질문 또는 정의 선언.
- **제목**: 개념명 + 한 줄 정의 (의문형 가능).
- **배경**: dark
- **시각 지시**: 제목만 큰 활자 중앙 정렬.

## Slide 2 · Core-1: 본질 (light)
- **역할**: 개념의 본질 1가지. `essence_units[0]` 배치.
- **제목**: 본질 claim.
- **배경**: light
- **시각 지시**: 제목 + 한 줄 설명.

## Slide 3 · Core-2: 예시 (light) — 선택 (core_length=3 시 포함)
- **역할**: 구체 예시 1개. `essence_units[1]` 배치.
- **제목**: 예시 도메인명.
- **배경**: light
- **시각 지시**: 예시 bullet + 연결 설명.

## Slide 4 · Core-3: 추가 예시 (light) — core_length=3 시만 포함
- **역할**: 대조 예시 또는 엣지 케이스. `essence_units[2]` 배치.
- **배경**: light

## Slide 5 · Close (dark)
- **역할**: 개념 요약 + 다음 행동 (선택).
- **제목**: 한 문장 요약 (평서형).
- **배경**: dark
- **시각 지시**: 제목만 중앙 정렬.

## Rules Checklist
- [ ] Core 길이 2~3 (core_length: 2 또는 3). 4~5 슬라이드 총 구성.
- [ ] dark-light-...-dark 패턴 (Open/Close dark).
- [ ] Generalization plugin 미활성 (`required_plugins: []`).
- [ ] 디자인 토큰은 `design-tokens.md` 참조.
