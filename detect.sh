#!/bin/bash

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi

source $SCRIPT_DIR/common.sh

validate_setup

echo "Searching for cluster local images"
cat /dev/null > $TMP_FILE_NAME
count=0
found=0
while read -r json; do
    count=$((count + 1))
    if (( count % STATUS_UPDATE_THRESHOLD == 0 )); then
        echo "=== Processed $count images so far ==="
    fi

    clusterLocal=$(echo "$json" | jq '.result.image.isClusterLocal')
    if [[ "$clusterLocal" != "true" ]]; then
        continue
    fi

    # Skip images that are flagged as cluster local
    name=$(echo $json | jq -r '.result.image.name.fullName')
    if [[ "$name" == "image-registry.openshift-image-registry"* ]]; then
        echo "Skipping: $name"
        continue
    fi

    found=$((found + 1))
    record=$(echo "$json" | jq -c '{id: .result.image.id, name: .result.image.name.fullName}')
    echo "$record" | tee -a $TMP_FILE_NAME
done < <(curl -ksS -H "Authorization: Bearer $ROX_API_TOKEN" "https://$ROX_ENDPOINT/v1/export/images" | jq -c '.')

echo
echo "Found $found/$count images flagged as clusterLocal"