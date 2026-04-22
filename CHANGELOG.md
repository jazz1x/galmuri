# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Engine/adapter refactor (tracked under 0.0.1 development, not yet versioned as a release).

### Added

- **Engine/adapter architecture**: `distill` is now the shared engine producing EngineOutput JSON, consumed by four adapters (`explain`, `pitch`, `doc`, `deck`).

- **explain adapter**: Inline markdown summary for the author. `audience=me` auto-fixed, no file created, no audience query.

- **pitch adapter**: Hook-Core-CTA structure in 3–5 lines for a named audience.

- **doc adapter**: Distilled markdown saved to `docs/galmuri-doc-{slug}.md` with audience selection and asset recording.

- **deck adapter**: Structured slide copy (JSON + markdown) using Jobs-inspired design tokens (SF Pro, 16:9, dark-light-dark sandwich pattern). No binary file build.

- **Four deck presets**: `decision-sandwich-6` (6-slide two-option decision), `pitch-deck` (3-slide), `concept-explain` (4–5 slides), `story-arc` (variable-length narrative).

- **EngineOutput JSON schema** (`skills/distill/references/essence-schema.json`): JSON Schema draft-07 for `EssenceUnit` and top-level fields.

- **scripts/validate-essence.sh**: Validates EngineOutput JSON against schema; exit 0 on pass, exit 1 on failure.

- **scripts/preflight.sh**: Checks runtime prerequisites (jq, bash, bats); exit 3 with message on missing dependency.

- **Deprecation alias routing**: `decide` and `shrink` trigger phrases route to context-appropriate adapters. One-time session-scoped warning via `.galmuri/tmp/.warned-{alias}`.

### Changed

- **distill skill** rewritten as a pure engine: flags `--mode`, `--ratio`, `--audience`, `--weak-decomposition`, `--input`. Outputs EngineOutput JSON; no longer handles save/render decisions.

- **distill/references/prompt.md**: Merged compression tactics from shrink (복문→단문, 추상화, 고유명사·수치·인용, 시간 순서, 목차·메타 서술 금지). Added 본질환원/제1원칙/소크라테스 method sections.

- **Hooks** (`hooks/recommended.json`): Updated to per-skill matchers for all five skills. Removed `decide` and `shrink` hook entries.

### Deprecated

- **shrink skill**: Trigger phrases (`shrink`, `줄여줘`, `압축`) route to `explain` or `doc`. Scheduled for removal in a future release.

- **decide skill**: Trigger phrases (`decide`, `결정`) route to `deck --preset decision-sandwich-6`. Scheduled for removal in a future release.

### Removed

- `skills/decide/` — content migrated to `skills/deck/references/preset-decision-sandwich-6.md` and `skills/deck/references/design-tokens.md`.

- `skills/shrink/` — compression tactics migrated to `skills/distill/references/prompt.md`.

### Breaking

- **EngineOutput JSON is the new inter-skill contract.** External integrations consuming distill's raw markdown output must adapt to the `EngineOutput` schema.

- **`/galmuri:shrink` and `/galmuri:decide` commands removed.** Use `explain`, `doc`, or `deck` instead. Trigger phrase aliases remain for session routing in the current 0.0.x line.

---

## [0.0.1] — 2026-04-22

### Added

- **distill skill**: Extract essence from long text for a specific audience. Removes tone, examples, elaboration while preserving decision-changing claims. Includes LLM-as-judge verification and loss diff reporting.
  
- **shrink skill**: Compress text to a target token ratio with configurable retries. Maintains semantic content while fitting time constraints.

- **decide skill**: Transform 2-option decisions into 6-slide Jobs-style decision decks. Includes strict D/E/V/R (Decision/Execution/Validation/Recovery) decomposition, essence distillation, generalization across domains, and Socratic probe validation with 18 questions (3 per slide: Definition/Difference/Attribution).

- **Utility scripts**:
  - `count-tokens.sh`: Token counting with tiktoken support and word-count fallback
  - `evidence-check.sh`: Structure validation for distilled/compressed output
  - `diff-loss.sh`: Quantify information loss between before/after text
  - `record-asset.sh`: SHA-256 NFC-normalized asset recording
  - `query-assets.sh`: Retrieve distilled/compressed work by tags
  - `consolidate-assets.sh`: Deduplicate assets
  - `harnish-bridge.sh`: Bridge to external harnish integration
  - `i18n-sync-check.sh`: Validate heading structure parity between .md and .ko.md files
  - `install-hooks.sh`: Merge recommended hooks into settings.json with conflict resolution

- **Hooks** (optional, installed via `install-hooks.sh`):
  - `PreToolUse`: Validate distilled content before saving
  - `PostToolUse`: Record assets after writing distill/shrink outputs
  - `UserPromptSubmit`: Suggest galmuri skills on keyword match (갈무리, galmuri, tldr, 핵심만, 추려서)
  - `SessionStart`: Preload recent audience personas

- **Bilingual support**: Full English/Korean interface, skill docs, and prompts. Terminology dictionary per §4.8.8 (specification).

- **Asset tracking**: Automatic indexing of distilled/compressed work in `.galmuri/index.jsonl` for reuse and audience persona discovery.

- **Plugin manifest**:
  - `.claude-plugin/plugin.json`: Skill registration
  - `.claude-plugin/marketplace.json`: Marketplace listing

### Design Decisions

- **No binary rendering**: `decide` outputs JSON + markdown templates only. Consumers render with Keynote, PowerPoint, Figma, Slidev, Marp, etc. (future extension opportunity).

- **LLM-as-judge**: Distill/shrink use self-judge to validate claims against source. Decision deck uses Socratic probe (18 questions) to ensure slides are answerable, explicit, and attributable.

- **Asset deduplication**: SHA-256 NFC-normalized hash prevents duplicate recording of identical content across sessions.

- **Graceful degradation**: Falls back to word-count tokens if tiktoken unavailable. Silent skip on missing external dependencies.

- **Hooks over settings edits**: Complex hook commands are shim scripts, not inline in settings.json, for maintainability.

### Not Included (P1+)

- PowerPoint/Keynote slide rendering
- Batch processing multiple documents
- Streaming large outputs
- Custom LLM model selection within skills
- Analytics/usage dashboard
- CI integration for i18n validation
