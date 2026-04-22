# pitch — Hook-Core-CTA 프롬프트 규칙

## 구조

최종 출력은 **총 3~5줄**:

### Hook (정확히 1줄)
- 청자의 현재 상황을 찌르는 질문 또는 반전.
- 30자 이내.
- 평서문 금지 — 의문형 또는 감탄형.

### Core (1~2줄)
- 단일 claim + 근거 1개. 각 줄 50자 이내.
- 나열형 금지 (1개 핵심만).

### CTA (정확히 1줄)
- 행동 또는 판단 요청. 명령형 또는 의문형. 30자 이내.

### 선택 강조 줄 (최대 1줄 추가)
- core 를 날카롭게 만드는 대비 문장. 5줄 cap 에 포함.

## 톤
- 청자가 해당 분야 초보자여도 이해 가능: 전문 용어 사용 시 괄호 설명 동반.
- 군더더기·회피·모호한 표현 없음.

## 참조
- distill 출력은 `skills/distill/references/essence-schema.json` 준수 — `units[0].claim` 을 core claim 원천으로 사용.
- `skills/distill/references/socratic_probe.md` 또는 `decomposition.md` 본문 복제 금지 — 파일 경로 참조만.
