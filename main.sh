#!/bin/sh

set -e

CHAOS_DURATION=${CHAOS_DURATION:=60}
CHAOS_KIND=${CHAOS_KIND:="NULL"}

git clone https://github.com/WangXiangUSTC/chaos-mesh-actions.git
go run chaos-mesh-actions/utils/generate_config.go --chaos-type ${CHAOS_KIND}

git clone https://github.com/chaos-mesh/chaos-mesh.git
cd chaos-mesh
mv ../chaos.yaml ./

helm version
kubectl version
kubectl apply -f ./manifests/crd.yaml
kubectl create ns chaos-testing
helm install chaos-mesh helm/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock
kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh
kubectl apply -f chaos.yaml
