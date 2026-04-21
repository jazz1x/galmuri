#!/usr/bin/env bash
set -euo pipefail
SCOPE="project"; FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) SCOPE="user"; shift ;;
    --force) FORCE=1; shift ;;
    *) shift ;;
  esac
done
if [[ "$SCOPE" == "user" ]]; then TARGET="$HOME/.claude/settings.json"; else TARGET=".claude/settings.json"; fi
mkdir -p "$(dirname "$TARGET")"
[[ -f "$TARGET" ]] && cp "$TARGET" "${TARGET}.bak-$(date +%s)"
python3 - "$TARGET" "$FORCE" <<'PY'
import sys, json, os
target, force = sys.argv[1], sys.argv[2] == "1"
existing = json.load(open(target)) if os.path.exists(target) else {}
new = json.load(open("hooks/recommended.json"))
existing.setdefault("hooks", {})
for event, entries in new.get("hooks", {}).items():
    if event in existing["hooks"] and not force:
        ans = input(f"Conflict on '{event}' — [k]eep / [r]eplace / [b]oth: ").strip().lower()
        if ans == "k": continue
        if ans == "r": existing["hooks"][event] = entries; continue
        existing["hooks"][event] = existing["hooks"].get(event, []) + entries
    else:
        existing["hooks"][event] = existing["hooks"].get(event, []) + entries if event in existing["hooks"] else entries
json.dump(existing, open(target, "w"), indent=2)
print(f"merged hooks into {target}")
PY
