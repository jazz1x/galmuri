#!/usr/bin/env bash
set -euo pipefail
TAGS="" TYPE="" FORMAT="raw" LIMIT=10
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tags) TAGS="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) shift ;;
  esac
done
INDEX=".galmuri/index.jsonl"
[[ -r "$INDEX" ]] || exit 0
python3 - "$TAGS" "$TYPE" "$FORMAT" "$LIMIT" <<'PY'
import sys, json
tags, typ, fmt, limit = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
wanted = set(t for t in tags.split(",") if t)
rows = []
for line in open(".galmuri/index.jsonl", encoding="utf-8"):
    r = json.loads(line)
    if typ and r.get("type") != typ: continue
    if wanted and not wanted & set(r.get("tags", [])): continue
    rows.append(r)
rows = rows[-limit:]
if fmt == "inject":
    print("<!-- galmuri assets -->")
    for r in rows: print(f"- [{r['type']}] {r.get('excerpt','')[:100]}")
else:
    for r in rows: print(json.dumps(r))
PY
