---
preset_name: pitch-deck
core_length: 1
mode: reduce
ratio: 0.1
required_plugins: []
---

# Preset: pitch-deck

발표용 3 슬라이드 덱. Open-Core-1-Close 구조. dark-light-dark 패턴.

## Slide 1 · Open (dark)
- **역할**: Hook 선언. 청자의 상황을 찌르는 질문 또는 반전.
- **제목**: Hook (의문형 또는 반전 문장, 30자 이내).
- **배경**: dark
- **시각 지시**: 제목만 큰 활자 중앙 정렬. Parallel rule: Close 제목과 품사·길이 맞춤.

## Slide 2 · Core-1 (light)
- **역할**: 단일 핵심 claim + 근거 1개. `essence_units[0]` 배치.
- **제목**: 핵심 claim (30자 이내).
- **본문**: 근거 1개 (50자 이내).
- **배경**: light
- **시각 지시**: 좌측 제목, 우측 evidence.

## Slide 3 · Close (dark)
- **역할**: CTA. 행동 또는 판단 요청.
- **제목**: CTA (명령형 또는 의문형, 30자 이내).
- **배경**: dark
- **시각 지시**: 제목만 중앙 정렬. Parallel rule: Open 제목과 맞춤.

## Rules Checklist
- [ ] 3장 구조: Open / Core-1 / Close.
- [ ] dark-light-dark 순서 불변.
- [ ] Generalization plugin 미활성 (`required_plugins: []`).
- [ ] 디자인 토큰은 `design-tokens.md` 참조.
