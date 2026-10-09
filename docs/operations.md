# V2 operations

Current state follows the [post-migration report](history/athena-migration-report.md), incorporated 2026-10-09. Checks were reported by the operator, not run during this documentation update. Earlier procedures remain in the [September rebuild history](history/rebuild-history.md).

## Command ownership

| System | Operations |
|---|---|
| Apollo | Proxmox, storage, routing/NAT, firewall, VM backups |
| Athena VM 102 | Docker Compose telemetry, retention, guest packages |
| Hermes VM 101 | K3s, Docker Compose applications, host/Docker telemetry |
| Artemis | SSH, Git, kubeconfig and remote kubectl |

VM 100 has been deleted. Hestia CT 101 is retired and ID 101 now means Hermes VM 101; historical guest commands must not be replayed.

## Reported validation

- Athena migration preserved Prometheus, Grafana, Loki data and telemetry configuration.
- Prometheus, Loki, Grafana and cAdvisor health checked; seven Prometheus targets up.
- Fresh Hermes Docker logs queried on Athena at `100.93.224.83` through Loki.
- Hermes single-node K3s remains Ready, with Traefik and Artemis access.
- Apollo is operational after the [September power-loss incident](history/apollo-power-loss-2026-09.md). GPU reseating restored display and boot; Gen1 x16 link negotiation remains unresolved, with no active PCIe errors reported during investigation.

## Maintenance lessons

Validate configuration before restart; inspect active targets, listeners and fresh logs. Verify recoverable backups before destructive actions. The old Athena VM and migration backups were deleted after validation, so establish a current VM 102 recovery point before relying on older backup instructions.

Apollo's `amd_pstate`, USB/Wi-Fi initialization, firewall-service, metrics connection-refused and NVIDIA UCSI/I²C observations are separate investigation items, not established causes of the GPU/POST incident. The incident recommends returning the test PCIe setting to Auto; completion was not reported. Monitor for recurrence and defer further hardware changes while stable.

## Outstanding verification

- Export current VM 102 resource allocation, guest kernel and sanitized telemetry configuration.
- Reconcile the reported Apollo Proxmox version strings against a host export.
- Establish current backup inventory, protected off-box copies, automation and isolated restore drills.
- Validate Hermes workload policy, real PVC storage, rollout/rollback, Kubernetes metrics, host journals and K3s/containerd logs.
- Test fresh alert firing, notification delivery and recovery; historical Telegram success does not establish current delivery.

Current host directories are recorded in [Hermes infrastructure](../infrastructure/hermes/README.md). Historical [runbooks](history/v1/runbook.md), [health checks](history/v1/health-checks.md) and [troubleshooting](history/v1/troubleshooting.md) retain their dated context.
