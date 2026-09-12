# Hermes infrastructure

Hermes is VM 101: Ubuntu 24.04.5, 4 vCPU, 4 GiB RAM, 32 GiB disk, LAN `10.10.10.11`, Tailscale `100.91.200.31`. It runs single-node K3s `v1.36.4+k3s1`.

This directory is reserved for reviewed guest configuration exports and provisioning automation. No host configuration was fetched during the reorganization. The reported Netplan and K3s TLS SAN excerpts are in the [rebuild history](../../docs/history/rebuild-history.md); workload manifests belong in [kubernetes/](../../kubernetes/).
