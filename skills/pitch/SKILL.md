---
name: pitch
description: >
  Three-to-five-line message adapter for sharing with others. Hook-Core-CTA structure. Audience query required. Optional file save.
  Triggers: "꽂아줘", "전달할 메시지", "pitch", "슬랙에 붙일", "DM 보낼", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:pitch — Outbound message adapter

## Prerequisites
- `scripts/preflight.sh` passes.
- `skills/distill/` engine is installed.

## Step 1: Alias detection + Audience (required)

When triggered via `shrink` / `줄여줘` / `압축` — measure tokens, then route:
```bash
if [ ! -f ".galmuri/tmp/.warned-shrink" ]; then
  echo "[deprecated] the 'shrink' trigger is routed to a context-based adapter. Scheduled for removal in a future release." >&2
  touch ".galmuri/tmp/.warned-shrink"
fi
TOKEN_JSON=$(bash scripts/count-tokens.sh "$INPUT_FILE")
TOKEN_COUNT=$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['tokens'])")
# Routing rules:
# source_tokens ≥ 80 AND ratio ≤ 0.1 (or "one line / TL;DR") → pitch (run here)
# source_tokens ≥ 80 AND ratio > 0.1 → delegate to doc
# source_tokens < 80 → delegate to explain
if [ "$TOKEN_COUNT" -ge 80 ] && [ "$(echo "$RATIO <= 0.1" | bc)" = "1" ]; then
  : # pitch handles it
else
  echo "[shrink] this input fits the doc or explain adapter better. Re-invoke as /doc or /explain." >&2
  exit 0
fi
```

> "Who is this message for? (e.g. team lead, customer, Slack channel)"
- If audience is missing, you MUST ask. No default.

## Step 2: Engine Invoke
- Call `distill --mode reduce --ratio 0.08 --audience {X}`.
- Receive the EngineOutput JSON.

## Step 3: Render (Hook-Core-CTA)
Render 3–5 lines per `references/prompt.md`:
- **Hook (1 line)**: a question or reversal that pierces the recipient's current situation. ≤ 30 chars. No declaratives.
- **Core (1–2 lines)**: a single claim + one piece of supporting evidence. ≤ 50 chars per line. No enumeration (one core point only).
- **CTA (1 line)**: a request for action or judgment. Imperative or interrogative. ≤ 30 chars.
- 3–5 lines total.

## Step 4: Save HITL
> "Save to `docs/galmuri-pitch-{slug}.md`? (y/n/edit-slug)"
- Default: prompt (no auto-save, no auto-reject).
- `y` → create file. `n` → stdout only. `edit-slug` → rename, then create.

## Output Schema
3–5 lines of plain text (Hook + Core + CTA) + optional saved file.
