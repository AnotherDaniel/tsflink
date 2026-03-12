#!/bin/bash

# Usage: trudag_publish.sh

# Source shared config
source "$(dirname "$0")/config.sh"

# Get Repo name, to use in report generation
#OWNER="${GITHUB_REPOSITORY%/*}"
REPO="${GITHUB_REPOSITORY##*/}"

# Run scoring command, write output to file and capture output at the same time
echo "Publishing and packaging trudag report"
mkdir -p "$REPORT_DIR"
trudag publish -a -n "$REPO" -o "$REPORT_DIR" -d "$REPORT_DIR"/"$TRUDAG_SCORE_FILE"
tar cfj "$TRUDAG_REPORT_ARCHIVE" "$REPORT_DIR"
