#!/usr/bin/env bash
set -euo pipefail
scripts/query-assets.sh --tags audience --limit 3 --format inject 2>/dev/null || true
