#!/bin/bash
set -e

current_dir=$(pwd)
script_name=$(basename "${BASH_SOURCE[0]}")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
environment=$(basename $script_dir)

build_path_terraform=$script_dir/terraform
build_path_ansible=$script_dir/ansible

# We first need keys
echo "creating 01_rg"
cd $build_path_terraform/01_rg && ./build.sh

echo "destroying 08_dbfs"
cd $build_path_terraform/08_dbfs && ./destroy.sh &
thread8=$!

echo "destroying 07_rdg"
cd $build_path_terraform/07_rdg && ./destroy.sh &
thread7=$!

echo "destroying 05_dc"
cd $build_path_terraform/05_dc && ./destroy.sh &
thread5=$!

echo "destroying 04_wg"
cd $build_path_terraform/04_wg && ./destroy.sh &
thread4=$!

wait $thread8
wait $thread7
wait $thread5
wait $thread4

echo "destroying 03_storage"
cd $build_path_terraform/03_storage && ./destroy.sh &
thread3=$!

echo "destroying 02_network"
cd $build_path_terraform/02_network && ./destroy.sh &
thread2=$!

wait $thread3
wait $thread2

echo "destroying 01_rg"
cd $build_path_terraform/01_rg && ./destroy.sh


echo "removing ansible generated files"
if [ -f "$build_path_terraform/02_network/dnsservers.auto.tfvars" ]
then
  rm -f $build_path_terraform/02_network/dnsservers.auto.tfvars
fi
if [ -f "$build_path_terraform/06_fileshare/domainjoin.auto.tfvars" ]
then
  rm -f $build_path_terraform/06_fileshare/domainjoin.auto.tfvars
fi
