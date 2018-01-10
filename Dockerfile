FROM quay.io/coreos/etcd
MAINTAINER Hleb Rubanau <g.rubanau@gmail.com>

RUN apk add --update py-pip jq curl bash \
    && rm -rf /var/cache/apk/* 

RUN pip install awscli --upgrade

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY get_cluster_ips.sh /usr/local/bin/get_cluster_ips.sh
COPY get_local_ip.sh /usr/local/bin/get_local_ip.sh
RUN chmod u+x /usr/local/bin/*.sh

ENTRYPOINT [ "/bin/bash", "/usr/local/bin/entrypoint.sh" ]

