# V2 infrastructure and IaC

Based on the [September 12 rebuild record](history/rebuild-history.md), without new provisioning or live inspection.

| Resource | Apollo | Athena | Hermes |
|---|---|---|---|
| Identity | Physical host | VM 100 | VM 101 |
| Platform | Proxmox VE 9.2.2 / Debian 13 | Ubuntu 20.04.6 | Ubuntu 24.04.5 |
| Kernel | `7.0.2-6-pve` | `5.4.0-216-generic` | Not supplied |
| CPU | Ryzen 7 3700X, 8 cores / 16 threads | 4 vCPU | 4 vCPU |
| RAM | 16 GiB | 4 GiB | 4 GiB |
| Storage | ~238.5 GB NVMe + ~232.9 GB SATA | 32 GiB virtual disk | 32 GiB virtual disk |

Apollo's NVMe holds EFI, root, swap and the `local-lvm` thin pool. SATA is mounted at `/mnt/pve/Storage` for backups. Storage IDs are `local`, `local-lvm`, `Storage`.

Hermes uses Q35, VirtIO networking, VirtIO SCSI and QEMU Guest Agent enabled, with autostart. Its LV/filesystem was expanded within the original virtual disk to approximately 30 GB root, with 23 GB available at the recorded check. See rebuild sections 9–14 for creation commands and fixes.

Hestia CT 101 was destroyed after backup verification; Hermes now uses VM ID 101. No LXCs remain. Athena's final root usage was approximately 12 GB of 30 GB (40%), with 17 GB available; memory available was approximately 2.6 GiB. These are dated observations.

## Reproducibility

Infrastructure-as-code, Terraform-based homelab provisioning, Ansible and CI/CD remain future work. Retained [Floci examples](../archive/v1/terraform/floci/README.md) document earlier AWS API emulation experiments; Floci was removed from Athena and no current Hermes emulator deployment is reported. LocalStack is historical/deprecated. The repository is not a verified export of the current host configuration.

Athena's Ubuntu migration is planned separately, with backup and rollback preparation; see [recovery](disaster-recovery.md).
