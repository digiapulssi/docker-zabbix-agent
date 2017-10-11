# Use jessie because the zabbix agent deb package used does not support stretch yet
FROM debian:jessie-slim
MAINTAINER Sami Pajunen <sami.pajunen@digia.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        curl ca-certificates \
        jq \
        libcurl3-gnutls \
        libldap-2.4-2 \
        netcat-openbsd \
        pciutils \
        sudo \
        gdebi-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Zabbix Agent and update docker monitoring script
# so that it uses /host/var/run/docker.sock from host mount
RUN curl -L -o /tmp/zabbix-agent.deb https://github.com/digiapulssi/zabbix-agent/releases/download/3.2.3-1/zabbix-agent-pulssi_3.2.3-1.docker-host-monitoring.jessie-1_amd64.deb && \
    gdebi -n /tmp/zabbix-agent.deb && \
    rm /tmp/zabbix-agent.deb && \
    sed -i -e 's/\/var\/run/\/host\/var\/run/' /etc/zabbix/scripts/docker.sh && \
    mkdir -p /var/run/zabbix

COPY files/etc/sudoers.d/zabbix /etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix

COPY files/run.sh /
RUN chmod 700 /run.sh

EXPOSE 10050
CMD ["/bin/bash", "/run.sh"]
