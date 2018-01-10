#!/bin/bash

set -e 

#cluster_id="$( aws ecs describe-clusters --clusters $ECS_CLUSTER | jq '.clusters[]|.clusterArn' -r | head -n1 )"

jqfilter='.containerInstanceArns | join(",")'
ecs_instances_ids=$(aws ecs list-container-instances --cluster "${ECS_CLUSTER_NAME}" --status ACTIVE | jq "${jqfilter}" -r )

jqfilter='[ .containerInstances[] | .ec2InstanceId ] | join (",")'
ec2_instances_ids=$( aws ecs describe-container-instances --container-instances "$ecs_instances_ids" | jq "${jqfilter}" -r )


jqfilter=' .Reservations[] | [ .Instances[] | .PrivateIpAddress ] | join(" ")'
cluster_ips=$( aws ec2 describe-instances --instance-ids "${ec2_instances_ids}" | jq "${jqfilter}" -r )

export ECS_CLUSTER_IPS="$cluster_ips"
echo "ECS_CLUSTER_IPS=$cluster_ips"

