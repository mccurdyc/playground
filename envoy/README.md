# Playground

## Getting Started with Local Kubernetes

### Quickstart

1. Install the required dependencies
    - just - http://just.systems/
    - k3d - https://k3d.io/
    - helm - https://helm.sh/
    - tilt - https://tilt.dev/

2. Run `just tilt-up`

## Usage for Testing Envoy directly

1. Make a change to `minimal-envoy-config.yaml`
2. Port-forward Envoy

    ```bash
    kubectl port-forward -n playground svc/envoy 10000:10000 &
    ```

3. Access Envoy at `http://localhost:10000` and Envoy's admin page at `http://localhost:9901`

## Usage for Testing Envoy Gateway-fronted backends

1. Port forward the Envoy Gateway service 

    ```bash
    kubectl -n envoy-gateway-system \
    port-forward \
    svc/$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}') \
    8888:80 &
    ```

2. Curl the backend via the Envoy Gateway

    ```bash
    curl --verbose --header "Host: www.example.com" http://localhost:8888/get
    ```

### Tilt

Run `just tilt-up`

- You can view Tilt's web UI at `http://localhost:10350`

Tilt runs in the k3d cluster started by `just k3d-start`.

### Connecting to the k3d cluster

Set your context 

```bash
kubectl config set-context k3d-k3s-default
```

```bash
kubectl get po --namespace playground
```

## Debugging

If you run into weird errors around ports, you may need to run `docker stop $(docker ps -q) && docker system prune --all --force`
