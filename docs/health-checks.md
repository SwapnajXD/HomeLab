# Health Checks

## Overview

This document defines the standard health verification procedures for the Olympus HomeLab environment.

Health checks are performed after maintenance, infrastructure upgrades, incident recovery, configuration changes, and scheduled validation to ensure every infrastructure layer is operating correctly.

The verification process follows a bottom-up approach, validating networking and compute resources before container platforms, observability services, and application workloads.

---

# Environment Overview

| Component | Role |
|------------|------|
| Apollo | Proxmox VE Hypervisor & NAT Gateway |
| Artemis | Management Workstation |
| Athena | Ubuntu Operations VM |
| Hestia | Alpine Linux Application Container |
| K3s | Kubernetes Control Plane |
| Olympus API | Dashboard Backend |
| Grafana | Visualization |
| Prometheus | Metrics Collection |
| Loki | Log Aggregation |
| Grafana Alloy | Log Collection |
| Homepage | Dashboard Frontend |
| Vaultwarden | Password Manager |
| Floci | Local AWS Emulator |

---

# Layer 1 — Infrastructure Health

## Verify Hypervisor Availability

Execute from Artemis:

```bash
tailscale ping apollo
```

or

```bash
ssh root@apollo
```

### Expected Result

- Apollo is reachable.
- SSH login succeeds.
- Proxmox services respond normally.

---

## Verify Guest Compute Status

Execute on Apollo:

```bash
qm list
pct list
```

### Expected Result

| Guest | Expected State |
|---------|---------------|
| Athena (VM 100) | running |
| Hestia (CT 101) | running |

---

## Verify Autostart Configuration

Confirm:

- Athena autostarts after reboot.
- Hestia autostarts after reboot.

If required:

```bash
qm config 100
pct config 101
```

Verify:

```text
onboot: 1
```

---

# Layer 2 — Network Health

## Connectivity Ladder

If any node appears offline, validate connectivity in the following order.

### Step 1 — Gateway

```bash
ping 10.10.10.1
```

Expected:

```text
Gateway reachable
```

---

### Step 2 — Internet

```bash
ping 8.8.8.8
```

Expected:

```text
Internet reachable
```

---

### Step 3 — HTTPS

```bash
curl -I https://google.com
```

Expected:

```text
HTTP/2 200
```

---

### Step 4 — Tailscale

```bash
tailscale status
```

Expected:

- Apollo connected
- Athena connected
- Artemis connected

---

### Step 5 — Internal Connectivity

```bash
ping 10.10.10.10
ping 10.10.10.2
```

Expected:

Athena and Hestia respond successfully.

---

## Verify NAT Gateway Persistence

Execute from Athena:

```bash
ping 8.8.8.8
```

On Apollo:

```bash
iptables -t nat -L -v
```

Verify the MASQUERADE rule exists:

```text
POSTROUTING
MASQUERADE
10.10.10.0/24
```

Packets should increase while traffic flows.

---

## Verify DNAT Rules

```bash
iptables -t nat -L PREROUTING -v
```

Verify forwarding exists for:

- Homepage (3000)
- Vaultwarden (8080)

---

# Layer 3 — Container Runtime Health

## Docker Health

Execute:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Athena

Expected services:

- grafana
- prometheus
- loki
- grafana-alloy
- dashboard-api
- portainer
- floci_aws

### Hestia

Expected services:

- homepage
- vaultwarden

### Expected Result

Every container reports:

```text
Up
```

or

```text
Healthy
```

---

## Kubernetes Health

Execute from Artemis:

```bash
kubectl get nodes
```

Expected:

```text
STATUS
Ready
```

---

List all workloads:

```bash
kubectl get pods -A
```

Expected:

- CoreDNS Running
- Metrics Server Running
- Traefik Running
- User workloads Running

---

Verify cgroup v2:

```bash
stat -fc %T /sys/fs/cgroup
```

Expected:

```text
cgroup2fs
```

# Layer 4 — Observability Health

## Verify Prometheus

