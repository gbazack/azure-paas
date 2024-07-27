#!/bin/bash

# AKS Nodepools variables
# Clickhouse
export TF_VAR_nodepool_vm_size="Standard_D16s_v3"    # Must support Host Encryption
export TF_VAR_nodepool_node_count=4
export TF_VAR_nodepool_os_disk_size_gb=50           # Must be > 29
export TF_VAR_nodepool_az='["2"]'