#  How to prepare a azure service principal

Your can create an azure service principal for example using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli) or using [App registrations in AzureAD](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps).   
We only cover creating it with Azure CLI.

### Create service principal using Azure CLI

Login into Azure

```bash
az login
```

Create service principal. Feel free to adjust the name. You must enter `your-own-azure-subscription-id`. A subscription Id look something like this: c4521249-703d-4fff-9361-34249a4bf732

```bash
az ad sp create-for-rbac \
  --name="sp_playground" \
  --role="Contributor" \
  --scope="/subscriptions/<subscription-id>" \
  --years=2
```

The output will be some thing like this:

```json
{
  "appId": "da779e28-6832-48e6-a2f9-43c2d70b33be",
  "displayName": "sp_playground",
  "password": "4J26HCx003Jw_IsNUfBYsRLBKjeFQM_Y8u",
  "tenant": "a45b5b32-7739-1422-b12b-4f1d7bff3bc3"
}
```

### Copy the service principal info to your .env file

The copy the value `appId` into the variable `ARM_CLIENT_ID` in your `.env` file.   
The copy the value `password` into the variable `ARM_CLIENT_SECRET` in your `.env` file.    
The copy the value `tenant` into the variable `ARM_TENANT_ID` in your `.env` file.    
The copy your azure `subscription id` into the variable `ARM_SUBSCRIPTION_ID` in your `.env` file.    

Resulting contents of your `.env` file, which is a copy of [sample.env](../sample.env)

```bash
# Azure Tenant ID
export ARM_TENANT_ID="a45b5b32-7739-1422-b12b-4f1d7bff3bc3"
# Azure Subscription ID
export ARM_SUBSCRIPTION_ID="c4521249-703d-4fff-9361-34249a4bf732"
# Azure Service Principal App ID
export ARM_CLIENT_ID="da779e28-6832-48e6-a2f9-43c2d70b33be"
# Azure Service Principal App Secret Key
export ARM_CLIENT_SECRET="4J26HCx003Jw_IsNUfBYsRLBKjeFQM_Y8u"
```
