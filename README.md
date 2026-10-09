# Olympus HomeLab V2

A Proxmox-based Cloud/DevOps learning platform with separate infrastructure, observability, Kubernetes and management systems.

**Documentation synchronized: 2026-10-09**, from the operator's [post-migration report](docs/history/athena-migration-report.md) and [September Apollo incident](docs/history/apollo-power-loss-2026-09.md). Athena now runs as VM 102; VM 100 was deleted after migration validation. Exact event dates were not supplied. These are reported results, not new live checks.

```text
Artemis — Tailscale / SSH / kubectl / Git
                    |
             Apollo — Proxmox VE
             routing / NAT / storage
                    |
             10.10.10.0/24
          +---------+---------+
          |                   |
     Athena (VM 102)     Hermes (VM 101)
     Observability      Single-node K3s
```

| System | Current role and baseline |
|---|---|
| Apollo | Proxmox VE / Debian 13 (reported version details in the infrastructure guide), Ryzen 7 3700X, 16 GiB RAM; Wi-Fi WAN and private VM bridge |
| Athena | VM 102, Ubuntu 24.04.5; Docker Compose telemetry; replacement VM resource allocation not supplied |
| Hermes | Ubuntu 24.04.5; 4 vCPU, 6 GiB RAM (increased from 4 GiB), 32 GiB disk; K3s `v1.36.4+k3s1`, Ready; Floci on-demand via Docker Compose |
| Artemis | Management workstation; working Kubernetes API access over Tailscale |

Athena runs Prometheus, Grafana, Loki, Alloy, Node Exporter, cAdvisor, Proxmox Exporter and Glances. Hestia is retired; Athena's old K3s, Portainer and Floci deployments were removed. Historical source remains in the repository.

Start with the [post-migration report](docs/history/athena-migration-report.md), [earlier rebuild history](docs/history/rebuild-history.md), [V2 architecture](docs/architecture.md) and [roadmap](docs/roadmap.md).

## Documentation

See the [V2 diagram index](diagrams/README.md) for architecture, networking, metrics, logging, alerting and recovery diagrams.

- [Infrastructure](docs/infrastructure.md) and [networking](docs/networking.md)
- [Kubernetes](docs/kubernetes.md) and [observability](docs/observability.md)
- [Operations](docs/operations.md) and [backup/recovery](docs/disaster-recovery.md)
- [Changelog](docs/history/changelog.md), [project timeline](docs/history/project-timeline.md) and [historical incidents](docs/history/postmortems.md)
- [Retired services](docs/history/retired-services.md) and [pre-V2 roadmap](docs/history/v1/roadmap-pre-v2.md)

Current guides live in `docs/`, with dated records in `docs/history/` and obsolete V1 guides in `docs/history/v1/`. Deployment snapshots in `archive/v1/` are historical; current host configuration exports are still needed before the repository can reproduce the live V2 stack.

## Validation and recovery

The post-migration report records preserved Prometheus, Grafana and Loki data, healthy service endpoints, seven Prometheus targets up, and fresh Hermes Docker logs queried from Athena. Hermes remains a Ready single-node K3s cluster; cAdvisor `0.60.5` and host Alloy provide Docker telemetry.

The migration backups and old VM 100 disk were removed after verification. A retained recovery point for VM 102 is not established; see [recovery](docs/disaster-recovery.md) before relying on historical archive paths. Apollo is operational after the power-loss incident; its GPU still negotiates Gen1 x16, with no active PCIe errors reported during investigation.

Current focus: deploy a real application on Hermes K3s. The [Olympus infrastructure dashboard](docs/olympus.md) is a candidate; D2Bus, additional nodes and Oracle as a possible worker remain later work. Backup automation, isolated restore drills and Kubernetes-level telemetry remain outstanding.

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
