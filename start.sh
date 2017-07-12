#/bin/bash
set -e

if [ $# -lt 2 ]; then
    echo "Usage: $(basename $0) <zabbix-server> <hostname> [<host-metadata>]"
    exit 1
fi

ZABBIX_SERVER=$1
HOSTNAME=$2
HOST_METADATA=${3:-coreos}

docker run -d -p 10050:10050 --restart=always \
    -v /proc:/coreos/proc:ro -v /sys:/coreos/sys:ro -v /dev:/coreos/dev:ro \
    -v /var/run/docker.sock:/coreos/var/run/docker.sock \
    -v $(pwd)/hostname.conf:/etc/zabbix/$HOSTNAME.conf \
    --name coreos-agent digiapulssi/docker-zabbix-coreos  \
    $ZABBIX_SERVER $HOST_METADATA $HOSTNAME
