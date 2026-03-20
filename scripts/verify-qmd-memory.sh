#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import urllib.request
for url in ("http://127.0.0.1:16333/healthz", "http://127.0.0.1:16333/"):
    try:
        with urllib.request.urlopen(url, timeout=5) as r:
            print(url, r.status)
            print(r.read().decode("utf-8", "ignore")[:300])
            raise SystemExit(0)
    except Exception as exc:
        print(url, "ERR", exc)
raise SystemExit(1)
PY
