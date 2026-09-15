# Hermes infrastructure

No host configuration was fetched from Hermes during the reorganization — the following is reported by the operator, not independently verified from a live export. Per the [rebuild record](../../docs/history/rebuild-history.md): Hermes is VM 101, Ubuntu 24.04.5, 4 vCPU, 6 GiB RAM (increased from 4 GiB on 2026-09-14), 32 GiB disk, LAN `10.10.10.11`, Tailscale `100.91.200.31`, running single-node K3s `v1.36.4+k3s1`. Floci is also reported running here via Docker Compose (on-demand, not continuous).

This directory is reserved for reviewed guest configuration exports and provisioning automation. The reported Netplan and K3s TLS SAN excerpts are in the [rebuild history](../../docs/history/rebuild-history.md); workload manifests belong in [kubernetes/](../../kubernetes/).
