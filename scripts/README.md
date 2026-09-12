# Operational scripts

- `healthcheck.sh`: read-only local host, Docker and Tailscale status checks; run on the intended host (Athena for Docker telemetry).
- `restart-telemetry.sh [compose-file]`: validate and restart an existing Compose project, then show its status. Defaults to `docker/telemetry/docker-compose.yml` relative to the repository, regardless of the working directory. Fails if the file is absent. Requires Docker access and does not apply configuration changes or create a deployment.

The current V2 Compose export is pending; see [telemetry preparation](../docker/telemetry/README.md). No live restarts were performed during this reorganization.

The obsolete dashboard fetch scripts and their generated data are preserved in [archive/v1](../archive/v1/README.md). They retain historical host paths and are not active automation. See [operations](../docs/operations.md).
