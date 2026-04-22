---
preset_name: story-arc
core_length: dynamic
mode: reduce
ratio: user-defined
required_plugins: []
---

# Preset: story-arc

가변 길이 (내용 주도) preset. Core 길이 = `essence_units.length` (불변식).

## Core Length 규칙 (불변식)
```
core_length = essence_units 개수
```
- essence_units 개수가 Core 슬라이드 수를 결정한다. preset 이 고정값을 지정하지 않는다.
- essence_units 가 0 일 때: 검증 게이트 실패 — distill 엔진에 "No units produced" 오류 반환. 덱 생성 중단 후 HITL: "원본 텍스트를 다시 입력하거나 ratio 를 조정해주세요."

## Ratio
- 사용자 지정 (`--ratio` 인자). 미지정 시 엔진이 기본값 0.2 적용.

## 슬라이드 구조
1. **Open (dark)**: 이야기의 출발점 또는 긴장 상황.
2. **Core-1 ~ Core-N (light)**: `essence_units[0..N-1]` 각각 1장. N = essence_units.length.
3. **Close (dark)**: 해소 또는 행동 요청.

## 슬라이드 세부 지시

### Open (dark)
- **제목**: 이야기의 시작 상황 또는 긴장 질문.
- **배경**: dark
- **시각 지시**: 제목만 큰 활자 중앙 정렬. Parallel rule: Close 제목과 맞춤.

### Core-i (light) — i = 1..N
- **제목**: `essence_units[i-1].claim`.
- **본문**: `essence_units[i-1].essence` + `evidence[0]`.
- **배경**: light
- **시각 지시**: 제목 좌측, 본문 우측.

### Close (dark)
- **제목**: 해소 문장 또는 행동 촉구 (평서형 또는 명령형).
- **배경**: dark
- **시각 지시**: 제목만 중앙 정렬. Parallel rule: Open 제목과 맞춤.

## 체크리스트
- [ ] `core_length = essence_units 개수` 불변식 준수.
- [ ] essence_units 가 0 일 때 게이트 실패 + HITL 처리.
- [ ] Generalization plugin 미활성 (`required_plugins: []`).
- [ ] 디자인 토큰은 `design-tokens.md` 참조.
