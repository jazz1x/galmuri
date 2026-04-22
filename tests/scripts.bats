#!/usr/bin/env bats
# tests/scripts.bats — utility script unit tests.

load "$BATS_TEST_DIRNAME/setup.bash"

# ── parse-ratio.sh ──────────────────────────────────────────────────────────

@test "parse-ratio: korean jeolban -> 0.5" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "절반"
  [ "$status" -eq 0 ]
  [ "$output" = "0.5" ]
}

@test "parse-ratio: half → 0.5" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "half"
  [ "$status" -eq 0 ]
  [ "$output" = "0.5" ]
}

@test "parse-ratio: korean haeksimman -> 0.2" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "핵심만"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2" ]
}

@test "parse-ratio: korean hanjul -> 0.05" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "한줄"
  [ "$status" -eq 0 ]
  [ "$output" = "0.05" ]
}

@test "parse-ratio: direct numeric 0.2 → 0.2" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "0.2"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2" ]
}

@test "parse-ratio: direct numeric 0.05 → 0.05" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "0.05"
  [ "$status" -eq 0 ]
  [ "$output" = "0.05" ]
}

@test "parse-ratio: direct numeric 0.5 → 0.5" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "0.5"
  [ "$status" -eq 0 ]
  [ "$output" = "0.5" ]
}

@test "parse-ratio: invalid token exits 2" {
  run bash "$REPO_ROOT/scripts/parse-ratio.sh" "전부다"
  [ "$status" -eq 2 ]
}

# ── validate-essence.sh ─────────────────────────────────────────────────────

@test "validate-essence: valid fixture exits 0" {
  run bash "$REPO_ROOT/scripts/validate-essence.sh" \
    < "$REPO_ROOT/tests/fixtures/essence-valid.json"
  [ "$status" -eq 0 ]
}

@test "validate-essence: missing-claim fixture exits 1 with 'claim' in stderr" {
  run bash "$REPO_ROOT/scripts/validate-essence.sh" \
    < "$REPO_ROOT/tests/fixtures/essence-invalid-missing-claim.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"claim"* ]]
}

@test "validate-essence: bad-socratic fixture exits 1" {
  run bash "$REPO_ROOT/scripts/validate-essence.sh" \
    < "$REPO_ROOT/tests/fixtures/essence-invalid-bad-socratic.json"
  [ "$status" -eq 1 ]
}

# ── preflight.sh ─────────────────────────────────────────────────────────────

@test "preflight: exits 0 when jq bash bats are all present" {
  run bash "$REPO_ROOT/scripts/preflight.sh"
  [ "$status" -eq 0 ]
}

@test "preflight: exits 3 with message when jq is missing" {
  # Override PATH so jq is not visible but bash and bats are.
  tmpdir="$(mktemp -d)"
  ln -s "$(command -v bash)" "$tmpdir/bash"
  ln -s "$(command -v bats)" "$tmpdir/bats" 2>/dev/null || true
  # Do NOT link jq — that's the missing dep.
  run bash -c "env PATH='$tmpdir' bash '$REPO_ROOT/scripts/preflight.sh' 2>&1"
  rm -rf "$tmpdir"
  [ "$status" -eq 3 ]
  [[ "$output" == *"미설치"* ]]
}
