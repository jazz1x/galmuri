# First-Principle Decomposition — D/E/V/R Role Guide

## Role Definitions

- **D (Decision)**: The entity that accepts or rejects this claim. "Who has authority to approve or refuse this proposition?"
- **E (Execution)**: The entity that carries out the claim. "Who actually acts on this proposition?"
- **V (Validation)**: The entity that verifies the result. "Who confirms whether the outcome of this proposition is correct?"
- **R (Recovery)**: The entity responsible for restoration on failure. "Who restores the original state when this proposition fails?"

## Role Identification Questions (apply per claim)

```
Given claim: "{claim}"
Q_D: Who is the entity that can approve or reject this claim?
Q_E: Who is the entity that executes this claim?
Q_V: Who is the entity that verifies the result of this claim?
Q_R: Who is the entity that owns recovery if this claim fails?
```

## Strict vs Weak Modes

### Strict Mode (default)

All four role subjects must be **distinct** entities to PASS.
If any two roles share the same subject, the decomposition fails — return to refine the claim.

### Weak Mode (`--weak-decomposition`)

Subject overlap is allowed. Each role entry uses `"{subject} :: {perspective}"` format to express the different perspectives of the same subject.

Set `EssenceUnit.decomposition.weak: true` when using weak mode.

---

## Examples

### Strict Example

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

### Weak Example

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
