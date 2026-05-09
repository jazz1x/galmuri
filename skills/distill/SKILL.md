---
name: distill
description: >
  Core engine. Essence reduction + first-principles decomposition + Socratic validation. Invoked by adapters or directly. No persistence (adapters own that).
  Triggers: "distill", "핵심만", "본질", "distill engine"
version: 0.0.4
ssl:
  scheduling:
    anti_triggers:
      - "When an adapter (explain/pitch/doc/deck) is more appropriate than direct engine invocation"
      - "Inputs under 30 tokens — use chat directly"
  structural:
    scenes: [Input Capture, Mode Selection, Apply 3 Methods, Ratio Validation, Output]
    resumable: true
    branches:
      - "--mode omitted → Step 2 (mode selection); --mode specified → skip to Step 3"
      - "Step 3 retry-count < 2 → re-enter Step 3; ≥ 2 → fall through to Step 5 HITL"
      - "Step 5 validate-essence pass → emit JSON; fail → exit 1 + HITL [a]ccept/[r]e-target/[c]ancel"
  logical:
    tools: [Bash, Read]
    side_effects:
      reads: ["{input}", ".galmuri/tmp/retry-count.{slug}", "skills/distill/references/*"]
      writes: [".galmuri/tmp/source-{slug}.txt", ".galmuri/tmp/retry-count.{slug}"]
      deletes: [".galmuri/tmp/retry-count.{slug}"]
      network: []
    idempotent: false
    rollback: "Counter file is cleared on Step 1 entry and Step 5 exit. Mid-flow LLM failures: re-run from Step 1."
---

# galmuri:distill — Core Engine

## Prerequisites
- `scripts/preflight.sh` passes (jq, bats, bash required).
- `scripts/parse-ratio.sh` and `scripts/validate-essence.sh` are executable.

## Flags

| Flag | Required | Description |
|------|----------|-------------|
| `--mode reduce\|construct` | Yes (when called directly) | reduce = essence reduction, construct = structural expansion |
| `--ratio 0.05–0.5` | No (used in reduce mode) | Natural-language values accepted — parsed by `parse-ratio.sh` |
| `--audience {target}` | No | If omitted, the adapter handles it via HITL |
| `--weak-decomposition` | No | Allow Weak D/E/V/R decomposition |
| `--input {path}` | No | File path instead of stdin |

## Step 1: Input Capture [bash]

Persist source text to `.galmuri/tmp/source-{slug}.txt` and reset the retry counter (clears leftovers from prior sessions). If `--mode` is specified, skip Step 2 and jump to Step 3.

```bash
mkdir -p .galmuri/tmp
SLUG=$(echo "$INPUT" | head -c 40 | tr -cs '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]')
cat > ".galmuri/tmp/source-${SLUG}.txt"
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

## Step 2: Mode Selection [bash + HITL]

Skipped when `--mode` is explicit. Otherwise: count tokens, suggest a mode (`< 80` → construct, `≥ 80` → reduce), confirm via HITL — *"Proceed with reduce or construct? e.g. reduce (summarize), construct (structural expansion)."*

```bash
TOKEN_JSON=$(bash scripts/count-tokens.sh ".galmuri/tmp/source-${SLUG}.txt")
TOKEN_COUNT=$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['tokens'])")
[ "$TOKEN_COUNT" -lt 80 ] \
  && echo "[distill] short input (${TOKEN_COUNT} tokens) → construct mode recommended" \
  || echo "[distill] long input (${TOKEN_COUNT} tokens) → reduce mode recommended"
```

## Step 3: Apply the 3 Methods [LLM]

Apply the three method references in order:

| # | Method | Reference | Output |
|---|---|---|---|
| 1 | Essence reduction | `references/prompt.md` | each claim → one-line subject-verb essence |
| 2 | First-principles decomposition | `references/decomposition.md` | 4 D/E/V/R questions (Weak mode under `--weak-decomposition`) |
| 3 | Socratic validation | `references/socratic_probe.md` | 3-axis probe → failed units → `dropped[]` |

**Retry contract (deterministic)**: (A) produce candidate `essence_units` → (B) schema-check via `bash scripts/validate-essence.sh` → (C) in reduce mode, re-apply if `|actual_ratio − target_ratio| > 0.05` (max 2 retries; past that, fall through to Step 5 HITL).

```bash
COUNT_FILE=".galmuri/tmp/retry-count.${SLUG}"
CURRENT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
echo $((CURRENT + 1)) > "$COUNT_FILE"
```

## Step 4: Ratio Validation [bash] (reduce mode only)

Final adjudication after the Step 3 LLM loop. If `|drift| > 0.05` persists: re-enter Step 3 when `retry-count < 2`, else fall through to Step 5 HITL.

```bash
bash scripts/validate-essence.sh < output.json
bash scripts/count-tokens.sh output.json
```

## Step 5: Output [bash]

`validate-essence.sh` pass is mandatory → emit EngineOutput JSON. Fail → exit 1 + HITL (`[a]ccept / [r]e-target / [c]ancel`). Either branch cleans up the retry counter before exit.

```bash
bash scripts/validate-essence.sh < final-output.json || {
  echo "[distill] validation failed"   # HITL: [a]ccept / [r]e-target / [c]ancel
  exit 1
}
cat final-output.json
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

## Output Schema
EngineOutput JSON (matches `essence-schema.json`):
```json
{
  "units": [...],
  "mode": "reduce|construct",
  "ratio": 0.2,
  "dropped": [...],
  "source_ref": ".galmuri/tmp/source-{slug}.txt"
}
```
No persistence here — the adapter receives EngineOutput and decides whether to persist.
