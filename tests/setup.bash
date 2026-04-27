#!/usr/bin/env bash
# tests/setup.bash — shared helpers for galmuri bats tests.
# load via:  load "$BATS_TEST_DIRNAME/setup.bash"
#
# galmuri's test surface is read-only (schema + frontmatter validation);
# no sandbox is needed. If a future test mutates the filesystem, lift
# honne's sandbox helpers (see honne/tests/setup.bash).

set -euo pipefail

bats_require_minimum_version 1.5.0

_setup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$_setup_dir/.." && pwd)"
unset _setup_dir
export REPO_ROOT
