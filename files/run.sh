#!/bin/sh
set -e

if [ -z "$ZABBIX_SERVER" ]; then
    echo "ZABBIX_SERVER environment variable is empty"
    exit 1
fi

if [ -z "$HOST" ]; then
    MACHINEID=$(cat /etc/machine-id)
    HOST="$METADATA-$MACHINEID"
    echo "HOST environment variable is empty, using generated host name $HOST"
fi

sed -i "s/^Server\=127.0.0.1/Server\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive\=127.0.0.1/ServerActive\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
# Log to stdout so that docker can capture it
sed -i "s/^LogFile\=.*/LogFile=\/proc\/self\/fd\/1/" /etc/zabbix/zabbix_agentd.conf
echo "Hostname=$HOST" >> /etc/zabbix/zabbix_agentd.conf
echo "HostMetadata=$METADATA" >> /etc/zabbix/zabbix_agentd.conf
echo "AllowRoot=1" >> /etc/zabbix/zabbix_agentd.conf

if [ ! -z "$PSKKey" ]; then
    # Check key validity (if it's not valid zabbix_agentd exits abnormally without a decent error output)
    if [[ ! "$PSKKey" =~ ^[a-f0-9]+$ ]]; then
        echo "PSKKey value $PSKKey contains invalid characters (must be a hexadecimal string)"
        exit 1
    fi
    if [ ${#PSKKey} -lt 32 -o ${#PSKKey} -gt 512 ]; then
        echo "PSKKey value $PSKKey is invalid length, must be between 32 and 512 characters"
        exit 1
    fi

    mkdir -p /etc/zabbix/tls
    echo "$PSKKey" > /etc/zabbix/tls/zabbix.psk
    chmod 600 /etc/zabbix/tls/zabbix.psk
    echo "TLSPSKFile=/etc/zabbix/tls/zabbix.psk" >> /etc/zabbix/zabbix_agentd.conf

    if [ -z "$PSKIdentity" ]; then
        echo "PSKIdentity environment variable is empty even though PSKKey environment variable is set"
        exit 1
    fi

    echo "TLSPSKIdentity=$PSKIdentity" >> /etc/zabbix/zabbix_agentd.conf
    echo "TLSAccept=psk" >> /etc/zabbix/zabbix_agentd.conf
    echo "TLSConnect=psk" >> /etc/zabbix/zabbix_agentd.conf
fi

zabbix_agentd -f
