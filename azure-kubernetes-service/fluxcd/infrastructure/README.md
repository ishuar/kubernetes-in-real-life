## FluxCD Configurations

- Multitenancy is enabled by default for FluxCD in Azure kubernetes Services. Therefore it is mandatory to use `fluxconfiguration` (`azurerm_kubernetes_flux_configuration`) namespace in configurations. It is possible to opt out of Multi Tenancy configuration by setting `multiTenancy.enforce=false`. More details at [Azure Docs](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2#opt-out-of-multi-tenancy).