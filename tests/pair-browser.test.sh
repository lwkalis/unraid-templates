#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
repo=$PWD
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
mkdir "$scratch/bin"
export PAIR_TEST_SCRATCH="$scratch"
cat > "$scratch/bin/docker" <<'MOCK'
#!/bin/sh
printf '%s\n' "$@" > "$PAIR_TEST_SCRATCH/docker-args"
[ "$1" = exec ] || exit 91
[ "${PAIR_TEST_DOCKER_FAIL-}" != 1 ] || exit 1
shift 2
exec "$@"
MOCK
cat > "$scratch/bin/wget" <<'MOCK'
#!/bin/sh
[ "$#" = 8 ] || exit 92
[ "$1" = -q ] && [ "$2" = -T ] && [ "$3" = 15 ] || exit 93
[ "$4" = -O ] && [ "$5" = - ] || exit 94
expected=$(printf 'opencode:%s' "$PAIR_TEST_EXPECTED_PASSWORD" | base64 | tr -d '\r\n')
[ "$6" = "--header=Authorization: Basic $expected" ] || exit 95
[ "$7" = --post-data= ] || exit 96
[ "$8" = http://127.0.0.1:4096/api/pair ] || exit 97
[ "${PAIR_TEST_WGET_FAIL-}" != 1 ] || exit 1
printf '%s\n' "${PAIR_TEST_RESPONSE}"
MOCK
chmod +x "$scratch/bin/docker" "$scratch/bin/wget"
PATH="$scratch/bin:$PATH"
export PATH
unset OPENCODE_PASSWORD
export OPENCODE_SERVER_PASSWORD='test-only long:password with spaces'
export PAIR_TEST_EXPECTED_PASSWORD="$OPENCODE_SERVER_PASSWORD"
export PAIR_TEST_RESPONSE='{"code":"abcdefghijklmnopqrstuv","expires_in":300}'

pass=0
run_ok() {
  sh "$repo/scripts/pair-browser.sh" "$@" > "$scratch/out" 2> "$scratch/err"
  grep -Fq "$expected_link" "$scratch/out"
  ! grep -Fq "$OPENCODE_SERVER_PASSWORD" "$scratch/out"
  ! grep -Fq "$OPENCODE_SERVER_PASSWORD" "$scratch/err"
  pass=$((pass + 1))
}
run_fail() {
  if sh "$repo/scripts/pair-browser.sh" "$@" > "$scratch/out" 2> "$scratch/err"; then
    echo "Expected failure: $*" >&2; exit 1
  fi
  ! grep -q /auth/connect/ "$scratch/out"
  ! grep -Fq "$OPENCODE_SERVER_PASSWORD" "$scratch/out"
  ! grep -Fq "$OPENCODE_SERVER_PASSWORD" "$scratch/err"
  pass=$((pass + 1))
}

expected_link='http://nas:4097/auth/connect/abcdefghijklmnopqrstuv'
run_ok http://nas:4097/
[ "$(sed -n '2p' "$scratch/docker-args")" = OpenCode ]
run_ok http://nas:4097 Custom-OpenCode
[ "$(sed -n '2p' "$scratch/docker-args")" = Custom-OpenCode ]
expected_link='https://[fd00::1]:444/auth/connect/abcdefghijklmnopqrstuv'
run_ok 'https://[fd00::1]:444'
export OPENCODE_PASSWORD='preferred test password'
export PAIR_TEST_EXPECTED_PASSWORD="$OPENCODE_PASSWORD"
run_ok 'https://[fd00::1]:444'
unset OPENCODE_PASSWORD
export PAIR_TEST_EXPECTED_PASSWORD="$OPENCODE_SERVER_PASSWORD"

run_fail
run_fail http://nas a b
for bad in 'ftp://nas' 'http://user:secret@nas' 'http://nas/path' 'http://nas?query' 'http://nas#fragment' 'http://nas bad' 'http://nas;echo'; do
  run_fail "$bad"
done
run_fail http://nas --privileged
run_fail http://nas 'bad name'
export PAIR_TEST_DOCKER_FAIL=1
run_fail http://nas
unset PAIR_TEST_DOCKER_FAIL
export PAIR_TEST_WGET_FAIL=1
run_fail http://nas
unset PAIR_TEST_WGET_FAIL
export OPENCODE_PASSWORD=''
run_fail http://nas
unset OPENCODE_PASSWORD
for bad in '{}' '{"code":"bad","expires_in":300}' '<html>Unauthorized</html>' '{"code":"abcdefghijklmnopqrstuv","expires_in":0}' '{"code":"../../../../../../evil","expires_in":300}'; do
  export PAIR_TEST_RESPONSE="$bad"
  run_fail http://nas
done
printf 'Passed %s pairing helper checks.\n' "$pass"
