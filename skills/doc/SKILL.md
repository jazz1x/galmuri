---
name: doc
description: >
  Document adapter. Calls the distill engine, formats the result as markdown, and saves it to a file. Inherits the prior distill save flow.
  Triggers: "문서로", "정리해서 저장", "doc", "기록으로", "shrink", "줄여줘", "압축"
version: 0.0.1
---

# galmuri:doc — Document adapter

## Prerequisites
- `scripts/preflight.sh` passes.
- `skills/distill/` engine is installed.
- `scripts/record-asset.sh` is executable.

## Step 1: Alias detection + Audience

When triggered via `shrink` / `줄여줘` / `압축`:
```bash
if [ ! -f ".galmuri/tmp/.warned-shrink" ]; then
  echo "[deprecated] the 'shrink' trigger is routed to a context-based adapter. Scheduled for removal in a future release." >&2
  touch ".galmuri/tmp/.warned-shrink"
fi
# source_tokens ≥ 80 AND ratio > 0.1 → doc runs; otherwise → delegate to another adapter
```

> "Who is this document for? (e.g. the whole team, future-me, an external reviewer)"
- Ask if audience is missing.

## Step 2: Engine Invoke
- Call `distill --mode reduce --ratio 0.3 --audience {X}`.
- Receive the EngineOutput JSON.

## Step 3: Render
- EngineOutput.units → markdown body:
  - Section title = first unit's `claim`.
  - Each unit's `essence` + `evidence` becomes the body copy.
  - `dropped[]` becomes a "## Omitted items" section.

## Step 4: Save
Default path: `docs/galmuri-doc-{slug}.md`
> "Save to `docs/galmuri-doc-{slug}.md`? (y/n/edit-slug)"
- `y` → create the file, then proceed to Step 5.
- `n` → stdout only.
- `edit-slug` → rename, then create.

## Step 5: Asset record
After the file is created, run via the PostToolUse hook or directly:
```bash
bash scripts/record-asset.sh --type doc --tags "doc,{slug}" \
  --source-ref ".galmuri/tmp/source-{slug}.txt" --output "docs/galmuri-doc-{slug}.md"
```

## Output Schema
A markdown file (`docs/galmuri-doc-{slug}.md`) + an asset record.
