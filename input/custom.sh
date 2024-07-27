#!/bin/bash
# Copyright: Edinio Zacko
# contact: morenzack@gmail.com


#Azure Resource Group Variables
export TF_VAR_resource_group_name=ARM_RG_NAME        # Targeted Azure resource group name
export TF_VAR_location_suffix=francecentral          # Location of the resource group. Example: francecentral
export TF_VAR_service_principal_name=ARM_SP_NAME     # Name of the Service Principal identity
export TF_VAR_client_id=ARM_SP_APP_ID                # AppId of the Service Principal
export TF_VAR_client_secret=ARM_SP_APP_ID            # Password of the Service Principal
export TF_VAR_tenant_id=ARM_SP_TENANT_ID             # TenantId of the Service Principal
export TF_VAR_subscription_id=ARM_SUBSCRIPTION_ID    # Targeted Azure Subscription Id
export TF_VAR_location="France Central"              #      Example: "France Central"


# Storage variables for TFstate
export TF_VAR_storage_account_name="${TF_VAR_prefix_name}tfstate"
export TF_VAR_container_name="${TF_VAR_prefix_name}tfstate"

# Backend config variables for TFstate
export ARM_CLIENT_ID="${TF_VAR_client_id}"
export ARM_CLIENT_SECRET="${TF_VAR_client_secret}"
export ARM_SUBSCRIPTION_ID="${TF_VAR_subscription_id}"
export ARM_TENANT_ID="${TF_VAR_tenant_id}"
export TF_VAR_boundary_gcp_sa=PATH_TO_GCP_SA_FILE

# Kubernetes Variables
export TF_VAR_env_dns_name=ENV_DNS
export TF_VAR_cloud_dns_sa=PATH_TO_GCP_SA_FILE


# AKS Cluster Variables
export TF_VAR_prefix_name=PREFIX_NAME                 # Must contain only small letters and digits! Should 10 characters Max.
export TF_VAR_dns_prefix=${TF_VAR_prefix_name}
export TF_VAR_kubernetes_version=K8S_VERSION
export TF_VAR_tag_used_by=TEAM/CLIENT
export TF_VAR_tag_purpose=PURPOSE

# AKS Nodepools variables
# nodepool
export TF_VAR_nodepool_vm_size=ARM_VM_SIZE          # Must support Host Encryption
export TF_VAR_nodepool_node_count=1
export TF_VAR_nodepool_os_disk_size_gb=50           # Must be > 29
export TF_VAR_nodepool_az='["1", "2", "3"]'