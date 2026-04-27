#!/usr/bin/env bash
# Compare heading structure between a Markdown file and its .ko.md counterpart.
# Skips content inside fenced code blocks so inline # comments aren't treated
# as headings. Exit 0 on match, exit 1 on mismatch.
set -euo pipefail
BASE="${1:?base md required}"
KO="${BASE%.md}.ko.md"
[[ -r "$KO" ]] || { echo "missing ko: $KO" >&2; exit 1; }

extract_headings() {
  python3 - "$1" <<'PY'
import sys, re
in_fence = False
for line in open(sys.argv[1], encoding="utf-8"):
    if re.match(r'^```', line):
        in_fence = not in_fence
    if in_fence:
        continue
    m = re.match(r'^(#{1,6}) ', line)
    if m:
        print(m.group(1))
PY
}

diff <(extract_headings "$BASE") <(extract_headings "$KO") || {
  echo "heading structure mismatch: $BASE vs $KO" >&2
  exit 1
}
