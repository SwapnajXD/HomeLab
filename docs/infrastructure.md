# V2 infrastructure and IaC

Based on the [September 12 rebuild record](history/rebuild-history.md) plus a [September 14 continuation](history/rebuild-history.md#60-resource-reallocation) (resource resize, Hermes↔Athena observability integration, Floci deployment), without new provisioning or live inspection since.

| Resource | Apollo | Athena | Hermes |
|---|---|---|---|
| Identity | Physical host | VM 100 | VM 101 |
| Platform | Proxmox VE 9.2.2 / Debian 13 | Ubuntu 20.04.6 | Ubuntu 24.04.5 |
| Kernel | `7.0.2-6-pve` | `5.4.0-216-generic` | Not supplied |
| CPU | Ryzen 7 3700X, 8 cores / 16 threads | 2 vCPU (reduced from 4) | 4 vCPU |
| RAM | 16 GiB | 2 GiB (reduced from 4) | 6 GiB (increased from 4) |
| Storage | ~238.5 GB NVMe + ~232.9 GB SATA | 32 GiB virtual disk | 32 GiB virtual disk |

Apollo's NVMe holds EFI, root, swap and the `local-lvm` thin pool. SATA is mounted at `/mnt/pve/Storage` for backups. Storage IDs are `local`, `local-lvm`, `Storage`.

Hermes uses Q35, VirtIO networking, VirtIO SCSI and QEMU Guest Agent enabled, with autostart. Its LV/filesystem was expanded within the original virtual disk to approximately 30 GB root, with 23 GB available at the recorded check. See rebuild sections 9–14 for creation commands and fixes.

Hestia CT 101 was destroyed after backup verification; Hermes now uses VM ID 101. No LXCs remain. Athena's final root usage was approximately 12 GB of 30 GB (40%), with 17 GB available; memory available was approximately 2.6 GiB before the September 14 resize. These are dated observations.

**Resource resize (2026-09-14):** allocation was reviewed against actual workload demand — Athena's observability stack runs comfortably in 2 GiB given 7-day Loki retention and a small number of scrape targets; the freed RAM was moved to Hermes for Kubernetes workload growth. Post-resize, Athena reported ~1.9 GiB usable / ~1.0 GiB available memory with all containers still running; Hermes reported ~5.8 GiB usable / ~4.8 GiB available with the K3s node still `Ready`. See [rebuild history §60](history/rebuild-history.md#60-resource-reallocation).

## Reproducibility

Infrastructure-as-code, Terraform-based homelab provisioning, Ansible and CI/CD remain future work. Retained [Floci examples](../archive/v1/terraform/floci/README.md) document earlier AWS API emulation experiments. **Floci is now reported deployed on Hermes** (not Athena) via Docker Compose, on-demand rather than continuously running — see [Kubernetes](kubernetes.md) and [rebuild history §64](history/rebuild-history.md#64-floci-deployed-on-hermes-on-demand-docker-compose--not-k3s). LocalStack is historical/deprecated. The repository is not a verified export of the current host configuration.

Athena's Ubuntu migration is planned separately, with backup and rollback preparation; see [recovery](disaster-recovery.md).