Execute:

```bash
curl -I http://localhost:9090/-/healthy
```

### Expected Result

```text
HTTP/1.1 200 OK
```

---

## Verify Prometheus Targets

Open:

```text
http://10.10.10.10:9090/targets
```

or

```bash
curl -s http://localhost:9090/api/v1/targets \
| jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

### Expected Targets

- node-exporter
- proxmox-exporter
- prometheus

Every target should report:

```text
UP
```

---

## Verify Grafana

Execute:

```bash
curl http://localhost:3001/api/health
```

### Expected Result

```json
{
  "database":"ok"
}
```

Grafana dashboards should load successfully.

---

## Verify Loki

Execute:

```bash
curl -I http://localhost:3100/ready
```

### Expected Result

```text
HTTP/1.1 200 OK
```

If unhealthy, verify the standalone configuration:

```yaml
common:
  replication_factor: 1

ring:
  kvstore:
    store: inmemory
```

---

## Verify Grafana Alloy

Execute:

```bash
docker logs --tail 50 grafana-alloy
```

### Expected Result

- Docker discovery active
- Containers discovered successfully
- No continuous ingestion errors
- Logs forwarded to Loki

---

## Verify End-to-End Logging

Open **Grafana Explore** and query:

```text
{container_name=~".+"}
```

### Expected Result

- Live container logs visible
- No missing labels
- Continuous log ingestion

---

# Layer 5 — Dashboard & Application Health

## Verify Olympus Dashboard API

Execute:

```bash
curl http://10.10.10.10:8000/olympus | jq .
```

### Expected Result

A valid JSON response containing:

- LastFM
- Weather
- Pokémon
- Investments
- System information

---

## Verify Homepage

Open:

```text
http://<apollo-ip>:3000
```

### Expected Result

- Homepage loads successfully
- Widgets display live data
- Hero panel displays correctly
- No broken images

---

## Verify Vaultwarden

Open:

```text
https://<apollo-ip>:8080
```

### Expected Result

- Login page loads
- No **400 Bad Request**
- HTTPS certificate accepted

> **Note:** Vaultwarden is configured for **HTTPS only**. Accessing it over HTTP will result in a protocol mismatch.

---

## Verify Dashboard Synchronization

On Athena:

```bash
ls /tmp/*.lock
```

### Expected Result

No stale lock files remain after scheduled jobs.

Verify cron execution:

```bash
grep CRON /var/log/syslog
```

Expected:

- Scheduled jobs execute normally.
- No overlapping executions.
- `flock` prevents concurrent runs.

---

## Verify Inter-Node Synchronization

Execute:

```bash
ssh root@10.10.10.2 "echo 'SSH OK'"
```

### Expected Result

```text
SSH OK
```

Passwordless Ed25519 authentication succeeds.

---

# Layer 6 — Development Platform Health

## Verify Floci

Execute:

```bash
curl -I http://localhost:4566
```

### Expected Result

```text
HTTP/1.1 200 OK
```

---

## Verify Terraform

Execute:

```bash
terraform plan
```

### Expected Result

```text
No changes.
Infrastructure matches the configuration.
```

Expected managed resources:

- tf-homelab-storage-bucket
- tf-homelab-metadata

---

## Verify Kubernetes Remote Access

Execute from Artemis:

```bash
kubectl get pods -n artemis-lab
```

### Expected Result

Pods are listed successfully with no TLS errors.

Verify the kubeconfig is using Athena's LAN IP:

```text
10.10.10.10
```

instead of the Tailscale IP.

# Health Verification Checklist

## Infrastructure

- [ ] Apollo is reachable via SSH and Tailscale.
- [ ] Proxmox web interface is accessible.
- [ ] Athena (VM 100) is running.
- [ ] Hestia (CT 101) is running.
- [ ] Guest autostart is enabled.
- [ ] NAT MASQUERADE rule is active.
- [ ] DNAT rules are present.
- [ ] Internet connectivity is available from all guests.
- [ ] Internal LAN communication is functional.
- [ ] Tailscale mesh is fully connected.

---

## Kubernetes & Containers

- [ ] K3s node reports **Ready**.
- [ ] CoreDNS is running.
- [ ] Metrics Server is running.
- [ ] Traefik is running.
- [ ] User workloads are healthy.
- [ ] cgroup v2 is enabled.
- [ ] Athena Docker containers are healthy.
- [ ] Hestia Docker containers are healthy.

---

## Observability

- [ ] Prometheus is healthy.
- [ ] All Prometheus targets report **UP**.
- [ ] Grafana is accessible.
- [ ] Loki readiness endpoint returns **200 OK**.
- [ ] Grafana Alloy is forwarding logs.
- [ ] Logs are visible in Grafana Explore.

---

## Applications

- [ ] Olympus Dashboard API returns valid JSON.
- [ ] Homepage loads successfully.
- [ ] Homepage widgets display live data.
- [ ] Hero panel displays correctly.
- [ ] Vaultwarden is accessible over HTTPS.
- [ ] No stale cron lock files exist.
- [ ] Dashboard synchronization is functioning.

---

## Development Platform

- [ ] Floci is operational.
- [ ] Terraform plan reports no drift.
- [ ] Remote kubectl management works.
- [ ] Inter-node SSH synchronization succeeds.

---

# Operational Readiness Matrix

| Capability | Status | Verification |
|------------|--------|--------------|
| Virtualization | PASS | Apollo, Athena and Hestia operational |
| Networking | PASS | NAT, DNAT and LAN connectivity verified |
| Remote Access | PASS | SSH and Tailscale operational |
| Containerization | PASS | Docker workloads healthy |
| Kubernetes | PASS | K3s cluster healthy |
| Monitoring | PASS | Prometheus targets UP |
| Logging | PASS | Loki and Grafana Alloy operational |
| Dashboard API | PASS | API responding with valid JSON |
| Homepage | PASS | Frontend accessible |
| Vaultwarden | PASS | HTTPS functioning correctly |
| Infrastructure as Code | PASS | Terraform validated |
| Local Cloud | PASS | Floci operational |
| Disaster Recovery | PASS | Recovery procedures validated |

---

# Recommended Verification Frequency

| Check | Frequency |
|--------|-----------|
| Infrastructure Health | Daily |
| Docker Containers | Daily |
| K3s Cluster | Daily |
| Dashboard API | Daily |
| Homepage & Vaultwarden | Daily |
| Prometheus Targets | Daily |
| Loki & Alloy | Daily |
| Terraform Plan | Weekly |
| NAT & DNAT Persistence | After every Apollo reboot |
| Disaster Recovery Drill | Monthly |
| Full Infrastructure Validation | After major infrastructure changes |

---

# Current Operational Status

| Property | Status |
|----------|--------|
| Environment State | **Stable Operational Environment** |
| Platform Maturity | **Production-Inspired HomeLab** |
| Last Full Validation | **June 2026** |
| Kubernetes Status | **Operational** |
| Dashboard V2 Status | **Operational** |
| Observability Status | **Healthy** |
| Documentation Coverage | **Complete** |
| Operational Readiness | **FULLY VALIDATED** |

---

# Conclusion

The Olympus HomeLab has been validated across every operational layer, including infrastructure, networking, containerization, Kubernetes, observability, automation, and application services.

Routine health verification, documented operational procedures, and continuous validation ensure that the platform remains reliable, maintainable, and resilient. Incident-driven improvements—including persistent NAT configuration, cgroup v2 migration, Dashboard V2 architecture, and standardized recovery procedures—have strengthened the environment and reduced operational risk.

By combining proactive monitoring, centralized logging, Infrastructure as Code, secure remote administration, and comprehensive documentation, the HomeLab closely reflects production-inspired operational practices while serving as a platform for ongoing learning and experimentation.

**Environment Status:** Stable Operational Environment

**Last Validation:** June 2026

**Operational Readiness:** **FULLY VALIDATED**