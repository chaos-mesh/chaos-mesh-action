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
for ((k=0; k<30; k++)); do
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
