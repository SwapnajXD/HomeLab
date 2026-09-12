# V2 operations

The [September 12 rebuild history](history/rebuild-history.md) is the dated implementation and troubleshooting record. Its health results were supplied by the operator; this documentation update did not run live checks.

## Command ownership

| System | Operations |
|---|---|
| Apollo | `qm`, `pct`, `vzdump`; storage, routing/NAT and firewall |
| Athena | Docker Compose telemetry, log retention, guest packages |
| Hermes | K3s, guest networking, Kubernetes workloads |
| Artemis | SSH, Git, kubeconfig and remote kubectl |

Hestia is retired. VM 101 now means Hermes, so historical CT 101 procedures must not be replayed.

## Reported validation

- Apollo: Internet and VM connectivity, forwarding/NAT, active firewall service and working storage.
- Athena: eight running containers, zero failed systemd units, Prometheus ready, Grafana database `ok`, Loki ready, five up scrape targets and TCP 2375 not listening.
- Hermes: Ready K3s node, healthy system components and working Artemis API access with certificate validation.
- Athena backup: successful `vzdump` and Zstandard integrity check; restore testing pending.

Athena's three normal package upgrades included Tailscale `1.102.2` → `1.102.4`; no reboot was required. Ubuntu 20.04.6 and kernel `5.4.0-216-generic` remained. The reported ESM update notice led to deferring a major OS migration for separate planning.

## Maintenance lessons

Validate configuration before restart, inspect active Prometheus targets rather than historical series, identify port owners before removing listeners, and investigate real connectivity before resetting failed systemd states. Preserve and verify backups before destructive changes. Historical cleanup commands in the rebuild record are not routine maintenance steps.

## Outstanding verification

Athena's exact LAN IP is unconfirmed in the new report. Hermes baseline policy, storage tests, observability integration, application recovery, automated backup coverage, restore testing and fresh alert-delivery validation remain outstanding. The named Athena archive's ordering relative to the package upgrade should be checked before relying on its exact package contents.

Earlier [runbooks](history/v1/runbook.md), [health checks](history/v1/health-checks.md), [troubleshooting](history/v1/troubleshooting.md), [validation reports](history/v1/validation-report.md) and [postmortems](history/postmortems.md) preserve history; use the V2 inventory and endpoints when planning future operations.
