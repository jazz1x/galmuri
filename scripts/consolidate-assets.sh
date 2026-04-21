#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import json, os, glob
seen = {}; rows = []
for f in sorted(glob.glob(".galmuri/assets/*.jsonl")):
    for line in open(f, encoding="utf-8"):
        r = json.loads(line)
        h = r["hash"]
        if h in seen: continue
        seen[h] = True; rows.append(r)
with open(".galmuri/index.jsonl", "w", encoding="utf-8") as out:
    for r in rows: out.write(json.dumps(r) + "\n")
print(f"indexed {len(rows)} unique assets")
PY
