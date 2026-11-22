#!/usr/bin/env bash
set -euo pipefail
: "${SUFFIX:?Set SUFFIX to unique 5-12 lowercase letters/digits}"
RG=${RG:-rg-lab12-storage}; LOCATION=${LOCATION:-centralindia}; REDUNDANCY=${REDUNDANCY:-Standard_LRS}
DEPLOY_DISK=${DEPLOY_DISK:-false}; DEPLOY_PREMIUM_FILES=${DEPLOY_PREMIUM_FILES:-false}
[[ "$SUFFIX" =~ ^[a-z0-9]{5,12}$ ]] || { echo 'Invalid SUFFIX'; exit 1; }
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
az account show >/dev/null
az group create -n "$RG" -l "$LOCATION" -o none
az deployment group create -g "$RG" -n "lab12-$(date +%s)" --template-file "$ROOT/infra/main.bicep" \
 --parameters suffix="$SUFFIX" location="$LOCATION" redundancy="$REDUNDANCY" deployDisk="$DEPLOY_DISK" deployPremiumFiles="$DEPLOY_PREMIUM_FILES" \
 --query properties.outputs -o json
printf 'Deployment complete. Account: stlab12%s\n' "$SUFFIX"
