# Azure Playground at {{ public_hosting_domain }}

Region: `{{ vault_global_azure_location }}`   
Hosting Domain: `{{ public_hosting_domain }}`

| Setting           | Value |
| :---------------- | :-------------------------------- |
| AD Domain Name:        | `{{ dns_domain_name }}` |
| AD Distinquished Name: | `{{ domain_ou_base }}` |
| AD Netbios Name:       | `{{ domain_netbios_name }}` |
| Subnet:                | `{{ vault_global_azure_virual_network_subnet_address_prefix }}` |
{% if (doc_sensitive | default(false)) %}| Domain Admin:          | `{{ domain_admin_user_short }}` |
| Domain Admin UPN:      | `{{ domain_admin_user }}` |
| Domain Admin Password: | `{{ domain_admin_password }}` |
{% endif %}

### Guacamole:

**[https://guac.{{ public_hosting_domain }}](https://guac.{{ public_hosting_domain }})**

### RD Gateway:

`rdg.{{ public_hosting_domain }}`
{% if 'windows_rdcb' in groups %}
### RD Web

**[https://rdg.{{ public_hosting_domain }}/RDWeb](https://rdg.{{ public_hosting_domain }}/RDWeb)**
{% endif %}
### File Shares

| UNC Path           | Local Path | Description |
| :---------------- | :----------- | :------------|
{% for share in winfs_shares %}| \\\\{{ groups["windows_fs"][0] }}\\{{ share.name }} | {{ share.path }} | {{ share.description }} |
{% endfor %}

### Additional Features

- {% if fileshare_storage_account_shares is defined %}✔{% else %}✖{% endif %} Azure Fileshares
- {% if (fslogix_profilecontainer_enabled) %}✔{% else %}✖{% endif %} FSLogix Profile Container
- {% if (fslogix_officecontainer_enabled) %}✔{% else %}✖{% endif %} FSLogix Office Container

{% if (doc_sensitive | default(false)) %}
### SSH Host Config File

```
Host {{ vault_global_reversproxy_dns_hostname }}
    HostName {{ vault_global_reversproxy_dns_hostname }}.{{ vault_global_azure_location_dns }}
    Port 1122
    User {{ ansible_user }}
    IdentityFile {{ vault_global_ssh_private_key }}
    StrictHostKeyChecking no
{% for host in (groups["all"] | difference(["wg0"]))  %}
Host {{ host }}
    HostName {{ host }}.{{ dns_domain_name }}
    User {{ ansible_user }}
    IdentityFile {{ vault_global_ssh_private_key }}
    StrictHostKeyChecking no
    ProxyCommand ssh -p 1122 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i {{ vault_global_ssh_private_key }} -W %h:%p -q {{ ansible_user }}@{{ vault_global_reversproxy_dns_hostname }}.{{ vault_global_azure_location_dns }}
{% endfor %}
```

To use the SSH Config File:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
nano ~/.ssh/config
# copy and paste the contents and save the file
chmod 600 ~/.ssh/config
```

### SSH raw commands

##### SSH into wg0:

```shell
ssh -p 1122 -i {{ vault_global_ssh_private_key }}  \
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null \
{{ vault_global_admin_user }}@{{ vault_global_reversproxy_dns_hostname }}.{{ vault_global_azure_location_dns }}
```

{% for host in (groups["all"] | difference(["wg0"])) %}
##### SSH into {{ host }}:

```shell
ssh -i {{ vault_global_ssh_private_key }} \
-o StrictHostKeyChecking=no \
-o UserKnownHostsFile=/dev/null \
-o ProxyCommand="ssh -p 1122 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i {{ vault_global_ssh_private_key }} -W %h:%p -q {{ ansible_user }}@{{ vault_global_reversproxy_dns_hostname }}.{{ vault_global_azure_location_dns }}" \
{{ ansible_user }}@{{ host }}.{{ dns_domain_name }}
```
{% endfor %}
{% endif %}
