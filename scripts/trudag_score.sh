#!/bin/bash

# Usage: trudag_score.sh

# Source shared config
source "$(dirname "$0")/config.sh"

# Run scoring command, write output to file and capture output at the same time
output="$(trudag score | tee "$TRUDAG_SCORE_FILE")"

# Extract score from the first line
TRUDAG_SCORE=$(echo "$output" | head -n1 | awk -F'=' '{gsub(/;.*$/, "", $2); print $2}' | xargs)
echo "$TRUDAG_SCORE"
