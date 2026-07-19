# Infrastructure Validation Report

## Overview

This document records the formal validation procedures performed against the Olympus HomeLab infrastructure.

Validation is performed after major infrastructure changes, maintenance windows, recovery testing, and platform upgrades to verify operational stability, networking, observability, automation, Kubernetes functionality, and disaster recovery readiness.

The current report reflects the infrastructure following the June 2026 Kubernetes deployment, the Dashboard API's decommission from active deployment (2026-07-10), and a full live-infrastructure audit (2026-07-18) that reconciled documentation against actual running systems.

> **Archival note:** Tests 14, 15, and 30 below validated the Olympus Dashboard API, which was the custom FastAPI backend behind the Homepage widget at the time. That component has since been **decommissioned from active deployment** — Homepage now runs in a stock-plus-theme configuration with no backend dependency (see `architecture.md`, `postmortems.md`). The Dashboard API's source code remains in the repository as a portfolio reference. Those test results are kept for historical/audit purposes; they no longer describe anything currently running.

---

# Environment Under Test

| Component | Role | Status |
|------------|-----------------------------|--------|
| Apollo | Proxmox VE Hypervisor & Gateway | PASS |
| Artemis | Management Workstation | PASS |
| Athena | Ubuntu Operations VM | PASS |
| Hestia | Alpine Application LXC | PASS |
| K3s Cluster | Kubernetes Control Plane | PASS |
| Olympus Dashboard API *(decommissioned from deployment — code retained)* | FastAPI Backend | PASS at time of test |
| Grafana | Visualization | PASS |
| Prometheus | Metrics Collection | PASS |
| Loki | Centralized Logging | PASS |
| Grafana Alloy | Log Collection (Athena + Hestia) | PASS |
| cAdvisor | Per-container metrics | PASS |
| Glances | System monitor | PASS |
| Node Exporter | Host metrics (Athena + Hestia) | PASS |
| Portainer | Container Management | PASS |
| Portainer Agent | Remote container management (Hestia) | PASS |
| Floci | AWS Emulator (on-demand) | PASS when started |
| Homepage | Service Dashboard | PASS |
| Vaultwarden | Password Manager | PASS |
| Tailscale | Secure Remote Access (4 nodes) | PASS |

---

# Validation Scope

The following areas are validated:

- Compute Infrastructure
- Virtualization
- Network Routing
- NAT Persistence
- Remote Administration
- Kubernetes Operations
- Dashboard Backend
- Monitoring
- Logging
- Automation
- Infrastructure as Code
- Disaster Recovery
- Operational Readiness

---

# Infrastructure Validation

## Test 01 — Hypervisor Accessibility

### Objective

Verify Apollo is operational and reachable.

### Procedure

```bash
ssh root@apollo
```

### Expected Result

Administrative shell access is established.

### Result

**PASS**

---

## Test 02 — Virtual Machine Health

### Procedure

```bash
qm status 100
```

### Expected Result

```text
status: running
```

### Result

**PASS**

---

## Test 03 — Container Health

### Procedure

```bash
pct status 101
```

### Expected Result

```text
status: running
```

### Result

**PASS**

---

## Test 04 — Guest Autostart Validation

### Objective

Verify Athena and Hestia automatically recover following an Apollo reboot.

### Procedure

1. Reboot Apollo.
2. Wait for Proxmox to become available.
3. Verify guest status.

### Expected Result

- Athena automatically starts.
- Hestia automatically starts.

### Result

**PASS**

---

# Network & Remote Access Validation

## Test 05 — Tailscale Connectivity

### Procedure

```bash
tailscale ping apollo
tailscale ping athena
```

### Expected Result

```text
pong
```

### Result

**PASS**

---

## Test 06 — Persistent NAT Validation

### Objective

Verify Apollo restores outbound NAT after reboot.

### Procedure

From Athena:

```bash
ping -c 4 8.8.8.8
```

Verify on Apollo:

```bash
iptables -t nat -L -v
```

### Expected Result

- Internet connectivity available.
- MASQUERADE rules active.

### Result

**PASS**

---

## Test 07 — Port Forwarding Validation

Verify Homepage:

```bash
curl -I http://100.81.86.51:3000
```

Verify Vaultwarden:

```bash
curl -Ik https://100.81.86.51:8080
```

### Expected Result

HTTP 200 responses.

### Result

**PASS**

---

## Test 08 — Connectivity Ladder Validation

### Objective

Verify the standardized troubleshooting workflow.

### Procedure

Simulate a network interruption and verify:

1. Apollo reachable.
2. Internet reachable.
3. HTTPS connectivity.
4. Tailscale connected.
5. Peer communication functional.

### Result

**PASS**

---

