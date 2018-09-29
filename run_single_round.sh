# arguments: index name,
# remove all the pods
DATE=`date '+%Y-%m-%d-%H%M'`
DAY=`date '+%Y-%m-%d'`
SIZE=30
CPU=1000
MEM=500
STORAGE=2000
DATA_SIZE=10
./create_all_pods.sh $DATE $SIZE $CPU $MEM $STORAGE
kubectl exec hawq-master-667dff4c6c-t8xzq -- bash -c "rm -rf /home/gpadmin/tpch_sqls"
kubectl cp tpch_sqls default/hawq-master-667dff4c6c-t8xzq:/home/gpadmin/
mkdir -p ~/workspace/data/hawq-tpch/$DAY/$DATE
sleep 70
#live_pods=`kubectl get pods | grep -o "group1[a-z0-9\-]*"`
#for podname in $live_pods
#do
#    kubectl describe pod $podname > ~/workspace/data/hawq-tpch/$DATE/$1/describe-$podname
#done

sed "s/DATA_SIZE/$DATA_SIZE/g" start_tpch-template.exp > start_tpch.exp
expect ./start_tpch.exp
./retrieve_data.sh $DATE
./remove_all_pods.sh $DATE
sleep 5
