# decide — 의사결정 덱 생성 프롬프트

## 7 Absolute Rules

1. **Dark 1st**: Slide 1 (Problem) — 다크 배경
2. **Light sandwich**: Slides 2–5 — 라이트 배경 (4개 연속)
3. **Dark final**: Slide 6 (Conclusion) — 다크 배경
4. **Parallel text**: 같은 위치의 텍스트는 길이·품사 일치
5. **2 options**: 항상 정확히 2개 선택지 (A, B)
6. **6 slides fixed**: 슬라이드 개수 고정 (확장 금지)
7. **Jobs tokens**: 디자인 인텐트 (style, palette, typography) 포함

## JSON Schema (galmuri-decide-{slug}.json)

**전체 스키마**:

```json
{
  "design_intent": {
    "style": "Apple Keynote / Steve Jobs",
    "aspect_ratio": "16:9",
    "font_stack": ["SF Pro", "Helvetica Neue", "Arial"],
    "typography_pt": {
      "title": [60, 80],
      "subtitle": [22, 32],
      "body": [14, 18],
      "caption": [11, 14]
    },
    "palette": { "dark_bg": "#111111", "light_bg": "#FFFFFF" },
    "structure": "dark-white*4-dark sandwich",
    "emoji_policy": "chips/headers only, 0 in body",
    "parallel_rule": "same-position text must match length and part-of-speech"
  },
  "title": "{의사결정 질문}",
  "options": {
    "A": { "label": "{옵션 A}", "color": "#RRGGBB" },
    "B": { "label": "{옵션 B}", "color": "#RRGGBB" }
  },
  "slides": [
    { "number": 1, "title": "Problem",    "bg": "dark",  "copy": { ... } },
    { "number": 2, "title": "Concept",    "bg": "light", "copy": { ... } },
    { "number": 3, "title": "Comparison", "bg": "light", "copy": { ... } },
    { "number": 4, "title": "Examples",   "bg": "light", "copy": { ... } },
    { "number": 5, "title": "Trade-off",  "bg": "light", "copy": { ... } },
    { "number": 6, "title": "Conclusion", "bg": "dark",  "copy": { ... } }
  ]
}
```

**Validation**:
- `options` 정확히 2개 (A, B). `options.*.color` 각각 HEX `^#[0-9A-Fa-f]{6}$` 1개, A ≠ B.
- `slides` 정확히 6개. `slides[i].number` 는 1~6 (1-based, 배열 인덱스 `i` 는 0~5).
- `slides[i].bg` 규칙: **slide number 1, 6 → "dark"**, **slide number 2, 3, 4, 5 → "light"** (샌드위치 구조).
- 각 slide `copy` 는 슬라이드별 구조 준수: Problem 은 큰 질문+chips / Concept 는 cards×2 / Comparison 은 columns×2 / Examples 는 rows×3 / Trade-off 는 cards×2+callout / Conclusion 은 operating_rule+diagram_hint.

## Slide Specification (`references/slide-mapping.md` 참조)

| Slide | Title | Role | BG | Copy Elements |
|-------|-------|------|----|----|
| 1 | Problem | 현상 | dark | 큰 질문 + A/B 라벨 |
| 2 | Concept | 공통 이해 | light | 기본 원리 + 배경 |
| 3 | Comparison | 비교 | light | A 장점·단점 vs B 장점·단점 |
| 4 | Examples | 시나리오 | light | A 예시 + B 예시 |
| 5 | Trade-off | 가중치 | light | 최우선·이차 가치 |
| 6 | Conclusion | 결론 | dark | 단일 선택 + Operating rule + Recovery |

## 금지 사항
- "상황에 따라" 표현 금지 (단일 결론 강제)
- 슬라이드 추가/삭제 금지
- 3개 이상 선택지 금지
- 배경색 규칙 위반
