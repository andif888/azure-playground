######################
# Optional Variables:
######################

# Every variable which is define in this file has precedence over a
# corresponding variable which you have define in your .env file
# using the TF_VAR_ prefix.
# Because of this file is part on the respository and is not in the
# .gitignore list, it would be not a good idea to store sensible values like
# access keys or passwords in this file.

# --------------------------------------
# Azure Windows VM Timezone
#---------------------------------------

# Default:
# azure_vm_windows_timezone = "UTC"

# Example for W. Europe Standard Time:
# azure_vm_windows_timezone = "W. Europe Standard Time"


# --------------------------------------
# Azure Windows VM User Language
#---------------------------------------

# Default:
# azure_vm_windows_user_language = "en-US"

# Example for de-DE:
# azure_vm_windows_user_language = "de-DE"


# --------------------------------------
# Azure File Share Default Configuration
#---------------------------------------

# If you change the defaults here, make sure to
# - source your .env file
# - run build.sh in ./terraform/06_fileshare
# - run the ansible playbook azure-storage-joindomain.yml
# Commands:
# source .env
# cd ./terraform/06_fileshare && ./build.sh
# cd ../..
# ansible-playbook -i ./ansible/inventory ./ansible/azure-storage-joindomain.yml

#
# Share-level default permissions for all authenticated identities:
#

# https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-assign-permissions?tabs=azure-powershell#share-level-permissions-for-all-authenticated-identities
# In Azure, default is "None" and access is handled using dedicated RBAC.
# We need to have a different value, because otherwise we need to have AzureConnect
# configured and sync our AD User and Groups to AzureAD and assign RBACs.
# This is why we use "StorageFileDataSmbShareElevatedContributor" to enable users from our
# AD Domain have unrestriced access in the first place.
# We can easily use NFTS ACL later to restrict access for AD Users and Groups.
# This is similar to having am onprem fileshare with unrestriced share permission
# for Authenticated Users and restricting access using NTFS ACLs.
#
# Possible Values:
# None|StorageFileDataSmbShareContributor|StorageFileDataSmbShareReader|StorageFileDataSmbShareElevatedContributor
#
# Default:
# default_share_permission = "StorageFileDataSmbShareElevatedContributor"

#
# Define the Shares, which should get created:
#

# Default:
# storage_shares = [
#   { name = "officecontainer", quota = 50, rbacs = [] },
#   { name = "profilecontainer", quota = 50, rbacs = [] },
#   { name = "stuff", quota = 50, rbacs = [] }
# ]


# -------------------------------------------------------------------------------------
# Azure File Share Configuration Example with share level permission for AzureAD Groups
#--------------------------------------------------------------------------------------

# Example to define shares with share level permission of roles.
# For this example to work you need to configure AzureConnect and sync
# AD Users and Groups to AzureAD, otherwise the storage_shares_principal_names
# cannot be found.

# default_share_permission = "None"
#
# storage_shares_principal_names = ["IT","Finance", "Sales"]
#
# storage_shares = [
#   {
#     name = "officecontainer",
#     quota = 50,
#     rbacs = [
#       {
#         principal_name = "IT",
#         role = "Storage File Data SMB Share Elevated Contributor"
#       },
#       {
#         principal_name = "Sales",
#         role = "Storage File Data SMB Share Contributor"
#       },
#       {
#         principal_name = "Finance",
#         role = "Storage File Data SMB Share Contributor"
#       }
#     ]
#   },
#   {
#     name = "profilecontainer",
#     quota = 50,
#     rbacs = [
#       {
#         principal_name = "IT",
#         role = "Storage File Data SMB Share Elevated Contributor"
#       },
#       {
#         principal_name = "Sales",
#         role = "Storage File Data SMB Share Contributor"
#       },
#       {
#         principal_name = "Finance",
#         role = "Storage File Data SMB Share Contributor"
#       }
#     ]
#   },
#   {
#     name = "stuff",
#     quota = 50, rbacs = [
#       {
#         principal_name = "IT",
#         role = "Storage File Data SMB Share Elevated Contributor"
#       }
#     ]
#   }
# ]
