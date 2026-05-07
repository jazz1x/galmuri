#!/usr/bin/env bats
# tests/skills.bats — skill structure and content assertions.

load "$BATS_TEST_DIRNAME/setup.bash"

# ── Structure: deprecated directories removed ────────────────────────────────

@test "skills/decide directory does not exist" {
  [ ! -d "$REPO_ROOT/skills/decide" ]
}

@test "skills/shrink directory does not exist" {
  [ ! -d "$REPO_ROOT/skills/shrink" ]
}

# ── Structure: i18n parity ────────────────────────────────────────────────────

@test "every skills/*/SKILL.md heading structure matches SKILL.ko.md" {
  run python3 -c "
import os, subprocess
root = '$REPO_ROOT/skills'
bad = []
for name in sorted(os.listdir(root)):
    en = os.path.join(root, name, 'SKILL.md')
    ko = os.path.join(root, name, 'SKILL.ko.md')
    if not (os.path.isfile(en) and os.path.isfile(ko)): continue
    r = subprocess.run(
        ['bash', '$REPO_ROOT/scripts/i18n-sync-check.sh', en],
        capture_output=True, text=True
    )
    if r.returncode != 0:
        bad.append(f'{name}: heading mismatch between SKILL.md and SKILL.ko.md')
assert not bad, bad
"
  [ "$status" -eq 0 ]
}

@test "every skills/*/SKILL.md has a corresponding SKILL.ko.md" {
  run python3 -c "
import os
root = '$REPO_ROOT/skills'
bad = []
for name in sorted(os.listdir(root)):
    sdir = os.path.join(root, name)
    if not os.path.isdir(sdir): continue
    en = os.path.join(sdir, 'SKILL.md')
    ko = os.path.join(sdir, 'SKILL.ko.md')
    if os.path.isfile(en) and not os.path.isfile(ko):
        bad.append(f'{name}: SKILL.ko.md missing')
assert not bad, bad
"
  [ "$status" -eq 0 ]
}

# ── Structure: Socratic probe reference ──────────────────────────────────────

@test "exactly one file under skills/ contains 'Definition/Difference/Attribution'" {
  run bash -c "grep -rl 'Definition/Difference/Attribution' '$REPO_ROOT/skills/'"
  [ "$status" -eq 0 ]
  count=$(echo "$output" | grep -c .)
  [ "$count" -eq 1 ]
}

# ── explain adapter: no forbidden save/persist words ─────────────────────────
# Body-scoped (after the second `---` delimiter). Frontmatter ssl: blocks may
# legitimately mention `writes:` as part of the side_effects schema.

@test "explain/SKILL.md body contains no save/persist/record forbidden words" {
  run bash -c "! awk '/^---\$/{c++; next} c==2' '$REPO_ROOT/skills/explain/SKILL.md' \
    | grep -qE '저장|기록|save|write|persist|docs/galmuri|record-asset|PostToolUse'"
  [ "$status" -eq 0 ]
}

@test "explain/SKILL.md body does not query audience" {
  run bash -c "! awk '/^---\$/{c++; next} c==2' '$REPO_ROOT/skills/explain/SKILL.md' \
    | grep -qE 'audience 질의|누구한테|누구 용|청자|for whom|target audience'"
  [ "$status" -eq 0 ]
}

# ── deck adapter: no binary build words ──────────────────────────────────────
# Body-scoped (after the second `---` delimiter).

@test "deck/SKILL.md body contains no binary build forbidden words" {
  run bash -c "! awk '/^---\$/{c++; next} c==2' '$REPO_ROOT/skills/deck/SKILL.md' \
    | grep -iE 'pptx|keynote|build.*binary'"
  [ "$status" -eq 0 ]
}

@test "deck/SKILL.md references both output file extensions" {
  run bash -c "grep -q 'galmuri-deck-{slug}.json' '$REPO_ROOT/skills/deck/SKILL.md' && \
               grep -q 'galmuri-deck-{slug}.md'   '$REPO_ROOT/skills/deck/SKILL.md'"
  [ "$status" -eq 0 ]
}

