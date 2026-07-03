# Disaster Recovery Runbook

## Purpose

This document defines the disaster recovery procedures for the Olympus HomeLab environment.

Its objective is to restore critical infrastructure and services as quickly as possible following hardware failures, software failures, networking issues, configuration drift, or complete infrastructure outages.

Recovery follows a **dependency-aware** model, ensuring foundational infrastructure is restored before application services. All procedures have been validated against the current production-inspired architecture.

---

# Recovery Objectives

| Priority | Components | Target RTO |
|----------|------------|------------|
| Priority 1 | Apollo, vmbr0, NAT Gateway, Tailscale | < 5 Minutes |
| Priority 2 | Athena, Dashboard API, K3s Cluster | < 3 Minutes |
| Priority 3 | Hestia, Homepage, Vaultwarden | < 2 Minutes |
| Priority 4 | Observability Stack (Grafana, Prometheus, Loki, Alloy) | < 2 Minutes |
| Priority 5 | Floci & Terraform Services | < 1 Minute |

---

# Environment Overview

## Apollo

**Platform**

- Proxmox VE

**Responsibilities**

- Hypervisor
- Virtual Networking
- NAT Gateway
- VM/LXC Hosting
- Storage Management

---

## Athena (VM 100)

**Platform**

Ubuntu Server VM

**Responsibilities**

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter
- Portainer
- Olympus Dashboard API
- K3s Cluster
- Floci

Athena functions as the operational backbone of the HomeLab.

---

## Hestia (CT 101)

**Platform**

Alpine Linux LXC

**Responsibilities**

- Homepage
- Vaultwarden

Hestia hosts lightweight frontend services while backend processing remains on Athena.

---

# Recovery Dependency Model

Infrastructure must always be restored in dependency order.

```text
Physical Power
        │
        ▼
Apollo (Hypervisor)
        │
        ▼
vmbr0 Bridge
        │
        ▼
Outbound NAT
        │
        ▼
Tailscale Connectivity
        │
        ▼
Athena
    ├── Dashboard API
    ├── K3s
    ├── Grafana
    ├── Prometheus
    ├── Loki
    ├── Alloy
    └── Floci
        │
        ▼
Hestia
    ├── Homepage
    └── Vaultwarden
        │
        ▼
Infrastructure Validation
```

Application services should never be restored before their dependencies.

---

# Initial Diagnostics

Before performing recovery, determine where the failure originates.

## Connectivity Ladder

Follow this sequence exactly.

### Step 1 — Gateway

```bash
ping 10.10.10.1
```

Expected:

```text
Successful response
```

---

### Step 2 — Internet

From Athena:

```bash
ping 8.8.8.8
```

Expected:

```text
Packets received
```

---

### Step 3 — HTTPS Connectivity

```bash
curl -I https://google.com
```

Expected:

```text
HTTP/2 200
```

Confirms:

- Internet connectivity
- DNS
- SSL

---

### Step 4 — Tailscale

```bash
tailscale status
```

Expected:

- Apollo connected
- Athena connected

---

### Step 5 — Internal Connectivity

Verify:

```bash
ping 10.10.10.10
ping 10.10.10.2
```

This isolates:

- Firewall problems
- Routing problems
- Bridge failures

---

# Cold-Start Recovery

Use this procedure after a complete infrastructure shutdown.

## Step 1 — Restore Apollo

Verify:

- Power
- Storage
- Network Interfaces
- vmbr0

```bash
ip addr
bridge link
```

---

## Step 2 — Verify IP Forwarding

```bash
sysctl net.ipv4.ip_forward
```

Expected

```text
1
```

---

## Step 3 — Verify NAT Rules

```bash
iptables -t nat -L -n -v
```

Confirm:

- MASQUERADE rule
- Homepage forwarding
- Vaultwarden forwarding

If required, restore outbound NAT.

```bash
iptables -t nat -A POSTROUTING \
-s 10.10.10.0/24 \
-o wlan0 \
-j MASQUERADE
```

> If your outbound interface changes, replace `wlan0` with the active interface.

---

## Step 4 — Verify Tailscale

```bash
tailscale status
```

Ensure:

- Apollo connected
- Athena connected

---

## Step 5 — Start Athena

```bash
qm start 100
```

Verify:

```bash
qm status 100
```

Expected:

```text
status: running
```

---

## Step 6 — Verify Athena

```bash
ssh ubuntu@athena
```

Then verify Docker:

```bash
docker ps
```

Expected services include:

- grafana
- prometheus
- loki
- alloy
- portainer
- dashboard-api
- floci

---

## Step 7 — Verify K3s

From Artemis:

```bash
kubectl get nodes
```

Expected:

```text
STATUS: Ready
```

If nodes are not Ready, verify:

