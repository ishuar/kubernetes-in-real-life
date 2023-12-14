- [Secret Management](#secret-management)
  - [external-secrets-operator](#external-secrets-operator)

# Secret Management

Secret Management with `external-secrets-operator` with Azure Key Vault as backend.

## external-secrets-operator

This directory contains `External Secrets Operator` helm release and its secret store configurations.

[External Secrets Operator](https://external-secrets.io/latest/) is a Kubernetes operator that integrates external secret management systems like AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault, IBM Cloud Secrets Manager, CyberArk Conjur and many more. The operator reads information from external APIs and automatically injects the values into a Kubernetes Secret

It is installed using official helm chart [external-secrets](https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets)

- Official documentation: [External Secrets Operator](https://external-secrets.io/latest/)
- Official Documentation: [secretstore](https://external-secrets.io/latest/api/secretstore/)