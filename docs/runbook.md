# Operations Runbook

## Purpose

This document contains standard operational procedures for managing, validating, maintaining, and troubleshooting the HomeLab environment.

The goal is to provide a single reference for routine administration and service management.

---

# Infrastructure Overview

| Host    | Purpose                    |
| ------- | -------------------------- |
| Apollo  | Proxmox VE Hypervisor      |
| Hestia  | Core Services LXC          |
| Athena  | Monitoring & Automation VM |
| Artemis | Management Workstation     |

---

# Service Inventory

## Hestia

Services:

* Homepage
* Vaultwarden

---

## Athena

Services:

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Portainer
* LocalStack

---

# Daily Health Checks

## Verify Tailscale Connectivity

From Artemis:

```bash
tailscale status
```

Expected:

```text
Apollo    online
Athena    online
```

---

## Verify Apollo Reachability

```bash
ping <apollo-ip>
```

Expected:

```text
64 bytes from ...
```

---

## Verify Athena Reachability

```bash
ping <athena-ip>
```

Expected:

```text
64 bytes from ...
```

---

## Verify Docker Services

SSH into Athena:

```bash
ssh ubuntu@athena
```

Check containers:

```bash
docker ps
```

Expected containers:

```text
grafana
prometheus
loki
alloy
node-exporter
proxmox-exporter
portainer
localstack
```

---

# Weekly Health Checks

## Verify Prometheus Readiness

```bash
curl http://localhost:9090/-/ready
```

Expected:

```text
Prometheus is Ready.
```

---

## Verify Loki Readiness

```bash
curl http://localhost:3100/ready
```

Expected:

```text
ready
```

---

## Verify Loki Labels

```bash
curl http://localhost:3100/loki/api/v1/labels
```

Expected:

Returned labels.

---

## Verify Node Exporter

```bash
curl http://localhost:9100/metrics
```

Expected:

Metrics returned.

---

## Verify Proxmox Exporter

```bash
curl http://localhost:9221/metrics
```

Expected:

Metrics returned.

---

## Verify Telegram Alerting

Open Grafana:

```text
Alerting → Contact Points
```

Send test notification.

Expected:

Telegram message received.

---

# Docker Stack Management

## Telemetry Stack

Location:

```bash
~/homelab/docker-compose/telemetry
```

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
```

### View Logs

```bash
docker compose logs -f
```

---

## Core Services Stack

Location:

```bash
~/homelab/docker-compose/core-services
```

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
```

---

## LocalStack Stack

Location:

```bash
~/homelab/docker-compose/localstack
```

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
```

---

# Monitoring Procedures

## Check Prometheus Targets

Open:

```text
http://athena:9090/targets
```

Verify:

```text
UP
```

for:

* node-exporter
* proxmox-exporter

---

## Check Grafana

Open:

```text
http://athena:3000
```

Verify:

* Dashboards load
* Prometheus datasource healthy
* Loki datasource healthy

---

## Check Logs in Grafana

Open:

```text
Grafana → Explore
```

Query:

```logql
{job=~".+"}
```

Expected:

Container logs returned.

---

## Verify Loki Internal Services

```bash
curl http://localhost:3100/services
```

Expected:

* Distributor ACTIVE
* Ingester ACTIVE
* Scheduler ACTIVE
* Compactor ACTIVE

---

# Terraform Operations

Location:

```bash
~/homelab/terraform/localstack
```

---

## Validate

```bash
terraform validate
```

---

## Plan

```bash
terraform plan
```

---

## Apply

```bash
terraform apply
```

---

## Destroy

```bash
terraform destroy
```

---

## Verify Resources

List buckets:

```bash
awslocal s3 ls
```

List tables:

```bash
awslocal dynamodb list-tables
```

Expected resources:

```text
tf-homelab-storage-bucket
tf-homelab-metadata
```

---

# Backup Validation

## Verify Proxmox Backup Jobs

Open:

```text
Datacenter
→ Backup
```

Verify:

* Scheduled jobs present
* Recent jobs successful

---

## Verify Backup Storage

Open:

```text
Datacenter
→ Storage
```

Confirm backup archives exist.

---

# Service Recovery

## Restart Individual Container

Check:

```bash
docker ps -a
```

Inspect:

```bash
docker logs CONTAINER_NAME
```

Restart:

```bash
docker restart CONTAINER_NAME
```

---

## Recreate Telemetry Stack

```bash
cd ~/homelab/docker-compose/telemetry

docker compose down
docker compose up -d
```

---

## Recreate Core Services

```bash
cd ~/homelab/docker-compose/core-services

docker compose down
docker compose up -d
```

---

## Recreate LocalStack

```bash
cd ~/homelab/docker-compose/localstack

docker compose down
docker compose up -d
```

---

# Proxmox Operations

## Verify VM Status

```bash
qm list
```

---

## Verify LXC Status

```bash
pct list
```

---

## Start Athena

```bash
qm start 101
```

---

## Start Hestia

```bash
pct start <container-id>
```

---

# Emergency Procedures

## Reboot Apollo

```bash
ssh root@apollo
```

Execute:

```bash
reboot
```

Verify:

* Apollo online
* Athena online
* Hestia online
* Services healthy

---

## Router Outage Recovery

Expected sequence:

```text
Router Online
      ↓
Apollo Reconnects
      ↓
Tailscale Reconnects
      ↓
Athena Reconnects
      ↓
Services Available
```

No manual action normally required.

---

# Health Verification Checklist

Infrastructure:

* [ ] Apollo reachable
* [ ] Athena reachable
* [ ] Hestia reachable
* [ ] Tailscale operational

Monitoring:

* [ ] Grafana operational
* [ ] Prometheus operational
* [ ] Loki operational
* [ ] Alloy operational
* [ ] Metrics available
* [ ] Logs available

Alerting:

* [ ] Telegram notifications operational

Development:

* [ ] LocalStack operational
* [ ] Terraform validation successful

Core Services:

* [ ] Homepage accessible
* [ ] Vaultwarden accessible

---

# Useful Commands

## Container Status

```bash
docker ps
```

---

## Container Resource Usage

```bash
docker stats
```

---

## Disk Usage

```bash
df -h
```

---

## Memory Usage

```bash
free -h
```

---

## Uptime

```bash
uptime
```

---

## Network Connections

```bash
ss -tulpn
```

---

## Tailscale Status

```bash
tailscale status
```

---

## Execute Health Check Script

```bash
~/homelab/scripts/healthcheck.sh
```

---

# Related Documentation

* architecture.md
* inventory.md
* network.md
* troubleshooting.md
* disaster-recovery.md
* validation-report.md

---

# Current Operational Status

Environment State:

Stable Operational Environment

Operational Readiness:

Validated

Documentation Status:

Current
