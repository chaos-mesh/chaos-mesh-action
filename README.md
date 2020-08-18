# chaos-mesh-action ![Chaos](https://github.com/chaos-mesh/chaos-mesh-action/workflows/Chaos/badge.svg)

`chaos-mesh-action` is a GitHub action that applies chaos engineering to your development workflow using Chaos Mesh. It  automatically deploys the Chaos Mesh environment and injects the specified chaos experiment. 

For more details on Chaos Mesh, refer to [https://chaos-mesh.org/](https://chaos-mesh.org/).

## Usage

### Step 1. Prepare chaos configuration file

Prepare the configuration file (YAML) of the failures which you expect to inject into the system, for example:

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

### Step 2. Encode the chaos configuration file with base64

Obtain the base64 value of the chaos configuration file using the following command:

```shell
CFG_BASE64=`base64 chaos.yaml`
```

### Step 3. Create the workflow

#### Deploy the Kubernetes cluster

A Kubernetes cluster is required for the workflow. You can use [Kind Cluster](https://github.com/marketplace/actions/kind-cluster) or [Kind Action](https://github.com/marketplace/actions/kind-kubernetes-in-docker-action) to deploy.

#### Use chaos-mesh-action

To create the workflow in GitHub action, use chaos-mesh/chaos-mesh-action in the yaml configuration file and configure the base64 value of the chaos configuration file. The chaos-mesh related configuration is as follows:

```yaml
    - name: Run chaos mesh action
      uses: chaos-mesh/chaos-mesh-action@master
      env:
        CFG_BASE64: ${CFG_BASE64}
```

For the complete configuration file, see [sample](https://github.com/chaos-mesh/chaos-mesh-action/blob/master/.github/workflows/chaos.yml).

## Limitation

- Link to private K8s clusters is not supported for now.
- Only helm 3.x is supported for now.
