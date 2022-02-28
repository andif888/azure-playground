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
  - wireguard

runcmd:
 - echo "Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null
 - sudo sed -i -e '/^#Port/s/^.*$/Port 1122/' /etc/ssh/sshd_config
 - sudo systemctl restart ssh
