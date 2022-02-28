#cloud-config
ssh_pwauth: yes
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - ufw
  - unzip
  - python3
  - python3-pip
  - sshpass
  - net-tools

runcmd:
 - echo "Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null
