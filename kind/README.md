1. Create Kind Cluster with the config

```bash
## scope config directory
kind create cluster --config config.yaml
```

2. Install Nginx Ingress controller with kind recommendation to work with localhost domain.

```bash
## scope config directory
## with above step successful your context should be automatically set up to Kind.
kubectl apply -k .
```

> ref: https://kind.sigs.k8s.io/docs/user/ingress


3. Install Flagger

```bash
helm repo add flagger https://flagger.app

helm upgrade --install flagger flagger/flagger \
--namespace flagger \
--set prometheus.install=true \
--set meshProvider=kubernetes \
--version 1.41.0 \
--create-namespace
```

- Install Flagger load tester

```bash
export NAMESPACE=pod-info
helm upgrade -i flagger-loadtester flagger/loadtester \
--namespace=$NAMESPACE \
--version 0.35.0 \
--create-namespace
```

- Install PodInfo in $NAMESPACE with

```bash
## scope workloads directory
kubectl apply -k .
```

