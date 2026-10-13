#!/usr/bin/env bash
# INSTRUCTOR-ONLY. Verifies the public test suite against the reference
# solutions in solutions/, without touching the student-facing src/ tree.
#
# Usage:  ./check-solutions.sh
#
# Copies the project to a scratch directory, swaps the stubs in src/ for the
# reference implementations, and runs the full suite there. A green run means
# the stubs, tests, and solutions are mutually consistent and the assignment is
# solvable exactly as written.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

echo "==> staging a scratch copy in $SCRATCH"
cp -r "$HERE/." "$SCRATCH/"
rm -rf "$SCRATCH/out" "$SCRATCH/cache"

echo "==> swapping student stubs for reference solutions"
for f in "$HERE"/solutions/*.sol; do
  base="$(basename "$f")"
  if [[ ! -f "$SCRATCH/src/$base" ]]; then
    echo "    !! solutions/$base has no counterpart in src/ -- filename mismatch" >&2
    exit 1
  fi
  cp "$f" "$SCRATCH/src/$base"
  echo "    src/$base <- solutions/$base"
done
rm -rf "$SCRATCH/solutions"

echo "==> forge test"
cd "$SCRATCH"
forge test "$@"
