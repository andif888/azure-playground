#!/bin/bash
ansible-galaxy role install -v -r requirements.yml -p roles/
ansible-galaxy collection install -v -r requirements.yml
# https://docs.microsoft.com/en-us/azure/developer/ansible/install-on-linux-vm?tabs=azure-cli#create-azure-credentials
