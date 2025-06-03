#!/bin/bash

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi

source $SCRIPT_DIR/common.sh

validate_setup

if [[ ! -f $TMP_FILE_NAME ]]; then
    echo "$TMP_FILE_NAME does not exist, run detect.sh first"
    exit 1
fi

verify_delegated_scanning_disabled

line_count=$(wc -l < $TMP_FILE_NAME | xargs)
read -p "Are you sure you want to re-scan $line_count images? [Y/n]: " result
result=$(echo $result | tr '[:upper:]' '[:lower:]')
if [[ ! -z $result && $result != "y" ]]; then
    exit 0
fi
echo

fails=0
count=0
while IFS= read -r line; do
    name=$(echo "$line" | jq -r '.name')
    id=$(echo "$line" | jq -r '.id')

    if [[ "$name" != *"@"* ]]; then
        name="${name}@${id}"
    fi

    echo "Scanning image: $name"
    res=$(roxctl image scan --retries=0 --insecure-skip-tls-verify --image="$name" --output=json 2>&1)
    rc=$?
    if [[ "$rc" != "0" ]]; then
        fails=$((fails + 1))
        echo "$res"
    fi

    count=$((count + 1))
    if (( count % STATUS_UPDATE_THRESHOLD == 0 )); then
        echo "=== Processed $count images so far ==="
    fi
done < "$TMP_FILE_NAME"

echo
echo "Scanned $((count-fails))/$count images successfully, the clusterLocal flag for these images should now be false"