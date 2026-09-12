# Olympus V1 archive

Historical material is preserved here for reference, not active deployment:

- `configs/`: old Apollo/Hestia definitions, network backups and Athena Promtail configuration.
- `docker-compose/`: core services, dashboard API, LocalStack and the outdated telemetry snapshot.
- `terraform/`: Floci and LocalStack examples.
- `scripts/`: retired dashboard data-fetch jobs.
- `data/`: locally preserved generated dashboard JSON, still ignored by Git.

Archived scripts and deployment snapshots retain original absolute host paths, endpoints and dependencies. They are not relocated runnable deployments. Do not replay them against Olympus V2. For example, `configs/apollo/101.conf` defines retired Hestia, while current VM 101 is Hermes.

The old dashboard API mounts `/home/ubuntu/homelab/data`; the fetch scripts use that path or `$HOME/homelab/data`. Their local JSON outputs were preserved here because the dashboard is retired. Missing private exporter settings and old host-local runtime data were not fabricated.

See [retirement history](../../docs/history/retired-services.md) and the [V2 rebuild](../../docs/history/rebuild-history.md).
