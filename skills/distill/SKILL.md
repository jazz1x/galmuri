---
name: galmuri:distill
description: Distill the essence from long text for a specific audience. Returns core claims + a loss diff. Requires --audience. Uses .harnish/.honne assets when present (silent skip otherwise).
version: 0.0.1
---

# galmuri:distill — 핵심 추리기

## Step 1: Audience Context
1. Check `--audience` arg. If absent → run `scripts/query-assets.sh --tags audience --limit 3` → offer past audiences. If still absent → ask user. No defaults.
2. Read `.harnish/persona.json` + `.honne/persona.json` if present (formality/verbosity only, §master.3.4).

## Step 1.5: Sibling Reflection
- `.harnish/persona.json` 있으면 formality/verbosity 읽기
- 유저에게: "harnish persona 에 따라 <제안 청자> 로 제안합니다 — [a]ccept / [c]hange / [i]gnore"
- a → 청자 확정, c → Step 1 되돌아감, i → persona 무시
- 명시 --audience 있으면 스텝 자체 skip

## Step 2: Source Capture
Write original source to `.galmuri/tmp/source-{slug}.txt` (for PreToolUse hook).

## Step 3: Extract Essence
LLM prompt (see `references/prompt.md`): "Remove tone, examples, elaboration. Keep only claims that change decisions for {audience}."

## Step 4: Verify
- `scripts/evidence-check.sh --source .galmuri/tmp/source-{slug}.txt --output -` (structure gate)
- LLM-as-judge pass (§master.4.2): for each claim, is it semantically grounded in source? Drop/regen failures.

## Step 5: Loss Diff
- `scripts/diff-loss.sh --before source --after output` → bullet list (top 3~5).

## Step 6: HITL Save
> "Save to `docs/galmuri-{suggested-slug}.md`? (y/n/edit-slug)"
- On `y`: Write → PostToolUse hook records asset → delete temp source.

## Output Schema
markdown body + optional `--json`: `{essence, dropped[], audience, evidence[]}`
