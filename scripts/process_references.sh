#!/bin/bash

# Usage: process_references.sh '[tsffer_json]'

# The caller must quote the json snippet passed as an argument to this script: 
#   `process_references.sh '{"key":"value"}'`
# This script is able to run/add reference items to trudag frontmatter multiple times, so that targeted
# trudag elements can accrue evidence references from multiple inputs. 

# Deal with yq version differences, to make this work x-platform
if yq --version 2>/dev/null | grep -q 'v4'; then
    # Current MacOS
    YQ_CMD="yq -P"
else
    # Current Ubuntu
    YQ_CMD="yq -y"
fi

# tsffer item json content, error if not provided
TSFFER_JSON="${1:?Error: TSFFER_JSON parameter is required}"

# Placeholder string that we're looking for in trudag items, for replacing with reference information. We're doing
# this using two different placeholders so that in the case of a fronmatter wihout existing references, we target a
# placeholder that does not interfere with trudag linting (#EVIDENCE_REF#), whereas in a trudag item that already 
# contains a "reference:" section, we find that and add new references above any existing entries.
REFERENCES_PLACEHOLDER="#EVIDENCE_REF#"
REFERENCES_HEADER="references:"

if ! echo "$TSFFER_JSON" | jq . >/dev/null 2>&1; then
  echo "Error: Invalid JSON provided" >&2
  exit 1
fi

# Source shared config
source "$(dirname "$0")/config.sh"

# Process tsffer metadata
DESCRIPTION=$(echo "$TSFFER_JSON" | jq -r '.["asset-info"].description')
ASSET_NAME=$(echo "$TSFFER_JSON" | jq -r '.["asset-info"].name')

echo "$TSFFER_JSON" | jq -r '.["asset-info"]["tsf-ids"][]' | while read -r itemid; do
  TSF_FILE="$(trudag manage show-item --path "$itemid")"

  if [[ -z "$TSF_FILE" ]] || [[ ! -f "$TSF_FILE" ]]; then
    echo "Error: $itemid in $ASSET_NAME points to a non-existing or invalid TSF entity" >&2
    continue
  fi
  echo "Processing tsffer asset $ASSET_NAME, referring to TSF item: $itemid (in $TSF_FILE)"

  # Generate YAML evidence representation of ref block
  YAML_BLOCK=$(echo "$TSFFER_JSON" |
    jq -r '
      def ensure_array: if type=="array" then . else [.] end;
      def rename(map): with_entries(.key |= (map[.] // .));

      .["asset-info"]["reference-properties"]
      | ensure_array
      | map(rename({reference_type:"type"}))
      | select(length > 0)
    ' | $YQ_CMD | sed 's/^/    /')

  if [[ -n "$YAML_BLOCK" ]]; then
    # Prepend "references:" header line
    YAML_BLOCK="$REFERENCES_HEADER
$YAML_BLOCK"
    # ESCAPED_YAML=$(printf '%s\n' "$YAML_BLOCK" | sed 's/[\/&]/\\&/g')

    # Replace "references:" or "#$EVIDENCE_REF$" placeholder in $TSF_FILE with generated evidence reference properties yaml string
    # Replacement matching only works if the placeholder strings are located at the beginning of a line (hence the the '\n' matching)
    # We're doing if this way (instead of using sed and awk, for instance) to make this work with our multiline yaml, both on Linux and MacOS.
    # Doing that with awk and sed tends to become horribly complicated for x-platform, requiring tmp files and generally looking horrible.
    old_file_contents=$(< "$TSF_FILE")
    new_file_contents=${old_file_contents//$'\n'"$REFERENCES_HEADER"/$'\n'"$YAML_BLOCK"}
    new_file_contents=${new_file_contents//$'\n'"$REFERENCES_PLACEHOLDER"/$'\n'"$YAML_BLOCK"}
    printf '%s\n' "$new_file_contents" > "$TSF_FILE"
  fi

  # We need to set the newly modified item to 'reviewed', as current trudag otherwise refuses to compute scores
  echo "Setting review flag for $itemid"
  trudag manage set-item "$itemid"

done
