# Olympus HomeLab V2

A Proxmox-based Cloud/DevOps learning platform with separate infrastructure, observability, Kubernetes and management systems.

**Baseline: September 12, 2026**, based on the operator's rebuild report. The infrastructure rebuild is complete; application deployment, Hermes observability integration and recovery automation remain pending. This documentation update did not perform live checks.

```text
Artemis — Tailscale / SSH / kubectl / Git
                    |
             Apollo — Proxmox VE
             routing / NAT / storage
                    |
             10.10.10.0/24
          +---------+---------+
          |                   |
     Athena (VM 100)     Hermes (VM 101)
     Observability      Single-node K3s
```

| System | Current role and baseline |
|---|---|
| Apollo | Proxmox VE 9.2.2, Debian 13, Ryzen 7 3700X, 16 GiB RAM; Wi-Fi WAN and private VM bridge |
| Athena | Ubuntu 20.04.6; 4 vCPU, 4 GiB RAM, 32 GiB disk; Docker Compose telemetry |
| Hermes | Ubuntu 24.04.5; 4 vCPU, 4 GiB RAM, 32 GiB disk; K3s `v1.36.4+k3s1`, Ready |
| Artemis | Management workstation; working Kubernetes API access over Tailscale |

Athena runs Prometheus, Grafana, Loki, Alloy, Node Exporter, cAdvisor, Proxmox Exporter and Glances. Hestia is retired; Athena's old K3s, Portainer and Floci deployments were removed. Historical source remains in the repository.

Start with the [complete rebuild history, challenges and validation](rebuild-history.md), [V2 architecture](architecture.md) and [roadmap](HOMELAB_ROADMAP.md).

## Documentation

See the [V2 diagram index](architecture/README.md) for architecture, networking, metrics, logging, alerting and recovery diagrams.

- [Infrastructure](infrastructure.md) and [networking](networking.md)
- [Kubernetes](kubernetes.md) and [observability](observability.md)
- [Operations](operations.md) and [backup/recovery](disaster-recovery.md)
- [Changelog](docs/historical/changelog.md), [project timeline](docs/historical/project-timeline.md) and [historical incidents](docs/historical/postmortems.md)
- [Retired services](docs/historical/retired-services.md) and [pre-V2 roadmap](docs/historical/roadmap-pre-v2.md)

Older documentation lives in `docs/historical/`; diagrams, screenshots and deployment examples retain their historical context. Use the root-level documentation for the current reported baseline; retained configuration files are not a verified export of the rebuilt hosts.

## Validation and recovery

The rebuild report records eight running Athena containers, healthy Prometheus/Grafana/Loki endpoints, five up Prometheus targets, zero failed Athena systemd units, Docker TCP 2375 closed, seven-day Loki retention and a Ready Hermes node. Hermes metrics/logs are not yet integrated with Athena.

Athena's V2 backup is retained on Apollo at `/mnt/pve/Storage/dump/vzdump-qemu-100-2026_09_12-18_35_13.vma.zst`. It passed Zstandard integrity testing; full restore testing remains pending. Hestia and V1 configuration backups were preserved.

Next work: audit and configure the Kubernetes workload baseline, integrate Hermes monitoring, test storage and rollout/rollback, deploy an application such as D2Bus, automate backups and test recovery. Athena's OS migration is a separate planned change. Multi-node Kubernetes and an optional Raspberry Pi are outside the current core design.

## Repository

The repository root contains the current documentation and V2 rebuild history. `docs/historical/` contains the older documentation. Root `.mmd` files contain current diagrams; `architecture/` provides their index. `docs/historical/diagrams/` and `screenshots/` preserve earlier visual context. `docker-compose/`, `configs/`, `scripts/` and `terraform/` retain implementation examples and prior deployment material.

Licensed under the [MIT License](LICENSE).
