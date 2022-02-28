# How to prepare the azure storage account

The purpose of the azure storage account is to centrally store terraform state files, so that terraform can manage the state of your environment. Terraform state files are small json files. So any low cost azure storage account is sufficient. This storage account can be re-used for multiple environments.

Your can create a azure storage account for example using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli) or using [Azure Portal](https://portal.azure.com/). You can also use the public repo at [andif888/azure-bootstrap](https://github.com/andif888/azure-bootstrap) to accomplish this task.   
We only cover creating it with Azure CLI here.

Login into Azure

```bash
az login
```

Make sure your are on the correct subscription.

```bash
az account set --subscription <subscription-id>
```

### azure resource group

To create a general-purpose v2 storage account with Azure CLI, first create a new **resource group** by calling the az group create command. Choose your individual name for the resource group. In the sample I have chosen `rg-playground-bootstrap`.

```bash
az group create \
  --name rg-playground-bootstrap \
  --location germanywestcentral
```

If you're not sure which azure region to specify for the --location parameter, you can retrieve a list of supported regions for your subscription with the az account list-locations command.

```bash
az account list-locations \
  --query "[].{Region:name}" \
  --out table
```

### azure storage account

Next, create a standard general-purpose v2 **storage account** by using the az storage account create command. Remember that the name of your storage account must be unique across Azure, so you must choose your own value value. In the sample I have chosen `stplaygroundbs`.

```bash
az storage account create \
  --name stplaygroundbs \
  --resource-group rg-playground-bootstrap \
  --location germanywestcentral \
  --sku Standard_LRS \
  --kind StorageV2
```

### azure storage container inside the storage account

Next, create a **storage container** inside the storage account with Azure CLI. Call the az storage container create command.

```bash
az storage container create \
    --name terraformstates \
    --account-name stplaygroundbs
```

### retrieve storage account access key

Next, retrieve the **access key** of the storage account

```bash
az storage account keys list \
  --resource-group rg-playground-bootstrap \
  --account-name stplaygroundbs
```

The output is something like this. Take a note of the **value** of `key1`

```json
[
  {
    "creationTime": "2022-02-23T21:55:41.611639+00:00",
    "keyName": "key1",
    "permissions": "FULL",
    "value": "nOC8J/fA9j48szOWCzxwhuXYduEnX+txTMnO71RIZOVluKO7XByhpGsU6d1u+uSuU306Zt3JWJNKiB/6wMromw=="
  },
  {
    "creationTime": "2022-02-23T21:55:41.611639+00:00",
    "keyName": "key2",
    "permissions": "FULL",
    "value": "qMSYxd5n5kLWnRqueaGocFmI9p8+1QupA6YAWFRqU7hBIDUSbqBrT3ro7MgBE21/EhTzHuwIUbtCSPBlSN5O7A=="
  }
]
```


## Copy the storage account info to your .env file

Copy the name of the created **resource group** into the variable `TF_VAR_azure_bootstrap_resource_group_name` in your `.env` file.   
Copy the name of the created **storage account** into the variable `TF_VAR_azure_bootstrap_storage_account_name` in your `.env` file.    
Copy the name of the created **storage container** into the variable `TF_VAR_azure_bootstrap_storage_account_container_name` in your `.env` file.    
Copy the **location** of the used **azure region** into the variable `TF_VAR_azure_location` in your `.env` file.  
Copy the **value** of `key1` of the storage account access key into the variable `ARM_ACCESS_KEY`


Resulting contents of your `.env` file, which is a copy of [sample.env](../sample.env)

```shell
# -------------
# Azure Details
# -------------

# Azure Tenant ID
export ARM_TENANT_ID="a45b5b32-7739-1422-b12b-4f1d7bff3bc3"
# Azure Subscription ID
export ARM_SUBSCRIPTION_ID="c4521249-703d-4fff-9361-34249a4bf732"
# Azure Service Principal App ID
export ARM_CLIENT_ID="da779e28-6832-48e6-a2f9-43c2d70b33be"
# Azure Service Principal App Secret Key
export ARM_CLIENT_SECRET="4J26HCx003Jw_IsNUfBYsRLBKjeFQM_Y8u"
# Access Key for the the pre-existing Azure Storage Account
export ARM_ACCESS_KEY="nOC8J/fA9j48szOWCzxwhuXYduEnX+txTMnO71RIZOVluKO7XByhpGsU6d1u+uSuU306Zt3JWJNKiB/6wMromw=="


# ----------------------------------------------------------
# Mandatory variables for pre-existing azure storage account
# ----------------------------------------------------------

# Name of an existing resource-group hosting a storage account for terraform state files
export TF_VAR_azure_bootstrap_resource_group_name="rg-playground-bootstrap"

# Name of an existing storage account to save terraform state files
export TF_VAR_azure_bootstrap_storage_account_name="stplaygroundbs"

# Name of an existing blob container to save terraform state files
export TF_VAR_azure_bootstrap_storage_account_container_name="terraformstates"


# -------------------------------------
# Mandatory variable for azure location
# -------------------------------------

# Azure Location where the resource should be deployed
export TF_VAR_azure_location="germanywestcentral"

```
