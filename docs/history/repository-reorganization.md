# Repository reorganization — 2026-09-12

The V2 repository was reorganized locally after the rebuild documentation update. This changes repository paths, not paths or services on Apollo, Athena or Hermes. No live configuration was fetched and no deployment was performed.

## Path map

| Previous location | Current location |
|---|---|
| Root V2 guides | `docs/` |
| `HOMELAB_ROADMAP.md` | `docs/roadmap.md` — single active roadmap |
| Root roadmap pointer | `archive/documentation/roadmap-pointer-pre-reorganization.md` |
| `rebuild-history.md` | `docs/history/rebuild-history.md` |
| `docs/historical/` | Dated records in `docs/history/`; obsolete guides in `docs/history/v1/` |
| Root Mermaid files | `diagrams/`; architecture and networking filenames shortened |
| `architecture/README.md` | `diagrams/README.md` |
| Old diagram archive | `archive/documentation/diagrams/` |
| `configs/` | `archive/v1/configs/`; current infrastructure locations prepared separately |
| `docker-compose/` | `archive/v1/docker-compose/`; V2 export destination is `docker/telemetry/` |
| `terraform/floci/`, `terraform/localstack/` | `archive/v1/terraform/` |
| `scripts/fetch_*.sh` | `archive/v1/scripts/` |
| Dashboard `data/` | `archive/v1/data/`, local and still ignored by Git |
| Existing screenshots | `screenshots/historical/` |
| `Questions.txt` | `archive/documentation/Questions.txt` |

The active Kubernetes namespace, workload, service, ingress, config, storage and observability directories are prepared with placeholders. No application manifests are claimed deployed. Replaced overview/readme files and the prior restart helper are preserved in `archive/documentation/pre-reorganization/`.

## Configuration findings

- Apollo's old `101.conf` is a Hestia LXC definition, not Hermes VM 101. The network backup also differs from the reported V2 network; both are archived.
- The old telemetry Compose uses Promtail, omits several reported V2 containers and references unavailable host-local files. Its associated Prometheus config has three target jobs rather than the five reported in V2. The old files are archived without rewriting their historical configuration.
- `infrastructure/athena/prometheus/alert.rules.yml` is a retained reference copy, explicitly marked as requiring comparison with Athena. A current sanitized `prometheus.yml` and complete telemetry Compose/Loki/Alloy/exporter configuration remain to be imported.
- The archived dashboard API and fetch jobs retain original absolute host paths. These are historical dependencies, not broken paths in active automation. Historical command transcripts and snapshot README files likewise retain their original path context.
- The former LocalStack provider lockfile was tracked despite the general ignore rule. An exact archive-path exception preserves its trackability. Dashboard data and credentials remain ignored.

## Verification

Every pre-reorganization file was accounted for at its new or unchanged location. Non-Markdown files were verified byte-for-byte except the intentionally revised telemetry restart helper and ignore-rule update; the old helper is preserved separately. All eight local JSON files were preserved without adding them to version control.

Markdown navigation links were rebased and checked, excluding deliberately preserved guide snapshots whose original references are part of their historical context. Active Bash files passed syntax checks. No GitHub workflows were present to update.

The restart helper was tested with a mock Docker command: a missing default Compose file invokes no Docker; an explicit path works from another working directory; failed configuration validation prevents restart. The helper now restarts existing containers rather than running Compose down/up. It does not apply configuration changes. No actual Docker operation was performed during verification.

Current diagrams were moved unchanged; historical embedded diagrams and command transcripts were retained. The untracked `homelab-audit.txt` remains local and untouched.
