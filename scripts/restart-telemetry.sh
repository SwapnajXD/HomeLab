#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
compose_file=${1:-"$script_dir/../docker/telemetry/docker-compose.yml"}
if [[ ! -f "$compose_file" ]]; then
  printf 'Compose file not found: %s\nImport the reviewed Athena V2 configuration or pass its path.\n' "$compose_file" >&2
  exit 1
fi

docker compose -f "$compose_file" config --quiet
docker compose -f "$compose_file" restart
docker compose -f "$compose_file" ps
