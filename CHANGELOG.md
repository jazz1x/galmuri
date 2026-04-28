# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
