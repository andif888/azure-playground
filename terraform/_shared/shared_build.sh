#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
script_dir_name=$(basename $script_dir)

shared_vars_file=../../global.tfvars

echo "key: $script_dir_name"

terraform init -upgrade \
-backend-config="resource_group_name=${TF_VAR_azure_bootstrap_resource_group_name}" \
-backend-config="storage_account_name=${TF_VAR_azure_bootstrap_storage_account_name}" \
-backend-config="container_name=${TF_VAR_azure_bootstrap_storage_account_container_name}" \
-backend-config="key=${TF_VAR_environment_prefix}_${script_dir_name}.tfstate"
terraform validate
terraform plan -var-file $shared_vars_file -input=false -out=planfile
terraform apply -auto-approve planfile
