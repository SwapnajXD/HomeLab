#!/bin/bash

cd ~/homelab/docker-compose/telemetry || exit 1

docker compose down

docker compose up -d

docker ps
