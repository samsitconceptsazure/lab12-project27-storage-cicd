# Azure CLI Lab — Step by Step

## Prerequisites
Azure CLI with Bicep, Python 3, an Azure subscription, GitHub repository, permission to create resource groups and storage accounts. Use a permitted region. For GitHub Actions, configure OIDC as described in `GITHUB_OIDC.md`.

## Manual deployment (Cloud Shell)
```bash
az login
az account set --subscription '<subscription-id>'
export LOCATION=centralindia
export SUFFIX=abc12345 # globally unique: 3-12 lowercase letters/digits
az group create -n rg-lab12-p27-dev -l "$LOCATION"
# Grant your signed-in user Storage Blob Data Contributor on the storage account after deployment if needed.
# The deployment script handles resource group creation and Bicep deployment:
bash scripts/deploy.sh dev
bash scripts/verify.sh dev
```

## Grant data-plane permissions (manual execution)
After the first deployment creates the account, if blob upload fails:
```bash
SUB=$(az account show --query id -o tsv)
USER_ID=$(az ad signed-in-user show --query id -o tsv)
STORAGE=stdev${SUFFIX}
az role assignment create --assignee-object-id "$USER_ID" --assignee-principal-type User --role 'Storage Blob Data Contributor' --scope "/subscriptions/$SUB/resourceGroups/rg-lab12-p27-dev/providers/Microsoft.Storage/storageAccounts/$STORAGE"
# Wait 2-10 minutes for RBAC propagation, then rerun:
bash scripts/deploy.sh dev
```

## Other environments
```bash
bash scripts/deploy.sh qa
bash scripts/deploy.sh stage
bash scripts/deploy.sh prod
for e in dev qa stage prod; do bash scripts/verify.sh "$e"; done
```

## Inspect deployment
```bash
az storage account list --query '[].{name:name,rg:resourceGroup,sku:sku.name}' -o table
az deployment group list -g rg-lab12-p27-dev -o table
az storage account show -g rg-lab12-p27-dev -n stdev${SUFFIX} --query '{url:primaryEndpoints.web,httpsOnly:enableHttpsTrafficOnly}'
```

## Cleanup
```bash
bash scripts/cleanup.sh dev
bash scripts/cleanup.sh qa
bash scripts/cleanup.sh stage
bash scripts/cleanup.sh prod
```
