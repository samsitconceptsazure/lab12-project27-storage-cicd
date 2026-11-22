#!/usr/bin/env bash
set -euo pipefail
RG=${RG:-rg-lab12-storage}
[[ "${CONFIRM_DELETE:-}" == "$RG" ]] || { echo "To delete all lab resources: CONFIRM_DELETE=$RG bash scripts/cleanup.sh"; exit 1; }
az group delete -n "$RG" --yes --no-wait
echo 'Deletion requested; verify completion in Azure Portal.'
