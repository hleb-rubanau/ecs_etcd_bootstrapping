#!/bin/bash

set -e

mkdir -p /data

if [ -e /data/metadata.json ]; then
    new_metadata=$( find /data/metadata.json -mtime -10 )
fi

if [ -z "$new_metadata" ]; then
    curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
        > /data/metadata.json.new   || true
    
    if [ -s /data/metadata.json.new ]; then
        mv -v /data/metadata.json.new /data/metadata.json
    else
        echo "Metadata file is empty!"
    fi

    if [ ! -e /data/metadata.json ]; then
        touch /data/metadata.json 
    fi
fi

export LOCAL_IP=$( cat /data/metadata.json | jq '.privateIp' -r )
export AWS_DEFAULT_REGION=$(cat /data/metadata.json | jq '.region' -r )
