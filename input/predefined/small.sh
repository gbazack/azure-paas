#!/bin/bash

# AKS Nodepools variables
# nodepool
export TF_VAR_nodepool_vm_size="Standard_DS2_v2"          # Must support Host Encryption
export TF_VAR_nodepool_node_count=2
export TF_VAR_nodepool_os_disk_size_gb=30           # Must be > 29
export TF_VAR_nodepool_az='["2"]'