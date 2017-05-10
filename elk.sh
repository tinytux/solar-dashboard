#!/bin/bash
#
# ELK service script.
#

SCRIPTDIR="$(dirname "$0")"

if ! [ -x "$(command -v docker-compose)" ]; then
    echo "docker and docker-compose required."
    echo "See https://docs.docker.com/compose/install/"
    exit 1
fi

if ! [ -x "$(command -v awk)" ]; then
    echo "awk required. Run 'sudo apt-get install gawk'"
    exit 1
fi

RAMSIZE="$(free | awk '/^Mem:/{print int($2 / 1000000)}')"
if [[ ${RAMSIZE} -lt 8 ]]; then
    echo "${RAMSIZE} GB RAM detected. This configuration requires at least 8 GB RAM."
    exit 1
fi

MAPCOUNT="$(cat /proc/sys/vm/max_map_count)"
if [[ ${MAPCOUNT} -lt 262144 ]]; then
    echo "Current max_map_count is ${MAPCOUNT}. elasticsearch requires at least 262144:"
    echo "https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html"
    echo "Run 'sudo sysctl -w vm.max_map_count=262144'"
    exit 1
fi

RAMSIZE="$(free | awk '/^Mem:/{print int($2 / 1000000)}')"
if [[ ${RAMSIZE} -lt 8 ]]; then
    echo "${RAMSIZE} GB RAM detected. This configuration requires at least 8 GB RAM."
    exit 1
fi


case "$1" in
'start' | '--start')
    echo "Starting logstash, elasticsearch, kibana and grafana..."
    docker-compose up -d
    docker-compose ps
    ;;
'stop' | '--stop')
    echo "Stopping logstash, elasticsearch, kibana and grafana..."
    docker-compose stop
    ;;
'rm' | 'remove' | '--remove')
    echo "Stopping and removing all containers including the elasticsearch index..."
    docker-compose kill
    docker-compose rm -f logstash elasticsearch kibana grafana
    rm -rf docker-elk/elasticsearch/data/nodes/0
    #rm -rf docker-elk/grafana/data/plugins
    #rm -rf docker-elk/grafana/data/sessions
    ;;
'logstash-restart' | '--logstash-restart')
    echo "Restarting logstash..."
    docker-compose restart logstash
    docker-compose logs --tail=100 -f logstash
    ;;
*)  echo "ELK service script"
    echo "~^~~~~~~~~~~~~~~^~"
    echo " Usage:"
    echo "      Start all containers:"
    echo "        ./elk.sh start"
    echo 
    echo "      Stop all containers:"
    echo "        ./elk.sh stop"
    echo 
    echo "      Stop and delete all containers including the elasticsearch index:"
    echo "        ./elk.sh rm"
    echo 
    echo "      Restart the logstash container (required after configuration change):"
    echo "        ./elk.sh logstash-restart"
    echo 
    exit 1
    ;;
esac

echo "Done."

