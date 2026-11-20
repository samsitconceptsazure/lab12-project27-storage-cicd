#!/usr/bin/env bash
set -euo pipefail
ENV="${1:?Pass environment}"
: "${SUFFIX:?Set SUFFIX}"
RG="${RG_PREFIX:-rg-lab12-p27}-${ENV}"
STORAGE="st${ENV}${SUFFIX}"
URL=$(az storage account show -g "$RG" -n "$STORAGE" --query primaryEndpoints.web -o tsv)
[[ "$URL" == https://* ]] || { echo 'No HTTPS static website endpoint'; exit 1; }
python3 - "$URL" "$ENV" <<'PY2'
import json,sys,urllib.request
url,env=sys.argv[1:]
with urllib.request.urlopen(url+'deployment.json',timeout=25) as r: data=json.load(r)
assert data['environment']==env,data
with urllib.request.urlopen(url,timeout=25) as r: assert b'SamsITConcepts' in r.read()
print('PASS:',url,'environment',env)
PY2
