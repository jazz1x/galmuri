---
name: distill
description: >
  Core engine. Essence reduction + first-principles decomposition + Socratic validation. Invoked by adapters or directly. No persistence (adapters own that).
  Triggers: "distill", "핵심만", "본질", "distill engine"
version: 0.0.1
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

```bash
mkdir -p .galmuri/tmp
SLUG=$(echo "$INPUT" | head -c 40 | tr -cs '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]')
cat > ".galmuri/tmp/source-${SLUG}.txt"
# reset retry counter (clean up leftovers from prior sessions)
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

- Persist source text to `.galmuri/tmp/source-{slug}.txt`.
- If `--mode` is omitted, proceed to Step 2. If specified, skip Step 2 → Step 3.

## Step 2: Mode Selection [bash + HITL]

```bash
TOKEN_JSON=$(bash scripts/count-tokens.sh ".galmuri/tmp/source-${SLUG}.txt")
TOKEN_COUNT=$(printf '%s' "$TOKEN_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['tokens'])")
if [ "$TOKEN_COUNT" -lt 80 ]; then
  echo "[distill] short input (${TOKEN_COUNT} tokens) → construct mode recommended"
else
  echo "[distill] long input (${TOKEN_COUNT} tokens) → reduce mode recommended"
fi
```

- Skip this step when `--mode` is explicit.
- Otherwise, suggest a mode based on token count → confirm with HITL.
  > "Proceed with reduce or construct? e.g. reduce (summarize), construct (structural expansion)"

## Step 3: Apply the 3 Methods [LLM]

Apply `references/prompt.md` + `references/decomposition.md` + `references/socratic_probe.md` in order:

1. **Method 1 — Essence reduction**: each claim → a one-line subject-verb essence.
2. **Method 2 — First-principles decomposition**: apply the 4 D/E/V/R questions (Weak mode under `--weak-decomposition`).
3. **Method 3 — Socratic validation**: 3-axis probe → failed units land in `dropped[]`.

**Retry contract (deterministic)**:
- Step A: produce candidate essence_units.
- Step B: schema-check via `bash scripts/validate-essence.sh`.
- Step C: in reduce mode, re-apply if `|actual_ratio - target_ratio| > 0.05` (max 2 retries).

Retry counter management (bash):

```bash
COUNT_FILE=".galmuri/tmp/retry-count.${SLUG}"
CURRENT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
echo $((CURRENT + 1)) > "$COUNT_FILE"
```

Past 2, fall through to the HITL branch in Step 5.

## Step 4: Ratio Validation [bash] (reduce mode only)

```bash
bash scripts/validate-essence.sh < output.json
bash scripts/count-tokens.sh output.json
```

- Final adjudication after the Step 3 LLM loop.
- If ratio drift > 0.05 persists, check retry-count → re-enter Step 3 if < 2, else HITL in Step 5.

## Step 5: Output [bash]

```bash
bash scripts/validate-essence.sh < final-output.json || {
  echo "[distill] validation failed"
  # HITL: [a]ccept / [r]e-target / [c]ancel
  exit 1
}
cat final-output.json
# clear counter
rm -f ".galmuri/tmp/retry-count.${SLUG}"
```

- Final `validate-essence.sh` pass is mandatory → emit EngineOutput JSON.
- On failure: exit 1 + HITL (`[a]ccept / [r]e-target / [c]ancel`).
- On either branch (normal or HITL), clean up the retry counter file before exit.

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
