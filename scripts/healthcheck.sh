#!/usr/bin/env bash
# Local diagnostics; no service restarts or privilege escalation.
set -uo pipefail

check_docker=true
check_tailscale=true
for arg in "$@"; do
  case "$arg" in
    --skip-docker) check_docker=false ;;
    --skip-tailscale) check_tailscale=false ;;
    --help)
      printf 'Usage: %s [--skip-docker] [--skip-tailscale]\n' "$0"
      printf 'HEALTHCHECK_TIMEOUT: per-command timeout in seconds (default: 10).\n'
      exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
limit=${HEALTHCHECK_TIMEOUT:-10}
if [[ ! $limit =~ ^[1-9][0-9]*$ ]]; then
  printf 'HEALTHCHECK_TIMEOUT must be a positive integer.\n' >&2
  exit 2
fi
if ! command -v timeout >/dev/null 2>&1; then
  printf 'FAIL: GNU timeout is required.\n' >&2
  exit 1
fi
failures=0
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
run() { timeout --kill-after=2s "${limit}s" "$@"; }
check() {
  local label=$1
  shift
  printf '\n%s\n' "$label"
  if run "$@"; then printf 'PASS: %s\n' "$label"; else fail "$label"; fi
}
check 'System uptime' uptime
check 'Memory information' free -h
check 'Filesystem information' df -h

if "$check_docker"; then
  printf '\nRunning Docker containers\n'
  if ids=$(run docker ps --quiet); then
    if [[ -z $ids ]]; then
      fail 'No running Docker containers; use --skip-docker on non-Docker hosts.'
    else
      mapfile -t containers <<< "$ids"
      if states=$(run docker inspect --format '{{.Name}} {{if .State.Health}}{{.State.Health.Status}}{{else}}unconfigured{{end}}' "${containers[@]}"); then
        printf '%s\n' "$states"
        while read -r name state; do
          case "$state" in
            healthy) printf 'PASS: %s\n' "$name" ;;
            unconfigured) printf 'INFO: %s has no Docker healthcheck; application health is unverified.\n' "$name" ;;
            *) fail "$name health is ${state:-unknown}" ;;
          esac
        done <<< "$states"
      else
        fail 'Docker inspection failed.'
      fi
    fi
  else
    fail 'Docker unavailable or access denied; run with authorized Docker access.'
  fi
else
  printf '\nSKIP: Docker\n'
fi

if "$check_tailscale"; then
  printf '\nTailscale backend\n'
  if status=$(run tailscale status --json); then
    if backend=$(printf '%s' "$status" | run python3 -c 'import json,sys; print(json.load(sys.stdin)["BackendState"])'); then
      if [[ $backend == Running ]]; then
        printf 'PASS: Tailscale backend Running (peer connectivity not tested).\n'
      else
        fail "Tailscale backend is $backend"
      fi
    else
      fail 'Cannot parse Tailscale status; Python 3 and BackendState are required.'
    fi
  else
    fail 'Tailscale status failed.'
  fi
else
  printf '\nSKIP: Tailscale\n'
fi
printf '\nResult: %s failed checks.\n' "$failures"
(( failures == 0 ))
