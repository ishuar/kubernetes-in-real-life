# Introduction

This documentation guides you through the deployment and exposure of the sample-app using Ingress in Kubernetes. The process involves configuring ingress.yaml, service.yaml, and sample-app.yaml to define the necessary rules, services, and deployment configurations.


## Files:

1. `ingress.yaml`
   - Purpose: Defines the Ingress rules for routing traffic to the sample-app.

2. `service.yaml`
  - Purpose: Defines the Kubernetes Service for the sample-app.

3. `sample-app.yaml`
  - Purpose: Defines the deployment configuration for the sample-app.

## Apply Configurations:

Below command can be used to deploy resources in this directory.

```bash
git clone https://github.com/ishuar/kubernetes-in-real-life.git
cd kubernetes-in-real-life/expose-sample-app-with-ingress
kubectl apply -f ./
```

> Adjust the hosts values in ingress resource with the hostname you need.