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
      uses: WangXiangUSTC/chaos-mesh-actions@master
      env:
        CHAOS_KIND: NetworkChaos
        CHAOS_DURATION: 30
        APP_NAME: nginx
```
