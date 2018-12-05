#!/bin/bash
BASEDIR=$(dirname "$0")
pushd $BASEDIR
kubectl get pods -o wide > ./ip
kubectl describe hawqresourcepool hawq-resource-pool > ./resourcepool.yaml
python36 python/retrieve_ip.py ./ip ./resourcepool.yaml
popd
