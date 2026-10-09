# Hermes infrastructure

No host configuration was fetched from Hermes during the reorganization — the following is reported by the operator, not independently verified from a live export. Per the [rebuild record](../../docs/history/rebuild-history.md): Hermes is VM 101, Ubuntu 24.04.5, 4 vCPU, 6 GiB RAM (increased from 4 GiB on 2026-09-14), 32 GiB disk, LAN `10.10.10.11`, Tailscale `100.91.200.31`, running single-node K3s `v1.36.4+k3s1`. Floci is also reported running here via Docker Compose (on-demand, not continuous).

This directory is reserved for reviewed guest configuration exports and provisioning automation. The reported Netplan and K3s TLS SAN excerpts are in the [rebuild history](../../docs/history/rebuild-history.md); workload manifests belong in [kubernetes/](../../kubernetes/).

## Post-migration layout and telemetry

The [latest operator report](../../docs/history/athena-migration-report.md) retains Hermes VM 101 / `10.10.10.11` / `100.91.200.31` and separates host directories as follows:

```text
~/apps/dashboard/       # Intended Olympus application
~/apps/floci/           # compose/, compose.yml, data/
~/backups/
~/config/
~/k8s/apps/
~/k8s/infrastructure/
~/k8s/namespaces/
~/scripts/start
~/scripts/stop
~/tmp/
```

Floci uses `floci/floci:latest` with ports `4566`, `6379–6399` and `7001–7099`. Its data directory contains Resource Explorer view/index/setup JSON and generated TLS certificate/key/metadata files; these remain host-local. Docker Compose remains intentional alongside K3s.

Hermes cAdvisor is `0.60.5`. Host systemd Alloy reads Docker logs, labels them `host="hermes"`, and pushes to `http://100.93.224.83:3100/loki/api/v1/push`. Its HTTP interface is `100.91.200.31:12345`. The operator reports fresh logs queried after migration. The proposed [Olympus dashboard](../../docs/olympus.md) remains a future K3s workload.
