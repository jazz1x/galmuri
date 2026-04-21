# galmuri

> Claude Code 플러그인 — 맥락을 모으고, 정리하고, 갈무리한다

**galmuri** (갈무리) — 한국어 순우리말로 *"잘 거두어 간수한다 / 일을 마무리한다"*. 흩어진 맥락을 손실 투명성·증거 근거·의사결정 덱 템플릿으로 갈무리한다.

[English](./README.md)

## Install

Claude Code 실행 후:

```
/plugin marketplace add https://github.com/jazz1x/galmuri.git
/plugin install galmuri
```

선택 — 권장 훅 등록 (`.claude/settings.json` 에 HITL 머지):

```bash
bash scripts/install-hooks.sh          # project-level (기본)
bash scripts/install-hooks.sh --user   # user-level
```

## Skills

| Skill | Command | Role |
|-------|---------|------|
| **distill** | `/galmuri:distill` | 청자별 본질 추출 (톤·예시·부연 삭제, 주장만 유지) |
| **shrink** | `/galmuri:shrink` | 목표 토큰 비율로 압축 + 재시도 루프 + 손실 diff |
| **decide** | `/galmuri:decide` | 2지선택 결정 → 6슬라이드 Jobs-style 템플릿 (JSON + markdown, 바이너리 빌드 없음) |

각 스킬은 **독립 궤도**에서 동작하며, 오직 **공유 아티팩트 (파일)** 로만 연결된다.

```
distill ──→  docs/galmuri-{slug}.md        (본질 + 손실 bullets)
                ↓
shrink  ──→  docs/galmuri-{slug}.md        (목표 비율 압축 + 손실 diff)
                ↓
decide  ──→  docs/galmuri-decide-{slug}.json  (슬라이드 카피 + design_intent)
             docs/galmuri-decide-{slug}.md   (발표 스크립트 + 18 소크라테스 노트)

     └── .galmuri/ (자산 인덱스: audience, summary, decision-deck, evidence-trace)
```

## Usage

### 1. Distill (본질 추출)

```
User: /galmuri:distill
→ "청자는 누구입니까? (engineer / exec / 5-year-old / 자유 입력)"

User: "engineer, 5분 standup"
→ 원문 로드 → LLM 이 주장만 남기도록 추출 → LLM-as-judge 각 주장의 원문 근거 검증
→ markdown 출력: 본질 + "## 손실 bullet" (상위 3~5개, 우선순위대로)
→ HITL: "docs/galmuri-{slug}.md 에 저장할까요? (y / n / edit-slug)"
```

### 2. Shrink (목표 비율 압축)

```
User: /galmuri:shrink --target-ratio 0.2 --audience exec
→ 원문 토큰 수 측정 → source_tokens × 0.2 로 압축
→ |actual - target| > 5% 면 최대 2회 재시도
→ 미달 시: [a]ccept 현 비율 / [r]e-target 재지정 / [c]ancel
→ 압축 markdown + 토큰 비교 리포트 출력
→ 선택 --show-loss 시 문장 단위 diff
```

### 3. Decide (의사결정 덱 템플릿)

```
User: /galmuri:decide
→ 5단계 프로토콜: Phenomenon → Decomposition (D/E/V/R) → Essence → Generalization → Reconstruction
→ strict 모드는 D/E/V/R 이 서로 다른 주체여야 함
→ 소규모 팀: /galmuri:decide --weak-decomposition (동일 주체의 관점 분리)

출력: 2 템플릿 파일 (바이너리 빌드 없음)
  - {slug}.json  — 슬라이드 카피 + design_intent (Jobs 토큰)
  - {slug}.md    — 발표 스크립트 + 18 소크라테스 probe (Definition × Difference × Attribution)

Consumer 가 Keynote / PowerPoint / Figma / Slidev / Marp 로 렌더.
```

## Hooks

`hooks/recommended.json` 에 권장 훅이 정의되어 있다. `scripts/install-hooks.sh` 가 `.claude/settings.json` 에 HITL 충돌 해결과 함께 머지.

| Event | Trigger | What it does |
|-------|---------|--------------|
| `PreToolUse` | `docs/galmuri-*.md` Write | 저장 전 `evidence-check.sh` 구조 게이트 실행 |
| `PostToolUse` | galmuri 출력 Write/Edit | 출력을 `.galmuri/assets/` 에 자산으로 기록 |
| `UserPromptSubmit` | `갈무리 \| galmuri \| tldr \| 핵심만 \| 추려서` 매칭 | 해당 스킬 제안 힌트 주입 |
| `SessionStart` | 세션 시작 | 과거 자산에서 최근 청자 컨텍스트 주입 |

