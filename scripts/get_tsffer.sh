#/bin/bash

# Usage: get_tsffer.sh [optional_tsffer_source_url]

# Retrieve tsffer manifest files either from GH CI artifact store, or by downloading from
# optionally provided URL (typically pointing to a release asset). It is expected that 
# a download URL references an archive of tsffer files, as created by the `package` operation
# of the [tsffer GitHub action](https://github.com/AnotherDaniel/tsffer).

# Source shared config
source "$(dirname "$0")/config.sh"

# Create and verify tmp dir
WORK_DIR=`mktemp -d`
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp directory"
  exit 1
fi

function cleanup {
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

if [[ -n "$TSFFER_URL" ]]; then
  # Download tsffer artifact from provided URL
  ARCHIVE_FILE="$WORK_DIR/$(basename "$TSFFER_URL")"
  curl -L "$TSFFER_URL" -o "$ARCHIVE_FILE"

  # Extract from archive
  tar -xjf "$ARCHIVE_FILE" -C "$TSFFER_DIR"

else
  # Retrieve tsffer artifacts from current github CI run
  gh run download "${{ github.run_id }}" --pattern '*.tsffer' --dir $WORK_DIR

  # Flatten stupid dir structure that gh run download creates
  find tmp -mindepth 2 -type f -exec mv -t $TSFFER_DIR {} +
fi
