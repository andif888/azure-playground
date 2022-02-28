#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
environment=$(basename $script_dir)
build_path_terraform=$script_dir/terraform

rm -rf $build_path_terraform/01_rg/.terraform
rm -f $build_path_terraform/01_rg/.terraform.lock.hcl
rm -f $build_path_terraform/01_rg/planfile

rm -rf $build_path_terraform/02_network/.terraform
rm -f $build_path_terraform/02_network/.terraform.lock.hcl
rm -f $build_path_terraform/02_network/planfile
rm -f $build_path_terraform/02_network/dnsservers.auto.tfvars

rm -rf $build_path_terraform/03_storage/.terraform
rm -f $build_path_terraform/03_storage/.terraform.lock.hcl
rm -f $build_path_terraform/03_storage/planfile

rm -rf $build_path_terraform/04_vpn/.terraform
rm -f $build_path_terraform/04_vpn/.terraform.lock.hcl
rm -f $build_path_terraform/04_vpn/planfile

rm -rf $build_path_terraform/04_wg/.terraform
rm -f $build_path_terraform/04_wg/.terraform.lock.hcl
rm -f $build_path_terraform/04_wg/planfile

rm -rf $build_path_terraform/05_dc/.terraform
rm -f $build_path_terraform/05_dc/.terraform.lock.hcl
rm -f $build_path_terraform/05_dc/planfile

rm -rf $build_path_terraform/06_fileshare/.terraform
rm -f $build_path_terraform/06_fileshare/.terraform.lock.hcl
rm -f $build_path_terraform/06_fileshare/planfile
rm -f $build_path_terraform/06_fileshare/domainjoin.auto.tfvars

rm -rf $build_path_terraform/07_rdg/.terraform
rm -f $build_path_terraform/07_rdg/.terraform.lock.hcl
rm -f $build_path_terraform/07_rdg/planfile

rm -rf $build_path_terraform/08_dbfs/.terraform
rm -f $build_path_terraform/08_dbfs/.terraform.lock.hcl
rm -f $build_path_terraform/08_dbfs/planfile
