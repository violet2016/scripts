# arguments: $1 index name; $2 group size; $3 cpu; $4 mem; $5 storage;
sed "s/NUM_GROUP_SIZE/$2/g; s/CPU_SIZE/$3/g; s/MEM_SIZE/$4/g; s/STORAGE_SIZE/$5/g;" hawq-resourcepool-template.yaml > hawq-resourcepool-template-$1.yaml
pushd /Users/vcheng/workspace/go-workspace/src/github.com/Pivotal-DataFabric/hawq-misc/hack/docker
sed "s/NUM_GROUP_SIZE/$2/g" Dockerfile-rm-apiproxy.template > Dockerfile-rm-apiproxy
HAWQ_DOCKER_TAG="perf" ./docker_push_test.sh
rm Dockerfile-rm-apiproxy
popd
kubectl create -f hawq-apiproxy.yaml
kubectl create -f hawq-resourcepool-template-$1.yaml
