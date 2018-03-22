#!/bin/bash

set -e 
set -o pipefail
#set -x
# connects to etcd on localhost
if [ -z "$ETCD_ENDPOINTS" ]; then echo "ETCD_ENDPOINTS is empty" >&2 ; exit 1 ; fi
if [ -z "$ETCD_SERVICES_PREFIX" ] ; then echo "ETCD_SERVICES_PREFIX is empty" >&2 ; exit 1 ; fi
if [ -z "$(which docker)" ]; then echo "Docker command not found" >&2 ; exit 1 ; fi
if [ -z "$(which etcdctl)" ]; then echo "Etcdctl not found" >&2 ; exit 1 ; fi


function list_services {
	etcdctl --endpoints="$ETCD_ENDPOINTS" ls -r $ETCD_SERVICES_PREFIX | grep $(hostname)
}

function do_cleanup() {
    for service in $( list_services ) ; do
        container_name=$( echo "$service" | cut -f2 -d: )
        if [ -z "$( docker ps | grep $container_name )" ]; then
               echo "Remove dangling record: $service"
           echo "etcdctl --endpoints="$ETCD_ENDPOINTS" rm $service"
        fi
    done
}

while true ; do
     do_cleanup;
     sleep 60;
done
