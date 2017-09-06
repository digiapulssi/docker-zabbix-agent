FROM debian:wheezy-slim
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
        gdebi-core \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/digiapulssi/zabbix-agent/releases/download/3.2.3-1.0/zabbix-agent_3.2.3-1.0.digiapulssi+wheezy-1_amd64.deb \
    gdebi zabbix-agent*.deb \
    rm zabbix-agent*.deb

COPY etc/zabbix/ /etc/zabbix/
COPY etc/sudoers.d/zabbix /etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix

COPY files/run.sh /
RUN chmod 700 /run.sh

EXPOSE 10050
CMD ["/bin/bash", "/run.sh"]
