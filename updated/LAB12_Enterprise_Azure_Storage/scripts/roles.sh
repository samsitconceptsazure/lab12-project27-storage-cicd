#!/usr/bin/env bash
set -euo pipefail
: "${PRINCIPAL_OBJECT_ID:?Set the Entra object ID to grant roles}"; RG=${RG:-rg-lab12-storage}
SUB=$(az account show --query id -o tsv)
SCOPE="/subscriptions/$SUB/resourceGroups/$RG"
for ROLE in 'Storage Blob Data Contributor' 'Storage Queue Data Contributor' 'Storage Table Data Contributor'; do
 az role assignment create --assignee-object-id "$PRINCIPAL_OBJECT_ID" --assignee-principal-type User --role "$ROLE" --scope "$SCOPE" -o none || echo "Check existing assignment: $ROLE"
done
printf 'Azure Files SMB requires separate identity-based authentication setup; see docs/PORTAL-AND-CLI-GUIDE.md\n'