# Kubernetes Validation

## Test 09 — Cluster Health

### Procedure

```bash
kubectl get nodes
```

### Expected Result

```text
Ready
```

### Result

**PASS**

---

## Test 10 — System Pods

### Procedure

```bash
kubectl get pods -A
```

### Expected Result

CoreDNS, Local Path Provisioner, Metrics Server, Portainer Agent, and system workloads are all in the **Running** state. No Ingress controller (Traefik) is deployed in this cluster.

### Result

**PASS**

---

## Test 11 — Remote Kubernetes Administration

### Procedure

From Artemis:

```bash
kubectl get pods -n artemis-lab
```

### Expected Result

Successful TLS connection using Athena's LAN IP (`10.10.10.10`).

### Result

**PASS**

---

## Test 12 — cgroup v2 Validation

### Procedure

```bash
stat -fc %T /sys/fs/cgroup
```

### Expected Result

```text
cgroup2fs
```

### Result

**PASS**

---

## Test 13 — Namespace Isolation

### Procedure

```bash
kubectl get all -n artemis-lab
```

### Expected Result

Learning workloads remain isolated from the `default` and `kube-system` namespaces.

### Result

**PASS**

# Dashboard & Automation Validation *(Archived — Component Since Decommissioned)*

> Tests 14–17 validated the Olympus Dashboard API and its supporting automation, which has since been decommissioned from active deployment (2026-07-10). The service's code is retained in the repository as a portfolio reference; Homepage now runs stock (plus a lightweight visual theme) with no backend or cron pipeline in production. Kept for historical record only.

## Test 14 — Olympus Dashboard API *(archived)*

### Objective

Verify the Dashboard V2 backend aggregates and serves data correctly.

### Procedure

```bash
curl http://10.10.10.10:8000/olympus | jq .
```

### Expected Result

The API returns valid JSON containing:

- LastFM (including album artwork)
- Weather
- Pokémon
- Financial data

### Result

**PASS**

---

## Test 15 — Dashboard Endpoint Validation *(archived)*

### Procedure

```bash
curl http://10.10.10.10:8000/weather | jq .
curl http://10.10.10.10:8000/prices | jq .
curl http://10.10.10.10:8000/pokemon | jq .
```

### Expected Result

Each endpoint returns valid JSON without errors.

### Result

**PASS**

---

## Test 16 — Widget Synchronization *(archived)*

### Objective

Verify Homepage widgets receive updated data.

### Procedure

1. Execute the synchronization wrapper.
2. Refresh Homepage.

### Expected Result

Widgets display current:

- Weather
- LastFM
- Pokémon
- Market data

### Result

**PASS**

---

## Test 17 — Cron & Concurrency Validation *(archived)*

### Objective

Verify scheduled fetch scripts do not overlap.

### Procedure

Start a fetch script manually while Cron executes the same script.

### Expected Result

The second execution exits immediately because `flock` holds the lock.

### Result

**PASS**

---

## Test 18 — JSON Integrity Validation

### Objective

Ensure API responses remain valid when external data contains special characters.

### Procedure

Validate generated JSON files.

```bash
jq . data/*.json
```

### Expected Result

All JSON files validate successfully.

### Result

**PASS**

---

# Observability Validation

## Test 19 — Prometheus Readiness

### Procedure

```bash
curl -I http://10.10.10.10:9090/-/ready
```

### Expected Result

```text
HTTP/1.1 200 OK
```

### Result

**PASS**

---

## Test 20 — Prometheus Targets

### Procedure

Open:

```text
http://10.10.10.10:9090/targets
```

### Expected Result

All configured targets report:

```text
UP
```

### Result

**PASS**

---

## Test 21 — Grafana Validation

### Procedure

Open Grafana.

```text
http://10.10.10.10:3001
```

### Expected Result

- Dashboards load successfully.
- Prometheus datasource is healthy.
- Loki datasource is healthy.
- Panels display current metrics.

### Result

**PASS**

---

## Test 22 — Loki Validation

### Procedure

```bash
curl -I http://10.10.10.10:3100/ready
```

### Expected Result

```text
HTTP/1.1 200 OK
```

### Result

**PASS**

---

## Test 23 — End-to-End Logging Pipeline

### Procedure

In Grafana Explore, execute:

```text
{container_name=~".+"}
```

### Expected Result

Live logs from Docker containers and Kubernetes workloads are visible.

### Result

**PASS**

---

## Test 24 — Grafana Alloy Validation

### Procedure

```bash
docker logs alloy
```

### Expected Result

- Docker discovery active
- No ingestion failures
- Logs successfully forwarded to Loki

### Result

**PASS**

---

# Infrastructure as Code Validation

## Test 25 — Floci Validation

