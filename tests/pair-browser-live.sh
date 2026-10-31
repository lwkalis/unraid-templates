#!/bin/sh
# CI-only integration check against the exact upstream image in the template.
set -eu
cd "$(dirname "$0")/.."
scratch=$(mktemp -d)
container=opencode-pairing-test
trap 'docker rm -f "$container" >/dev/null 2>&1 || true; rm -rf "$scratch"' EXIT HUP INT TERM
docker run -d --name "$container" -p 127.0.0.1:14096:4096 \
  --workdir=/tmp --entrypoint=opencode \
  -e OPENCODE_SERVER_PASSWORD='ci-only-long-password:with-spaces 123' \
  ghcr.io/anomalyco/opencode:2.0.32 serve --hostname 0.0.0.0 --port 4096 >/dev/null
origin=http://127.0.0.1:14096
ready=false
for attempt in $(seq 1 90); do
  status=$(curl -s -o /dev/null -w '%{http_code}' "$origin/api/info" || true)
  if [ "$status" = 401 ]; then ready=true; break; fi
  sleep 2
done
[ "$ready" = true ] || { echo 'Server did not become ready' >&2; exit 1; }
sh scripts/pair-browser.sh "$origin" "$container" > "$scratch/link"
link=$(tail -n 1 "$scratch/link")
status=$(curl -sS -H 'Accept: text/html' -c "$scratch/cookies" -D "$scratch/headers" -o /dev/null -w '%{http_code}' "$link")
[ "$status" = 302 ]
grep -iq '^location: /' "$scratch/headers"
grep -q opencode_session_14096 "$scratch/cookies"
[ "$(curl -sS -b "$scratch/cookies" -o /dev/null -w '%{http_code}' "$origin/api/info")" = 200 ]
[ "$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' "$link")" = 401 ]
[ "$(curl -sS -o /dev/null -w '%{http_code}' "$origin/api/info")" = 401 ]
echo 'Live pairing: cookie accepted, single-use link enforced, unauthenticated API rejected.'