- cgroup v2
- kubeconfig
- certificate SANs

---

## Step 8 — Start Hestia

```bash
pct start 101
```

Verify:

```bash
pct status 101
```

Expected:

```text
status: running
```

---

## Step 9 — Validate Services

Homepage

```text
http://Apollo:3000
```

Dashboard API

```text
http://Athena:8000/olympus
```

Vaultwarden

```text
https://Apollo:8080
```

Always access Vaultwarden using HTTPS.

---

## Step 10 — Validate Observability

Verify:

- Grafana
- Prometheus
- Loki
- Alloy

Check:

```bash
docker ps
```

Confirm all telemetry containers are healthy.

---

## Step 11 — Final Validation

Verify:

- Dashboard widgets update
- Metrics available
- Logs available
- Kubernetes Ready
- Homepage loads
- Vaultwarden login page accessible

Once all validation checks pass, the environment has returned to a **Stable Operational State**.


# Failure Scenarios & Recovery Procedures

## Scenario 1 — Apollo Unreachable

### Symptoms

- Proxmox Web UI unavailable
- SSH inaccessible
- Athena and Hestia offline
- Tailscale unreachable
- All hosted services unavailable

### Verification

From Artemis:

```bash
tailscale ping apollo
```

If unreachable, verify local connectivity:

```bash
ping 10.10.10.1
```

### Recovery

1. Verify the Airtel Fiber router is online.
2. Confirm Apollo is powered on.
3. Check physical network connectivity.
4. Verify `vmbr0` exists.
5. Confirm Tailscale is running.
6. Validate outbound NAT rules.

If internet access is unavailable from internal nodes:

```bash
iptables -t nat -L -n -v
```

Restore the outbound NAT rule if necessary:

```bash
iptables -t nat -A POSTROUTING \
-s 10.10.10.0/24 \
-o wlan0 \
-j MASQUERADE
```

Verify inbound forwarding for:

- Homepage (3000)
- Vaultwarden (8080)

---

## Scenario 2 — Athena Offline

### Symptoms

- Grafana unavailable
- Prometheus unavailable
- Dashboard widgets stale
- Dashboard API unavailable
- `kubectl` fails
- Portainer unavailable

### Verification

```bash
qm status 100
```

### Recovery

Start Athena:

```bash
qm start 100
```

Verify SSH:

```bash
ssh ubuntu@athena
```

Verify containers:

```bash
docker ps
```

Expected containers:

- grafana
- prometheus
- loki
- alloy
- dashboard-api
- portainer
- floci

---

## Scenario 3 — Hestia Offline

### Symptoms

- Homepage unavailable
- Vaultwarden unavailable

### Verification

```bash
pct status 101
```

### Recovery

Start Hestia:

```bash
pct start 101
```

Verify:

```bash
ping 10.10.10.2
```

Then confirm:

- Homepage loads
- Vaultwarden login page loads

---

## Scenario 4 — Tailscale Failure

### Symptoms

- Remote administration unavailable
- SSH via MagicDNS fails
- Tailnet devices unreachable

### Verification

```bash
tailscale status
```

### Recovery

Restart Tailscale:

```bash
sudo tailscale up
```

Verify:

```bash
tailscale ping apollo
tailscale ping athena
```

If only Athena is disconnected, verify internet connectivity before troubleshooting Tailscale.

---

## Scenario 5 — NAT Gateway Failure

### Symptoms

- Athena cannot access the Internet
- Package updates fail
- Dashboard API data becomes stale
- External APIs unreachable

### Verification

```bash
curl -I https://google.com
```

If unsuccessful:

```bash
iptables -t nat -L -n -v
```

Verify:

- IP forwarding enabled
- MASQUERADE rule present

Restore if required.

---

## Scenario 6 — Dashboard API Failure

### Symptoms

- Homepage widgets unavailable
- Dashboard displays stale data
- API endpoints fail

### Verification

```bash
docker ps | grep dashboard-api
```

Test API:

```bash
curl http://10.10.10.10:8000/olympus
```

### Recovery

Restart the service:

```bash
docker restart dashboard-api
```

If data remains stale:

- Check fetch script logs
- Verify cron execution
- Verify outbound Internet connectivity

---

## Scenario 7 — Dashboard Data Collection Failure

### Symptoms

Widgets stop updating.

Examples:

- Weather
- Last.fm
- Pokémon

### Verification

Inspect logs:

```bash
tail -f /var/log/olympus_fetch.log
```

Verify scheduled jobs:

```bash
crontab -l
```

### Recovery

Run a manual update:

```bash
./olympus_update.sh
```

Verify:

- Fetch scripts completed
- JSON generated successfully
- API reflects new data

---

## Scenario 8 — Cron Lock Failure

