#!/bin/bash

REQUIREMENT_ID="${1:?Error: REQUIREMENT_ID parameter is required}"

if [[ -z "$REQUIREMENT_ID" ]]; then
    exit
fi

fail_on_error=${OFT_FAIL_ON_ERROR:-"false"}
report_format=${OFT_REPORT_FORMAT:-"plain"}
tags=${OFT_TAGS:-""}
file_patterns=${OFT_FILE_PATTERNS:-"."}

options=(-o "$report_format")
if [[ -n "$tags" ]]; then
  options=("${options[@]}" -t "$tags")
fi

echo "::notice::using OpenFastTrace JARs from: ${LIB_DIR}"
echo "::notice::running OpenFastTrace for file patterns: $file_patterns"

# we need to provide the file patterns unquoted in order for the shell to expand any glob patterns like "*.md"
oft_output=$(java -cp "${LIB_DIR}/*" org.itsallcode.openfasttrace.core.cli.CliStarter trace "${options[@]}" $file_patterns |grep "$REQUIREMENT_ID")
oft_output="${oft_output:?No requirement information found for $REQUIREMENT_ID}"

echo "$oft_output"
