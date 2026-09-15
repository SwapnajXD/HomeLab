# Olympus HomeLab V2

A Proxmox-based Cloud/DevOps learning platform with separate infrastructure, observability, Kubernetes and management systems.

**Baseline: September 12, 2026**, based on the operator's rebuild report, with a **September 14, 2026 continuation** (resource resize, Hermes↔Athena observability integration, Floci deployment). The infrastructure rebuild is complete; application deployment and recovery automation remain pending. This documentation update did not perform live checks.

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
| Athena | Ubuntu 20.04.6; 2 vCPU, 2 GiB RAM (reduced from 4 GiB), 32 GiB disk; Docker Compose telemetry |
| Hermes | Ubuntu 24.04.5; 4 vCPU, 6 GiB RAM (increased from 4 GiB), 32 GiB disk; K3s `v1.36.4+k3s1`, Ready; Floci on-demand via Docker Compose |
| Artemis | Management workstation; working Kubernetes API access over Tailscale |

Athena runs Prometheus, Grafana, Loki, Alloy, Node Exporter, cAdvisor, Proxmox Exporter and Glances. Hestia is retired; Athena's old K3s, Portainer and Floci deployments were removed. Historical source remains in the repository.

Start with the [complete rebuild history, challenges and validation](docs/history/rebuild-history.md), [V2 architecture](docs/architecture.md) and [roadmap](docs/roadmap.md).

## Documentation

See the [V2 diagram index](diagrams/README.md) for architecture, networking, metrics, logging, alerting and recovery diagrams.

- [Infrastructure](docs/infrastructure.md) and [networking](docs/networking.md)
- [Kubernetes](docs/kubernetes.md) and [observability](docs/observability.md)
- [Operations](docs/operations.md) and [backup/recovery](docs/disaster-recovery.md)
- [Changelog](docs/history/changelog.md), [project timeline](docs/history/project-timeline.md) and [historical incidents](docs/history/postmortems.md)
- [Retired services](docs/history/retired-services.md) and [pre-V2 roadmap](docs/history/v1/roadmap-pre-v2.md)

Current guides live in `docs/`, with dated records in `docs/history/` and obsolete V1 guides in `docs/history/v1/`. Deployment snapshots in `archive/v1/` are historical; current host configuration exports are still needed before the repository can reproduce the live V2 stack.

## Validation and recovery

The rebuild report records eight running Athena containers, healthy Prometheus/Grafana/Loki endpoints, five up Prometheus targets, zero failed Athena systemd units, Docker TCP 2375 closed, seven-day Loki retention and a Ready Hermes node. Hermes metrics (host + container, via a dedicated cAdvisor `0.60.5`) and logs (via Grafana Alloy) are now confirmed integrated with Athena's Prometheus and Loki as of the September 14 continuation.

Athena's V2 backup is retained on Apollo at `/mnt/pve/Storage/dump/vzdump-qemu-100-2026_09_12-18_35_13.vma.zst`. It passed Zstandard integrity testing; full restore testing remains pending. Hestia and V1 configuration backups were preserved.

Next work: audit and configure the Kubernetes workload baseline, integrate Hermes monitoring, test storage and rollout/rollback, deploy an application such as D2Bus, automate backups and test recovery. Athena's OS migration is a separate planned change. Multi-node Kubernetes and an optional Raspberry Pi are outside the current core design.

## Repository

See the [reorganization record](docs/history/repository-reorganization.md) for the path map, configuration gaps and verification results.

```text
HomeLab/
├── README.md
├── LICENSE
├── docs/                  # Current guides and one canonical roadmap
│   └── history/           # Rebuild and incident records; v1/ for older guides
├── diagrams/              # Current Mermaid sources
├── infrastructure/        # Apollo, Athena and Hermes configuration locations
├── kubernetes/            # Prepared manifest directories; no workloads yet
├── docker/telemetry/      # Awaiting the current Athena Compose export
├── terraform/             # Future active provisioning
├── scripts/               # Health check and telemetry restart helpers
├── screenshots/historical/
└── archive/               # V1 deployments, data and superseded documentation
```

The old Apollo `101.conf` belongs to Hestia, and the old telemetry Compose uses Promtail. Both are archived. The active infrastructure directories document missing exports; no replacement configuration is claimed to have been fetched or deployed. The previous dashboard JSON remains locally preserved and ignored under `archive/v1/data/`.

Licensed under the [MIT License](LICENSE).
