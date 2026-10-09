# V2 infrastructure and IaC

Current state follows the [operator-supplied post-migration report](history/athena-migration-report.md), incorporated 2026-10-09 without live inspection. The exact migration date is not supplied.

| Resource | Apollo | Athena | Hermes |
|---|---|---|---|
| Identity | Standalone physical host | VM 102 | VM 101 |
| Platform | Proxmox VE / Debian 13 | Ubuntu Server 24.04.5 LTS | Ubuntu 24.04.5 |
| Kernel | Reported `7.0.14-19-pve` | Not supplied for VM 102 | Not supplied |
| CPU | Ryzen 7 3700X, 8 cores / 16 threads | Not supplied for VM 102 | Last recorded 4 vCPU |
| RAM | 16 GiB DDR4-3200 | Not supplied for VM 102 | Last recorded 6 GiB |
| Storage | Earlier inventory: ~238.5 GB NVMe + ~232.9 GB SATA | Not supplied for VM 102 | Last recorded 32 GiB disk |
| Internal IP | `10.10.10.1` | `10.10.10.10` | `10.10.10.11` |

VM 100 (Ubuntu 20.04) was retired and deleted after Athena's telemetry configuration and Prometheus/Grafana/Loki data were migrated and verified on VM 102. The old 2 vCPU / 2 GiB / 32 GiB allocation belongs to VM 100 and must not be assumed for VM 102. Hermes allocations were last recorded on September 14.

## Apollo hardware and versions

MSI X570-A PRO motherboard, MSI GTX 1660 SUPER 6 GB, Cooler Master MWE 750 White 230V V2 (`MPE-7501-ACABW-IN`) PSU, BIOS `E7C37AMS.HA0` dated 2020-09-07. The Ryzen CPU has no integrated graphics. See the [power-loss investigation](history/apollo-power-loss-2026-09.md) for GPU reseating, Gen1 x16 link negotiation, diagnostic evidence and deferred investigation.

The latest account lists Proxmox VE `9.2.0`, `pve-manager 9.2.20`, `pve-qemu-kvm 11.0.3-3`, `qemu-server 9.2.8`, Ceph `19.2.6-pve4` and ZFS `2.4.4-pve1`. These are supplied strings, not independently verified versions; the VE/manager strings need reconciliation with a current host export. Earlier records listed VE 9.2.2 and kernel `7.0.2-6-pve`.

Storage IDs are `local`, `local-lvm` and `Storage`; the latter is mounted at `/mnt/pve/Storage`. Migration backups and VM 100's disk were removed. Apollo is not a Proxmox cluster and remains a single physical point of failure.

## Reproducibility

Current host exports remain pending. Terraform, Ansible and CI/CD provisioning are planned; archived configurations cannot reproduce the current hosts. Request sanitized VM 101 and VM 102 definitions, interfaces, storage and firewall configuration when exporting the live baseline.

Hermes runs K3s and deliberately retains Docker Compose for Floci. Its last recorded Q35/VirtIO/guest-agent and disk-expansion details remain in the [September rebuild history](history/rebuild-history.md). Hestia CT 101 is retired; its archived definition is not Hermes VM 101. See [recovery](disaster-recovery.md) for the post-migration backup gap.
