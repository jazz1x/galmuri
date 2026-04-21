#!/usr/bin/env bash
set -euo pipefail
TYPE="" TAGS="" SOURCE_REF="" OUTPUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) TYPE="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --source-ref) SOURCE_REF="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *) shift ;;
  esac
done
ASSETS_DIR=".galmuri/assets"; mkdir -p "$ASSETS_DIR"
TS=$(date -u +%s)
OUT_FILE="$ASSETS_DIR/${TYPE}-${TS}.jsonl"
python3 - "$TYPE" "$TAGS" "$SOURCE_REF" "$OUTPUT" "$TS" "$OUT_FILE" <<'PY'
import sys, json, unicodedata, re, hashlib
typ, tags, src, output, ts, out_file = sys.argv[1:7]
text = open(src, encoding="utf-8").read()
norm = re.sub(r"\s+", " ", unicodedata.normalize("NFC", text)).strip()
h = hashlib.sha256(norm.encode()).hexdigest()
excerpt = text[:200]
row = {
  "type": typ, "ts": int(ts), "hash": h,
  "tags": [t for t in tags.split(",") if t],
  "output": output, "excerpt": excerpt
}
with open(out_file, "a", encoding="utf-8") as f:
    f.write(json.dumps(row, ensure_ascii=False) + "\n")
PY
