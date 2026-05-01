---
name: pitch
description: >
  Three-to-five-line message adapter for sharing with others. Hook-Core-CTA structure. Audience query required. Optional file save.
  Triggers: "꽂아줘", "전달할 메시지", "pitch", "슬랙에 붙일", "DM 보낼", "shrink", "줄여줘", "압축"
version: 0.0.2
---

# galmuri:pitch — Outbound message adapter

## Prerequisites
- `scripts/preflight.sh` passes.
- `skills/distill/` engine is installed.

## Step 1: Alias detection + Audience (required)

**When triggered via `shrink` / `줄여줘` / `압축`:** warn once that the shrink alias is deprecated, then apply the routing rules below to decide whether pitch is the right adapter.

Routing rules (apply in order):
- Input is **long (≥ 80 tokens) AND ratio ≤ 0.1** (or user says "one line" / "TL;DR") → pitch handles it, continue.
- Input is **long AND ratio > 0.1** → tell the user: "This input is better suited for `/doc`. Please re-invoke as `/doc`." and stop.
- Input is **short (< 80 tokens)** → tell the user: "Short input is better suited for `/explain`. Please re-invoke as `/explain`." and stop.

**When triggered directly as `pitch`:** skip routing, proceed immediately.

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