# ── distill engine: required flags ───────────────────────────────────────────

@test "distill/SKILL.md declares --mode flag" {
  run grep -q '\-\-mode' "$REPO_ROOT/skills/distill/SKILL.md"
  [ "$status" -eq 0 ]
}

@test "distill/SKILL.md declares --ratio flag" {
  run grep -q '\-\-ratio' "$REPO_ROOT/skills/distill/SKILL.md"
  [ "$status" -eq 0 ]
}

@test "distill/SKILL.md declares --audience flag" {
  run grep -q '\-\-audience' "$REPO_ROOT/skills/distill/SKILL.md"
  [ "$status" -eq 0 ]
}

@test "distill/SKILL.md declares --weak-decomposition flag" {
  run grep -q '\-\-weak-decomposition' "$REPO_ROOT/skills/distill/SKILL.md"
  [ "$status" -eq 0 ]
}

# ── deck presets: all four preset files exist ─────────────────────────────────

@test "all four deck preset files exist" {
  run python3 -c "
import os
base = '$REPO_ROOT/skills/deck/references'
presets = [
    'preset-decision-sandwich-6.md',
    'preset-pitch-deck.md',
    'preset-concept-explain.md',
    'preset-story-arc.md',
]
missing = [p for p in presets if not os.path.isfile(os.path.join(base, p))]
assert not missing, f'missing presets: {missing}'
"
  [ "$status" -eq 0 ]
}

@test "preset-decision-sandwich-6.md references generalization-check plugin" {
  run grep -q 'generalization-check' \
    "$REPO_ROOT/skills/deck/references/preset-decision-sandwich-6.md"
  [ "$status" -eq 0 ]
}

# ── explain adapter: Skill-tool delegation (not blockquote note) ─────────────

@test "explain/SKILL.md Step 2 explicitly delegates via Skill tool" {
  # The engine call must be a first-class instruction, not buried in a blockquote.
  run grep -q 'Skill tool' "$REPO_ROOT/skills/explain/SKILL.md"
  [ "$status" -eq 0 ]
}

# ── pitch adapter: prose routing (no bc float comparison) ────────────────────

@test "pitch/SKILL.md Step 1 uses prose routing without bc" {
  # bc float comparison is non-portable and doesn't execute in LLM context.
  run bash -c "! grep -wq 'bc' '$REPO_ROOT/skills/pitch/SKILL.md'"
  [ "$status" -eq 0 ]
}

# ── doc adapter: PostToolUse hook is automatic ────────────────────────────────

@test "doc/SKILL.md Step 5 states PostToolUse hook runs automatically" {
  run grep -q 'automatically' "$REPO_ROOT/skills/doc/SKILL.md"
  [ "$status" -eq 0 ]
}

# ── SSL frontmatter contract (audit follow-up) ────────────────────────────────
# Every SKILL.md (en + ko) must declare an `ssl:` block in its YAML frontmatter
# with the keys the skill-auditor relies on: anti_triggers, idempotent, side_effects.

@test "every SKILL.md frontmatter declares an ssl: block" {
  run python3 - <<'PY'
import sys, glob, yaml
bad = []
for f in glob.glob("skills/*/SKILL.md") + glob.glob("skills/*/SKILL.ko.md"):
    with open(f) as fh:
        parts = fh.read().split('---', 2)
    fm = yaml.safe_load(parts[1])
    if not isinstance(fm, dict) or 'ssl' not in fm:
        bad.append(f)
assert not bad, f"missing ssl: block in {bad}"
PY
  [ "$status" -eq 0 ]
}

@test "every SKILL.md ssl block declares idempotent and side_effects" {
  run python3 - <<'PY'
import sys, glob, yaml
bad = []
for f in glob.glob("skills/*/SKILL.md") + glob.glob("skills/*/SKILL.ko.md"):
    with open(f) as fh:
        parts = fh.read().split('---', 2)
    fm = yaml.safe_load(parts[1])
    ssl = fm.get('ssl', {})
    logical = ssl.get('logical', {})
    if 'idempotent' not in logical or 'side_effects' not in logical:
        bad.append(f)
assert not bad, f"missing idempotent or side_effects in {bad}"
PY
  [ "$status" -eq 0 ]
}

