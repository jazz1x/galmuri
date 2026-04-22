# Socratic Probe — 문항 템플릿

> N units × 3축 (Definition / Difference / Attribution) = 3N 문항
> (deck preset 의 경우 N = core_length + 2, 그 외 어댑터는 N = units.length)

## 검증 로직

각 문항은 2축으로 판정:

- **answerable**: claim/unit 텍스트만으로 답변 가능한가? (Y/N)
- **explicit**: 답이 claim/unit 에 명시적으로 적혀있는가? (Y/N)

**통과 조건**: `answerable=Y AND explicit=Y`.

**실패 시 복귀**:

| 실패한 축 | 복귀 단계 |
|---|---|
| Definition 실패 | Step 2 (Decomposition) |
| Difference 실패 | Step 3 (Essence) |
| Attribution 실패 | Step 5 (Reconstruction) |

---

## Unit · Problem

- **Q1 Definition**: 이 claim/unit 의 한 줄 핵심 질문은?
- **Q2 Difference**: 지금 고르는 것은 X인가 Y인가?
- **Q3 Attribution**: 이 결정의 책임자는?

## Unit · Concept

- **Q1 Definition**: 역할 A를 한 문장으로 정의하면?
- **Q2 Difference**: A와 B의 경계는 어디인가?
- **Q3 Attribution**: 이 행동은 A인가 B인가?

## Unit · Comparison

- **Q1 Definition**: 무게 축은 무엇인가?
- **Q2 Difference**: 옵션1과 옵션2의 실제 차이는?
- **Q3 Attribution**: 이 축에서 우리가 더 중시하는 것은?

## Unit · Examples

- **Q1 Definition**: 이 claim/unit 에서 분해는 어떻게 적용되는가?
- **Q2 Difference**: 이 claim/unit 은 다른 것과 구조가 같은가?
- **Q3 Attribution**: 이 claim/unit 에서 실행은 누가 하는가?

## Unit · Trade-off

- **Q1 Definition**: 우리가 잃는 것은?
- **Q2 Difference**: 한쪽의 장점이 다른 쪽의 약점이 되는가?
- **Q3 Attribution**: 무엇을 양보할 수 있는가?

## Unit · Conclusion

- **Q1 Definition**: 결론을 한 문장으로?
- **Q2 Difference**: 다른 선택지와 무엇이 다른가?
- **Q3 Attribution**: Recovery는 누가 책임지는가?
