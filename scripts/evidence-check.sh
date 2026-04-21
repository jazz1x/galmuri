#!/usr/bin/env bash
set -euo pipefail
SRC="" OUT="" REQUIRE_SMALLER=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SRC="$2"; shift 2 ;;
    --output) OUT="$2"; shift 2 ;;
    --require-smaller) REQUIRE_SMALLER=1; shift ;;
    *) shift ;;
  esac
done
[[ -r "$SRC" ]] || { echo "source unreadable: $SRC" >&2; exit 1; }
if [[ "$OUT" == "-" ]]; then
  OUT_CONTENT=$(cat)
else
  [[ -r "$OUT" ]] || { echo "output unreadable: $OUT" >&2; exit 1; }
  OUT_CONTENT=$(cat "$OUT")
fi
[[ -n "$OUT_CONTENT" ]] || { echo "output empty" >&2; exit 1; }
SRC_SIZE=$(wc -c < "$SRC")
OUT_SIZE=${#OUT_CONTENT}
if [[ "$OUT_SIZE" -gt "$SRC_SIZE" ]]; then
  if [[ "$REQUIRE_SMALLER" == "1" ]]; then
    echo "fail: output larger than source (shrink mode)" >&2
    exit 1
  fi
  echo "warn: output larger than source (distill mode, accepted)" >&2
fi
exit 0
