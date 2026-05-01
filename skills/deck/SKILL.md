---
name: deck
description: >
  Deck generation adapter. Requires a preset selection. Emits two files — a SlideSpec JSON and a presentation script markdown. No binary build.
  Triggers: "덱", "슬라이드", "deck", "발표 자료", "decide", "의사결정", "A vs B", "결정해", "뭐가 나아"
version: 0.0.2
---

# galmuri:deck — Deck generation adapter

## Prerequisites
- `scripts/preflight.sh` passes.
- `skills/distill/` engine is installed.

## Step 1: Alias detection + Preset selection (required)

When triggered via `decide` / `의사결정` / `A vs B` / `결정해` / `뭐가 나아`:
```bash
# deprecation warning (once per session)
if [ ! -f ".galmuri/tmp/.warned-decide" ]; then
  echo "[deprecated] the 'decide' trigger is routed to deck --preset decision-sandwich-6. Scheduled for removal in a future release." >&2
  touch ".galmuri/tmp/.warned-decide"
fi
```
On alias detection, `--preset decision-sandwich-6` is auto-injected.

When `--preset` is missing, ask via HITL:
> "Which preset should we use? e.g. `decision-sandwich-6`, `pitch-deck`, `concept-explain`, `story-arc`
>  1. decision-sandwich-6 (decision deck, 6 slides)
>  2. pitch-deck (presentation, 3 slides)
>  3. concept-explain (concept introduction, 4–5 slides)
>  4. story-arc (variable length)"

Selected preset file: `references/preset-{name}.md`

## Step 2: Engine Invoke
Pick mode/ratio from the preset (read the preset file's frontmatter):
- Call `distill --mode {preset.mode} --ratio {preset.ratio} --audience {X}`.
- Receive the EngineOutput JSON.

## Step 3: SlideSpec generation
EngineOutput.units + preset mapping → SlideSpec[]:
- Place each unit onto a slide following the preset file's slide structure.
- Apply the color/font tokens from `references/design-tokens.md`.

## Step 4: Save (2 files)
1. `docs/galmuri-deck-{slug}.json` — SlideSpec JSON (for machine consumption).
2. `docs/galmuri-deck-{slug}.md` — presentation script + visual cues (for humans).

> "Create both files? `docs/galmuri-deck-{slug}.{json,md}` (y/n/edit-slug)"

**No binary build step.**
Do not introduce logic that emits native presentation-program file formats.

## Output Schema
- `docs/galmuri-deck-{slug}.json`: SlideSpec[] array.
- `docs/galmuri-deck-{slug}.md`: per-slide script + visual cues.
