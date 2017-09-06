#!/bin/sh
set -e

SERVER="$1"
METADATA="$2"
HOST="$3"

if [ -z "$ZABBIX_SERVER" ]; then
    echo "ZABBIX_SERVER environment variable is empty"
    exit 1
fi

if [ -z "$HOST" ]; then
    MACHINEID=$(cat /etc/machine-id)
    HOST="$METADATA-$MACHINEID"
    echo "HOST environment variable is empty, using generated host name $HOST"
fi

sed -i "s/^Server\=.*/Server\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive\=.*/ServerActive\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname\=.*/Hostname\='$HOST'/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^HostMetadata\=.*/HostMetadata\='$METADATA'/" /etc/zabbix/zabbix_agentd.conf
echo "AllowRoot=1" >> /etc/zabbix/zabbix_agentd.conf

if [ ! -z "$PSKKey" ]; then
    mkdir -p /etc/zabbix/tls
    echo "$PSKKey" > /etc/zabbix/tls/zabbix.psk
    chmod 600 /etc/zabbix/tls/zabbix.psk
    echo "TLSPSKFile=/etc/zabbix/tls/zabbix.psk" >> /etc/zabbix/zabbix_agentd.conf

    if [ -z "$PSKIdentity" ]; then
        echo "PSKIdentity environment variable is empty even though PSKKey environment variable is set"
        exit 1
    fi

    echo "TLSPSKIdentity='$PSKIdentity'" >> /etc/zabbix/zabbix_agentd.conf
    echo "TLSAccept=psk" >> /etc/zabbix/zabbix_agentd.conf
    echo "TLSConnect=psk" >> /etc/zabbix/zabbix_agentd.conf
fi

zabbix_agentd -f
