#!/usr/bin/env bash
# SessionStart hook: inject recent galmuri asset context into the session.
# Reads the 3 most recently recorded assets (any type) and emits them as
# inline context so Claude is aware of recent distillation work.
set -euo pipefail
scripts/query-assets.sh --limit 3 --format inject 2>/dev/null || true
