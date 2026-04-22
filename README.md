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

Once installed, try the fastest path end-to-end:

```
# Inside a Claude Code session, in any project with a long doc or transcript
/galmuri:distill
```

Sample flow (simplified):

```
user   > /galmuri:distill docs/meeting-2026-04-20.md --audience exec

step 1 > Audience: exec (from --audience)
step 2 > Source captured → .galmuri/tmp/source-meeting-2026-04-20.txt
step 3 > Extracting claims (tone/examples/elaboration removed)…
step 4 > evidence-check: structure ✓  ·  LLM-as-judge: 4/4 claims grounded
step 5 > Loss diff: top 3 dropped items listed
step 6 > Save to docs/galmuri-meeting-2026-04-20.md? (y / n / edit-slug)
user   > y

✓ Saved: docs/galmuri-meeting-2026-04-20.md
✓ Asset recorded: .galmuri/assets/summary.jsonl
```

If `--audience` is omitted, galmuri first offers recent audiences from `.galmuri/assets/` (via `scripts/query-assets.sh`), then asks explicitly — no silent default.

Then compress further or turn a decision into a deck:

```
/galmuri:shrink --target-ratio 0.2 --audience exec
/galmuri:decide
```

## Usage

### 1. Distill (essence extraction)

```
User: /galmuri:distill
→ "Who is the audience? (engineer / exec / 5-year-old / free text)"

User: "engineer, 5-min standup"
→ Reads source → LLM distills to claims only → LLM-as-judge verifies each claim against source
→ Emits markdown: core essence + "## Loss bullets" (top 3~5 dropped items, prioritized)
→ HITL: "Save to docs/galmuri-{slug}.md? (y / n / edit-slug)"
```

### 2. Shrink (target-ratio compression)

```
User: /galmuri:shrink --target-ratio 0.2 --audience exec
→ Counts source tokens → compress to source_tokens × 0.2
→ Up to 2 retries if |actual - target| > 5%
→ On miss: [a]ccept current / [r]e-target / [c]ancel
→ Emits compressed markdown with token comparison report
→ Optional --show-loss for sentence-level diff
```

### 3. Decide (decision deck template)

```
User: /galmuri:decide
→ 5-step protocol: Phenomenon → Decomposition (D/E/V/R) → Essence → Generalization → Reconstruction
→ Strict mode requires Decision/Execution/Validation/Recovery on distinct subjects
→ Small teams: /galmuri:decide --weak-decomposition (perspective separation on same subject)

Output: 2 template files (no binary build)
  - {slug}.json  — slide copy + design_intent (Jobs tokens)
  - {slug}.md    — presentation script + 18 Socratic probe questions (Definition × Difference × Attribution)

Consumers render via Keynote / PowerPoint / Figma / Slidev / Marp.
```

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
