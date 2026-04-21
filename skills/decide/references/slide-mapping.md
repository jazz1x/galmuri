# Slide Mapping — Structure Reference

> 6슬라이드 구조 및 Jobs 토큰 가이드.

## Slide 1: Problem (다크)

**구조**:
- 제목: 한 줄 질문 (큰 활자)
- 선택지: Option A / Option B (라벨)
- 맥락: 선택 배경 (짧은 문장)

**카피 예시**:
```
Monolith vs Microservices?

Option A: 단일 Repository
Option B: 분산 Repository

When should we refactor?
```

---

## Slide 2: Concept (라이트)

**구조**:
- 제목: 개념 이름
- 본문: 역사/배경/기본 원리
- 선택과의 관계: 왜 지금 이 선택인가

**카피 예시**:
```
Monoliths started first

- 단순성, 배포 용이
- Microservices = network complexity
- But systems grow; refactoring inevitable
```

---

## Slide 3: Comparison (라이트)

**구조**:
- A의 장점 | B의 장점
- A의 단점 | B의 단점
- 무게 축 한 줄 (옵션 간 근본 차이 — 이 슬라이드는 비교 축만 제시하고, 실제 trade-off 수용·판단은 Slide 5 "Trade-off" 에서 진행)

**카피 예시**:
```
Monolith Strengths: simple, fast deploy
Microservices Strengths: independent scaling, isolation

Monolith Drawback: coupling grows
Microservices Drawback: network latency, operational complexity
```

---

## Slide 4: Examples (라이트)

**구조**:
- A 선택 시나리오 (구체적 결과)
- B 선택 시나리오 (구체적 결과)
- 비교 가능한 기준

**카피 예시**:
```
If Monolith: Single deploy, 1 database, unified monitoring

If Microservices: 5 services, API gateway, distributed tracing, 5 databases
```

---

## Slide 5: Trade-off (라이트)

**구조**:
- 최우선 가치 (조직의 1순위)
- 이차 가치 (차선택)
- 가중치에 따른 각 선택지의 위치

**카피 예시**:
```
Primary: Scaling ability
Secondary: Deployment simplicity

Monolith: Fails on scaling (0/10), Excels on simplicity (9/10)
Microservices: Excels on scaling (9/10), Needs complexity mgmt (5/10)
```

---

## Slide 6: Conclusion (다크)

**구조**:
- 단일 결론 (A 또는 B, "상황에 따라" 금지)
- Operating Rule (결정 운영 원칙)
- Recovery (실패 시 대응)

**카피 예시**:
```
Go Microservices for growth > 5M DAU

Operating Rule:
- Start with 3-service core
- Async-first communication
- Monthly scalability review

Recovery:
If latency > 200ms, add caching layer
```

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

## Rules Checklist

- [ ] Slide 1 = dark, Slides 2-5 = light, Slide 6 = dark
- [ ] Exactly 2 options (A, B) with distinct colors
- [ ] Exactly 6 slides (no add/remove)
- [ ] Parallel text alignment (same position = same length/POS)
- [ ] Single conclusion (no "depends" phrases)
- [ ] Operating rule defined
- [ ] Recovery plan defined
