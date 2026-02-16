#!/bin/bash

# Usage: process_references.sh '[tsffer_json]'

# The caller must quote the json snippet passed as an argument to this script: 
#   `process_references.sh '{"key":"value"}'`

# tsffer item json content, error if not provided
TSFFER_JSON="${1:?Error: TSFFER_JSON parameter is required}"

if ! echo "$TSFFER_JSON" | jq . >/dev/null 2>&1; then
  echo "Error: Invalid JSON provided" >&2
  exit 1
fi

# Source shared config
source "$(dirname "$0")/config.sh"

# Process tsffer metadata
DESCRIPTION=$(echo "$TSFFER_JSON" | jq -r '.["asset-info"].description')
ASSET_NAME=$(echo "$TSFFER_JSON" | jq -r '.["asset-info"].name')

echo "Processing $ASSET_NAME"
echo "$TSFFER_JSON" | jq -r '.["asset-info"]["tsf-ids"][]' | while read -r itemid; do
  TSF_FILE="$(trudag manage show-item --path $itemid)"

  if [[ -z "$TSF_FILE" ]] || [[ ! -f "$TSF_FILE" ]]; then
    echo "Error: $itemid in $ASSET_NAME points to a non-existing or invalid TSF entity" >&2
    continue
  fi

  echo "  Processing: $itemid in TSF file $TSF_FILE"
  echo "$TSFFER_JSON" | jq -r '.["asset-info"]["evidence-links"][]' | while read -r link; do
    echo "    Processing: $link"
  done

done
