### retrieve data from kubenetes ###

DATE=`date +%Y-%m-%d`
#mkdir -p ~/workspace/data/hawq-tpch/$DATE/$1/
cp hawq-resourcepool-template-$1.yaml ~/workspace/data/hawq-tpch/$DATE/$1/
kubectl get pods -o wide > ~/workspace/data/hawq-tpch/$DATE/$1/ip

sed "s/TIME_HOLDER/$1/g" log_template.json > log.json
es2csv -q '*' -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i prometheus-2018-09-26 -o ~/workspace/data/hawq-tpch/$DATE/$1/prometheus.csv -k
es2csv -q @'./log.json' -r -u http://localhost:8001/api/v1/namespaces/hawq-monitoring/services/elasticsearch-logging/proxy -i logstash-`date +%Y.%m.%d` -o ~/workspace/data/hawq-tpch/$DATE/$1/api-log.csv -k
logfile="~/workspace/data/hawq-tpch/$DATE/$1/api-log.csv"

kubectl cp default/hawq-master-667dff4c6c-t8xzq:/home/gpadmin/test_result/ ~/workspace/data/hawq-tpch/$DATE/$1/

if [ -f $logfile ]; then
   echo "File $logfile saved."
else
   echo "File $logfile does not saved. start rescue"
   ./rescue.sh ~/workspace/data/hawq-tpch/$DATE/$1
fi
rm log.json

filename=`kubectl exec hawq-master-667dff4c6c-t8xzq -- bash -c "cd /home/gpadmin/hawq-data-directory/masterdd/pg_log && ls -ltr | tail -1 | xargs -n 1 | tail -1"`

kubectl cp default/hawq-master-667dff4c6c-t8xzq:/home/gpadmin/hawq-data-directory/masterdd/pg_log/$filename ~/workspace/data/hawq-tpch/$DATE/$1/
live_pods=`kubectl get pods | grep -o "group1[a-z0-9\-]*"`
for podname in $live_pods
do
    echo "$podname"
    segfilename=`kubectl exec $podname -- bash -c "cd /home/gpadmin/hawq-data-directory/segmentdd/pg_log && ls -ltr | tail -1 | xargs -n 1 | tail -1"`
    kubectl cp default/$podname:/home/gpadmin/hawq-data-directory/segmentdd/pg_log/$segfilename ~/workspace/data/hawq-tpch/$DATE/$1/
    mv ~/workspace/data/hawq-tpch/$DATE/$1/$segfilename ~/workspace/data/hawq-tpch/$DATE/$1/$podname-$segfilename
done
