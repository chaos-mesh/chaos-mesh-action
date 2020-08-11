#!/bin/sh

set -e

CFG_BASE64=${CFG_BASE64:="NULL"}

echo "generate chaos.yaml"
if [ "$CFG_BASE64" != "NULL" ]; then
    echo "$CFG_BASE64" | base64 --decode > chaos.yaml
else
    echo "CFG_BASE64 is empty"
    exit 1
fi
cat chaos.yaml

echo "install chaos mesh"
helm version
kubectl version
kubectl apply -f https://raw.githubusercontent.com/chaos-mesh/chaos-mesh/master/manifests/crd.yaml
kubectl create ns chaos-testing
helm install chaos-mesh helm/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

echo "wait pod status to running"
kubectl wait --namespace=chaos-testing --for=condition=Ready pods  --all
kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh

kubectl apply -f chaos.yaml
