#!/usr/bin/env bash
set -euo pipefail
FILE="${1:?file required}"
if command -v python3 >/dev/null && python3 -c "import tiktoken" 2>/dev/null; then
  python3 - "$FILE" <<'PY'
import sys, json, tiktoken
p = sys.argv[1]
text = open(p, encoding="utf-8").read()
enc = tiktoken.get_encoding("cl100k_base")
print(json.dumps({
  "file": p,
  "tokens": len(enc.encode(text)),
  "chars": len(text),
  "lines": text.count("\n") + 1
}))
PY
else
  echo "warn: tiktoken unavailable — word count fallback" >&2
  python3 - "$FILE" <<'PY'
import sys, json
p = sys.argv[1]
t = open(p, encoding="utf-8").read()
print(json.dumps({"file": p, "tokens": len(t.split()), "chars": len(t), "lines": t.count("\n")+1}))
PY
fi
