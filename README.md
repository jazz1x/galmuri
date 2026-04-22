# galmuri

> Claude Code plugin — gather, organize, and keep context

![version](https://img.shields.io/badge/version-0.0.1-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![claude-code](https://img.shields.io/badge/claude--code-plugin-purple)

**galmuri** (갈무리) — Korean for *"gathering, organizing, and storing with care."* Turns sprawling context into well-kept summaries with explicit loss transparency, evidence grounding, and a decision-deck template engine.

[한국어](./README.ko.md)

## Skills

| Skill | Command | Role |
|-------|---------|------|
| **distill** | `/galmuri:distill` | Extract essence for a specific audience (tone/examples/elaboration removed; claims only) |
| **shrink** | `/galmuri:shrink` | Compress to a target token ratio with retry loop and loss diff |
| **decide** | `/galmuri:decide` | Turn 2-option decisions into a 6-slide Jobs-style template (JSON + markdown, no binary build) |

Each skill runs in an **independent orbit**, connected only through **shared artifacts (files)**.

```
distill ──→  docs/galmuri-{slug}.md        (essence + loss bullets)
                ↓
shrink  ──→  docs/galmuri-{slug}.md        (target-ratio compression + loss diff)
                ↓
decide  ──→  docs/galmuri-decide-{slug}.json  (slide copy + design_intent)
             docs/galmuri-decide-{slug}.md   (presentation script + 18 Socratic notes)

     └── .galmuri/ (asset index: audience, summary, decision-deck, evidence-trace)
```

## Install

### 1. Register the marketplace

Inside a Claude Code session, run:

```
/plugin marketplace add https://github.com/jazz1x/galmuri.git
```

Expected output:

```
✓ Marketplace 'galmuri' added (1 plugin)
```

### 2. Install the plugin

```
/plugin install galmuri
```

Expected output:

```
✓ Installed galmuri@0.0.1 — 3 skills registered (distill, shrink, decide)
```

### 3. Verify

```
/plugin list
```

You should see `galmuri` in the list. If the three slash commands below autocomplete, you're good:

```
/galmuri:distill
/galmuri:shrink
/galmuri:decide
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

Force-overwrite existing hook entries on conflict (skip HITL merge):

```bash
bash scripts/install-hooks.sh --force
```

See the [Hooks](#hooks) section for what each hook does.

### 5. Uninstall

```
/plugin uninstall galmuri
/plugin marketplace remove galmuri
```

Hook entries added by `install-hooks.sh` remain in your `settings.json` — remove them manually or restore from the `.bak-<epoch>` file.

---

## Quickstart

Just invoke the skill. It asks what it needs in plain language.

```
user   > /galmuri:distill
galmuri > 누구한테 보여줄 요약인가요? 예: 리뷰어, 팀 채널, 임원, 혹은 상황을 한 줄로 설명해주셔도 돼요.
user   > 리뷰어한테 PR 설명용
galmuri > 원문은? (파일 경로 / 붙여넣기 / git diff)
user   > git diff main...HEAD
galmuri > [추출 → 검증 → 손실 diff]
          Save to docs/galmuri-pr-summary.md? (y / n / edit-slug)
user   > y
✓ Saved · asset recorded in .galmuri/assets/summary.jsonl
```

Same pattern for the others — bare invocation opens a conversation, no flag memorization:

```
/galmuri:shrink   → "얼마나 줄일까요? (절반 / 핵심 / 한 줄 / 직접 비율)"
/galmuri:decide   → "어떤 결정을 고민 중이세요? 한 줄로"
```

Power users can skip the questions by passing args directly — see [Usage](#usage).

## Usage

### 1. Distill (essence extraction)

Conversational (default):
```
/galmuri:distill
→ "누구한테 보여줄 요약인가요? 예: 리뷰어, 팀 채널, 임원…"
→ user replies in any form — audience is inferred
→ source prompt → distill → verify → loss diff → HITL save
```

With flags (skip the question):
```
/galmuri:distill path/to/source.md --audience exec
```

### 2. Shrink (target-ratio compression)

Conversational (default):
```
/galmuri:shrink
→ "얼마나 줄일까요? 예: '절반' / '핵심만 (5분)' / '한 줄 TL;DR' / 비율 (0.05~0.5)"
→ reply mapped to ratio (절반→0.5, 핵심→0.2, 한줄→0.05)
→ source prompt → compress (max 2 retries if |actual-target|>5%) → HITL save
→ on ratio miss: [a]ccept / [r]e-target / [c]ancel
```

With flags:
```
/galmuri:shrink path/to/source.md --target-ratio 0.2 --audience exec [--show-loss]
```

### 3. Decide (decision deck template)

Conversational (default):
```
/galmuri:decide
→ "어떤 결정을 고민 중이세요? 한 줄로 — 예: 'Postgres 로 갈지 SQLite 유지할지'"
→ 5-step protocol: Phenomenon → Decomposition (D/E/V/R) → Essence → Generalization → Reconstruction
→ Strict mode requires D/E/V/R on distinct subjects
```

With flags:
```
/galmuri:decide "Postgres vs SQLite 마이그레이션" --weak-decomposition
```

Output: 2 template files (no binary build)
- `{slug}.json` — slide copy + design_intent (Jobs tokens)
- `{slug}.md` — presentation script + 18 Socratic probe questions (Definition × Difference × Attribution)

Consumers render via Keynote / PowerPoint / Figma / Slidev / Marp.

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
| `PreToolUse` | Write to `docs/galmuri-*.md` | Runs `evidence-check.sh` structure gate before save |
| `PostToolUse` | Write/Edit of galmuri outputs | Records the output as an asset in `.galmuri/assets/` |
| `UserPromptSubmit` | Prompt matches `갈무리 \| galmuri \| tldr \| 핵심만 \| 추려서` | Injects a hint suggesting the relevant skill |
| `SessionStart` | Session begins | Injects recent audience context from past assets |

Hooks are opt-in — all skills work without them.

## Assets

Every output is recorded in `.galmuri/assets/*.jsonl` with a SHA-256 NFC-normalized hash of the source. Five asset types:

| Type | Captured when |
|------|---------------|
| `summary` | distill/shrink output saved |
| `decision-deck` | decide template built |
| `compression-pattern` | Recurring compression ratios / audience patterns detected |
| `evidence-trace` | evidence-check passes (claim → source mapping) |
| `recovery-trace` | Socratic probe recovery loop fires |

Consolidate duplicates + rebuild index:

```bash
bash scripts/consolidate-assets.sh
```

Query past assets (used by skills' Step 2 and the SessionStart hook):

```bash
bash scripts/query-assets.sh --tags audience --limit 3 --format inject
```

`.galmuri/assets/` and `.galmuri/index.jsonl` are gitignored by default.

## Sibling Integration (optional)

galmuri reads sibling plugin state when present, silently skips when absent:

| Source | When read | Effect |
|--------|-----------|--------|
| `.harnish/persona.json` | distill/shrink Step 1 | Suggests default audience from persona (user `--audience` wins) |
| `.harnish/assets/*.jsonl` | All skills Step 2 | Tag-based context injection via `harnish-bridge.sh` |
| `.honne/recent-reflection.md` | decide Step 1 | One-line hint if relevant to the decision |
| `.honne/persona.json` | distill/shrink Step 1 | Reflects `formality` / `verbosity` only (other fields ignored) |

All reflections are surfaced to the user explicitly (HITL `[a]ccept / [c]hange / [i]gnore`). No silent tone shifts.

## Fork & Customize

Three ways to use this repo as a base:

### A. Cherry-pick a single skill into your project

```bash
mkdir -p .claude/skills
cp -r /path/to/galmuri/skills/distill .claude/skills/
```

The skill is available as `distill` (no plugin namespace). Replace with `shrink` or `decide`.

### B. Fork as your own plugin marketplace

```bash
gh repo fork jazz1x/galmuri --clone
cd galmuri
# edit .claude-plugin/plugin.json (name, author, repository)
# edit .claude-plugin/marketplace.json (owner, plugin entries)
git commit -am "fork: rebrand"
git push
```

### C. Use as read-only upstream

```bash
git clone https://github.com/jazz1x/galmuri.git
cd your-project
claude --plugin-dir /path/to/galmuri
git -C /path/to/galmuri pull   # update later
```

## Naming

- **galmuri** (갈무리) = gather + organize + keep (Korean native word)
- **distill** = remove tone and scaffolding, keep only claims that change decisions
- **shrink** = target-ratio compression with explicit loss transparency
- **decide** = 2-option fork → D/E/V/R decomposition → 6-slide Jobs-style deck

## Triad

galmuri sits between two sibling plugins — independent, connected by shared artifacts only:

```
harnish (make)  ──→  honne (know)  ──→  galmuri (keep)
  execution         reflection          refinement
```

- [harnish](https://github.com/jazz1x/harnish) — autonomous implementation engine
- [honne](https://github.com/jazz1x/honne) — evidence-backed self-reflection (6-axis persona)
- [galmuri](https://github.com/jazz1x/galmuri) — summary · decision-deck · documentation (formerly *hanashi*)

## Footnote

> *"Compression is lossy. Silence about what was lost is the actual failure."*

Every galmuri output includes a loss diff. If it doesn't, we built the wrong tool.

## License

MIT — See [LICENSE](./LICENSE).
