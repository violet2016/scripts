
prometheus_db_suffix=$1
DATE=`date '+%Y-%m-%d %H:%M:%S'`
sed "s/TIME_HOLDER/$DATE/g" log_template.json > log.json
es2csv -q '*' -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i prometheus-$1 -o /tmp/prometheus.csv -k
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date +%Y.%m.%d` -o /tmp/api-log.csv -k
# delete the prometheus database
./delete.sh prometheus-$1
#call python program to handle the files
