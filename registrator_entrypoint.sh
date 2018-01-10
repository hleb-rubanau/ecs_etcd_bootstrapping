#!/bin/bash

set -e 

ORIGINAL_CMD="$*"

source $(dirname $0)/get_local_ip.sh


exec /bin/registrator -ip $LOCAL_IP $ORIGINAL_CMD
