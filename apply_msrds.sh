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
cd $build_path_terraform/09_msrds && ./build.sh &
thread9=$!
wait $thread2
wait $thread3
wait $thread4
wait $thread5
wait $thread7
wait $thread8
wait $thread9

[ "$vms_already_alive" = true ] || (echo "wait 5 minutes to VM provisioning ..."; sleep 5m)


echo "provisioning with ansible"
cd $build_path_ansible \
&& ./requirements_download.sh \
&& ansible-playbook -i inventory generic-domain-members.yml --limit "windows_rdg,windows_rdcb,windows_rdsh"

cd $build_path_ansible \
&& ansible-playbook -i inventory generic-rdcb.yml &
thread10=$!

cd $build_path_ansible \
&& ansible-playbook -i inventory generic-rdg.yml --tags "win_feature_rds_web_access" &
thread11=$!

cd $build_path_ansible \
&& ansible-playbook -i inventory generic-rdsh.yml \
&& ansible-playbook -i inventory infra-rdsh-fslogix.yml \
&& ansible-playbook -i inventory infra-rdsh-apps.yml &
thread12=$!

wait $thread10
wait $thread11
wait $thread12

cd $build_path_ansible \
&& ansible-playbook -i inventory infra-dh-containers.yml --tags "docker_container_traefik" &
thread13=$!

cd $build_path_ansible \
&& ansible-playbook -i inventory generic-rds-deployment.yml

wait $thread13

cd $build_path_ansible \
&& ansible-playbook -i inventory infra-rdcb-certificates.yml

# thread17
cd $build_path_ansible \
&& ansible-playbook -i inventory final-infra-dh-guac-connection-lists.yml --tags "windows_rdcb_rdp,windows_rdcb_ssh,windows_rdsh_rdp,windows_rdsh_ssh" &
thread17=$!

# thread18
cd $build_path_ansible \
&& ansible-playbook -i inventory final-local-doc.yml &
thread18=$!

# thread19
cd $build_path_ansible \
&& ansible-playbook -i inventory infra-windows-international.yml &
thread19=$!

# thread20
cd $build_path_ansible \
&& ansible-playbook -i inventory final-windows-doc.yml &
thread20=$!

wait $thread17
wait $thread18
wait $thread19
wait $thread20
