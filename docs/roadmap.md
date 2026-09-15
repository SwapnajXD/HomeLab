# Olympus HomeLab V2 roadmap

Olympus is a Cloud/DevOps learning and portfolio platform. Prioritize **infrastructure → automation → deployment → observability → reliability → recovery → cloud**, rather than the number of tools installed.

Status reflects the operator-supplied [September 12, 2026 rebuild record](history/rebuild-history.md) plus a [September 14, 2026 continuation](history/rebuild-history.md#60-resource-reallocation) (resource resize, Hermes↔Athena observability integration, Floci deployment), not a new live audit. Checked items are reported achievements; unchecked items remain planned. Earlier milestones retain their historical context.

## Phase 1 — Foundation: Completed

- [x] Proxmox and Linux VMs/LXCs.
- [x] Networking, NAT, firewall, SSH, and Tailscale.
- [x] Docker and Docker Compose.

## Phase 2 — Observability: Completed

- [x] Prometheus, Grafana, Loki, and Grafana Alloy.
- [x] Node Exporter, Proxmox Exporter, and cAdvisor.
- [x] Grafana alerting and Telegram notifications.

## Phase 3 — Reliability / Operations: Completed baseline

- [x] Health checks, disaster recovery documentation, operational runbooks, and troubleshooting documentation.
- [x] Incident/postmortem documentation and infrastructure validation.
- [x] VM/LXC autostart, firewall persistence, and networking incident recovery.

These achievements do not imply automated backups, complete restore coverage, or current uptime guarantees. Apollo's incident and dynamic WAN-aware firewall/NAT resolution remain in [postmortems](history/postmortems.md).

## Phase 4 — Kubernetes: Hermes baseline completed

- [x] Create Hermes VM 101: 4 vCPU, 4 GiB RAM, 32 GiB disk, Ubuntu 24.04.5, `10.10.10.11`.
- [x] Install single-node K3s `v1.36.4+k3s1`; verify Ready node and system pods.
- [x] Validate Artemis API access over Tailscale with matching TLS SAN.
- [x] Back up and uninstall Athena's old K3s; remove Floci and Portainer.
- [x] Retire Hestia after backup verification; keep Athena observability-only.
- [ ] Audit K3s baseline; define namespaces, RBAC, secrets and resource limits.
- [ ] Configure application ingress and test persistent storage.
- [x] Monitor Hermes host/Docker metrics from Athena and centralize Docker logs in Loki (host metrics via Node Exporter, container metrics via a dedicated cAdvisor 0.60.5, logs via Grafana Alloy — all confirmed 2026-09-14).
- [ ] Integrate and validate Kubernetes metrics, K3s/containerd workload logs and host journal collection.
- [ ] Validate alerts, rollout/rollback and recovery.

Single-node operation is intentional. Floci is now reported deployed on Hermes via Docker Compose, on-demand rather than continuously running. See [Kubernetes baseline](kubernetes.md).

## Phase 5 — Workload Platform: Planned

- [ ] Deploy a real application to K3s; D2Bus is a future candidate.
- [ ] Demonstrate building, containerizing, deploying, observing, updating, and recovering the application, including any required persistent data.

The outcome is the ability to operate an application on Kubernetes, beyond having a cluster. No production traffic or users are claimed.

## Phase 6 — Helm: Planned

- [ ] Implement application charts, values, and environment configuration.
- [ ] Exercise upgrades and rollbacks with observable results.

## Phase 7 — CI/CD: Planned

- [ ] Select tooling and implement `Git push → Tests → Build → Container image → Registry → Deployment`.
- [ ] Validate a failed build/test gate, a successful release, and a recovery path.

No CI/CD implementation is claimed. With later GitOps, the pipeline can update deployment configuration in Git for controller reconciliation.

## Phase 8 — GitOps: Planned

- [ ] Select Argo CD or Flux.
- [ ] Implement `Git → GitOps Controller → Kubernetes` and verify reconciliation and recovery from a bad change.

## Phase 9 — Configuration Management: Planned

- [ ] Introduce Ansible where repeatability provides value: VM configuration, packages, baseline setup, and repeatable server provisioning.
- [ ] Demonstrate repeatable execution and document what remains manual.

Terraform/Floci examples remain as historical learning material; Floci is reported deployed on Hermes via on-demand Docker Compose as of September 14. Proxmox IaC and broader VM reproducibility are incremental future work; the whole homelab is not claimed to be Terraform-provisioned.

## Phase 10 — Secrets: Planned

- [ ] Learn and implement SOPS with age for appropriate configuration secrets.
- [ ] Document access, key protection, rotation, and recovery.

Do not add Vault solely to expand the tool list. Hestia's retired Vaultwarden service and retained recovery material are separate from this planned infrastructure-secrets workflow.

## Phase 11 — Backup & Recovery: Baseline archived; improvements planned

- [x] Preserve Hestia/V1 recovery material and verify the Hestia compressed backup.
- [x] Create Athena V2 snapshot-mode backup on Apollo and pass Zstandard integrity testing.
- [ ] Define backup rotation and a Hermes backup baseline.
- [ ] Plan and test Athena's Ubuntu 20.04 → 24.04 migration and rollback.

- [ ] Automate backups and maintain off-box copies.
- [ ] Test restores, document recovery procedures, and perform regular recovery drills.
- [ ] Record evidence that required data and services can be restored.

Existing recovery documentation is Completed; automated backup coverage and future restore results are not. See [recovery requirements](disaster-recovery.md).

## Phase 12 — Reliability / Failure Testing: Planned V2 exercises

- [ ] Stop Hermes, break a workload, delete a pod, restart services, and simulate node failure in controlled exercises.
- [ ] Test monitoring alerts and recovery, recording results and lessons.
- [ ] Demonstrate `Hermes fails → Athena detects failure → Prometheus records it → Grafana displays it → Alert fires → Operator investigates → Hermes/workload recovered`.

Earlier pod recreation and recovery exercises remain historical achievements. The complete Hermes demonstration is future work. A single-node outage requires node recovery; cross-node rescheduling requires the optional later node.

## Phase 13 — Real Cloud: Planned / later

- [ ] Deploy a small real-cloud workload on AWS or another low-cost/free-tier provider, with extremely low spending limits and a cleanup plan.
- [ ] Use Terraform where practical to connect local infrastructure, IaC, and cloud operations.

Historical Floci work demonstrates **Terraform-based cloud infrastructure workflows using local AWS API emulation**, not actual AWS infrastructure or evidence of real-cloud deployment experience.

## Priority order

| Priority | Ordered work |
|---|---|
| Highest | 1. audit K3s and set workload policy; 2. monitor Hermes; 3. centralize Hermes logs; 4. test storage and rollback; 5. deploy a real application |
| Next | 8. Helm; 9. CI/CD; 10. GitOps; 11. Ansible; 12. secrets management; 13. backup/restore automation; 14. failure testing |
| Later | 15. multi-node Kubernetes; 16. real cloud; 17. SLOs/error budgets; 18. advanced infrastructure testing; 19. additional automation |

Multi-node Kubernetes is optional: add another VM/node to practice scheduling, node failure, rescheduling and cluster maintenance after the initial migration. It is not an initial Hermes requirement or an HA claim. Restore testing is still pending despite successful archive integrity checks.

## Engineering history and completion evidence

The Dashboard API, custom Homepage data widgets, retired fetch pipelines, and LocalStack do not define the V2 core. See [retired services](history/retired-services.md) for the build/test/operate/evaluate/retire story; historical source and incident reports are preserved.

When a milestone is implemented, record dated configuration references, validation outcomes, recovery evidence, and remaining limitations before marking it Completed. Update the current inventory and operational references after actual infrastructure changes. [Known verification gaps](operations.md) must be resolved during implementation, not guessed away in documentation.
