# galmuri

> Claude Code plugin — gather, organize, and keep context

![version](https://img.shields.io/badge/version-0.1.0-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![claude-code](https://img.shields.io/badge/claude--code-plugin-purple)

**galmuri** (갈무리) — Korean for *"gathering, organizing, and storing with care."* Turns sprawling context into well-kept summaries with explicit loss transparency, evidence grounding, and a deck template engine.

[한국어](./README.ko.md)

## Architecture

galmuri is organized as **one engine + four adapters**:

```
                    ┌─────────────────────────────────┐
                    │         distill (engine)         │
                    │  reduce · ratio · socratic probe │
                    └───────────────┬─────────────────┘
                                    │ EngineOutput JSON
              ┌─────────┬───────────┼───────────┬─────────┐
              ▼         ▼           ▼           ▼         ▼
           explain    pitch        doc         deck
          (inline)  (3-5 lines)  (file)    (JSON+md)

                              deck presets
                    ┌──────────────────────────────────┐
                    │ decision-sandwich-6  pitch-deck   │
                    │ concept-explain      story-arc    │
                    └──────────────────────────────────┘
```

| Skill | Role | Output |
|-------|------|--------|
| **distill** | Extract essence — audience-tuned, D/E/V/R decomposition, Socratic probe | EngineOutput JSON (internal) |
| **explain** | Inline markdown summary for the author (`audience=me` auto-fixed) | stdout only |
| **pitch** | Hook-Core-CTA in 3–5 lines for a named audience | stdout only |
| **doc** | Distilled markdown saved to `docs/` | `docs/galmuri-doc-{slug}.md` |
| **deck** | Structured slide copy (JSON + markdown) using Jobs-inspired design tokens | `galmuri-deck-{slug}.json` + `galmuri-deck-{slug}.md` |

## Install

### 1. Register the marketplace

Inside a Claude Code session, run:

```
/plugin marketplace add https://github.com/jazz1x/galmuri.git
```

### 2. Install the plugin

```
/plugin install galmuri
```

Expected output:

```
✓ Installed galmuri@0.1.0 — 5 skills registered (distill, explain, pitch, doc, deck)
```

### 3. Verify

```
/plugin list
```

All five slash commands should autocomplete:

```
/galmuri:distill
/galmuri:explain
/galmuri:pitch
/galmuri:doc
/galmuri:deck
```

### 4. (Optional) Install hooks

galmuri ships optional hooks that add evidence gates, asset recording, prompt hints, and session context injection. They are **opt-in** — all skills work without them.

Project-level (recommended — scopes hooks to this repo only):

```bash
bash scripts/install-hooks.sh
# writes → .claude/settings.json   (backup: .claude/settings.json.bak-<epoch>)
```

User-level (apply globally to every project):

```bash
bash scripts/install-hooks.sh --user
# writes → ~/.claude/settings.json
```

See the [Hooks](#hooks) section for what each hook does.

### 5. Uninstall

```
/plugin uninstall galmuri
/plugin marketplace remove galmuri
```

---

## Quickstart

Just invoke the adapter. It asks what it needs in plain language.

**explain** — quick inline summary (no file created):
```
user    > /galmuri:explain path/to/long-doc.md
galmuri > [distill → inline markdown output]
```

**pitch** — 3–5 line pitch for a specific audience:
```
user    > /galmuri:pitch
galmuri > 누구를 위한 pitch 인가요? 예: 투자자, 팀, 고객
user    > 팀 전체 스프린트 킥오프용
galmuri > [Hook-Core-CTA, 3–5 lines]
```

**doc** — distilled markdown saved to file:
```
user    > /galmuri:doc path/to/source.md
galmuri > 누구를 위한 문서인가요? 예: 팀 전체, 나중의 나, 외부 리뷰어
user    > 나중의 나
galmuri > Save to docs/galmuri-doc-source.md? (y / n / edit-slug)
user    > y
✓ Saved · asset recorded in .galmuri/
```

**deck** — structured slide copy:
```
user    > /galmuri:deck
galmuri > 어떤 내용을 슬라이드로 만들까요?
user    > Postgres vs SQLite 마이그레이션 결정
galmuri > [decision-sandwich-6 preset auto-applied]
          → galmuri-deck-postgres-vs-sqlite.json
          → galmuri-deck-postgres-vs-sqlite.md
```

## Usage

### distill (engine)

Produces EngineOutput JSON consumed by adapters. Direct invocation useful for piping or scripting.

```
/galmuri:distill path/to/source.md --audience exec --ratio 0.2
```

Flags: `--mode reduce`, `--ratio`, `--audience`, `--weak-decomposition`, `--input`

### explain (adapter)

Inline summary for the author. No file created, no audience query.

```
/galmuri:explain path/to/source.md
```

Natural language triggers: `설명해`, `이해하게`, `정리해서 보여줘`, `readme 읽고`

### pitch (adapter)

3–5 line Hook-Core-CTA for a named audience.

```
/galmuri:pitch path/to/source.md --audience investor
```

Natural language triggers: `pitch 해`, `한 문단으로`, `소개해줘`

### doc (adapter)

Distilled markdown saved to `docs/galmuri-doc-{slug}.md`.

```
/galmuri:doc path/to/source.md --audience team
```

Natural language triggers: `문서로`, `정리해서 저장`, `기록으로`

### deck (adapter)

Structured slide copy — Jobs-inspired design tokens (SF Pro, 16:9, dark-light-dark pattern), rendered as JSON + markdown. No binary file build.

```
/galmuri:deck path/to/source.md --preset decision-sandwich-6
```

Presets:

| Preset | Slides | Use case |
|--------|--------|----------|
| `decision-sandwich-6` | 6 | Two-option decision with D/E/V/R decomposition |
| `pitch-deck` | 3 | Short investor or team pitch |
| `concept-explain` | 4–5 | Concept introduction |
| `story-arc` | varies | Narrative-structured content |

Natural language triggers: `슬라이드로`, `deck 만들어`, `발표자료`

## Backwards Compatibility

`decide` and `shrink` trigger phrases are routed to context-appropriate adapters in 0.1.x. They will be **removed in 0.2.0**.

| Old trigger | Routes to |
|-------------|-----------|
| `decide`, `결정` | `deck --preset decision-sandwich-6` |
| `shrink`, `줄여줘`, `압축` | `explain` (short source) or `doc` (long source) |

A one-time deprecation warning fires per session on first use of the old trigger.

## Contributing

This repo ships a pre-commit guardrail at `.githooks/pre-commit` that blocks runtime artifacts, validates plugin JSON, checks README heading parity between `README.md` and `README.ko.md`, and runs the full `tests/` suite when `bats` is installed. Git does not auto-install repo hooks — enable once per clone:

```bash
git config core.hooksPath .githooks
```

Run tests directly:

```bash
bash tests/run.sh   # requires bats-core + python3
```

CI runs the same suite on ubuntu + macos via `.github/workflows/tests.yml`.

## Hooks

galmuri ships recommended hooks in `hooks/recommended.json`. `scripts/install-hooks.sh` merges them into `.claude/settings.json` with HITL conflict resolution.

| Event | Trigger | What it does |
|-------|---------|--------------|
| `PreToolUse` | Any skill invocation | Captures source to `.galmuri/tmp/` |
| `PostToolUse` | Write/Edit of galmuri outputs | Records the output as an asset in `.galmuri/` |
| `UserPromptSubmit` | Prompt matches skill trigger phrases | Injects a hint routed to the matching adapter |
| `SessionStart` | Session begins | Injects recent audience context from past assets |

Hooks are opt-in — all skills work without them.

## Assets

Every output is recorded in `.galmuri/*.jsonl` with metadata. Asset types:

| Type | Captured when |
|------|---------------|
| `summary` | distill/explain/doc output |
| `deck` | deck template built |
| `pitch` | pitch output |
| `evidence-trace` | evidence-check passes |

Query past assets:

```bash
bash scripts/query-assets.sh --tags audience --limit 3 --format inject
```

`.galmuri/` is gitignored by default.

## Sibling Integration (optional)

galmuri reads sibling plugin state when present, silently skips when absent:

| Source | When read | Effect |
|--------|-----------|--------|
| `.harnish/persona.json` | distill Step 1 | Suggests default audience from persona |
| `.honne/persona.json` | distill Step 1 | Reflects `formality` / `verbosity` only |

## Naming

- **galmuri** (갈무리) = gather + organize + keep (Korean native word)
- **distill** = remove tone and scaffolding, keep only claims that change decisions
- **explain** = inline, self-directed summary (audience=me)
- **pitch** = concise Hook-Core-CTA for a named audience
- **doc** = distilled document saved to file
- **deck** = structured slide copy with Jobs-inspired design tokens

## Triad

galmuri sits between two sibling plugins — independent, connected by shared artifacts only:

```
harnish (make)  ──→  honne (know)  ──→  galmuri (keep)
  execution         reflection          refinement
```

- [harnish](https://github.com/jazz1x/harnish) — autonomous implementation engine
- [honne](https://github.com/jazz1x/honne) — evidence-backed self-reflection (6-axis persona)
- [galmuri](https://github.com/jazz1x/galmuri) — summary · deck · documentation

## Footnote

> *"Compression is lossy. Silence about what was lost is the actual failure."*

Every galmuri output includes a loss diff. If it doesn't, we built the wrong tool.

## License

MIT — See [LICENSE](./LICENSE).
