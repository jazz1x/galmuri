#!/usr/bin/env bash
# Parse natural language ratio token → numeric ratio (0.05–0.5).
# Usage: echo "절반" | bash parse-ratio.sh
#        bash parse-ratio.sh "0.2"
# Exit 0 on success (prints ratio), exit 2 on unknown token.
set -uo pipefail

if [ $# -ge 1 ]; then
  INPUT="$1"
else
  read -r INPUT
fi

INPUT="$(echo "$INPUT" | xargs | tr '[:upper:]' '[:lower:]')"

if [[ "$INPUT" =~ ^(절반|half)$ ]]; then
  echo "0.5"
elif [[ "$INPUT" =~ ^(핵심만|핵심|essence|coreonly|core-only|core\ only)$ ]]; then
  echo "0.2"
elif [[ "$INPUT" =~ ^(한줄|한\ ?줄|oneline|one-line|one\ line|tl;?dr)$ ]]; then
  echo "0.05"
elif [[ "$INPUT" =~ ^0\.(0[5-9]|[1-4][0-9]?|50?)$ ]]; then
  # Normalise to canonical form (strip trailing zero from 0.50)
  python3 -c "print(f'{float(\"$INPUT\"):.2g}')"
else
  echo "unknown ratio token: $INPUT" >&2
  exit 2
fi
