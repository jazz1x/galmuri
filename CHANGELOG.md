# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.3] — 2026-05-07

Audit follow-up: every SKILL adopts the SSL (Scheduling-Structural-Logical) frontmatter contract, deck triggers narrow to resolve a collision with `harnish:forki`, and pitch's routing rule clarifies that `ratio` is inferred — not a user-input variable.

### Added

- **SSL frontmatter on all 5 skills**: every `SKILL.md` and `SKILL.ko.md` now declares an `ssl:` block with `scheduling.anti_triggers`, `structural.scenes`, `structural.resumable`, `logical.tools`, `logical.side_effects` (reads/writes/deletes/network), `logical.idempotent`, and `logical.rollback`. Surfaces the side-effect contract for static auditors and downstream consumers.
- **+8 regression tests** (83 → 91): `ssl:` block presence, idempotent boolean type, scheduling.anti_triggers presence, en/ko parity for technical fields (scenes/tools/side_effects/idempotent), deck description triggers do not claim decide/의사결정/결정해, pitch ratio-inference disclaimer is pinned in body.

### Changed

- **deck triggers narrowed**: `decide`, `의사결정`, `결정해` removed from the deck adapter's description. These were ambiguous with `harnish:forki` (verbatim `decide` collision + `결정해⊃결정` substring match). Remaining triggers: `덱`, `슬라이드`, `deck`, `발표 자료`, `A vs B`, `뭐가 나아`.
- **deck Step 1 simplified**: dropped the deprecation-warning bash block since the deprecated triggers are gone. Heading became `Step 1: Preset selection (required)`.
- **pitch Step 1 prose**: added a one-line note that `ratio` in routing rules is inferred from natural-language signal ("한 줄"/"TL;DR"/"one line"), not a user-input variable. The hardcoded `--ratio 0.08` is in Step 2.
- **explain forbidden-words test scoped to body**: the test now greps the body only (after the second `---`). Frontmatter `ssl:` blocks may legitimately mention `writes:` as part of the `side_effects` schema.

### Removed

- **`decide` / `의사결정` / `결정해` deprecation aliases on deck.** These had been routed to `deck --preset decision-sandwich-6` since 0.0.1 with a one-time per-session warning. Users invoking decision-style prompts should now use `harnish:forki` for binary decision forcing, or call `deck --preset decision-sandwich-6` explicitly when slides are the intended deliverable. README and CHANGELOG references updated.

### Fixed

- **distill `rm -f` was undeclared**: Step 1 + Step 5 delete `.galmuri/tmp/retry-count.{slug}` but the frontmatter never declared it. Now in `ssl.logical.side_effects.deletes`.
- **doc/deck non-idempotency was undeclared**: re-runs append duplicate asset records (test `e2e.bats:433` confirms dedup is intentionally not enforced at record time). Now declared as `ssl.logical.idempotent: false` with the manual `record-asset.sh` recovery path documented in `rollback`.

## [0.0.2] — 2026-05-01

Documentation, install ergonomics, and adapter clarity. No behavior changes.

### Added

- **skills.sh install path**: `npx skills add jazz1x/galmuri` works alongside the existing `/plugin marketplace add` flow (Claude Code, Cursor, Codex, Windsurf, and 40+ other agents). Documented in both READMEs.
- **Regression tests** (73 → 83): Skill-tool delegation pin, prose-routing pin (no `bc`), PostToolUse auto-execution pin, plus six edge-case e2e tests (empty files, duplicate-hash records, empty index, diff-loss boundaries).

### Changed

- **English-base SKILL.md**: All five SKILL.md frontmatter descriptions and bodies are now English. Korean trigger phrases are preserved in the description so auto-invocation on Korean still fires; full Korean prose remains in `SKILL.ko.md`.
- **pitch routing**: Step 1 routing replaced inline `count-tokens.sh + bc` subprocess pair with prose rules. No external dependencies in adapter routing.
- **explain Step 2**: Promoted Skill-tool delegation to a first-class instruction (was a blockquote note).
- **doc Step 5**: Clarifies that the `PostToolUse` hook (`asset-record.sh`) runs automatically; manual `record-asset.sh` invocation is the fallback path only.

### Fixed

- **marketplace.json description**: Was Korean while `plugin.json` was English; both now English.

## [0.0.1] — 2026-04-28

Initial release. Engine/adapter architecture, bilingual support, hooks pipeline, asset tracking, and full test suite.

### Added

- **Engine/adapter architecture**: `distill` is the shared engine producing EngineOutput JSON, consumed by four adapters (`explain`, `pitch`, `doc`, `deck`).

