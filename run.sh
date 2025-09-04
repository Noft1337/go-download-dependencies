#!/bin/bash

set -e 

# Get package name 
if [ -z "$1" ]; then
	echo "Usage: $0 <go_module> <output_dir|optional>"
	exit 1
fi

_module_name=$(python -c "print('-'.join(\"$1\".split(\"/\")[1:]))")

# Init output dir
if [ -z $2 ]; then
	OUTPUT_DIR="$(pwd)/godeps-$_module_name-$(date +'%Y%m%dT%H:%M')"
else
	OUTPUT_DIR="$2"
fi

# Check if 'go' command is available.
if ! command -v go &> /dev/null; then
    echo "Error: 'go' command not found. Please install Go."
    exit 1
fi

# Check if 'jq' command is available.
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq."
    echo "On macOS: brew install jq"
    echo "On Debian/Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Init temporary go project
WORKDIR="$(mktemp -d -t gomod-archives-XXXXXX)"
cleanup() {
  echo ">>> Cleaning up $WORKDIR"
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

cd "$WORKDIR"
go mod init temp-mod &>/dev/null
go get "$1"

# Download modules here
export GOPATH="$(pwd)/go"

# Download all modules
echo ">>> Downloading all dependencies for $1"
JSON_Q="$(go list -m -json all | jq -s)" && python << EOF | xargs -I{} go mod download {}
import sys
import json

s = """
$JSON_Q
"""
for pkg in json.loads(s):
    try:
        print(f'{pkg["Path"]}@{pkg["Version"]}')
    except KeyError:
        continue
EOF

# Move all modules to the output dir
mkdir -p "$OUTPUT_DIR"
mv go/pkg/mod/cache/download/* $OUTPUT_DIR
rm -rf "$OUTPUT_DIR/sumdb"
echo ">>> Modules saved in $OUTPUT_DIR"
echo ">>> Exiting..." 
