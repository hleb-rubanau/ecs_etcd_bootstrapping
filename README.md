# Opinionated etcd-for-ecs
This container utilizes AWS meta-data services in order to figure out the cluster configuration.

## ECS-specific assumptions made by container

It assumes that it's copy is running on each EC2 instance of the cluser.

* Cluster token is derived from cluster name
* Node names are automatically derived from IPs. 
* List of nodes is obtained from AWS -- grant container permissions to list & describe container instances, and to describe EC2 instances
* Protocol used is HTTP over AWS private IPs. 

> Make sure that ETCD_CLIENT_PORT and ETCD_PEER_PORT are set to the range not available to the outer world

## ECS parameters 

Optimal solution is to place the task definition with the following parameters: 
*   number of tasks = number of nodes in the cluster
*   network = host
*   ports = arbitrary pair (specified via ETCD_CLIENT_PORT and ETCD_PEER_PORT), better beyond range of Docker dynamical ports

Such constraints will automatically force ECS cluster to place each task clone on every instance (due to combination of scalability and port-binding constraints)

## Volumes to be mounted

* /etc/ecs:/etc/ecs:ro
* /host-local-data-directory:/data


## You've warned
WARNING: image is not well-tested yet

# Docker Hub
[hleb/ecs\_etcd\_bootstrapping](/https://hub.docker.com/r/hleb/ecs_etcd_bootstrapping/)

# Copyleft

Hleb Rubanau &lt;g.rubanau@gmail.com&gt; (c) 2018

