<!-- BEGIN_TF_DOCS -->
## Requirements

- Terraform version v1.7+
- An existing Azure resource group with [lock protection](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json)
- [Service principal](https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?tabs=bash) named `terraform` in the above-mentioned resource group with the required roles (by default `Contributor`). 

#### Terraform providers

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](##requirement\_azurerm) | ~> 3.90 |
| <a name="requirement_kubernetes"></a> [kubernetes](##requirement\_kubernetes) | ~> 2.26 |
| <a name="requirement_helm"></a> [helm](##requirement\_helm) | ~> 2.12 |


## How to use the PaaS environment

1. Set deployment parameters:
- There exists three predefined deployment files namely `small.sh`, `large.sh` and `custom.sh`.
- Select and update a file based on the customer requirements.

2. Create an Azure container storage to save the Terraform state:

```bash
./azure-paas.sh init small.sh
```

3. Deploy the Azure PaaS with the following command:

```bash
./azure-paas.sh create small.sh
```

4. Test the PaaS by deploying a two-tier application on it:

```bash
./azure-paas.sh test small.sh
```

5. To destroy the PaaS environment, remove the Lock protection then run the following:

```bash
./azure-paas.sh delete small.sh
```

## Terraform Modules

| Name | Source | Version |
|------|--------|:---------:|
| <a name="module_keyvault"></a> [keyvault](./keyvault/)                        | ./keyvault                | 1.0 |
| <a name="module_network"></a> [network](./network/)                           | ./network                 | 1.0 |
| <a name="module_gateway"></a> [gateway](./gateway/)                           | ./gateway                 | 1.0 |
| <a name="module_aks"></a> [aks](./aks/)                                       | ./aks                     | 1.0 |
| <a name="module_kubernetes"></a> [namespace](./kubernetes/)                   | ./kubernetes              | 1.0 |
<!-- | <a name="module_cert-manager"></a> [cert-manager](./kubernetes/cert-manager/) | ./kubernetes/cert-manager | 1.0 |
| <a name="module_boundary"></a> [boundary](./boundary/)                        | ./kubernetes/boundary     | 1.0 |
| <a name="module_ingress"></a> [ingress](./kubernetes/ingress/)                | ./kubernetes/ingress      | 1.0 | -->


## Data Source

| Name | Description | Type |
|:------|:------     |:------:|
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-source/resource_group) | Use this data source to access information about an existing Resource Group |Data |
| [azurerm_client_config.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)  | Use this data source to access the configuration of the AzureRM provider |Data |

## Inputs

The input variables are described in `small.sh`, `large.sh` and `custom.sh` files.


## Outputs

| Name | Description |
|------|-------------|
| <a name="gateway_frontend_ip"></a> [gateway\_frontend\_ip](./outputs.tf) | Public IPv4 address of application gateway |

## References

- Click [here](./DOCUMENTATION.md) to have an overview of the PaaS architecture
<!-- END_TF_DOCS -->
