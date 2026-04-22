# 제1원칙 분해 — D/E/V/R 역할 가이드

## 역할 정의

- **D (Decision)**: 결정을 내리는 주체. "누가 이 명제를 받아들이거나 거부할 권한이 있는가?"
- **E (Execution)**: 실행·집행하는 주체. "누가 이 명제를 실제 행동으로 옮기는가?"
- **V (Validation)**: 검증·측정하는 주체. "누가 이 명제의 결과가 맞는지 확인하는가?"
- **R (Recovery)**: 실패 시 복구·회복하는 주체. "누가 이 명제가 실패했을 때 원상복구하는가?"

## 역할 식별 질문 템플릿 (claim 1개당 4 질문 순차 적용)

```
주어진 claim: "{claim}"
Q_D: 이 claim 을 승인/거부할 수 있는 주체는 누구인가?
Q_E: 이 claim 을 실행하는 주체는 누구인가?
Q_V: 이 claim 의 결과를 검증하는 주체는 누구인가?
Q_R: 이 claim 이 실패하면 복구 책임을 지는 주체는 누구인가?
```

## Strict vs Weak 모드

### Strict 모드 (기본)

4 역할의 subject 가 모두 **distinct** 해야 PASS.
두 역할이 같은 subject 를 공유하면 분해 실패 — claim 재정제 필요.

### Weak 모드 (`--weak-decomposition`)

subject 중복 허용. 각 역할은 `"{subject} :: {perspective}"` 형태로 동일 주체의 다른 관점을 표현.

`EssenceUnit.decomposition.weak: true` 플래그 설정 필수.

---

## 예시

### Strict 예시

```json
{
  "claim": "코드 리뷰는 4시간 내 완료한다",
  "decomposition": {
    "role_D": "팀 리드",
    "role_E": "리뷰 할당 개발자",
    "role_V": "CI 파이프라인",
    "role_R": "당직 엔지니어"
  }
}
```

### Weak 예시

```json
{
  "claim": "1인 스타트업은 MVP 를 2주 내 배포한다",
  "decomposition": {
    "weak": true,
    "role_D": "창업자 :: 기능 scope 결정 관점",
    "role_E": "창업자 :: 코딩/배포 관점",
    "role_V": "창업자 :: 사용자 반응 관측 관점",
    "role_R": "창업자 :: 장애 대응 관점"
  }
}
```
