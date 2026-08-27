#!/usr/bin/env bash

echo "run-gitian.sh is deprecated for Bitcoin Core 31.1; use run-guix.sh instead." >&2
exec "$(dirname "$0")/run-guix.sh" "$@"
