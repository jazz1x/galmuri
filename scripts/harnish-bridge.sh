#!/usr/bin/env bash
set -euo pipefail
CMD="${1:?cmd required}"; shift
HARNISH_ROOT="${HARNISH_ROOT:-$(pwd)/.harnish}"
SCRIPT="$HARNISH_ROOT/scripts/${CMD}.sh"
[[ -x "$SCRIPT" ]] || exit 0
exec "$SCRIPT" "$@"
