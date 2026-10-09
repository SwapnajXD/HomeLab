# Apollo infrastructure

Apollo owns Proxmox VE, storage, VM networking, routing/NAT, firewalling and guest backups. See the [infrastructure baseline](../../docs/infrastructure.md) and [networking](../../docs/networking.md).

Current host configuration exports have not been imported. The old `configs/apollo/101.conf` is **Hestia's retired LXC definition**, not Hermes VM 101; it is preserved with the obsolete network backup in [the V1 archive](../../archive/v1/configs/apollo/). Do not restore it as a Hermes VM configuration.

Future sanitized exports belong here: the actual Hermes VM definition, host interfaces, storage configuration and firewall service/script. Preserve credential files outside Git.

## Latest operator report

Apollo remains a standalone Proxmox host with no physical HA. See the [current hardware/version inventory](../../docs/infrastructure.md) and [September power-loss investigation](../../docs/history/apollo-power-loss-2026-09.md). The GPU was reseated after a VGA debug LED/no-display incident; the host is operational, but the GPU link remains Gen1 x16. The supplied Proxmox version strings require host-export confirmation.

Current guests are Hermes VM 101 and Athena VM 102. Include both definitions in the next sanitized export; VM 100 and its disk were removed after Athena migration validation.
