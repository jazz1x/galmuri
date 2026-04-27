#!/usr/bin/env bats
# tests/e2e.bats — end-to-end pipeline tests for galmuri scripts and hooks.
#
# These tests exercise the full data flow without an LLM:
#   - source capture → asset record → asset query pipeline
#   - hook shim I/O contracts (slug extraction, evidence check)
#   - prompt-hint routing correctness
#   - shrink alias deprecation warning
#   - consolidate → query round-trip

load "$BATS_TEST_DIRNAME/setup.bash"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

setup() {
  WORK=$(mktemp -d)
  mkdir -p "$WORK/.galmuri/tmp" "$WORK/.galmuri/assets" "$WORK/docs" "$WORK/scripts" "$WORK/hooks/shims"
  # Symlink scripts and hook shims into WORK so relative paths resolve.
  for f in "$REPO_ROOT"/scripts/*.sh; do ln -sf "$f" "$WORK/scripts/$(basename "$f")"; done
  for f in "$REPO_ROOT"/hooks/shims/*.sh; do ln -sf "$f" "$WORK/hooks/shims/$(basename "$f")"; done
}

teardown() {
  rm -rf "$WORK"
}

# ---------------------------------------------------------------------------
# 1. record-asset.sh → query-assets.sh pipeline
# ---------------------------------------------------------------------------

@test "e2e: record-asset then query-assets finds the record" {
  # Write a fake source file
  echo "original source text for hashing" > "$WORK/.galmuri/tmp/source-myslug.txt"
  echo "distilled output" > "$WORK/docs/galmuri-doc-myslug.md"

  cd "$WORK"
  run bash scripts/record-asset.sh \
    --type doc \
    --tags "doc,myslug" \
    --source-ref ".galmuri/tmp/source-myslug.txt" \
    --output "docs/galmuri-doc-myslug.md"
  [ "$status" -eq 0 ]

  # Verify at least one asset file was written
  local count
  count=$(ls .galmuri/assets/*.jsonl 2>/dev/null | wc -l)
  [ "$count" -ge 1 ]

  # query-assets.sh must find the record without consolidation
  run bash scripts/query-assets.sh --type doc --limit 5 --format raw
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import json, sys
rows = [json.loads(l) for l in sys.stdin if l.strip()]
assert any(r.get('type') == 'doc' for r in rows), f'doc record not found in: {rows}'
"
  [ "$?" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 2. consolidate-assets.sh → query-assets.sh round-trip
# ---------------------------------------------------------------------------

@test "e2e: consolidate-assets builds index readable by query-assets" {
  echo "src" > "$WORK/.galmuri/tmp/source-cs.txt"
  echo "out" > "$WORK/docs/galmuri-pitch-cs.md"

  cd "$WORK"
  bash scripts/record-asset.sh --type pitch --tags "pitch,cs" \
    --source-ref ".galmuri/tmp/source-cs.txt" --output "docs/galmuri-pitch-cs.md"

  run bash scripts/consolidate-assets.sh
  [ "$status" -eq 0 ]
  [ -f ".galmuri/index.jsonl" ]

  # Query must still find the record (reads assets/*.jsonl or index.jsonl)
  run bash scripts/query-assets.sh --type pitch --limit 5 --format raw
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c "
import json, sys
rows = [json.loads(l) for l in sys.stdin if l.strip()]
assert any(r.get('type') == 'pitch' for r in rows), 'pitch record not found after consolidate'
"
  [ "$?" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 3. pre-write.sh slug extraction
# ---------------------------------------------------------------------------

@test "e2e: pre-write.sh strips type prefix from slug correctly" {
  # Setup: source file uses bare slug (no type prefix)
  echo "original source content" > "$WORK/.galmuri/tmp/source-myslug.txt"
  echo "distilled content" > "$WORK/docs/galmuri-doc-myslug.md"

  # Simulate pre-write hook: file galmuri-doc-myslug.md → slug should be myslug
  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'file_path': 'docs/galmuri-doc-myslug.md', 'content': 'distilled content'}}))
")
  cd "$WORK"
  # Hook exits 0 when source file found (evidence check passes, output <= source is warn-only)
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/pre-write.sh"
  # exit 0 means the slug resolved correctly and source was found
  [ "$status" -eq 0 ]
}

@test "e2e: pre-write.sh exits 0 (skip) when no source file found" {
  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'file_path': 'docs/galmuri-doc-noslug.md', 'content': 'content'}}))
")
  cd "$WORK"
  # No source file → hook should exit 0 silently (graceful skip)
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/pre-write.sh"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 4. post-write.sh records asset and removes source
# ---------------------------------------------------------------------------

@test "e2e: post-write.sh records asset and cleans up source file" {
  echo "original" > "$WORK/.galmuri/tmp/source-pw.txt"
  echo "output" > "$WORK/docs/galmuri-doc-pw.md"

  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'file_path': 'docs/galmuri-doc-pw.md'}}))
")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/post-write.sh"
  [ "$status" -eq 0 ]

  # Source file should have been removed
  [ ! -f ".galmuri/tmp/source-pw.txt" ]

  # Asset should be recorded
  count=$(ls .galmuri/assets/*.jsonl 2>/dev/null | wc -l)
  [ "$count" -ge 1 ]
}

# ---------------------------------------------------------------------------
# 5. asset-record.sh (PostToolUse hook)
# ---------------------------------------------------------------------------

@test "e2e: asset-record.sh records asset and removes source" {
  echo "source text" > "$WORK/.galmuri/tmp/source-ar.txt"
  echo "output text" > "$WORK/docs/galmuri-pitch-ar.md"

  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'file_path': 'docs/galmuri-pitch-ar.md'}}))
")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/asset-record.sh"
  [ "$status" -eq 0 ]
  [ ! -f ".galmuri/tmp/source-ar.txt" ]
}

@test "e2e: asset-record.sh skips non-galmuri files" {
  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'file_path': 'src/main.py'}}))
")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/asset-record.sh"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 6. source-capture.sh (PreToolUse hook)
# ---------------------------------------------------------------------------

@test "e2e: source-capture.sh writes source to .galmuri/tmp/" {
  INPUT=$(python3 -c "
import json
print(json.dumps({'tool_input': {'prompt': 'This is the user prompt text to distill'}}))
")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/source-capture.sh"
  [ "$status" -eq 0 ]

  # A source file should have been created
  count=$(find .galmuri/tmp -name 'source-*.txt' 2>/dev/null | wc -l)
  [ "$count" -ge 1 ]
}

@test "e2e: source-capture.sh skips when prompt is empty" {
  INPUT=$(python3 -c "import json; print(json.dumps({'tool_input': {}}))")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/source-capture.sh"
  [ "$status" -eq 0 ]
  count=$(find .galmuri/tmp -name 'source-*.txt' 2>/dev/null | wc -l)
  [ "$count" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 7. prompt-hint.sh routing correctness
# ---------------------------------------------------------------------------

@test "e2e: prompt-hint.sh routes distill keywords to galmuri:distill" {
  INPUT=$(python3 -c "import json; print(json.dumps({'prompt': '핵심만 추려줘'}))")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/prompt-hint.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"galmuri:distill"* ]]
}

@test "e2e: prompt-hint.sh routes shrink keywords to explain/doc (not deprecated shrink)" {
  INPUT=$(python3 -c "import json; print(json.dumps({'prompt': '이 글 좀 줄여줘'}))")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/prompt-hint.sh"
  [ "$status" -eq 0 ]
  # Must NOT suggest the removed galmuri:shrink skill
  [[ "$output" != *"galmuri:shrink"* ]]
  # Must suggest explain or doc
  [[ "$output" == *"galmuri:explain"* || "$output" == *"galmuri:doc"* ]]
}

@test "e2e: prompt-hint.sh routes decide keywords to deck preset (not deprecated decide)" {
  INPUT=$(python3 -c "import json; print(json.dumps({'prompt': 'A vs B 결정해줘'}))")
  cd "$WORK"
  run bash -c "printf '%s' '$INPUT' | bash hooks/shims/prompt-hint.sh"
  [ "$status" -eq 0 ]
  # Must NOT suggest the removed galmuri:decide skill
  [[ "$output" != *"galmuri:decide"* ]]
  # Must suggest deck
  [[ "$output" == *"galmuri:deck"* ]]
}

# ---------------------------------------------------------------------------
# 8. evidence-check.sh byte consistency
# ---------------------------------------------------------------------------

@test "e2e: evidence-check.sh passes when output is smaller than source" {
  echo "This is a long source text with many words and sentences." > "$WORK/src.txt"
  echo "Short." > "$WORK/out.txt"

  cd "$WORK"
  run bash scripts/evidence-check.sh --source src.txt --output out.txt
  [ "$status" -eq 0 ]
}

@test "e2e: evidence-check.sh warns but passes when output is larger (distill mode)" {
  echo "Short." > "$WORK/src.txt"
  echo "This is a much longer output than the source, which is allowed in distill mode." > "$WORK/out.txt"

  cd "$WORK"
  run --separate-stderr bash scripts/evidence-check.sh --source src.txt --output out.txt
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"warn"* ]]
}

@test "e2e: evidence-check.sh fails when output larger and require-smaller set" {
  echo "Short." > "$WORK/src.txt"
  echo "This is a much longer output than the source, which fails in shrink mode." > "$WORK/out.txt"

  cd "$WORK"
  run bash scripts/evidence-check.sh --source src.txt --output out.txt --require-smaller
  [ "$status" -ne 0 ]
}

@test "e2e: evidence-check.sh handles Korean multibyte text correctly" {
  # Korean: 3 bytes per char; ensure byte comparison is consistent
  printf '안녕하세요 이것은 긴 원본 텍스트입니다. 여러 문장이 포함되어 있습니다.\n' > "$WORK/src-ko.txt"
  printf '짧음.\n' > "$WORK/out-ko.txt"

  cd "$WORK"
  run bash scripts/evidence-check.sh --source src-ko.txt --output out-ko.txt
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 9. parse-ratio.sh + count-tokens.sh integration
# ---------------------------------------------------------------------------

@test "e2e: count-tokens.sh output can be parsed for integer comparison" {
  echo "The quick brown fox jumps over the lazy dog" > "$WORK/sample.txt"
  cd "$WORK"
  local tok_json tok
  tok_json=$(bash scripts/count-tokens.sh sample.txt 2>/dev/null)
  tok=$(printf '%s' "$tok_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['tokens'])")
  [ "$tok" -gt 0 ]
}

@test "e2e: validate-essence.sh rejects ratio below 0.05" {
  local f
  f=$(mktemp)
  python3 -c "
import json
d = json.load(open('$REPO_ROOT/tests/fixtures/essence-valid.json'))
d['ratio'] = 0.01
print(json.dumps(d))
" > "$f"
  run bash "$REPO_ROOT/scripts/validate-essence.sh" < "$f"
  rm -f "$f"
  [ "$status" -ne 0 ]
}

@test "e2e: validate-essence.sh rejects ratio above 0.5" {
  local f
  f=$(mktemp)
  python3 -c "
import json
d = json.load(open('$REPO_ROOT/tests/fixtures/essence-valid.json'))
d['ratio'] = 0.99
print(json.dumps(d))
" > "$f"
  run bash "$REPO_ROOT/scripts/validate-essence.sh" < "$f"
  rm -f "$f"
  [ "$status" -ne 0 ]
}

@test "e2e: validate-essence.sh accepts ratio at boundary 0.05" {
  local f
  f=$(mktemp)
  python3 -c "
import json
d = json.load(open('$REPO_ROOT/tests/fixtures/essence-valid.json'))
d['ratio'] = 0.05
print(json.dumps(d))
" > "$f"
  run bash "$REPO_ROOT/scripts/validate-essence.sh" < "$f"
  rm -f "$f"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 10. diff-loss.sh — Korean sentence boundary detection
# ---------------------------------------------------------------------------

@test "e2e: diff-loss.sh detects lost Korean sentence (period boundary)" {
  printf '코드 리뷰는 4시간 내 완료한다. 팀 리드가 SLA를 강제한다.\n' > "$WORK/before.txt"
  printf '팀 리드가 SLA를 강제한다.\n' > "$WORK/after.txt"
  cd "$WORK"
  run bash scripts/diff-loss.sh --before before.txt --after after.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"코드 리뷰는 4시간 내 완료한다"* ]]
}

@test "e2e: diff-loss.sh reports no loss when content preserved" {
  printf 'Everything is preserved here.\n' > "$WORK/same-before.txt"
  printf 'Everything is preserved here.\n' > "$WORK/same-after.txt"
  cd "$WORK"
  run bash scripts/diff-loss.sh --before same-before.txt --after same-after.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "e2e: diff-loss.sh handles English sentence boundaries" {
  printf 'First sentence. Second sentence! Third sentence?\n' > "$WORK/en-before.txt"
  printf 'Second sentence!\n' > "$WORK/en-after.txt"
  cd "$WORK"
  run bash scripts/diff-loss.sh --before en-before.txt --after en-after.txt
  [ "$status" -eq 0 ]
  # First and Third should appear as lost
  [[ "$output" == *"First sentence"* || "$output" == *"Third sentence"* ]]
}

# ---------------------------------------------------------------------------
# 11. session-start.sh — outputs inject format (not empty)
# ---------------------------------------------------------------------------

@test "e2e: session-start.sh emits inject header when assets exist" {
  echo "src" > "$WORK/.galmuri/tmp/source-ss.txt"
  echo "out" > "$WORK/docs/galmuri-doc-ss.md"
  cd "$WORK"
  bash scripts/record-asset.sh --type doc --tags "doc,ss" \
    --source-ref ".galmuri/tmp/source-ss.txt" --output "docs/galmuri-doc-ss.md"

  run bash hooks/shims/session-start.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"galmuri assets"* ]]
}

@test "e2e: session-start.sh exits 0 silently when no assets recorded" {
  cd "$WORK"
  run bash hooks/shims/session-start.sh
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 12. i18n — SKILL.md/SKILL.ko.md heading parity
# ---------------------------------------------------------------------------

@test "e2e: i18n-sync-check.sh skips code-block # comments (deck regression)" {
  cd "$WORK"
  # Simulate a SKILL.md with a bash comment inside a code fence
  mkdir -p skill-test
  cat > skill-test/SKILL.md <<'EOF'
# My Skill

## Step 1

```bash
# this comment must not count as a heading
```

## Step 2
EOF
  cat > skill-test/SKILL.ko.md <<'EOF'
# My Skill

## Step 1

```bash
# 이 주석은 헤딩으로 처리되면 안 됨
```

## Step 2
EOF
  run bash scripts/i18n-sync-check.sh skill-test/SKILL.md
  [ "$status" -eq 0 ]
}
