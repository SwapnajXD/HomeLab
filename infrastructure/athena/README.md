# Athena infrastructure

Athena VM 100 hosts the eight-container V2 observability stack. See [observability](../../docs/observability.md).

The previous Prometheus configuration and Promtail files are preserved in the [V1 telemetry archive](../../archive/v1/docker-compose/telemetry/) and [old Athena configs](../../archive/v1/configs/athena/). They do not establish the current V2 configuration.

Place reviewed, sanitized current Prometheus files in `prometheus/`. The retained InstanceDown rule is included there as a reference; confirm it against Athena before deployment. The current `prometheus.yml`, Loki configuration, Alloy configuration and Proxmox exporter settings still need to be exported from Athena. Exporter credentials must remain untracked.

The intended Compose location is [docker/telemetry](../../docker/telemetry/).