### Symptoms

- Widgets stop updating
- Jobs appear idle
- No recent timestamps

### Verification

Check for stale lock files:

```bash
ls /tmp/*.lock
```

### Recovery

If no job is running, remove stale locks:

```bash
rm /tmp/*.lock
```

Run a manual refresh afterward.

---

## Scenario 9 — Invalid JSON

### Symptoms

Homepage reports:

- Invalid JSON
- Widget rendering failures

### Verification

Validate generated files:

```bash
jq . *.json
```

### Recovery

Ensure all fetch scripts generate JSON using `jq` instead of manual string concatenation.

Re-run the affected fetch script.

---

## Scenario 10 — Kubernetes Cluster Failure

### Symptoms

- Pods stuck in `ContainerCreating`
- Node reports `NotReady`
- Deployments fail

### Verification

```bash
kubectl get nodes
kubectl get pods -A
```

### Recovery

Verify cgroup v2:

```bash
cat /proc/cmdline
```

Expected:

```text
systemd.unified_cgroup_hierarchy=1
```

Restart K3s:

```bash
sudo systemctl restart k3s
```

Verify:

```bash
kubectl get nodes
```

Node should report:

```text
Ready
```

---

## Scenario 11 — kubectl TLS Failure

### Symptoms

```text
certificate signed by unknown authority
```

or

```text
x509 certificate is valid for...
```

### Cause

The kubeconfig references Athena's Tailscale IP instead of its LAN IP.

### Recovery

Update the kubeconfig server endpoint:

```text
https://10.10.10.10:6443
```

Retry:

```bash
kubectl get nodes
```

---

## Scenario 12 — Observability Stack Failure

### Symptoms

- Grafana unavailable
- Dashboards empty
- Metrics missing

### Verification

```bash
docker ps
```

Check Prometheus:

```bash
curl http://10.10.10.10:9090/-/ready
```

Check Loki:

```bash
curl http://10.10.10.10:3100/ready
```

### Recovery

Restart telemetry stack:

```bash
docker compose restart
```

Verify:

- Grafana
- Prometheus
- Loki
- Alloy

---

## Scenario 13 — Loki Not Ready

### Symptoms

No logs appear in Grafana.

### Verification

```bash
docker logs loki
```

### Recovery

Verify standalone configuration:

```yaml
replication_factor: 1

kvstore:
  store: inmemory
```

Restart Loki:

```bash
docker restart loki
```

---

## Scenario 14 — Missing Container Logs

### Symptoms

Metrics available but no logs visible.

### Verification

```bash
docker logs alloy
```

### Recovery

Restart Alloy:

```bash
docker restart alloy
```

Verify log ingestion in Grafana Explore.

---

## Scenario 15 — Floci Failure

### Symptoms

Terraform cannot communicate with AWS emulator.

### Verification

```bash
curl http://10.10.10.10:4566
```

### Recovery

Restart Floci:

```bash
docker restart floci
```

Verify endpoint responsiveness before retrying Terraform.

---

## Scenario 16 — Terraform Failure

### Verification

```bash
terraform validate
terraform plan
```

### Recovery

Verify Floci is operational.

If state becomes inconsistent:

```bash
terraform destroy
terraform apply
```

Confirm resources:

- tf-homelab-storage-bucket
- tf-homelab-metadata

---

## Scenario 17 — Vaultwarden Returns "400 Bad Request"

### Symptoms

Homepage works but Vaultwarden displays:

```text
400 Bad Request
```

### Cause

Client is using HTTP instead of HTTPS.

### Recovery

Access Vaultwarden using:

```text
https://Apollo:8080
```

No infrastructure changes are required if Homepage remains accessible.


# Recovery Validation

Perform the following validation checks before declaring the environment operational.

---

## Infrastructure

### Apollo

Verify:

```bash
ping 10.10.10.1
```

Expected:

```text
Successful response
```

---

### Virtual Workloads

Verify:

```bash
qm status 100
pct status 101
```

Expected:

```text
status: running
```

---

### Tailscale

```bash
tailscale status
```

Expected:

- Apollo connected
- Athena connected

---

### NAT Gateway

```bash
curl -I https://google.com
```

Expected:

```text
HTTP/2 200
```

---

## Kubernetes

Verify cluster health.

```bash
kubectl get nodes
```

Expected:

```text
STATUS: Ready
```

Verify workloads.

```bash
kubectl get pods -A
```

Expected:

All pods should report:

```text
Running
```

---

## Dashboard API

Verify API availability.

```bash
curl http://10.10.10.10:8000/olympus
```

Expected:

Valid JSON response.

---

## Homepage

Verify:

- Homepage loads successfully
- Widgets display current data
- Service links function correctly

---

## Vaultwarden

