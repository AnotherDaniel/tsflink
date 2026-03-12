#!/usr/bin/env bash
set -euo pipefail

# Setting script output to deal with both running in a GitHub runner, or standalone
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
    echo "OUTPUT"
    echo "$name: $value"
  fi
}

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: $1 is not installed" >&2
    exit 1
  fi
}

# Ensure availability of commands required by this action
check_command curl
check_command gh
check_command jq
check_command trudag

# Source shared config
source "$(dirname "$0")/config.sh"

# Make git accept our working directory permissions
git config --global --add safe.directory "$GITHUB_WORKSPACE"

# Add custom trudag formatters to workspace (only if we're truly running inside a github action container)
if [ -d "/app/.dotstop_extensions" ]; then
  cp -fr /app/.dotstop_extensions "$GITHUB_WORKSPACE"
fi

# tsffer manifest file location
mkdir -p "$TSFFER_DIR"
if [[ ! "$TSFFER_DIR" || ! -d "$TSFFER_DIR" ]]; then
  echo "Could not create tsffer asset directory"
  exit 1
fi

# Retrieve tsffer assets
"$(dirname "$0")/get_tsffer.sh" "$TSFFER_URL"

# Process each tsffer file, to link evidence refs into tsf tree
for file in "$TSFFER_DIR"/*.tsffer; do
  [[ -f "$file" ]] || continue
  "$(dirname "$0")/process_references.sh" "$(cat "$file")"
done

# Create and package trudag report
"$(dirname "$0")/trudag_publish.sh"

# Extract overall score
TRUDAG_SCORE=$(jq -r '.scores[] | select(.id | endswith("TRUSTABLE-SOFTWARE")) | .score' "$REPORT_DIR"/"$TRUDAG_SCORE_FILE")
echo "Trudag score: $TRUDAG_SCORE"

# Set action ouput - tsf score and generated report archive 
set_output "TRUDAG_SCORE" "$TRUDAG_SCORE"
set_output "TRUDAG_REPORT" "$TRUDAG_REPORT_ARCHIVE"
