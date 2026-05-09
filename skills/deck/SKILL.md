---
name: deck
description: >
  Deck generation adapter. Requires a preset selection. Emits two files — a SlideSpec JSON and a presentation script markdown. No binary build.
  Triggers: "덱 만들어", "슬라이드 만들어", "발표 자료", "deck 생성", "deck 만들어", "A vs B 슬라이드", "뭐가 나은지 슬라이드"
version: 0.0.4
ssl:
  scheduling:
    anti_triggers:
      - "Single binary decision without slide intent — use harnish:forki"
      - "Document-style output without slides — use doc"
  structural:
    scenes: [Preset selection, Engine Invoke, SlideSpec generation, Save]
    resumable: false
  logical:
    tools: [Skill, Write]
    side_effects:
      reads: ["skills/deck/references/preset-{name}.md", "skills/deck/references/design-tokens.md"]
      writes: ["docs/galmuri-deck-{slug}.json", "docs/galmuri-deck-{slug}.md"]
      deletes: []
      network: []
    idempotent: false
    rollback: "User answers 'n' at Save HITL → no files created."
---

# galmuri:deck — Deck generation adapter

## Prerequisites
- `scripts/preflight.sh` passes.
- `skills/distill/` engine is installed.

## Step 1: Preset selection (required)

When `--preset` is missing, ask via HITL — *"Which preset? e.g. `pitch-deck` for a 3-slide presentation."* Selected preset resolves to `references/preset-{name}.md`.

| # | Preset | Shape |
|---|---|---|
| 1 | `decision-sandwich-6` | decision deck, 6 slides |
| 2 | `pitch-deck` | presentation, 3 slides |
| 3 | `concept-explain` | concept introduction, 4–5 slides |
| 4 | `story-arc` | variable length |

## Step 2: Engine Invoke
Pick mode/ratio from the preset (read the preset file's frontmatter):
- Call `distill --mode {preset.mode} --ratio {preset.ratio} --audience {X}`.
- Receive the EngineOutput JSON.

## Step 3: SlideSpec generation
EngineOutput.units + preset mapping → SlideSpec[]:
- Place each unit onto a slide following the preset file's slide structure.
- Apply the color/font tokens from `references/design-tokens.md`.

## Step 4: Save (2 files)

| File | Content |
|---|---|
| `docs/galmuri-deck-{slug}.json` | SlideSpec[] array (machine consumption) |
| `docs/galmuri-deck-{slug}.md` | per-slide script + visual cues (humans) |

> "Create both files? `docs/galmuri-deck-{slug}.{json,md}` (y/n/edit-slug)"

**No binary build step.** Do not introduce logic that emits native presentation-program file formats.