### Procedure

```bash
curl http://10.10.10.10:4566
```

### Expected Result

Floci endpoint responds successfully.

### Result

**PASS**

---

## Test 26 — Terraform Workflow

### Procedure

```bash
terraform validate
terraform plan
```

### Expected Result

- Configuration validates successfully.
- Execution plan completes without errors.

### Result

**PASS**

---

## Test 27 — Resource Validation

### Procedure

```bash
aws --endpoint-url=http://10.10.10.10:4566 s3 ls

aws --endpoint-url=http://10.10.10.10:4566 dynamodb list-tables
```

### Expected Result

Resources include:

- `tf-homelab-storage-bucket`
- `tf-homelab-metadata`

### Result

**PASS**

# Disaster Recovery Validation

## Test 28 — Hypervisor Recovery

### Objective

Verify the environment recovers automatically following an Apollo reboot.

### Procedure

1. Reboot Apollo.
2. Wait for Proxmox services to become available.
3. Verify guest startup.
4. Verify container recovery.

### Expected Result

- Apollo boots successfully.
- Athena autostarts.
- Hestia autostarts.
- Docker restart policies restore all services.
- Tailscale reconnects automatically.

### Result

**PASS**

---

## Test 29 — Kubernetes Recovery

### Objective

Verify the K3s cluster recovers after a VM restart.

### Procedure

```bash
kubectl get nodes
kubectl get pods -A
```

### Expected Result

- Athena reports **Ready**.
- System workloads recover automatically.
- No pods remain in `ContainerCreating`.

### Result

**PASS**

---

## Test 30 — Dashboard Recovery *(archived — see note above)*

### Objective

Verify Dashboard V2 resumes normal operation following service interruption.

### Procedure

1. Restart Dashboard API.
2. Wait for scheduled synchronization.
3. Refresh Homepage.

### Expected Result

- API responds successfully.
- Widgets update automatically.
- No stale or corrupted data.

### Result

**PASS** *(historical — this API no longer exists; recovering Homepage today is just `docker restart homepage`)*

---

## Test 31 — Connectivity Ladder Validation

### Objective

Validate the documented troubleshooting methodology.

### Procedure

Perform the following checks in order:

1. Ping Apollo.
2. Ping `8.8.8.8`.
3. Execute:

```bash
curl -I https://google.com
```

4. Verify:

```bash
tailscale status
```

5. Verify peer-to-peer communication.

### Expected Result

The fault domain can be isolated without unnecessary troubleshooting.

### Result

**PASS**

---

## Test 32 — Disaster Recovery Runbook

### Objective

Validate documented recovery procedures.

### Procedure

Execute simulated recovery scenarios using the Disaster Recovery Runbook.

### Expected Result

Recovery objectives are achieved within documented RTO targets.

### Result

**PASS**

---

## Test 33 — Homepage Stock Configuration (Current)

### Objective

Confirm Homepage on Hestia runs standalone in its stock configuration (plus an intentional, lightweight visual theme), with no runtime dependency on the decommissioned Dashboard API.

### Procedure

```bash
docker inspect homepage --format '{{.State.Status}}'
curl -I http://<apollo-ip>:3000
cat homepage-config/custom.js    # expected: empty
cat homepage-config/custom.css   # expected: visual theme only, no data-fetching logic
```

Confirm no `dashboard-api` container is running on Athena.

### Expected Result

- Homepage container is running.
- Homepage loads with stock service-discovery widgets plus visual theming — no custom data widget.
- `custom.js` is empty; `custom.css` contains only styling rules.
- No `dashboard-api` container currently running anywhere in the environment (its source code remains in the repository, intentionally, but is not deployed).

### Result

**PASS**

---

## Test 34 — Live Infrastructure Audit (2026-07-18)

### Objective

Cross-check every claim in this documentation set against live system state across Apollo, Athena, and Hestia, rather than relying on prior documentation being accurate.

### Procedure

Ran direct commands on all three hosts: `docker ps -a`, `kubectl get pods -A`, `tailscale status`, `iptables -t nat -S`, `ip route`, `pvesm status`, `lscpu`/`free -h`/`lsblk`, `find / -iname ".env"`, and a live Loki label query.

### Findings (see `postmortems.md` for the full write-up)