Verify:

```text
https://Apollo:8080
```

Expected:

Vaultwarden login page loads over HTTPS.

---

## Prometheus

```bash
curl http://10.10.10.10:9090/-/ready
```

Expected:

```text
Prometheus is Ready
```

---

## Loki

```bash
curl http://10.10.10.10:3100/ready
```

Expected:

```text
HTTP/1.1 200 OK
```

---

## Grafana

Verify:

- Dashboards load
- Prometheus datasource healthy
- Loki datasource healthy

---

## Grafana Alloy

```bash
docker logs alloy
```

Expected:

Container discovery and log forwarding are functioning normally.

---

## Floci

Verify:

```bash
curl http://10.10.10.10:4566
```

Then confirm Terraform connectivity.

```bash
terraform plan
```

Expected:

Successful execution without connectivity errors.

---

# Recovery Validation Checklist

## Infrastructure

- [ ] Apollo operational
- [ ] vmbr0 operational
- [ ] IP forwarding enabled
- [ ] NAT rules present
- [ ] Internet connectivity restored
- [ ] Tailscale connected

---

## Compute

- [ ] Athena running
- [ ] Hestia running
- [ ] Docker operational
- [ ] Containers healthy

---

## Kubernetes

- [ ] Node Ready
- [ ] System pods healthy
- [ ] Dashboard API reachable

---

## Observability

- [ ] Grafana operational
- [ ] Prometheus collecting metrics
- [ ] Loki ingesting logs
- [ ] Alloy forwarding logs
- [ ] Dashboards loading

---

## Applications

- [ ] Homepage accessible
- [ ] Dashboard widgets updating
- [ ] Vaultwarden accessible via HTTPS

---

## Development

- [ ] Floci operational
- [ ] Terraform validated

---

# Recovery Design Principles

The Olympus HomeLab follows several principles to minimize downtime and ensure predictable recovery.

## Dependency-Aware Recovery

Restore foundational infrastructure before dependent services.

Order of recovery:

1. Apollo
2. Networking
3. Athena
4. Platform Services
5. Hestia
6. Validation

---

## Persistent Configuration

Critical configuration must survive host reboots.

Examples include:

- VM/LXC autostart
- NAT rules
- Docker restart policies
- Tailscale configuration

---

## Secure Remote Administration

All administrative access is performed through Tailscale and SSH.

No routine recovery procedures require exposing management services directly to the Internet.

---

## Infrastructure as Code

Infrastructure changes should be reproducible.

Before modifying infrastructure:

```bash
terraform validate
terraform plan
```

Terraform remains the authoritative source for Floci-managed resources.

---

## Safe Automation

Dashboard automation should always use:

- `jq` for JSON generation
- `flock` for concurrency control

These safeguards prevent malformed data and overlapping scheduled jobs.

---

## Continuous Validation

Recovery is considered complete only after:

- Services are reachable
- Metrics are available
- Logs are collected
- Dashboard widgets update
- Kubernetes reports healthy nodes

---

# Related Documentation

For additional operational guidance, refer to:

- `architecture.md` — System architecture and service layout
- `network.md` — Network topology and NAT configuration
- `inventory.md` — Infrastructure inventory
- `runbook.md` — Routine operational procedures
- `health-checks.md` — Daily and periodic validation tasks
- `troubleshooting.md` — Incident history and root cause analysis
- `validation-report.md` — Infrastructure validation records
- `changelog.md` — Infrastructure change history

---

# Current Recovery Status

| Component | Status |
|----------|--------|
| Apollo | ✅ Operational |
| Networking | ✅ Operational |
| Athena | ✅ Operational |
| K3s Cluster | ✅ Operational |
| Dashboard API | ✅ Operational |
| Hestia | ✅ Operational |
| Homepage | ✅ Operational |
| Vaultwarden | ✅ Operational |
| Grafana | ✅ Operational |
| Prometheus | ✅ Operational |
| Loki | ✅ Operational |
| Grafana Alloy | ✅ Operational |
| Floci | ✅ Operational |
| Terraform | ✅ Operational |

---

# Recovery Objectives Summary

| Objective | Target |
|-----------|--------|
| Apollo Recovery | < 5 Minutes |
| Athena Recovery | < 3 Minutes |
| Hestia Recovery | < 2 Minutes |
| Observability Recovery | < 2 Minutes |
| Development Services | < 1 Minute |
| Complete Environment Recovery | < 10 Minutes |

---

# Document Status

**Environment State:** Stable Operational Environment

**Recovery Procedures:** Documented and Validated

**Last Reviewed:** July 2026

This runbook reflects the current Olympus HomeLab architecture, including the Dashboard V2 backend, K3s cluster, centralized observability stack, and production-inspired recovery workflows.