훅은 선택사항 — 모든 스킬은 훅 없이도 작동한다.

## Assets

모든 출력은 `.galmuri/assets/*.jsonl` 에 SHA-256 NFC 정규화 해시와 함께 기록된다. 5가지 자산 타입:

| Type | 기록 시점 |
|------|---------------|
| `summary` | distill/shrink 출력 저장 |
| `decision-deck` | decide 템플릿 생성 |
| `compression-pattern` | 반복 압축 비율 / 청자 패턴 감지 |
| `evidence-trace` | evidence-check 통과 (주장 → 원문 매핑) |
| `recovery-trace` | 소크라테스 probe Recovery 루프 발동 |

중복 제거 + 인덱스 재생성:

```bash
bash scripts/consolidate-assets.sh
```

과거 자산 조회 (스킬 Step 2 와 SessionStart 훅이 사용):

```bash
bash scripts/query-assets.sh --tags audience --limit 3 --format inject
```

`.galmuri/assets/` 와 `.galmuri/index.jsonl` 은 기본적으로 gitignored.

## Sibling Integration (optional)

galmuri 는 sibling 플러그인 상태가 존재하면 subtle 하게 참고하고, 없으면 silent skip 한다:

| Source | 읽는 시점 | 효과 |
|--------|-----------|--------|
| `.harnish/persona.json` | distill/shrink Step 1 | persona 기반 기본 청자 제안 (유저 `--audience` 우선) |
| `.harnish/assets/*.jsonl` | 모든 스킬 Step 2 | `harnish-bridge.sh` 경유 태그 기반 컨텍스트 주입 |
| `.honne/recent-reflection.md` | decide Step 1 | 결정과 관련된 회고 한 줄 힌트 |
| `.honne/persona.json` | distill/shrink Step 1 | `formality` / `verbosity` 만 반영 (다른 필드 무시) |

반영 결과는 반드시 유저에게 명시적으로 노출 (HITL `[a]ccept / [c]hange / [i]gnore`). 암묵적 톤 변경 없음.

## Fork & Customize

이 리포를 베이스로 쓰는 3가지 방법:

### A. 스킬 하나만 프로젝트에 직접 복사

```bash
mkdir -p .claude/skills
cp -r /path/to/galmuri/skills/distill .claude/skills/
```

`distill` 으로 호출 가능 (플러그인 네임스페이스 없음). `shrink` 또는 `decide` 로 대체 가능.

### B. 자체 플러그인 마켓으로 포크

```bash
gh repo fork jazz1x/galmuri --clone
cd galmuri
# .claude-plugin/plugin.json 편집 (name, author, repository)
# .claude-plugin/marketplace.json 편집 (owner, plugin entries)
git commit -am "fork: rebrand"
git push
```

### C. 읽기 전용 upstream 으로 사용

```bash
git clone https://github.com/jazz1x/galmuri.git
cd your-project
claude --plugin-dir /path/to/galmuri
git -C /path/to/galmuri pull   # 업데이트
```

## Naming

- **galmuri** (갈무리) = 모으고 + 정리하고 + 간수한다 (한국어 순우리말)
- **distill** = 톤·수사 제거, 결정을 바꾸는 주장만 유지
- **shrink** = 목표 비율 압축 + 손실 투명성
- **decide** = 2지 분기 → D/E/V/R 분해 → 6슬라이드 Jobs-style 덱

## Triad

galmuri 는 두 sibling 플러그인 사이에 위치한다 — 독립적이되 공유 아티팩트로만 연결:

```
harnish (make)  ──→  honne (know)  ──→  galmuri (keep)
  실행              성찰                갈무리
```

- [harnish](https://github.com/jazz1x/harnish) — 자율 구현 엔진
- [honne](https://github.com/jazz1x/honne) — 자기 성찰 (개발 중)

## Footnote

> *"압축은 손실이다. 잃은 것에 대한 침묵이 진짜 실패다."*

모든 galmuri 출력은 손실 diff 를 포함한다. 안 그러면 잘못 만든 도구다.

## License

MIT — [LICENSE](./LICENSE) 참조.
