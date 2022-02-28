#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
environment=$(basename $script_dir)

build_path_terraform=$script_dir/terraform
build_path_ansible=$script_dir/ansible

cd $build_path_terraform/01_rg && ./build.sh
cd $build_path_terraform/02_network && ./build.sh &
thread2=$!
cd $build_path_terraform/03_storage && ./build.sh &
thread3=$!
cd $build_path_terraform/04_wg && ./build.sh &
thread4=$!
cd $build_path_terraform/05_dc && ./build.sh &
thread5=$!
cd $build_path_terraform/07_rdg && ./build.sh &
thread7=$!
cd $build_path_terraform/08_dbfs && ./build.sh &
thread8=$!
cd $build_path_terraform/06_fileshare && ./build.sh &
thread9=$!
wait $thread2
wait $thread3
wait $thread4
wait $thread5
wait $thread7
wait $thread8
wait $thread9

echo "provisioning with ansible"
cd $build_path_ansible \
&& ./requirements_download.sh \
&& ansible-playbook -i inventory azure-storage-joindomain.yml \
&& ansible-playbook -i inventory infra-mgmt-tools.yml --tags "azure_fileshares"

# thread18
cd $build_path_ansible \
&& ansible-playbook -i inventory final-local-doc.yml &
thread18=$!

# thread20
cd $build_path_ansible \
&& ansible-playbook -i inventory final-windows-doc.yml &
thread20=$!

wait $thread18
wait $thread20
