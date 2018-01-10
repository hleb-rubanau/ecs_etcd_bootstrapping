#!/bin/bash

set -e

PASSED_CLUSTER_ARGS="$*"


PEER_PORT=${ETCD_PEER_PORT:-2380}
CLIENT_PORT=${ETCD_CLIENT_PORT:-2379}

# exports ECS_CLUSTER value
source /etc/ecs/ecs.config
export ECS_CLUSTER_NAME=${ECS_CLUSTER:-default}

# exports ECS_CLUSTER_IPS
source $(dirname $0)/get_cluster_ips.sh

# exports LOCAL_IP
source $(dirname $0)/get_local_ip.sh

if [ -z "$ECS_CLUSTER_IPS" ] ; then
   if [ -z "$LOCAL_IP" ] ; then
        echo "ERROR: No ECS_CLUSTER_IPS and no LOCAL_IP discovered" >&2 ; exit 1;
   fi
   export ECS_CLUSTER_IPS="$LOCAL_IP"
fi

export OTHER_CLUSTER_IPS=$( echo "$ECS_CLUSTER_IPS" | sed -r -e 's/'$LOCAL_IP'//g' -e 's/\s+/ /g' -e 's/^\s*//g' -e 's/\s*$//g' )

function normalize_name() {
   echo "$1" | sed -r -e 's/[^a-zA-Z[:digit:]\_]/_/g'
}

CLUSTER_DEFINITION=""
for NODE_IP in $ECS_CLUSTER_IPS ; do
    name=$(normalize_name $NODE_IP)
    desc="$name=http://$NODE_IP:$PEER_PORT"
    if [ -z "$CLUSTER_DEFINITION" ]; then 
        CLUSTER_DEFINITION="$desc"
    else
        CLUSTER_DEFINITION="${CLUSTER_DEFINITION},${desc}"
    fi
done

export ETCD_NAME=$(normalize_name "$LOCAL_IP" ) 
export ETCD_DATA_DIR=/data/$ETCD_NAME

export ETCD_INITIAL_CLUSTER_STATE="new"
if [ ! -z "$OTHER_IPS" ]; then
   for other_ip in $OTHER_IPS; do
        health = "$( curl -m 3 -L http://$other_ip:2379/health )"
        if [ "$health" = '{"health": "true"}' ]; then
            export ETCD_INITIAL_CLUSTER_STATE="existing"
            break
        fi
   done
   # everybody could be bootstrapping or cluster is otherwise dead
   if [ "$ETCD_INITIAL_CLUSTER_STATE" = "new" ] ; then
        rm -rf $ETCD_DATA_DIR/*
   fi
fi

set -x
export ETCD_NAME="$ETCD_NAME"
export ETCD_DATA_DIR="$ETCD_DATA_DIR"
export ETCD_INITIAL_CLUSTER_STATE="$ETCD_INITIAL_CLUSTER_STATE"
export ETCD_INITIAL_CLUSTER_TOKEN=etcd_ecs_$( normalize_name "${ECS_CLUSTER_NAME}" )
export ETCD_LISTEN_CLIENT_URLS="http://$LOCAL_IP:$CLIENT_PORT,http://127.0.0.1:$CLIENT_PORT"
export ETCD_ADVERTISE_CLIENT_URLS="http://$LOCAL_IP:$CLIENT_PORT"
export ETCD_LISTEN_PEER_URLS="http://$LOCAL_IP:$PEER_PORT"
export ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$LOCAL_IP:$PEER_PORT"
export ETCD_INITIAL_CLUSTER="$CLUSTER_DEFINITION"


exec etcd $PASSED_CLUSTER_ARGS
