# galmuri

> Claude Code 플러그인 — 맥락을 모으고, 정리하고, 갈무리한다

![version](https://img.shields.io/badge/version-0.1.0-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![claude-code](https://img.shields.io/badge/claude--code-plugin-purple)

**galmuri** (갈무리) — 한국어 순우리말로 *"잘 거두어 간수한다 / 일을 마무리한다"*. 흩어진 맥락을 손실 투명성·증거 근거·덱 템플릿 엔진으로 갈무리한다.

[English](./README.md)

## 아키텍처

galmuri 는 **엔진 1개 + 어댑터 4개** 구조:

```
                    ┌─────────────────────────────────┐
                    │         distill (엔진)            │
                    │  reduce · ratio · 소크라테스 probe │
                    └───────────────┬─────────────────┘
                                    │ EngineOutput JSON
              ┌─────────┬───────────┼───────────┬─────────┐
              ▼         ▼           ▼           ▼         ▼
           explain    pitch        doc         deck
          (인라인)  (3-5줄)     (파일)     (JSON+md)

                              deck 프리셋
                    ┌──────────────────────────────────┐
                    │ decision-sandwich-6  pitch-deck   │
                    │ concept-explain      story-arc    │
                    └──────────────────────────────────┘
```

| Skill | 역할 | 출력 |
|-------|------|--------|
| **distill** | 본질 추출 — 청자 맞춤, D/E/V/R 분해, 소크라테스 probe | EngineOutput JSON (내부) |
| **explain** | 작성자용 인라인 markdown 요약 (`audience=me` 자동 고정) | stdout 전용 |
| **pitch** | 지정 청자를 위한 Hook-Core-CTA 3–5줄 | stdout 전용 |
| **doc** | 정제된 markdown → `docs/` 저장 | `docs/galmuri-doc-{slug}.md` |
| **deck** | Jobs-inspired 디자인 토큰 기반 슬라이드 카피 (JSON + markdown) | `galmuri-deck-{slug}.json` + `galmuri-deck-{slug}.md` |

## 설치

### 1. 마켓플레이스 등록

Claude Code 세션 안에서 실행:

```
/plugin marketplace add https://github.com/jazz1x/galmuri.git
```

### 2. 플러그인 설치

```
/plugin install galmuri
```

예상 출력:

```
✓ Installed galmuri@0.1.0 — 5 skills registered (distill, explain, pitch, doc, deck)
```

### 3. 확인

```
/plugin list
```

아래 슬래시 명령 5개가 자동완성되면 정상:

```
/galmuri:distill
/galmuri:explain
/galmuri:pitch
/galmuri:doc
/galmuri:deck
```

### 4. (선택) 훅 설치

galmuri 는 선택적 훅을 제공한다 — 증거 게이트, 자산 기록, 프롬프트 힌트, 세션 컨텍스트 주입. 훅 없이도 모든 스킬은 동작한다.

프로젝트 범위 (권장 — 해당 레포에만 적용):

```bash
bash scripts/install-hooks.sh
# → .claude/settings.json 에 병합 (백업: .claude/settings.json.bak-<epoch>)
```

유저 범위 (모든 프로젝트에 전역 적용):

```bash
bash scripts/install-hooks.sh --user
# → ~/.claude/settings.json 에 병합
```

### 5. 제거

```
/plugin uninstall galmuri
/plugin marketplace remove galmuri
```

---

## 빠른 시작

어댑터를 호출하면 필요한 것을 자연어로 물어본다.

**explain** — 빠른 인라인 요약 (파일 생성 없음):
```
user    > /galmuri:explain path/to/long-doc.md
galmuri > [distill → 인라인 markdown 출력]
```

**pitch** — 지정 청자용 3–5줄 pitch:
```
user    > /galmuri:pitch
galmuri > 누구를 위한 pitch 인가요? 예: 투자자, 팀, 고객
user    > 팀 전체 스프린트 킥오프용
galmuri > [Hook-Core-CTA, 3–5줄]
```

**doc** — 정제된 markdown 파일 저장:
```
user    > /galmuri:doc path/to/source.md
galmuri > 누구를 위한 문서인가요? 예: 팀 전체, 나중의 나, 외부 리뷰어
user    > 나중의 나
galmuri > docs/galmuri-doc-source.md 에 저장? (y / n / edit-slug)
user    > y
✓ 저장됨 · 자산 기록 .galmuri/
```

**deck** — 구조화 슬라이드 카피:
```
user    > /galmuri:deck
galmuri > 어떤 내용을 슬라이드로 만들까요?
user    > Postgres vs SQLite 마이그레이션 결정
galmuri > [decision-sandwich-6 프리셋 자동 적용]
          → galmuri-deck-postgres-vs-sqlite.json
          → galmuri-deck-postgres-vs-sqlite.md
```

## Usage

### distill (엔진)

어댑터가 소비하는 EngineOutput JSON 생성. 파이프 / 스크립트 연동에 유용.

```
/galmuri:distill path/to/source.md --audience exec --ratio 0.2
```

플래그: `--mode reduce`, `--ratio`, `--audience`, `--weak-decomposition`, `--input`

### explain (어댑터)

작성자용 인라인 요약. 파일 생성 없음, 청자 질의 없음.

```
/galmuri:explain path/to/source.md
```

자연어 트리거: `설명해`, `이해하게`, `정리해서 보여줘`, `readme 읽고`

### pitch (어댑터)

지정 청자를 위한 Hook-Core-CTA 3–5줄.

```
/galmuri:pitch path/to/source.md --audience investor
```

자연어 트리거: `pitch 해`, `한 문단으로`, `소개해줘`

### doc (어댑터)

정제된 markdown → `docs/galmuri-doc-{slug}.md` 저장.

```
/galmuri:doc path/to/source.md --audience team
```

자연어 트리거: `문서로`, `정리해서 저장`, `기록으로`

### deck (어댑터)

Jobs-inspired 디자인 토큰 (SF Pro, 16:9, dark-light-dark 패턴) 기반 슬라이드 카피 — JSON + markdown. 이진 파일 생성 없음.

```
/galmuri:deck path/to/source.md --preset decision-sandwich-6
```

프리셋:

| 프리셋 | 슬라이드 | 용도 |
|--------|--------|----------|
| `decision-sandwich-6` | 6 | D/E/V/R 분해를 활용한 2지선택 결정 |
| `pitch-deck` | 3 | 투자자/팀 단거리 pitch |
| `concept-explain` | 4–5 | 개념 소개 |
| `story-arc` | 가변 | 내러티브 구성 콘텐츠 |

자연어 트리거: `슬라이드로`, `deck 만들어`, `발표자료`

## 하위 호환성

`decide` 와 `shrink` 트리거는 0.1.x 에서 문맥에 맞는 어댑터로 라우팅된다. **0.2.0 에서 제거** 예정.

| 구 트리거 | 라우팅 대상 |
|-------------|-----------|
| `decide`, `결정` | `deck --preset decision-sandwich-6` |
| `shrink`, `줄여줘`, `압축` | `explain` (짧은 원문) 또는 `doc` (긴 원문) |

구 트리거 최초 사용 시 세션당 1회 deprecation 경고 출력.

## Contributing

이 레포는 `.githooks/pre-commit` 에 가드레일 훅을 둔다 — 런타임 산출물 차단, 플러그인 JSON 검증, `README.md` ↔ `README.ko.md` 헤딩 동기화 확인, `bats` 설치 시 `tests/` 전체 실행. Git 은 레포 훅을 자동 설치하지 않으므로 클론당 한 번 활성화:

```bash
git config core.hooksPath .githooks
```

테스트 직접 실행:

```bash
bash tests/run.sh   # bats-core + python3 필요
```

ubuntu + macos 에서 `.github/workflows/tests.yml` 로 동일 suite 가 CI 실행된다.

## Hooks

`hooks/recommended.json` 에 권장 훅이 정의되어 있다. `scripts/install-hooks.sh` 가 `.claude/settings.json` 에 HITL 충돌 해결과 함께 머지.

| Event | Trigger | 역할 |
|-------|---------|--------------|
| `PreToolUse` | 스킬 호출 | 소스를 `.galmuri/tmp/` 에 캡처 |
| `PostToolUse` | galmuri 출력 Write/Edit | 출력을 `.galmuri/` 에 자산으로 기록 |
| `UserPromptSubmit` | 스킬별 트리거 매칭 | 매칭된 어댑터로 라우팅된 힌트 주입 |
| `SessionStart` | 세션 시작 | 과거 자산에서 최근 청자 컨텍스트 주입 |

훅은 선택사항 — 모든 스킬은 훅 없이도 작동한다.

## Assets

모든 출력은 `.galmuri/*.jsonl` 에 메타데이터와 함께 기록된다.

| Type | 기록 시점 |
|------|---------------|
| `summary` | distill/explain/doc 출력 |
| `deck` | deck 템플릿 생성 |
| `pitch` | pitch 출력 |
| `evidence-trace` | evidence-check 통과 |

과거 자산 조회:

```bash
bash scripts/query-assets.sh --tags audience --limit 3 --format inject
```

`.galmuri/` 는 기본적으로 gitignored.

## Sibling Integration (optional)

galmuri 는 sibling 플러그인 상태가 존재하면 참고하고, 없으면 silent skip 한다:

| Source | 읽는 시점 | 효과 |
|--------|-----------|--------|
| `.harnish/persona.json` | distill Step 1 | persona 기반 기본 청자 제안 |
| `.honne/persona.json` | distill Step 1 | `formality` / `verbosity` 만 반영 |

## Naming

- **galmuri** (갈무리) = 모으고 + 정리하고 + 간수한다 (한국어 순우리말)
- **distill** = 톤·수사 제거, 결정을 바꾸는 주장만 유지
- **explain** = 인라인, 작성자 직접 이해용 요약 (audience=me)
- **pitch** = 지정 청자를 위한 간결한 Hook-Core-CTA
- **doc** = 정제된 문서 파일로 저장
- **deck** = Jobs-inspired 디자인 토큰 기반 슬라이드 카피

## Triad

galmuri 는 두 sibling 플러그인 사이에 위치한다 — 독립적이되 공유 아티팩트로만 연결:

```
harnish (make)  ──→  honne (know)  ──→  galmuri (keep)
  실행              성찰                갈무리
```

- [harnish](https://github.com/jazz1x/harnish) — 자율 구현 엔진
- [honne](https://github.com/jazz1x/honne) — 증거 기반 자기 성찰 (6축 persona)
- [galmuri](https://github.com/jazz1x/galmuri) — 요약 · 덱 · 문서화

## Footnote

> *"압축은 손실이다. 잃은 것에 대한 침묵이 진짜 실패다."*

모든 galmuri 출력은 손실 diff 를 포함한다. 안 그러면 잘못 만든 도구다.

## License

MIT — [LICENSE](./LICENSE) 참조.