@test "every SKILL.md ssl block declares scheduling.anti_triggers" {
  run python3 - <<'PY'
import sys, glob, yaml
bad = []
for f in glob.glob("skills/*/SKILL.md") + glob.glob("skills/*/SKILL.ko.md"):
    with open(f) as fh:
        parts = fh.read().split('---', 2)
    fm = yaml.safe_load(parts[1])
    sched = fm.get('ssl', {}).get('scheduling', {})
    if not sched.get('anti_triggers'):
        bad.append(f)
assert not bad, f"missing scheduling.anti_triggers in {bad}"
PY
  [ "$status" -eq 0 ]
}

# ── deck adapter: trigger disambiguation from harnish:forki ──────────────────

@test "deck/SKILL.md description triggers do not claim decide/의사결정/결정해" {
  # These belong to harnish:forki — keeping them here causes auto-invocation collisions.
  run bash -c "! awk '/^---\$/{c++; next} c==1' '$REPO_ROOT/skills/deck/SKILL.md' \
    | grep -E '\"decide\"|\"의사결정\"|\"결정해\"'"
  [ "$status" -eq 0 ]
}

@test "deck/SKILL.ko.md description triggers do not claim decide/의사결정/결정해" {
  run bash -c "! awk '/^---\$/{c++; next} c==1' '$REPO_ROOT/skills/deck/SKILL.ko.md' \
    | grep -E '\"decide\"|\"의사결정\"|\"결정해\"'"
  [ "$status" -eq 0 ]
}

# ── ssl block invariants (catch silent breakage) ──────────────────────────────

@test "every SKILL.md ssl.logical.idempotent is a boolean" {
  run python3 - <<'PY'
import glob, yaml
bad = []
for f in sorted(glob.glob("skills/*/SKILL.md") + glob.glob("skills/*/SKILL.ko.md")):
    fm = yaml.safe_load(open(f).read().split('---', 2)[1])
    val = fm.get('ssl', {}).get('logical', {}).get('idempotent')
    if not isinstance(val, bool):
        bad.append(f"{f}: idempotent={val!r} (type={type(val).__name__})")
assert not bad, bad
PY
  [ "$status" -eq 0 ]
}

@test "ssl logical/structural fields match between SKILL.md and SKILL.ko.md" {
  # Technical fields are contracts — they must be identical across locales.
  # Only user-facing prose (anti_triggers, rollback, branches text) may differ.
  run python3 - <<'PY'
import glob, os, yaml
bad = []
for en in sorted(glob.glob("skills/*/SKILL.md")):
    ko = en[:-3] + ".ko.md"
    if not os.path.isfile(ko):
        continue
    a = yaml.safe_load(open(en).read().split('---', 2)[1]).get('ssl', {})
    b = yaml.safe_load(open(ko).read().split('---', 2)[1]).get('ssl', {})
    for sec in ('structural', 'logical'):
        for key in ('scenes', 'resumable', 'tools', 'side_effects', 'idempotent'):
            av = a.get(sec, {}).get(key)
            bv = b.get(sec, {}).get(key)
            if av != bv:
                bad.append(f"{en}: ssl.{sec}.{key} drift between en/ko")
assert not bad, bad
PY
  [ "$status" -eq 0 ]
}

# ── pitch adapter: ratio inference disclaimer is load-bearing ────────────────

@test "pitch/SKILL.md pins the ratio-inference disclaimer in body" {
  # Without this note, future contributors will mistake `ratio` for a user-input
  # variable and reintroduce a prompt for it.
  run grep -qE 'ratio.*inferred|inferred.*ratio' "$REPO_ROOT/skills/pitch/SKILL.md"
  [ "$status" -eq 0 ]
}
