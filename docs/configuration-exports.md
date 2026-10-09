# Current configuration exports and recovery evidence

The repository does not yet reproduce the live stack. Read-only SSH attempts to Apollo (`100.81.86.51`) and Athena (`100.93.224.83`) timed out on 2026-10-09, so no current exports, VM 102 allocation or backup inventory were obtained. This is an access result, not evidence that the hosts are powered off.

## Required imports

| Source | Required material | Repository destination |
|---|---|---|
| Athena VM 102 | Authored telemetry Compose file, sanitized environment example, image versions, bind mounts and persistent-volume identities | `docker/telemetry/` |
| Athena | Current Prometheus scrape config and alert rules; validate using its deployed Prometheus version | `infrastructure/athena/prometheus/` |
| Athena | Loki config, Alloy config, exporter settings without credentials | `infrastructure/athena/` |
| Hermes | Host Alloy service/config, cAdvisor and Floci authored Compose definitions, sanitized examples | `infrastructure/hermes/` (organize actual imports by service) |
| Apollo | VM 101/102 definitions, version inventory, host network/storage/firewall definitions | `infrastructure/apollo/` |

On Apollo, read-only `qm config 102`, `qm config 101`, `pveversion -v` and `pvesm status` establish current resources, versions and storage. `pvesm list Storage --content backup` inventories that storage's backup entries; it does not establish off-box protection or restore success. Record collection time and command results with sensitive fields redacted. Inspect authored Compose/configuration files on Athena; rendered Compose may expand secrets and must not be committed blindly.

Preserve existing Compose project names, external networks, volume names and host mounts during import. A changed project name can create empty replacement volumes. Do not restart services as part of collecting exports. Record each configuration's original path, destination, validation command and any placeholders requiring local values. Keep real credentials and TLS private keys outside Git.

## VM 102 and recovery information still required

- CPU, RAM, disk allocation and guest kernel; do not copy VM 100's resource assumptions.
- Exact current backup identifier, creation time, scope, retention and storage location.
- Whether a protected off-box copy exists and who can access recovery credentials.
- Recorded restore test, data/service checks and measured recovery time.

Migration restore verification is historical evidence, but its backups were removed. See [recovery](disaster-recovery.md) for the current gap. Creating a new backup or performing a restore drill is separate host work, not something this repository cleanup performed.

## First Kubernetes application

[Olympus](olympus.md) is the proposed first workload. No application source, image, service contract or deployable configuration has been supplied in this repository. Add actual application manifests when the application is ready, with a pinned image, resource settings, ingress, secret references, readiness checks and rollback instructions. Do not label empty manifest directories or a throwaway demonstration as a completed deployment.
