#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
environment=$(basename $script_dir)

build_path_terraform=$script_dir/terraform
build_path_ansible=$script_dir/ansible


# thread1
echo "creating 01_rg"
cd $build_path_terraform/01_rg && ./build.sh

# thread2 -> depends_on: thread1
echo "creating 02_network"
cd $build_path_terraform/02_network && ./build.sh &
thread2=$!

# thread3 -> depends_on: thread1
echo "creating 03_storage"
cd $build_path_terraform/03_storage && ./build.sh &
thread3=$!

echo "waiting for thread2 (network)..."
wait $thread2
echo "thread2 (network) exited with $?"

echo "waiting for thread3 (storage)..."
wait $thread3
echo "thread3 (storage) exited with $?"

# thread4 -> depends_on: thread2 && thread3
echo "creating 04_wg"
cd $build_path_terraform/04_wg && ./build.sh &
thread4=$!

# thread5 -> depends_on: thread2 && thread3
echo "creating 05_dc"
cd $build_path_terraform/05_dc && ./build.sh &
thread5=$!

# thread7 -> depends_on: thread2 && thread3
echo "creating 07_rdg"
cd $build_path_terraform/07_rdg && ./build.sh &
thread7=$!

# thread8 -> depends_on: thread2 && thread3
echo "creating 08_dbfs"
cd $build_path_terraform/08_dbfs && ./build.sh &
thread8=$!

echo "waiting for thread4 (wg)..."
wait $thread4
echo "thread4 (wg) exited with $?"

echo "waiting for thread5 (dc)..."
wait $thread5
echo "thread5 (dc) exited with $?"

[ "$vms_already_alive" = true ] || (echo "wait 5 minutes to VM provisioning ..."; sleep 5m)

# thread9 -> depends_on thread4 and thread5
echo "provisioning with ansible"
cd $build_path_ansible \
&& ./requirements_download.sh \
&& ansible-playbook -i inventory generic-dc.yml &
thread9=$!

echo "waiting for thread7 (rdg)..."
wait $thread7
echo "thread7 (rdg) exited with $?"

echo "waiting for thread8 (dbfs)..."
wait $thread8
echo "thread8 (dbfs) exited with $?"

echo "waiting for thread9 (generic-dc)..."
wait $thread9
echo "thread9 (generic-dc) exited with $?"

# thread10 -> depends_on thread9
cd $build_path_ansible \
&& ansible-playbook -i inventory generic-ca.yml \
&& ansible-playbook -i inventory infra-dc.yml &
thread10=$!

# thread11
cd $build_path_ansible \
&& ansible-playbook -i inventory infra-dh.yml \
&& ansible-playbook -i inventory infra-dh-containers.yml &
thread11=$!

# thread13
cd $build_path_ansible \
&& ansible-playbook -i inventory generic-domain-members.yml &
thread13=$!

echo "waiting for thread13 (generic-domain-members)..."
wait $thread13
echo "thread13 (generic-domain-members) exited with $?"

# thread14
cd $build_path_ansible \
&& ansible-playbook -i inventory generic-rdcb.yml \
&& ansible-playbook -i inventory generic-rdg.yml \
&& ansible-playbook -i inventory infra-mgmt-tools.yml &
thread14=$!

# thread15
cd $build_path_ansible \
&& ansible-playbook -i inventory generic-fs.yml \
&& ansible-playbook -i inventory infra-fs.yml \
&& ansible-playbook -i inventory infra-sqldev.yml &
thread15=$!

echo "waiting for thread14 (generic-rdg)..."
wait $thread14
echo "thread14 (generic-rdg) exited with $?"

# thread16
cd $build_path_ansible \
&& ansible-playbook -i inventory final-infra-dh-guac-connection-lists.yml &
thread16=$!

# thread17
cd $build_path_ansible \
&& ansible-playbook -i inventory infra-rdg-certificates.yml &
thread17=$!

echo "waiting for thread10 (infra-dc)..."
wait $thread10
echo "thread10 (infra-dc) exited with $?"

echo "waiting for thread15 (generic-fs)..."
wait $thread15
echo "thread15 (generic-fs) exited with $?"

echo "waiting for thread17 (infra-rdg-certificates)..."
wait $thread17
echo "thread17 (infra-rdg-certificates) exited with $?"

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

echo "waiting for thread16 (infra-dh-guac-connections)..."
wait $thread16
echo "thread16 (infra-dh-guac-connections) exited with $?"

echo "waiting for thread19 (infra-windows-international)..."
wait $thread19
echo "thread19 (infra-windows-international) exited with $?"

echo "waiting for thread20 (final-windows-doc)..."
wait $thread20
echo "thread20 (final-windows-doc) exited with $?"

# thread21
cd $build_path_ansible \
&& ansible-playbook -i inventory azure-network-dns-servers.yml \
&& ansible-playbook -i inventory generic-linux-reboot.yml &
thread21=$!

echo "waiting for thread18 (final-local-doc)..."
wait $thread18
echo "thread18 (final-local-doc) exited with $?"

echo "waiting for thread21 (reboot)..."
wait $thread21
echo "thread21 (reboot) exited with $?"
