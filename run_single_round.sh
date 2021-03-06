# arguments: index name,
# remove all the pods
DATE=`date '+%Y-%m-%d-%H%M'`
DAY=`date '+%Y-%m-%d'`
master="hawq-master-667dff4c6c-t8xzq"
SIZE=$1
CPU=$2
MEM=$3
STORAGE=$4
DATA_SIZE=$5
./create_all_pods.sh $DATE $SIZE $CPU $MEM $STORAGE
kubectl exec $master -- bash -c "rm -rf /home/gpadmin/tpch_sqls && rm -rf /home/gpadmin/tpch_sqls_explain"
kubectl cp tpch_sqls default/$master:/home/gpadmin/
kubectl cp tpch_sqls_explain default/$master:/home/gpadmin/
mkdir -p ~/workspace/data/hawq-tpch/$DAY/$DATE
sleep 150
#live_pods=`kubectl get pods | grep -o "group1[a-z0-9\-]*"`
#for podname in $live_pods
#do
#    kubectl describe pod $podname > ~/workspace/data/hawq-tpch/$DATE/$1/describe-$podname
#done

sed "s/DATA_SIZE/$DATA_SIZE/g;s/MASTER/$master/g" start_tpch-template.exp > start_tpch.exp
expect ./start_tpch.exp
./retrieve_data.sh $DATE
./remove_all_pods.sh $DATE
./to_db.sh ~/workspace/data/hawq-tpch/$DAY/$DATE $DATA_SIZE
sleep 5