- Hestia runs 3 additional services not previously documented (Alloy, Node Exporter, Portainer Agent).
- Athena runs 2 additional services not previously documented (cAdvisor, Glances).
- Traefik is not deployed in K3s, despite earlier documentation suggesting it was kept.
- Floci is on-demand, not always-running.
- The Grafana Alloy Docker log discovery gap (open since 2026-07-05) is resolved — full ingestion confirmed.
- Tailscale mesh has 4 members, not 3 (a personal Android device, typically offline).
- No `.env` files exist anywhere — all configuration is inline in Compose files.
- An orphaned `core-services` Compose project (Portainer) exists with no matching compose file on disk.
- Apollo's NAT configuration had a real bug (stale interface reference after a WAN change) causing an actual internet outage; `nftables` was evaluated as a fix and explicitly declined once Apollo's `iptables-legacy` backend was found to be independent from it. Resolved with a dedicated, idempotent firewall script instead of a backend migration.

### Result

**PASS** — documentation has been reconciled to match live state as of this audit. This is now the source-of-truth baseline for future validation passes.

---

## Test 35 — Apollo Networking & Firewall Rework (2026-07-18)

### Objective

Verify Athena's internet connectivity is restored and durable across WAN interface changes, and confirm the `nftables` migration decision is correctly reflected in the running configuration.

### Procedure

```bash
ping -c3 8.8.8.8                                    # from Athena
curl -I https://google.com                          # from Athena
systemctl status apollo-firewall.service             # on Apollo
iptables -t nat -L POSTROUTING -n -v                  # on Apollo
ssh ubuntu@athena                                     # confirm unaffected
curl -I http://10.10.10.2:3000                        # Homepage, from LAN (hairpin)
curl -Ik https://10.10.10.2:8080                      # Vaultwarden, from LAN (hairpin)
```

### Expected Result

- Athena has full internet access.
- `apollo-firewall.service` reports `active (exited)`.
- The live MASQUERADE rule is bound to the interface actually carrying the default route (confirmed via `ip route`), not a hardcoded/stale one.
- SSH to Athena works normally.
- Both Homepage and Vaultwarden are reachable via hairpin NAT from inside the LAN, not just from outside.
- `nft list ruleset` is **not** the active firewall (confirms the decision to stay on `iptables` was actually implemented, not left half-migrated).

### Result

**PASS**

---

# Operational Readiness Matrix

| Capability | Status | Verification |
|------------|--------|--------------|
| Virtualization | PASS | Apollo operational |
| Containerization | PASS | Docker & K3s workloads healthy |
| Network Routing | PASS | NAT & DNAT persistence verified |
| Remote Administration | PASS | SSH, Tailscale & kubectl operational |
| Kubernetes | PASS | Cluster Ready |
| Homepage | PASS | Stock frontend accessible |
| Monitoring | PASS | Prometheus targets healthy |
| Logging | PASS | Loki ingestion verified for all 12 running containers across both hosts (confirmed 2026-07-18) |
| Alerting | PASS | Grafana notifications operational |
| Infrastructure as Code | PASS | Terraform & Floci operational |
| Disaster Recovery | PASS | Recovery procedures validated |

---

# Validation Summary

The Olympus HomeLab has been successfully validated across every operational layer, including compute infrastructure, networking, Kubernetes orchestration, observability, Infrastructure as Code, and disaster recovery.

The June–July 2026 platform changes — including the K3s deployment, the retirement of the custom Dashboard API in favor of a stock Homepage (with its code retained in the repo), improved network persistence, and a full live-infrastructure reconciliation audit — have been verified to operate reliably under both normal and recovery conditions.

The environment demonstrates production-inspired operational practices through:

- Secure remote administration with Tailscale
- Kubernetes-based workload orchestration
- Persistent NAT and port forwarding
- Centralized monitoring with Prometheus and Grafana
- Centralized logging with Grafana Alloy and Loki (container discovery gap open)
- A minimal, low-maintenance Homepage frontend
- Infrastructure as Code with Terraform and Floci
- Dependency-aware disaster recovery procedures
- Comprehensive operational documentation

---

# Overall Validation Status

| Category | Status |
|----------|--------|
| Infrastructure | PASS |
| Networking | PASS |
| Kubernetes | PASS |
| Applications (Homepage/Vaultwarden) | PASS |
| Monitoring | PASS |
| Logging | PASS — full ingestion confirmed 2026-07-18 |
| Infrastructure as Code | PASS |
| Disaster Recovery | PASS |

---

# Final Assessment

## Operational Readiness

**FULLY VALIDATED**

The Olympus HomeLab is operating as a stable, production-inspired SRE platform. All critical infrastructure components, networking, Kubernetes services, observability pipelines, and recovery procedures have been validated successfully and meet the documented operational requirements, with one open item (Grafana Alloy Docker log discovery) tracked in `troubleshooting.md`.

---

## Document Information

| Field | Value |
|-------|-------|
| Document Status | Current |
| Validation Status | PASS |
| Operational Readiness | Fully Validated |
| Last Validation | 2026-07-18 |
| Next Validation | Following major infrastructure changes or quarterly review |