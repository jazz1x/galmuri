# 슬라이드 매핑 — 구조 참조

> 6슬라이드 구조 및 Jobs 토큰 가이드.

## Slide 1: Problem (다크)

**구조**:
- 제목: 한 줄 질문 (큰 활자)
- 선택지: Option A / Option B (라벨)
- 맥락: 선택 배경 (짧은 문장)

---

## Slide 2: Concept (라이트)

**구조**:
- 제목: 개념 이름
- 본문: 역사/배경/기본 원리
- 선택과의 관계: 왜 지금인가

---

## Slide 3: Comparison (라이트)

**구조**:
- A의 장점 | B의 장점
- A의 단점 | B의 단점
- 무게 축 한 줄 (옵션 간 근본 차이 — 비교 축만 제시, 실제 trade-off 수용·판단은 Slide 5 에서)

---

## Slide 4: Examples (라이트)

**구조**:
- A 선택 시나리오
- B 선택 시나리오
- 비교 기준

---

## Slide 5: Trade-off (라이트)

**구조**:
- 최우선 가치
- 이차 가치
- 가중치에 따른 각 선택지 위치

---

## Slide 6: Conclusion (다크)

**구조**:
- 단일 결론 (A 또는 B)
- Operating Rule (결정 운영 원칙)
- Recovery (실패 시 대응)

---

## Design Intent (Jobs Tokens)

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
    "palette": {
      "dark_bg": "#111111",
      "light_bg": "#FFFFFF"
    },
    "structure": "dark-white*4-dark sandwich",
    "emoji_policy": "chips/headers only",
    "parallel_rule": "same-position text must match length and part-of-speech"
  }
}
```

---

## 규칙 체크리스트

- [ ] Slide 1 = 다크, Slides 2-5 = 라이트, Slide 6 = 다크
- [ ] 정확히 2개 선택지 (A, B) 서로 다른 색
- [ ] 정확히 6슬라이드 (추가/삭제 금지)
- [ ] 평행 텍스트 정렬 (같은 위치 = 같은 길이/품사)
- [ ] 단일 결론 (상황에 따라 금지)
- [ ] Operating rule 정의됨
- [ ] Recovery 계획 정의됨
