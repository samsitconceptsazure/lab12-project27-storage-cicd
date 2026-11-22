#!/usr/bin/env bash
set -euo pipefail
: "${SUFFIX:?Set SUFFIX}"; RG=${RG:-rg-lab12-storage}; LOCATION=${LOCATION:-centralindia}; A="stlab12${SUFFIX}"
# Requires Contributor + Network Contributor (or equivalent) and private DNS permissions.
az network vnet create -g "$RG" -n vnet-lab12 -l "$LOCATION" --address-prefix 10.77.0.0/16 --subnet-name snet-pe --subnet-prefix 10.77.1.0/24 -o none
ID=$(az storage account show -g "$RG" -n "$A" --query id -o tsv)
az network private-endpoint create -g "$RG" -n pe-lab12-blob -l "$LOCATION" --vnet-name vnet-lab12 --subnet snet-pe --private-connection-resource-id "$ID" --group-id blob --connection-name conn-blob -o none
az network private-dns zone create -g "$RG" -n privatelink.blob.core.windows.net -o none
az network private-dns link vnet create -g "$RG" -z privatelink.blob.core.windows.net -n link-lab12 --virtual-network vnet-lab12 --registration-enabled false -o none
az network private-endpoint dns-zone-group create -g "$RG" --endpoint-name pe-lab12-blob -n zonegroup --private-dns-zone privatelink.blob.core.windows.net --zone-name blob -o none
cat <<'EOF'
Private endpoint created. Verify DNS and data access FROM a VM/client in the VNet.
This does not secure file/queue/table endpoints; create separate endpoints for those services if required.
Do not disable public network access until a private client is tested.
EOF
