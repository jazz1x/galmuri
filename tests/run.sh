#!/usr/bin/env bash
# tests/run.sh — run the galmuri test suite (bats only).
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
fail() { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }
pass() { echo -e "${GREEN}✓ $1${NC}"; }

if ! command -v bats >/dev/null 2>&1; then
  fail "bats not installed — brew install bats-core (macOS) / apt install bats (linux)"
fi
if ! command -v python3 >/dev/null 2>&1; then
  fail "python3 not found"
fi

bats tests/
pass "all tests passed"
