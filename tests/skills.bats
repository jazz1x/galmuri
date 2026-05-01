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

@test "explain/SKILL.md contains no save/persist/record forbidden words" {
  run bash -c "! grep -qE '저장|기록|save|write|persist|docs/galmuri|record-asset|PostToolUse' \
    '$REPO_ROOT/skills/explain/SKILL.md'"
  [ "$status" -eq 0 ]
}

@test "explain/SKILL.md does not query audience" {
  run bash -c "! grep -qE 'audience 질의|누구한테|누구 용|청자|for whom|target audience' \
    '$REPO_ROOT/skills/explain/SKILL.md'"
  [ "$status" -eq 0 ]
}

# ── deck adapter: no binary build words ──────────────────────────────────────

@test "deck/SKILL.md contains no binary build forbidden words" {
  run bash -c "! grep -iE 'pptx|keynote|build.*binary' \
    '$REPO_ROOT/skills/deck/SKILL.md'"
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
