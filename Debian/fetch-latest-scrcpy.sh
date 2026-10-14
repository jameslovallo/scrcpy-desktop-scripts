#!/usr/bin/env bash
set -euo pipefail

# 1. Fetch latest Linux release URL
echo "Fetching latest scrcpy release URL..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/genymobile/scrcpy/releases/latest \
  | grep '"browser_download_url":' \
  | grep 'linux' \
  | grep -vE '(\.pem|\.sig)' \
  | grep -o 'https://[^"]*')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "Error: Could not find download URL." >&2
  exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")
TMP_DIR=$(mktemp -d)

# Cleanup temporary folder on exit
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading $FILENAME..."
curl -L -s --show-error -o "$TMP_DIR/$FILENAME" "$DOWNLOAD_URL"

echo "Extracting..."
mkdir -p ./scrcpy-latest

# Extract based on file extension
case "$FILENAME" in
  *.tar.gz|*.tgz)
    tar -xzf "$TMP_DIR/$FILENAME" -C ./scrcpy-latest --strip-components=1
    ;;
  *.tar.bz2|*.tbz2)
    tar -xjf "$TMP_DIR/$FILENAME" -C ./scrcpy-latest --strip-components=1
    ;;
  *.zip)
    unzip -q "$TMP_DIR/$FILENAME" -d ./scrcpy-latest
    ;;
  *)
    echo "Error: Unknown archive format: $FILENAME" >&2
    exit 1
    ;;
esac

echo "Successfully extracted to ./scrcpy-latest"