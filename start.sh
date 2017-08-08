#/bin/bash
set -e

# Option defaults
HELP="0"
NETWORK_SETTINGS=""
CONTAINER_NAME=coreos-agent

# Parse options
OPTS=$(getopt -o h -l enable-passive,container-name: -- "$@")
eval set -- $OPTS

while true ; do
  case "$1" in
    --enable-passive) NETWORK_SETTINGS="-p 10050:10050 --net=host" ; shift ;;
    --container-name) CONTAINER_NAME="$2" ; shift 2 ;;
    -h) HELP="1" ; shift ;;
    --) shift ; break ;;
    *) echo error ; exit 1 ;;
  esac
done

if [ $# -lt 2 ] || [ "$HELP" = "1" ]; then
    echo "USAGE: $(basename $0) [options] <zabbix-server> <hostname> [<host-metadata>]"
    echo ""
    echo "OPTIONS:  --enable-passive         Enable passive checks, publishes port 10050 and uses host networking for container"
    echo "          --container-name <name>  Override default agent container name (coreos-agent)"
    exit 0
fi

ZABBIX_SERVER=$1
HOSTNAME=$2
HOST_METADATA=${3:-coreos}

# Check if container with same name already exists
if [ "$(docker ps -qaf name=$CONTAINER_NAME)" != "" ]; then
  read -p "Docker container with name ${CONTAINER_NAME} already exists, delete [y/N]: " -n1 input
  echo ""
  if [ "y" = "$input" ]; then
    echo "Stopping/removing old proxy container..."
    docker stop ${CONTAINER_NAME} >/dev/null
    docker rm ${CONTAINER_NAME} >/dev/null
  else
    echo "Script terminated. Preserved existing container."
    exit 0
  fi
fi

# Start new container
docker run -d $NETWORK_SETTINGS --restart=always \
    -v /proc:/coreos/proc:ro -v /sys:/coreos/sys:ro -v /dev:/coreos/dev:ro \
    -v /var/run/docker.sock:/coreos/var/run/docker.sock \
    -v /etc/zabbix/$HOSTNAME.conf:/etc/zabbix/$HOSTNAME.conf \
    --name $CONTAINER_NAME digiapulssi/docker-zabbix-coreos  \
    $ZABBIX_SERVER $HOST_METADATA $HOSTNAME
