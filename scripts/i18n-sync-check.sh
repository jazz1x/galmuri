#!/usr/bin/env bash
set -euo pipefail
BASE="${1:?base md required}"
KO="${BASE%.md}.ko.md"
[[ -r "$KO" ]] || { echo "missing ko: $KO" >&2; exit 1; }
diff <(grep -E '^#{1,6} ' "$BASE" | sed -E 's/[^#].*//') \
     <(grep -E '^#{1,6} ' "$KO"   | sed -E 's/[^#].*//') || {
  echo "heading structure mismatch: $BASE vs $KO" >&2; exit 1;
}
