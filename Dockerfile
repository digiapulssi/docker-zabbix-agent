# Use jessie because the zabbix agent deb package used does not support stretch yet
FROM debian:jessie-slim
MAINTAINER Sami Pajunen <sami.pajunen@digia.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        curl \
        jq \
        libcurl3-gnutls \
        libldap-2.4-2 \
        netcat-openbsd \
        pciutils \
        sudo \
        gdebi-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/zabbix-agent*.deb /tmp/

# Remove docker monitoring script coming with debian package because it conflicts with our built-in docker monitoring items
# TBD, should some day merge them
RUN gdebi -n /tmp/zabbix-agent*.deb && \
    rm /etc/zabbix/zabbix_agentd.d/zabbix_discover_docker.conf && \
    mkdir -p /var/run/zabbix

COPY files/etc/zabbix/ /etc/zabbix/
COPY files/etc/sudoers.d/zabbix /etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix

COPY files/run.sh /
RUN chmod 700 /run.sh

EXPOSE 10050
CMD ["/bin/bash", "/run.sh"]
