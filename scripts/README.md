# Operational scripts

- `healthcheck.sh [--skip-docker] [--skip-tailscale]`: bounded, read-only local diagnostics. Returns 0 when selected checks pass, 1 on failed checks, or 2 on usage errors. Requires Bash, GNU timeout, uptime/free/df, plus Docker access and Tailscale/Python 3 unless skipped. No sudo prompts or service changes.
- `restart-telemetry.sh [compose-file]`: validate and restart an existing Compose project, then show its status. Defaults to `docker/telemetry/docker-compose.yml` relative to the repository, regardless of the working directory. Fails if the file is absent. Requires Docker access and does not apply configuration changes or create a deployment.

The current V2 Compose export is pending; see [telemetry preparation](../docker/telemetry/README.md). No live restarts were performed during this reorganization.

The obsolete dashboard fetch scripts and their generated data are preserved in [archive/v1](../archive/v1/README.md). They retain historical host paths and are not active automation. See [operations](../docs/operations.md).

## Health-check scope

`HEALTHCHECK_TIMEOUT` sets each command timeout in seconds (default 10). For a non-Docker host such as Apollo, explicitly use `--skip-docker`. Docker access failures, no running containers, unhealthy/starting containers and Tailscale backend states other than Running fail the check. Checks continue after failures and aggregate the exit status.

Only running containers are inspected: intentionally stopped Floci containers do not fail a telemetry-host check. A container without a configured healthcheck is reported as unverified, not application-healthy. This script cannot detect a missing expected service or prove endpoint readiness, peer connectivity, resource headroom or whole-homelab health. Uptime/memory/disk commands collect information; they apply no utilization thresholds.

Repository checks: see [CONTRIBUTING](../CONTRIBUTING.md). `validate-repo.py` checks local documentation/configuration consistency without contacting infrastructure.
