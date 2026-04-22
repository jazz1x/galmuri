#!/usr/bin/env bash
# Validate EngineOutput JSON against essence-schema.json constraints.
# Reads JSON from stdin.
# Exit 0 = valid, exit 1 = invalid (with error on stderr).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_DIR="$SCRIPT_DIR/../skills/distill/references"

INPUT="$(cat)"

# JSON parse check
if ! echo "$INPUT" | jq empty 2>/dev/null; then
  echo "invalid JSON" >&2
  exit 1
fi

errors=0

# Top-level required fields
for field in units mode dropped source_ref; do
  if ! echo "$INPUT" | jq -e "has(\"$field\")" >/dev/null 2>&1; then
    echo "missing top-level field: $field" >&2
    errors=$((errors + 1))
  fi
done

# mode enum
mode="$(echo "$INPUT" | jq -r '.mode // empty')"
if [[ "$mode" != "reduce" && "$mode" != "construct" ]]; then
  echo "invalid mode: $mode (must be reduce|construct)" >&2
  errors=$((errors + 1))
fi

# units array: validate each EssenceUnit
unit_count="$(echo "$INPUT" | jq '.units | length')"
for i in $(seq 0 $((unit_count - 1))); do
  unit="$(echo "$INPUT" | jq ".units[$i]")"

  # Required unit fields
  for field in id claim essence decomposition evidence socratic_pass tags; do
    if ! echo "$unit" | jq -e "has(\"$field\")" >/dev/null 2>&1; then
      echo "units[$i] missing field: $field" >&2
      errors=$((errors + 1))
    fi
  done

  # claim must be non-empty string
  claim="$(echo "$unit" | jq -r '.claim // empty')"
  if [ -z "$claim" ]; then
    echo "units[$i] claim is empty or missing" >&2
    errors=$((errors + 1))
  fi

  # decomposition required roles
  decomp="$(echo "$unit" | jq '.decomposition // {}')"
  for role in role_D role_E role_V role_R; do
    if ! echo "$decomp" | jq -e "has(\"$role\")" >/dev/null 2>&1; then
      echo "units[$i].decomposition missing: $role" >&2
      errors=$((errors + 1))
    fi
  done

  # socratic_pass: all 3 must be true
  sp="$(echo "$unit" | jq '.socratic_pass // {}')"
  for axis in definition difference attribution; do
    val="$(echo "$sp" | jq -r ".${axis} // empty")"
    if [ "$val" != "true" ]; then
      echo "units[$i].socratic_pass.$axis is not true (got: $val)" >&2
      errors=$((errors + 1))
    fi
  done
done

if [ "$errors" -gt 0 ]; then
  exit 1
fi
