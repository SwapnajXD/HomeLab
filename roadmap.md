# Olympus V2 roadmap

The canonical phase checklist is [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md).

The [September 12 rebuild](rebuild-history.md) completed Hermes provisioning, single-node K3s, Tailscale API access, Hestia retirement, Athena observability cleanup and the Athena baseline backup integrity check.

Next: Kubernetes baseline audit and policy, Hermes metrics/logs integrated with Athena, storage and rollout/rollback testing, an application such as D2Bus, backup automation and restore tests. Athena's OS migration is planned separately. Terraform, Ansible and CI/CD are future implementation work; Floci is not reported deployed in V2.

The [pre-V2 roadmap](docs/historical/roadmap-pre-v2.md) preserves earlier priorities. Multi-node Kubernetes and a Raspberry Pi remain optional later experiments.
