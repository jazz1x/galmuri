---
name: explain
description: >
  Inline self-comprehension adapter. Calls the distill engine to extract the essence of long text and renders it as inline markdown.
  audience=me is auto-fixed. Output only — no file generation.
  Triggers: "설명해", "이해하게", "explain", "정리해서 보여줘", "readme 읽고", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:explain — Inline reader-side summary

## Prerequisites
- `scripts/preflight.sh` passes (jq, bats, bash).
- `skills/distill/` engine is installed.

## Step 1: Alias detection + Input Capture

When triggered via `shrink` / `줄여줘` / `압축`:
```bash
if [ ! -f ".galmuri/tmp/.warned-shrink" ]; then
  echo "[deprecated] the 'shrink' trigger is routed to a context-based adapter. Scheduled for removal in a future release." >&2
  touch ".galmuri/tmp/.warned-shrink"
fi
# source_tokens < 80 → explain runs; otherwise → delegate to another adapter
```

- Pipe user input (a file path or stdin) into `.galmuri/tmp/source-{slug}.txt`.
  If no path is provided: "Tell me a file path or some text to explain. e.g. `README.md` — what should I explain?"
- audience is locked to `me` automatically (no separate prompt).

## Step 2: Engine Invoke

Call the `galmuri:distill` skill via the **Skill tool** with these arguments:

```
--mode reduce --ratio 0.2 --audience me --input {tmp file path from Step 1}
```

The engine returns an EngineOutput JSON. Pass it directly to Step 3.

Do **not** attempt to inline the distill logic here — always delegate to the skill.

## Step 3: Render
- EngineOutput.units → inline markdown:
  - First unit's `claim` becomes the top-line summary.
  - Each unit's `essence` is listed as a bullet.

## Step 4: Output
- Emit markdown to stdout. **No file-generation step** (by design).
- On session end, `.galmuri/tmp/source-{slug}.txt` is cleaned up automatically (hook).

## Output Schema
Markdown body only. No JSON output.
