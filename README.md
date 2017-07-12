# docker-zabbix-coreos-pulssi
Dockerized Zabbix agent for CoreOS with docker process monitoring.

Based on [https://github.com/bhuisgen/docker-zabbix-coreos].

## Installation

### Zabbix Server Configuration (Auto Registration)

1. Import Zabbix templates under [templates](templates) to Zabbix server.
2. Create new auto registration action and configure it as shown in images below.

![Action Tab](documentation/auto-registration-1.png)

![Operations Tab](documentation/auto-registration-2.png)

### Deploying the Zabbix Agent Container

Simple way to run the container is to use provided [hostname.conf](hostname.conf)
and [run.sh](run.sh). Copy these to CoreOS host and customize hostname.conf to
your needs. Then execute `run.sh` as follows:

```
./run.sh <zabbix-server> <hostname> [<host-metadata>]
```

Default for host-metadata is "coreos". If you use something else, the server
action condition must be modified accordingly.

## Monitored Items

### CoreOS

* Etcd client port status
* Etcd server port status
* Memory used by processes etcd
* Memory used by processes fleetd
* Number of processes etcd
* Number of processes fleetd
* Number of processes locksmithd
* Number of processes update_engine

### Docker

* Number of docker and docker-proxy processes in host
* For each container:
  * Exit code
  * Running state
  * Process ID
* Information of processes for each running container:
  * %CPU
  * %MEM
  * RSS
  * VSZ
