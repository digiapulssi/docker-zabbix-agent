# docker-zabbix-agent

Dockerized Zabbix agent for host and containers monitoring

* Zabbix Agent version 3.2.3 patched for host monitoring via volume mounts
* Container monitoring items included
* CoreOS specific monitoring items included (use them if host is CoreOS)
* Enables host and container monitoring in all Linux-based hosts

### Credits

Zabbix Agent patching and CoreOS monitoring template is based on
bhuisgen's work at https://github.com/bhuisgen/docker-zabbix-coreos.

## Usage

```
docker run -d \
  --restart=always \
  -p 10050:10050 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /dev:/host/dev:ro \
  -v /etc:/host/etc:ro \
  -v /var/run/docker.sock:/coreos/var/run/docker.sock \
  --env ZABBIX_SERVER=<zabbix server ip> \
  --env METADATA=<host metadata> \
  --env HOST=<host name> \
  --env PSKKey=<PSK TLS key> \
  --env PSKIdentity=<PSK identity> \
  digiapulssi/docker-zabbix-agent
```

### Notes

* Port mapping `-p 10050:10050` is optional and required only for passive agent checks.
* Metadata `METADATA` environment variable is optional and required only if
  auto registration is used in Zabbix Server.
* If host `HOST` environment variable is omitted, the container generates a host name
  `<host metadata>-<machine id>`, where machine id is read from /etc/machine-id
* PSK environment variables `PSKKey` and `PSKIdentity` are optional and
  required only if TLS PSK key is used for encryption and authentication with Zabbix Server
* To view Zabbix agent log, run `docker logs <container id>`

## Zabbix Items Supported

### Linux OS Template

Standard Linux OS Template items are supported for host monitoring.

![Linux Items Sample](https://github.com/digiapulssi/docker-zabbix-agent/raw/master/documentation/latestdata-oslinux.png)

Items known NOT to work properly:

* Number of logged in users (Zabbix uses who command inside docker container which shows the number of
  loggers users inside the container, not inside the host)
* Discovery founds virtual filesystem mounts used by docker volumes but their monitoring does not work

### CoreOS

The following items support host CoreOS monitoring. You can use them if the host is CoreOS.

A template file for Zabbix server is included: [template_coreos.xml](https://raw.githubusercontent.com/digiapulssi/docker-zabbix-agent/master/templates/template_coreos.xml).
The template items use active agent checks.

Supported items:

* Etcd client port status
* Etcd server port status
* Memory used by processes etcd
* Memory used by processes fleetd
* Number of processes etcd
* Number of processes fleetd
* Number of processes locksmithd
* Number of processes update_engine

![CoreOS Items Sample](https://github.com/digiapulssi/docker-zabbix-agent/raw/master/documentation/latestdata-coreos.png)

### Docker Containers

The following items support monitoring Docker containers running in the host.

A template file for Zabbix server is included: [docker-monitoring.xml](https://raw.githubusercontent.com/digiapulssi/docker-zabbix-agent/master/templates/docker-monitoring.xml).
The template items use active agent checks.

Supported items:

* Number of containers running in host
* Discovery of docker containers with following items
  * Status (1: not running, 2: running, 3: error)
  * Uptime
  * CPU usage
  * Disk usage
  * Memory usage
  * Incoming network traffic (eth0)
  * Outgoing network traffic (eth0)

![Docker Items Sample](https://github.com/digiapulssi/docker-zabbix-agent/raw/master/documentation/latestdata-docker.png)

Note that network traffic monitoring is based only on eth0 interface.

* It doesn't work if `--net=host` option is used for the monitored container
* Network monitoring does not show all traffic if additional network interfaces are used for monitored container

## Implementation Notes

The patched Zabbix Agent version and packaging scripts can be found at https://github.com/digiapulssi/zabbix-agent/tree/docker-host-monitoring.
