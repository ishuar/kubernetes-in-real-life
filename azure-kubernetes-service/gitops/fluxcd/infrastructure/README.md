- [Infrastructure](#infrastructure)
  - [cert-manager](#cert-manager)
  - [external-dns](#external-dns)
  - [ingress-nginx](#ingress-nginx)
  - [storageClasses](#storageclasses)

# Infrastructure

Within this directory, you'll find essential Kubernetes applications that form the backbone supporting end-user applications in the cluster.

## cert-manager

This directory contains `cert-manager` helm release configurations.

[cert-manager](https://cert-manager.io/docs/) adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

It is installed using the official helm chart [cert-manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager/1.13.0).

- Official documentation: [cert-manager](https://cert-manager.io/docs/)

## external-dns

This directory contains `ExternalDNS` helm release configurations.

[ExternalDNS](https://github.com/kubernetes-sigs/external-dns) makes Kubernetes resources discoverable via public DNS servers. It retrieves a list of resources (Services, Ingresses, etc.) from the Kubernetes API to determine a desired list of DNS records, ExternalDNS allows you to control DNS records dynamically via Kubernetes resources in a DNS provider-agnostic way.

It is installed using official helm chart [external-dns](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)

- Official documentation: [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)

## ingress-nginx

This directory contains `ingress-nginx` helm release configurations.

An Ingress controller is a specialized load balancer for Kubernetes (and other containerized) environments. Kubernetes is the de facto standard for managing containerized applications. For many enterprises, moving production workloads into Kubernetes brings additional challenges and complexities around application traffic management. An Ingress controller abstracts away the complexity of Kubernetes application traffic routing and provides a bridge between Kubernetes services and external ones

More details are [here]((https://www.nginx.com/resources/glossary/kubernetes-ingress-controller/#:~:text=An%20Ingress%20controller%20abstracts%20away,containers)%20running%20inside%20the%20platform)

`ingress-nginx` is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.

It is installed using official helm chart [ingress-nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)

- Official documentation: [ingress-nginx](https://kubernetes.github.io/ingress-nginx/how-it-works/)

## storageClasses

This section contains custom storage classes for applications, offering different configurations than the default for new storage classes.

- Official documentation: [storageClasses](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- AKS Storage Classes: [AKS storageClasses](https://learn.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes)
