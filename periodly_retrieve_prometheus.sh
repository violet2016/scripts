#!/bin/bash
BASEDIR=$(dirname "$0")
pushd $BASEDIR
prometheus_db_suffix=$1
DATE=`date '+%Y-%m-%d %H:%M:%S'`
sed "s/TIME_HOLDER/$DATE/g" ./log_template.json > ./log.json
es2csv -q '*' -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i prometheus-$1 -o /tmp/prometheus.csv -k
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date +%Y.%m.%d` -o /tmp/api-log-0.csv -k
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date -d '-1 day' +%Y.%m.%d` -o /tmp/api-log-1.csv -k

./delete.sh prometheus-$1
set -e
./to_db_prometheus.sh /tmp/prometheus.csv
rm /tmp/prometheus.csv
popd
