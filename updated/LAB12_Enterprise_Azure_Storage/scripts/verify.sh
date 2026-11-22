#!/usr/bin/env bash
set -euo pipefail
: "${SUFFIX:?Set SUFFIX}"; RG=${RG:-rg-lab12-storage}; A="stlab12${SUFFIX}"
echo 'Storage account:'; az storage account show -g "$RG" -n "$A" --query '{name:name,sku:sku.name,tls:minimumTlsVersion,https:enableHttpsTrafficOnly}' -o json
echo 'Blob container:'; az storage container show --account-name "$A" -n documents --auth-mode login --query name -o tsv
echo 'Queue and table:'
az storage queue list --account-name "$A" --auth-mode login --query '[].name' -o tsv
az storage table list --account-name "$A" --auth-mode login --query '[].name' -o tsv
echo 'Note: data-plane operations require data roles and network access.'
