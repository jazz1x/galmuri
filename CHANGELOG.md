# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-04-22

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

---

## [Unreleased]

(Future versions planned. Scope TBD based on user feedback.)
