#!/bin/bash

function usage() {
    # This function outputs the user manual
    local this_script=$(basename $0)
    cat <<EOF

    $this_script: Automation script to deploy and destroy a Kubernetes cluster on Azure.

    Usage: ./$this_script <action> <input>

        <action>:
                init          to create container storage for TF states
                create        to deploy the k8s cluster and its addons
                test          to deploy a two-tier application on the aks cluster
                delete        to destroy all resources of the enviroment
        <input>: parameters.sh
EOF
}

function create_bucket() {
    # This function creates an Azure storage container
    #       for storing the Terraform state files
    local container_name="$1"
    local tf_var_file_full_path="$2"

    mkdir -p "${PWD}/${container_name}"
    container_full_path=$(readlink -f $container_name)
    cp ./storage/* "${container_full_path}/"
    source $tf_var_file_full_path

    cd "${container_full_path}" && terraform init -upgrade=false
    cd "${container_full_path}" && terraform apply
}

case "$1" in
    "init")
        echo "Initializing deployment"
        tf_var_file=$(readlink -f $2)

        if [[ -n "${tf_var_file}" ]]; then
            source $tf_var_file
            echo "Creating container storage for TF state"
            create_bucket "${TF_VAR_container_name}" "${tf_var_file}"
        else
            echo -ne "\e[31m Error:  Invalid input values!\e[39m\n"
            usage
            exit 1
        fi
    ;;
    "create")
        tf_var_file=$(readlink -f $2)
        if [[ -n "${tf_var_file}" ]]; then
            source $tf_var_file
            echo "Creating the Kubernetes cluster and its addons"
            terraform init -backend-config="resource_group_name=${TF_VAR_resource_group_name}" \
                -backend-config="storage_account_name=${TF_VAR_storage_account_name}" \
                -backend-config="container_name=${TF_VAR_container_name}" -reconfigure
            terraform apply --target module.keyvault
            terraform apply --target module.network --target module.gateway
            terraform apply --target module.aks
        else
            echo -ne "\e[31m Error:  Invalid input values!\e[39m\n"
            usage
            exit 1
        fi
    ;;
    "test")
        tf_var_file=$(readlink -f $2)
        if [[ -n "${tf_var_file}" ]]; then
            source $tf_var_file
            echo "Deploying a two-tier application on the Kubernetes cluster"
            terraform init -backend-config="resource_group_name=${TF_VAR_resource_group_name}" \
                -backend-config="storage_account_name=${TF_VAR_storage_account_name}" \
                -backend-config="container_name=${TF_VAR_container_name}" -reconfigure
            terraform apply --target module.kubernetes
        else
            echo -ne "\e[31m Error:  Invalid input values!\e[39m\n"
            usage
            exit 1
        fi
    ;;
    "delete")
        tf_var_file=$(readlink -f $2)
        if [[ -n "${tf_var_file}" ]]; then
            source $tf_var_file
            echo "Destroying the Kubernetes cluster and its addons"
            terraform init \
                -backend-config="resource_group_name=${TF_VAR_resource_group_name}" \
                -backend-config="storage_account_name=${TF_VAR_storage_account_name}" \
                -backend-config="container_name=${TF_VAR_container_name}" \
                -backend-config="subscription_id=${TF_VAR_subscription_id}" \
                -backend-config="tenant_id=${TF_VAR_tenant_id}" \
                -reconfigure
            terraform destroy --target module.kubernetes
            terraform destroy --target module.aks
            terraform destroy --target module.gateway --target module.network
            terraform destroy --target module.keyvault
        else
            echo -ne "\e[31m Error:  Invalid input values!\e[39m\n"
            usage
            exit 1
        fi
    ;;
    *)
        echo -ne "\e[31m Error:  Invalid input values!\e[39m\n"
        usage
        exit 1
esac