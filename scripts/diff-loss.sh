#!/usr/bin/env bash
set -euo pipefail
python3 - "$@" <<'PY'
import sys, unicodedata, re, argparse
p = argparse.ArgumentParser()
p.add_argument("--before", required=True); p.add_argument("--after", required=True)
a = p.parse_args(sys.argv[1:])
def norm(s):
    s = unicodedata.normalize("NFC", s)
    return re.sub(r"\s+", " ", s).strip()
def sentences(s):
    return [norm(x) for x in re.split(r"[.!?。！？]|\n\n", s) if norm(x)]
b = sentences(open(a.before, encoding="utf-8").read())
f = sentences(open(a.after,  encoding="utf-8").read())
lost = [s for s in b if s not in f]
for s in lost[:50]:
    print(f"- {s[:200]}")
PY
