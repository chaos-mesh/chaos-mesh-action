#!/bin/sh

set -e

CHAOS_DURATION=${CHAOS_DURATION:=60}
CHAOS_KIND=${CHAOS_KIND:="NULL"}
APP_NAME=${APP_NAME:="NULL"}

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

echo "wait pod status to running"
for ((k=0; k<10; k++)); do
    kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh > pods.status
    cat pods.status

    run_num=`grep Running pods.status | wc -l`
    pod_num=$((`cat pods.status | wc -l` - 1))
    if [ $run_num == $pod_num ]; then
        break
    fi

    sleep 1
done

kubectl apply -f chaos.yaml

sleep $CHAOS_DURATION
