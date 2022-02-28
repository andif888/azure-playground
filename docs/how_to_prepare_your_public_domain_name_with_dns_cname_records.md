# How to prepare your public Domain Name with DNS CNAME records

You need a public Domain Name at any Domain Hosting provider.
This is used to make the environment your own. This enables you to access your environment using your own Domain Name. This can be any exisiting one. We only need to create two DNS CNAME Records, which acts like a subdomain. So no worry, we are not going to fuck up anything at your base domain.

### reverse proxy dns hostname

Terraform creates a small Linux VM for you which acts as reverse proxy. It gets a public IP address and a public DNS hostname assigned by Azure.

With the variable `TF_VAR_reversproxy_dns_hostname` in your `.env` file you can control the public DNS hostname of the Linux VM. You must choose any unique name.

Unique reverse proxy dns hostname in the `.env` file, which is a copy of [sample.env](../sample.env)

```shell
export TF_VAR_reversproxy_dns_hostname="playground873637"
```

If you deploy your infrastructure in azure region **germanywestcentral** then the domain part for your Linux VM will be `.germanywestcentral.cloudapp.azure.com` and the resulting public full qualified domain name of the Linux VM will be  **playground873637.germanywestcentral.cloudapp.azure.com**

Examples for other regions:

- West Europe:   .westeurope.cloudapp.azure.com  
- North Europe:  .northeurope.cloudapp.azure.com
- East US:       .eastus.cloudapp.azure.com


### Point a DNS CNAME record to the Azure revers proxy Linux VM

For example, your environment should be accessible at `playground.microhouse.de`    
microhouse.de a domain you own and control. You need to create the
following 2 DNS records at your domain hosting provider:

```
playground    CNAME   playground873637.germanywestcentral.cloudapp.azure.com
*.playground  CNAME   playground873637.germanywestcentral.cloudapp.azure.com
 ```

### public hosting domain

So now you should exactly understand what goes into the variable `TF_VAR_public_hosting_domain` in your .env file, which is a copy of [sample.env](../sample.env)

```shell
export TF_VAR_public_hosting_domain="playground.microhouse.de"
```
