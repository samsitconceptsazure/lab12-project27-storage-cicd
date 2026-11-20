#!/usr/bin/env bash
set -euo pipefail
ENV="${1:?Pass dev|qa|stage|prod}"
case "$ENV" in dev|qa|stage|prod) ;; *) exit 2;; esac
RG="${RG_PREFIX:-rg-lab12-p27}-${ENV}"
echo "Deleting resource group: $RG"
read -r -p "Type DELETE to confirm: " answer
[[ "$answer" == DELETE ]] || exit 1
az group delete -n "$RG" --yes --no-wait
