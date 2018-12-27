#!/bin/bash
BASEDIR=$(dirname "$0")
pushd $BASEDIR
prometheus_db_suffix=$1
DATE=`date -d '-1 hour' '+%Y-%m-%d %H:%M:%S'`
sed "s/TIME_HOLDER/$DATE/g" ./log_template.json > ./log.json
echo "===================== get prometheus metrics =====================\n"
es2csv -q '*' -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i prometheus-$1 -o /tmp/prometheus.csv -k
echo "===================== get api proxy logs =====================\n"
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date +%Y.%m.%d` -o /tmp/api-log-0.csv -k
echo "===================== get last day's api proxy logs =====================\n"
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date -d '-1 day' +%Y.%m.%d` -o /tmp/api-log-1.csv -k

./delete.sh prometheus-$1
set -e
echo "===================== write prometheus metrics to database =====================\n"
./to_db_prometheus.sh /tmp/prometheus.csv
echo "===================== get last day's api proxy logs =====================\n"
python36 python/api_log.py /tmp/api-log-0.csv /tmp/api-log-1.csv
#rm /tmp/prometheus.csv
rm ./log.json
popd
