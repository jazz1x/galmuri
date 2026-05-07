---
name: audit
description: >
  SKILL.md SSL (Scheduling-Structural-Logical) auditor. Decomposes a target SKILL.md (or a directory of skills) into the 3-layer frame, surfaces missing / ambiguous / risky declarations, and emits a diagnostic report. Read-only — never modifies originals. Use for self-review before PR, refactor regression checks, or bulk repo audits.
  Triggers: "skill audit", "ssl audit", "audit skill", "ssl 분해", "skill auditor", "audit-skill"
version: 0.0.3
ssl:
  scheduling:
    anti_triggers:
      - "Generic test/coverage inspection — use harnish:ralphi"
      - "Decision forcing — use harnish:forki"
      - "Freeform text summarization — use distill / explain / doc"
      - "Auto-fixing SKILL.md content — this skill is read-only"
  structural:
    scenes: [Ingest, Decompose, Audit, Score, Report]
    resumable: false
    branches:
      - "single file path → single-mode (one scorecard)"
      - "directory path → batch-mode (per-file scorecards + collision matrix)"
      - "Logical score < 60 → emit suggested frontmatter patch alongside diagnosis"
  logical:
    tools: [Read, Bash]
    side_effects:
      reads: ["{target_path}"]
      writes: ["{report_path} — default .galmuri/audit-{slug}.md, or stdout under --stdout"]
      deletes: []
      network: []
    idempotent: true
    rollback: null
---

# galmuri:audit — SKILL.md SSL auditor

Static SSL decomposition of one or more SKILL.md files. Produces diagnosis + suggested patches. **Originals are never modified.**

## Prerequisites
- `scripts/preflight.sh` passes (jq, bash, bats).
- Python 3 with PyYAML for frontmatter parsing.
- Read access to the target path.

## Step 1: Ingest

Receive a target path. If none is provided, ask in plain language:

> "What should I audit? Pass a path — e.g. `skills/distill/SKILL.md` for one skill, or `skills/` to batch the whole directory."

Two shapes accepted:

```bash
# Single file
audit ./skills/distill/SKILL.md

# Directory (batch mode — globs skills/*/SKILL.md)
audit ./skills
```

Validate each target:

- File exists and is readable.
- Frontmatter is present (between two `---` delimiters).
- Body length ≤ 500 lines (warn if larger — recommend section-wise decomposition; do not abort).

For directory input, glob `skills/*/SKILL.md` (and `*.ko.md` if present). Process each independently.

## Step 2: Decompose

Parse the YAML frontmatter and the body separately, then construct an SSL representation. Use this prompt verbatim when delegating to an LLM helper:

```
Read the SKILL.md and emit JSON only — no markdown fences.

{
  "scheduling": {
    "triggers": [list of phrases from the description "Triggers:" line],
    "anti_triggers": [from frontmatter ssl.scheduling.anti_triggers, or null],
    "ambiguity_notes": "any trigger ≤ 4 chars, or generic adverb / conjunction"
  },
  "structural": {
    "scenes": [from frontmatter, or inferred from "## Step N:" body headings],
    "branches": [explicit branch conditions in body],
    "resumable": bool
  },
  "logical": {
    "tools": [from frontmatter ssl.logical.tools],
    "side_effects": {
      "reads": [], "writes": [], "deletes": [], "network": []
    },
    "idempotent": bool,
    "rollback": string | null
  }
}

Fields not justified by the body or frontmatter must be null or empty array. Do not infer.
```

Avoiding inference is the whole point. A plausible-looking guess hides the audit signal.

## Step 3: Audit (per-layer)

### 3-A. Scheduling
- [ ] `triggers` non-empty
- [ ] no trigger is too generic (≤ 4 chars, or a stand-alone conjunction / adverb)
- [ ] `anti_triggers` declared
- [ ] (batch-mode only) no verbatim trigger collision with another skill in the batch

### 3-B. Structural
- [ ] `scenes` has 2+ entries (no monolithic single-block)
- [ ] each branch condition is in `branches` (not buried in prose)
- [ ] `resumable` matches body evidence (counter / state-marker files imply true; otherwise false)

### 3-C. Logical (highest weight — × 1.5)
- [ ] every body tool call is reflected in `tools`
- [ ] every destructive command (`rm`, `DROP`, `delete`, `--force`) reflected in `side_effects.deletes` (or `writes` if it is an overwrite)
- [ ] every network call (`curl`, `wget`, `fetch`, `http`) in `side_effects.network`
- [ ] non-idempotent body but `idempotent: true` declared = mismatch
- [ ] `idempotent: false` requires a `rollback` declaration

Cross-check (the actual grep this skill performs):

```bash
grep -E '(rm -rf?|DROP|delete|--force|--no-preserve)' "$target" | head -20
# compare against frontmatter ssl.logical.side_effects.deletes
```

If body reveals a destructive command not declared, that is a Logical ✗.

## Step 4: Score

Per layer, out of 100:

- Missing field: −15
- Ambiguous declaration: −8
- Logical layer multiplier: × 1.5

Status thresholds:

- ≥ 80 → ✓
- 60–79 → ⚠
- < 60 → ✗

The numeric score is a triage signal. Top-3 risks per skill matter more than the absolute score — a skill at 80 with a real Logical ✗ is more dangerous than one at 60 with three ⚠ on Scheduling.

## Step 5: Report

CLI-friendly markdown with bar charts, Top-3 risks, and suggested frontmatter patches.

Single-mode shape:

```
┌─ <relative SKILL.md path> ─────────────┐
│ Scheduling   ████████░░  77  ⚠         │
│ Structural   ██████████ 100  ✓         │
│ Logical      ████░░░░░░  43  ✗         │
└────────────────────────────────────────┘

Top 3 Risks:
1. ✗ [Logical] body has `rm -rf {tmp}` but side_effects.deletes is empty
2. ✗ [Logical] idempotent flag missing
3. ⚠ [Structural] Step 2 branch condition is in prose only

[Suggested patch — frontmatter]
ssl:
  logical:
    side_effects:
      deletes: ["{tmp_dir} contents"]
    idempotent: false
    rollback: "Manual restore from .bak directory"
```

Batch-mode adds:

- **Trigger collision matrix** — phrase × skill table; ✗ for verbatim collisions, ⚠ for substring/stem overlaps
- **Tool dependency graph** — which skills share which tools / scripts / hooks; identifies SPOFs

### Output destination

Default report file: `.galmuri/audit-{slug}.md` (slug derived from target name). Use `--stdout` to print to terminal instead. Use `--ci --threshold-logical=N` to exit non-zero when any skill scores below `N` on the Logical layer.

## Output Schema

A markdown report (CLI-friendly) containing per-skill scorecards, Top-3 risks, suggested patches, and (in batch-mode) a collision matrix and tool dependency graph. No JSON output, no source modification.

## What this skill does NOT do

- ✗ Modify any `SKILL.md` (read-only by contract)
- ✗ Execute any skill (static analysis only)
- ✗ Generate new skills — that is `skill-creator` territory
- ✗ General test / coverage inspection — that is `harnish:ralphi` territory
- ✗ Decision forcing — that is `harnish:forki` territory
- ✗ Freeform text summarization — that is `distill` / `explain` / `doc` territory

## Reference

The SSL framework comes from:

- arXiv:2604.24026 (Liang et al., 2026) — Scheduling-Structural-Logical skill decomposition
- Schank & Abelson, *Scripts, Plans, Goals and Understanding* (1977) — theoretical roots
