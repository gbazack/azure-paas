#!/bin/bash

# AKS Nodepools variables
# Database
export TF_VAR_database_vm_size="Standard_D16s_v3"    # Must support Host Encryption
export TF_VAR_database_node_count=4
export TF_VAR_database_os_disk_size_gb=50           # Must be > 29
export TF_VAR_database_az='["2"]'
# Backend
export TF_VAR_backend_vm_size="Standard_D16s_v3"    # Must support Host Encryption
export TF_VAR_backend_node_count=4
export TF_VAR_backend_os_disk_size_gb=50           # Must be > 29
export TF_VAR_backend_az='["2"]'