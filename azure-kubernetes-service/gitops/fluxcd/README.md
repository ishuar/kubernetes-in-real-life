- [fluxcd](#fluxcd)
  - [FluxCD Configurations](#fluxcd-configurations)
- [Directory Structure](#directory-structure)
    - [cluster-issuer](#cluster-issuer)
    - [infrastructure](#infrastructure)
    - [observability](#observability)
    - [secret-store](#secret-store)
    - [weave-gitops](#weave-gitops)

# fluxcd

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy.

- Official Documentation: [flux](https://fluxcd.io/flux/)

## FluxCD Configurations

GitOps with Flux v2 is enabled as a cluster extension in Azure Arc-enabled Kubernetes clusters or Azure Kubernetes Service (AKS) clusters, which is being used in this project.


Multitenancy is enabled by default for FluxCD in Azure kubernetes Services. Therefore it is mandatory to use `fluxconfiguration` (`azurerm_kubernetes_flux_configuration`) namespace in configurations. It is possible to opt out of Multi Tenancy configuration by setting `multiTenancy.enforce=false`. More details at [Azure Docs](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2#opt-out-of-multi-tenancy).

- Official Documentation: [Deploy applications using GitOps with Flux v2](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli)

# Directory Structure

### [cluster-issuer](./cluster-issuer/)

This directory contains the cluster issuer kubernetes resources that represent certificate authorities (CAs) that are able to generate signed certificates by honoring certificate signing requests. These are further used by `cert-manager` in the infrastructure directory to dynamically generate certificates based on ingress in the Kubernetes cluster.

- Official Documentation: [Issuer](https://cert-manager.io/docs/concepts/issuer/)

### [infrastructure](./infrastructure/)

Within this directory, you'll find essential Kubernetes applications that form the backbone supporting end-user applications in the cluster.

- Documentation: [infrastructure-readme](./infrastructure/README.md)

### [observability](./observability/)

This directory contains the kubernetes cluster and application observability configurations.

Components:

1. [`kube-prometheus-stack`](https://github.com/prometheus-operator/kube-prometheus)  as the fundamental monitoring system.This stack is meant for cluster monitoring, so it is pre-configured to collect metrics from all Kubernetes components.

2. [Grafana](https://grafana.com/docs/grafana/latest/fundamentals/?pg=oss-graf&plcmt=hero-btn-2) is open source visualization and analytics software. It allows you to query, visualize, alert on, and explore your metrics, logs, and traces no matter where they are stored. It provides you with tools to turn your time-series database (TSDB) data into insightful graphs and visualizations.

3. [Grafana Loki](https://grafana.com/docs/loki/latest/?pg=oss-graf&plcmt=hero-btn-2) is an open source, set of components that can be composed into a fully featured logging stack. more details at [here](https://grafana.com/docs/loki/latest/get-started/overview/?pg=oss-graf&plcmt=hero-btn-2)

> NOTE: To be configurred.

4. [The blackbox exporter](https://github.com/prometheus/blackbox_exporter) allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP, ICMP and gRPC.

> NOTE: To be configurred.

### [secret-store](./secret-store/)

This directory contains `external-secret-operator` secret store configurations facilitating secret management in a GitOps-native way without defining secret values in Git.

- Official Documentation: [secretstore](https://external-secrets.io/latest/api/secretstore/)

### [weave-gitops](./weave-gitops/)

This directory contains the Weave GitOps, which is a simple, open source developer platform for people who want cloud native applications but who don't have Kubernetes expertise. However only user interface of the weave-gitops have been used.

The Weave GitOps user interface enables you to manage and view all of your applications in one place

 It is also acting as a end-user application for this example.

- Official Documentation: [Weave GitOps Open Source UI](https://docs.gitops.weave.works/docs/open-source/getting-started/ui-OSS/)