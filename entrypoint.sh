#!/bin/sh

set -e

CHAOS_DURATION=${CHAOS_DURATION:=60}
CHAOS_KIND=${CHAOS_KIND:="NULL"}

##Extract the base64 encoded config data and write this to the KUBECONFIG
mkdir -p ${HOME}/.kube
echo "$KUBE_CONFIG_DATA" | base64 --decode > ${HOME}/.kube/config
export KUBECONFIG=${HOME}/.kube/config

ls -l ./

#ifconfig

helm version
kubectl version
kubectl apply -f https://github.com/chaos-mesh/chaos-mesh/blob/master/manifests/crd.yaml
kubectl create ns chaos-testing
helm install chaos-mesh helm/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock
kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh

go run utils/generate_config.go --chaos-type ${CHAOS_KIND}

kubectl apply -f chaos.yaml
