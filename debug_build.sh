#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
environment=$(basename $script_dir)

build_path_terraform=$script_dir/terraform
build_path_ansible=$script_dir/ansible

echo "creating 01_rg"
cd $build_path_terraform/01_rg && ./build.sh

echo "creating 02_network"
cd $build_path_terraform/02_network && ./build.sh

echo "creating 03_storage"
cd $build_path_terraform/03_storage && ./build.sh

echo "creating 04_wg"
cd $build_path_terraform/04_wg && ./build.sh

echo "creating 05_dc"
cd $build_path_terraform/05_dc && ./build.sh

echo "creating 07_rdg"
cd $build_path_terraform/07_rdg && ./build.sh

echo "creating 08_dbfs"
cd $build_path_terraform/08_dbfs && ./build.sh

[ "$vms_already_alive" = true ] || (echo "wait 4 minutes to VM provisioning ..."; sleep 4m)

echo "provisioning with ansible"
cd $build_path_ansible \
&& ./requirements_download.sh \
&& ansible-playbook -i inventory site.yml
