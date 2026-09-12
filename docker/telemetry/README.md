# Athena V2 telemetry

The active Compose destination is `docker/telemetry/docker-compose.yml`. That file is intentionally pending a sanitized export from Athena; this reorganization does not reconstruct missing live configuration from historical examples.

The export should describe Prometheus, Grafana, Loki, Alloy, Node Exporter, cAdvisor, Proxmox Exporter and Glances, with the existing persistent volume identities and retention settings preserved. Prometheus config mounts should resolve to `../../infrastructure/athena/prometheus/` from this directory. Keep Proxmox credentials untracked.

Before deployment, review every bind mount, validate the imported Compose and service configurations, and confirm that existing telemetry volumes will be reused. The [old Compose snapshot](../../archive/v1/docker-compose/telemetry/docker-compose.yml) is historical and contains missing host-local dependencies.

[scripts/restart-telemetry.sh](../../scripts/restart-telemetry.sh) accepts an explicit Compose path and fails before invoking Docker when the default V2 file has not been imported.
