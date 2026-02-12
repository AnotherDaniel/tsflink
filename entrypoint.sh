#!/usr/bin/env bash
set -euo pipefail

set_output() {
  local name="$1"
  local value="$2"

  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "${name}<<EOF"
      echo "$value"
      echo "EOF"
    } >> "$GITHUB_OUTPUT"
  else
    echo "[OUTPUT] ${name}<<EOF"
    echo "$value"
    echo "EOF"
  fi
}

ECHO="$1"
echo "Running tool for target: $ECHO"

VERSION=`trudag --version`
FILES=`ls -1q /github/workspace | wc -l`

set_output "version" "$VERSION"
set_output "files" "$FILES"
