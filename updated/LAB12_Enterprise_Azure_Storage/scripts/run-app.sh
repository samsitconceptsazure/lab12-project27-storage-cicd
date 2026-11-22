#!/usr/bin/env bash
set -euo pipefail
: "${SUFFIX:?Set SUFFIX}"; export STORAGE_ACCOUNT="stlab12${SUFFIX}"
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
python3 -m venv "$ROOT/.venv"
"$ROOT/.venv/bin/pip" install -r "$ROOT/app/requirements.txt"
export FLASK_SECRET_KEY="${FLASK_SECRET_KEY:-$(python3 -c 'import secrets;print(secrets.token_hex(32))')}"
cd "$ROOT/app"; "$ROOT/.venv/bin/python" app.py
