#!/bin/bash

TMP_FILE_NAME="tmp-cluster-local-images.json"
STATUS_UPDATE_THRESHOLD=100

function validate_setup() {
    if [[ -z "$ROX_ENDPOINT" ]]; then
        echo "env ROX_ENDPOINT missing"
        exit 1
    fi

    if [[ -z "$ROX_API_TOKEN" ]]; then
        echo "env ROX_API_TOKEN missing"
        exit 1
    fi

    echo "Pulling Central metadata"
    STATUSCODE=$(curl -k --silent --output /dev/stderr --write-out "%{http_code}" -H "Authorization: Bearer $ROX_API_TOKEN" "https://$ROX_ENDPOINT/v1/metadata")
    if [[ $STATUSCODE -ne 200 ]]; then
        echo
        echo "Unable to communicate with Central"
        exit 1
    fi  
    echo
    echo
}

function verify_delegated_scanning_disabled() {
    response=$(curl -k --silent --show-error --write-out "HTTPSTATUS:%{http_code}" -H "Authorization: Bearer $ROX_API_TOKEN" "https://$ROX_ENDPOINT/v1/delegatedregistryconfig")
    body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    if [[ $status -ne 200 ]]; then
        echo
        echo "Unable to pull existing delegated registry config, cannot be sure clusterLocal flag will be reset"
        echo "$body"
        exit 1
    fi

    echo "Current delegated scanning config:"
    echo $body
    echo

    enabled_for=$(echo $body | jq -r '.enabledFor')
    if [[ "$enabled_for" != "NONE" ]]; then
        echo "Delegated scanning is enabled. To ensure reset of the clusterLocal flag for all images delegated scanning must be disabled"
        exit 1
    fi
}