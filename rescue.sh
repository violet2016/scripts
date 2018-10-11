# logstash date should be one day early
firstfile=`ls $1/result_test_* | sort -n | head -1`
lastfile=`ls $1/result_test_* | sort -n | tail -1`
start_time=`grep "StartTime:" $firstfile | sed -En "s/StartTime:(.+)/\1/p"`
end_time=`grep 'EndTime:' $lastfile | sed -En "s/EndTime:(.+)/\1/p"`
sed "s/STARTTIME_HOLDER/$start_time/g;s/ENDTIME_HOLDER/$end_time/g" log_rescue_template.json > log_rescue.json
es2csv -q @'./log_rescue.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date -v-1d +%Y.%m.%d` -o $1/api-log.csv -k
rm ./log_rescue.json