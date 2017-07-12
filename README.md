# docker-zabbix-coreos-pulssi
Dockerized Zabbix agent for CoreOS with docker process monitoring. Standard Linux
OS template items are supported as well as Core OS and Docker specific
monitoring templates provided within this project.

Based on [https://github.com/bhuisgen/docker-zabbix-coreos] and uses its
modified agent.

## Installation

You can configure monitored hosts either manually or using auto registration.
Auto registration can be useful if managing many (possibly transient) Core OS
hosts. Itherwise manual configuration is quite sufficient.

### Zabbix Server Configuration (Manual)

1. Import Zabbix templates under [templates](templates) to Zabbix server (needs to be done only once).
2. Create host in Zabbix server.
3. Apply templates to host as shown in image below.

![Templates Tab](documentation/host-config-templates.png)

### Zabbix Server Configuration (Auto Registration)

1. Import Zabbix templates under [templates](templates) to Zabbix server.
2. Create new auto registration action and configure it as shown in images below.

![Action Tab](documentation/auto-registration-1.png)

![Operations Tab](documentation/auto-registration-2.png)

### Deploying the Zabbix Agent Container

Simple way to run the container is to use provided [hostname.conf](hostname.conf)
and [start.sh](start.sh). Copy these to CoreOS host and customize hostname.conf
to your needs. Then execute `start.sh` as follows:

```
./start.sh <zabbix-server> <hostname> [<host-metadata>]
```

Default for host-metadata is "coreos". If you use something else _and_
auto-registration, the server action condition must be modified accordingly.

## Template Items

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

* Number of containers running in host
* Discovery of docker containers with following items
  * Status (1: not running, 2: running, 3: error)
  * Uptime
  * CPU usage
  * Disk usage
  * Memory usage
  * Incoming network traffic (eth0)
  * Outgoing network traffic (eth0)

Note that network traffic monitoring is based only on eth0 interface which won't
work if using `--net="host"` option for container and will not show all traffic
if additional network interfaces are created for container.
