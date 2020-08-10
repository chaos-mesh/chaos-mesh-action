# chaos-mesh-action ![Chaos](https://github.com/chaos-mesh/chaos-mesh-action/workflows/Chaos/badge.svg)

A GitHub Action that applies chaos enginnering by Chaos Mesh in the workflow. More detail about Chaos Mesh can see [https://chaos-mesh.org/](https://chaos-mesh.org/).

## Features

`chaos-mesh-action` automatically deploy the Chaos Mesh environment and injects the specified chaos experiment.

## Example Usage

### Prepare chaos configuration file

First, prepare the chaos’ yaml configuration file which you expect to be injected into the system, for example:

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
 name: network-delay
 namespace: busybox
spec:
 action: delay # the specific chaos action to inject
 mode: all
 selector:
   pods:
     busybox:
       - busybox-0
 delay:
   latency: "10ms"
 duration: "5s"
 scheduler:
   cron: "@every 10s"
 direction: to
 target:
   selector:
     pods:
       busybox:
         - busybox-1
   mode: all
```

### Encode chaos configuration file with base64

Obtain the base64 value of the chaos configuration file through the following command:

```shell
CFG_BASE64=`base64 chaos.yaml`
```

### Create the workflow

#### Deploy K8s cluster

Need to deploy a K8s cluster in workflow, can use [Kind Cluster](https://github.com/marketplace/actions/kind-cluster) or [Kind Action](https://github.com/marketplace/actions/kind-kubernetes-in-docker-action).

#### Use chaos-mesh-action

When creating the workflow in Actions, use chaos-mesh/chaos-mesh-action in the yaml configuration file and configure the base64 value of the chaos configuration file. The chaos-mesh related configuration is as follows:

```yaml
    - name: Run chaos mesh action
      uses: chaos-mesh/chaos-mesh-action@master
      env:
        CFG_BASE64: ${CFG_BASE64}
```

For the complete configuration file, see the [sample configuration file](https://github.com/chaos-mesh/chaos-mesh-action/blob/master/.github/workflows/chaos.yml).

## Limitation

- Link to private K8s clusters is not supported now.
- Only support helm 3.x now.
