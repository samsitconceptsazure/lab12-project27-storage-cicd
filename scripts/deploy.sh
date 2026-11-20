#!/usr/bin/env bash
set -euo pipefail
ENVIRONMENT="${1:?Usage: scripts/deploy.sh dev|qa|stage|prod}"
case "$ENVIRONMENT" in dev|qa|stage|prod) ;; *) echo 'Invalid environment' >&2; exit 2;; esac
: "${SUFFIX:?Set SUFFIX to a globally unique lowercase alphanumeric value, 3-12 chars}"
[[ "$SUFFIX" =~ ^[a-z0-9]{3,12}$ ]] || { echo 'Invalid SUFFIX' >&2; exit 2; }
LOCATION="${LOCATION:-centralindia}"
RG_PREFIX="${RG_PREFIX:-rg-lab12-p27}"
RG="${RG_PREFIX}-${ENVIRONMENT}"
az group create -n "$RG" -l "$LOCATION" --tags project=lab12-p27 environment="$ENVIRONMENT" -o none
STORAGE=$(az deployment group create -g "$RG" -f infra/main.bicep -p environment="$ENVIRONMENT" suffix="$SUFFIX" location="$LOCATION" --query properties.outputs.storageAccountName.value -o tsv)
# Data-plane RBAC can take time to propagate; login-based upload avoids account keys.
python3 scripts/create_manifest.py "$ENVIRONMENT" "$STORAGE" > app/deployment.json
for attempt in {1..12}; do
 if az storage blob upload-batch --account-name "$STORAGE" --auth-mode login --destination '$web' --source app --overwrite -o none; then break; fi
 if [[ "$attempt" == 12 ]]; then echo 'Upload failed; check Storage Blob Data Contributor role and RBAC propagation' >&2; exit 1; fi
 sleep 15
done
URL=$(az storage account show -g "$RG" -n "$STORAGE" --query primaryEndpoints.web -o tsv)
echo "Deployed $ENVIRONMENT: $URL"
