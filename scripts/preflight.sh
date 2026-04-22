#!/usr/bin/env bash
# Prereq check: jq, bash, bats must be installed.
set -euo pipefail

for cmd in jq bash bats; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[prereq] '$cmd' 미설치. 설치 후 재시도해주세요 (자동 설치는 수행하지 않습니다)." >&2
    exit 3
  }
done
