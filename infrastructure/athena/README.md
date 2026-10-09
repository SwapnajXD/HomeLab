# Athena infrastructure

Athena VM 102 (Ubuntu Server 24.04.5 LTS) hosts the eight-container V2 observability stack. See [observability](../../docs/observability.md).

The previous Prometheus configuration and Promtail files are preserved in the [V1 telemetry archive](../../archive/v1/docker-compose/telemetry/) and [old Athena configs](../../archive/v1/configs/athena/). They do not establish the current V2 configuration.

Place reviewed, sanitized current Prometheus files in `prometheus/`. The retained InstanceDown rule is included there as a reference; confirm it against Athena before deployment. The current `prometheus.yml`, Loki configuration, Alloy configuration and Proxmox exporter settings still need to be exported from Athena. Exporter credentials must remain untracked.

The intended Compose location is [docker/telemetry](../../docker/telemetry/).

The [post-migration report](../../docs/history/athena-migration-report.md) records LAN `10.10.10.10`, Tailscale `100.93.224.83`, verified telemetry data and seven healthy targets. Old VM 100 and migration backups were deleted. VM 102 resource allocation and a retained backup are not specified; obtain current exports and recovery evidence.
