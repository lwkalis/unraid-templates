#!/bin/sh
# Create a browser session on the existing OpenCode 2.0.32 container.
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: sh pair-browser.sh http://UNRAID-HOST:HOST-PORT [CONTAINER]" >&2
  exit 2
fi
url=${1%/}
container=${2-OpenCode}
if ! printf '%s\n' "$url" | grep -Eq '^https?://(\[[0-9A-Fa-f:]+\]|[A-Za-z0-9.-]+)(:[0-9]+)?$'; then
  echo "Use the WebUI HTTP(S) origin only, without credentials, path, query or fragment." >&2
  exit 2
fi
case "$container" in
  ''|-*|*[!A-Za-z0-9_.-]*) echo "Invalid Docker container name." >&2; exit 2 ;;
esac

# Credentials stay inside the container. Do not enable tracing or print the response.
# OPENCODE_PASSWORD takes precedence over its legacy name, matching upstream.
if ! response=$(docker exec "$container" sh -c '
  password=${OPENCODE_PASSWORD-${OPENCODE_SERVER_PASSWORD-}}
  if [ -z "$password" ]; then
    echo "Set Server Password in Unraid and Apply before pairing." >&2
    exit 1
  fi
  header=$(printf "opencode:%s" "$password" | base64 | tr -d "\r\n")
  wget -q -T 15 -O - --header="Authorization: Basic $header" --post-data="" http://127.0.0.1:4096/api/pair
'); then
  echo "Could not create pairing link. Check the running container name, Server Password and internal port 4096." >&2
  exit 1
fi
code=$(printf '%s\n' "$response" | sed -n 's/^[[:space:]]*{[[:space:]]*"code"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)"[[:space:]]*,[[:space:]]*"expires_in"[[:space:]]*:[[:space:]]*300[[:space:]]*}[[:space:]]*$/\1/p')
if [ "${#code}" -ne 22 ]; then
  echo "Unexpected pairing response from OpenCode; no link was printed." >&2
  exit 1
fi
printf 'Open this single-use link within five minutes (keep it private):\n%s/auth/connect/%s\n' "$url" "$code"