- **explain adapter**: Inline markdown summary for the author. `audience=me` auto-fixed, no file created, no audience query.

- **pitch adapter**: Hook-Core-CTA structure in 3–5 lines for a named audience. Auto-routes `shrink` triggers based on token count.

- **doc adapter**: Distilled markdown saved to `docs/galmuri-doc-{slug}.md` with audience selection and asset recording.

- **deck adapter**: Structured slide copy (JSON + markdown) using Jobs-inspired design tokens (SF Pro, 16:9, dark-light-dark sandwich pattern). No binary file build.

- **Four deck presets**: `decision-sandwich-6` (6-slide two-option decision), `pitch-deck` (3-slide), `concept-explain` (4–5 slides), `story-arc` (variable-length narrative).

- **EngineOutput JSON schema** (`skills/distill/references/essence-schema.json`): JSON Schema draft-07 for `EssenceUnit` and top-level fields.

- **Utility scripts**:
  - `count-tokens.sh`: tiktoken support + word-count fallback; outputs `{"tokens": N, "chars": N, "lines": N}`
  - `evidence-check.sh`: byte-consistent source/output size comparison (`wc -c`); `--require-smaller` mode
  - `diff-loss.sh`: quantifies information loss; covers Western and Korean sentence boundaries (`다/요/죠/네/군` end-word markers)
  - `record-asset.sh`: SHA-256 NFC-normalized asset recording
  - `query-assets.sh`: reads `assets/*.jsonl` directly; falls back to `index.jsonl`
  - `consolidate-assets.sh`: deduplicate assets into `index.jsonl`
  - `parse-ratio.sh`: natural language + numeric ratio parsing; normalises `0.50` → `0.5`; supports `"core only"`, `"one line"`, `"tl;dr"`
  - `validate-essence.sh`: EngineOutput JSON schema validation with ratio bounds check (0.05–0.5)
  - `preflight.sh`: runtime prerequisites (jq, bash, bats); exit 3 on missing dep
  - `i18n-sync-check.sh`: fence-aware heading parity check between `.md` and `.ko.md` files
  - `install-hooks.sh`: merges recommended hooks into settings.json with conflict resolution

- **Hooks** (opt-in, installed via `install-hooks.sh`):
  - `PreToolUse/Write` → `pre-write.sh`: validates source evidence before writing a galmuri output file
  - `PostToolUse/Write|Edit` → `post-write.sh`, `asset-record.sh`: records output as asset; cleans source from `.galmuri/tmp/`
  - `UserPromptSubmit` → `prompt-hint.sh`, `source-capture.sh`: routes skill-trigger phrases to the matching adapter; captures user prompt to `.galmuri/tmp/`
  - `SessionStart` → `session-start.sh`: injects 3 most recent assets as session context

- **Deprecation alias routing**: `decide`/`shrink` trigger phrases route to context-appropriate adapters. One-time session-scoped warning via `.galmuri/tmp/.warned-{alias}`.

- **Bilingual support**: Full English/Korean interface, skill docs, and prompts.

- **Asset tracking**: Automatic recording in `.galmuri/assets/*.jsonl`; deduplicated via SHA-256 NFC-normalized hash.

- **Plugin manifest**:
  - `.claude-plugin/plugin.json`: skill registration
  - `.claude-plugin/marketplace.json`: marketplace listing

- **Test suite** (`tests/`):
  - `e2e.bats`: 26 end-to-end tests covering the full pipeline without an LLM
  - `manifest.bats`: hook shim existence, count-tokens JSON format, hook matcher validity
  - `scripts.bats`: parse-ratio, validate-essence, preflight unit tests
  - `skills.bats`: SKILL.md structure, i18n heading parity, skill contracts

### Design Decisions

- **No binary rendering**: `deck` outputs JSON + markdown templates only. Consumers render with Keynote, PowerPoint, Figma, Slidev, Marp, etc.

- **LLM-as-judge**: Distill uses self-judge to validate claims against source. Decision deck applies a Socratic probe (18 questions, 3 per slide — Definition/Difference/Attribution).

- **Asset deduplication**: SHA-256 NFC-normalized hash prevents duplicate recording across sessions.

- **Graceful degradation**: Word-count fallback when tiktoken unavailable. Silent skip on missing external dependencies.

- **Hooks over settings edits**: Complex hook commands are shim scripts, not inline in settings.json, for maintainability.

### Not Included (P1+)

- PowerPoint/Keynote slide rendering
- Batch processing multiple documents
- Streaming large outputs
- Custom LLM model selection within skills
- Analytics/usage dashboard
- CI integration for i18n validation
