kubectl delete -f hawq-resourcepool-template-$1.yaml
kubectl delete hawqqueries.rm.pivotaldata.io -l app=hawq-query
kubectl delete -f hawq-apiproxy.yaml
rm hawq-resourcepool-template-$1.yaml
./delete.sh prometheus-2018-09-26