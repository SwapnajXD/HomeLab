# Apollo infrastructure

Apollo owns Proxmox VE, storage, VM networking, routing/NAT, firewalling and guest backups. See the [infrastructure baseline](../../docs/infrastructure.md) and [networking](../../docs/networking.md).

Current host configuration exports have not been imported. The old `configs/apollo/101.conf` is **Hestia's retired LXC definition**, not Hermes VM 101; it is preserved with the obsolete network backup in [the V1 archive](../../archive/v1/configs/apollo/). Do not restore it as a Hermes VM configuration.

Future sanitized exports belong here: the actual Hermes VM definition, host interfaces, storage configuration and firewall service/script. Preserve credential files outside Git.
