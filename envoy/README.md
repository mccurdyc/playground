# Playground

## Usage for Testing Envoy Things Locally

1. Make a change to `minimal-envoy-config.yaml`
2. Watch Tilt do something
3. Curl ....

## Getting Started with Local Kubernetes

### Quickstart

1. Install the required dependencies
    - just - http://just.systems/
    - k3d - https://k3d.io/
    - helm - https://helm.sh/
    - tilt - https://tilt.dev/

2. Run `just k3d-init`

3. Access Envoy at `http://localhost:10000` and Envoy's admin page at `http://localhost:9901`

### Tilt

Run `just tilt-up`

- You can view Tilt's web UI at `http://localhost:10350`

Tilt runs in the k3d cluster started by `just k3d-init`.

### Connecting to the k3d cluster

Set your context 

```bash
kubectl config set-context k3d-tilt
```

```bash
kubectl get po
```
