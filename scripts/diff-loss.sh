#!/usr/bin/env bash
# Show sentences/clauses from --before that are absent in --after.
# Handles both Latin (. ! ?) and Korean (다. 요. 다.\n, 。！？) sentence boundaries.
set -euo pipefail
python3 - "$@" <<'PY'
import sys, unicodedata, re, argparse
p = argparse.ArgumentParser()
p.add_argument("--before", required=True)
p.add_argument("--after", required=True)
a = p.parse_args(sys.argv[1:])

def norm(s):
    s = unicodedata.normalize("NFC", s)
    return re.sub(r"\s+", " ", s).strip()

def sentences(s):
    # Split on:
    #   • Western sentence-final punctuation followed by space/newline
    #   • Korean sentence-final patterns: 다/요/죠/네/군 followed by . or \n
    #   • CJK sentence-final punctuation
    #   • Double newlines (paragraph break)
    pattern = r'(?<=[.!?。！？])\s+|(?<=[다요죠네군]\.)\s*\n|(?<=[다요죠네군])\n\n|\n\n'
    parts = re.split(pattern, s)
    return [norm(x) for x in parts if norm(x)]

before = sentences(open(a.before, encoding="utf-8").read())
after_set = set(sentences(open(a.after, encoding="utf-8").read()))
lost = [s for s in before if s not in after_set]
for s in lost[:50]:
    print(f"- {s[:200]}")
PY
