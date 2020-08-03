# chaos-mesh-actions [WIP]

Using Chaos Mesh in Github Action.

Example:

```yaml
name: Push

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:

    - name: Creating kind cluster
      uses: helm/kind-action@v1.0.0-rc.1

    - name: Print cluster information
      run: |
        kubectl config view
        kubectl cluster-info
        kubectl get nodes
        kubectl get pods -n kube-system
        helm version
        kubectl version
    - uses: actions/checkout@v2

    - name: Deploy an application
      run: |
        kubectl run nginx --image=nginx

    - name: Run chaos mesh action
      uses: chaos-mesh/chaos-mesh-actions@master
      env:
        CFG_BASE64:${CFG_BASE64}

    - name: Verify
      run: |
        echo "do some verify"
        kubectl exec busybox-0 -it -n busybox -- ping -c 30 busybox-1.busybox.busybox.svc

```

The ${CFG_BASE64} is generate by command:

```shell
CFG_BASE64=`base64  ./chaos.yaml`
```

`chaos.yaml` is your chaos config file.
