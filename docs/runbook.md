# Operations Runbook

## Purpose

This document defines the standard operational procedures for managing, validating, maintaining, and administering the Olympus HomeLab environment.

Its purpose is to provide a single reference for routine operations, preventative maintenance, and common administrative tasks.

---

# Infrastructure Overview

| Host    | Purpose                       |
| ------- | ----------------------------- |
| Apollo  | Proxmox VE Hypervisor         |
| Athena  | Operations & Observability VM |
| Hestia  | Core Services LXC             |
| Artemis | Management Workstation        |

---

# Service Inventory

## Athena

Hosted Services:

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Portainer
* Olympus Dashboard API
* Floci

---

## Hestia

Hosted Services:

* Homepage
* Vaultwarden
* Personal Feed Collection Scripts
* SSH Synchronization Endpoint

---

# Daily Health Checks

## Verify Tailscale Connectivity

From Artemis:

```bash
tailscale ping apollo
tailscale ping athena
```

Expected:

```text
pong
```

---

## Verify Apollo Reachability

```bash
ping -c 4 apollo
```

Expected:

```text
0% packet loss
```

---

## Verify Athena Access

```bash
ssh ubuntu@athena
```

Expected:

Successful SSH login.

---

## Verify Homepage Access

```bash
curl -I http://100.81.86.51:3000
```

Expected:

```text
HTTP/1.1 200 OK
```

---

## Verify Container Health

Athena:

```bash
ssh ubuntu@athena \
"docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

Hestia:

```bash
ssh root@10.10.10.2 \
"docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

Expected services:

### Athena

* grafana
* prometheus
* loki
* alloy
* node-exporter
* proxmox-exporter
* portainer
* dashboard-api
* floci

### Hestia

* homepage
* vaultwarden

---

# Weekly Health Checks

## Verify Prometheus

```bash
curl -I http://10.10.10.10:9090/-/ready
```

Expected:

```text
HTTP/1.1 200 OK
```

---

## Verify Loki

```bash
curl -I http://10.10.10.10:3100/ready
```

Expected:

```text
HTTP/1.1 200 OK
```

---

## Verify Loki Labels

```bash
curl -s http://10.10.10.10:3100/loki/api/v1/labels
```

Expected:

JSON label output.

---

## Verify Exporters

```bash
curl -s http://localhost:9100/metrics | head -n 5
curl -s http://localhost:9221/metrics | head -n 5
```

Expected:

Raw Prometheus metrics.

---

## Verify Telegram Alerting

Grafana:

```text
Alerting → Contact Points
```

Send a test notification.

Expected:

Telegram message received.

---

# Docker Stack Management

## Telemetry Stack

Location:

```text
~/homelab/docker-compose/telemetry/
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

### Logs

```bash
docker compose logs -f
```

---

## Core Services Stack

Location:

```text
~/homelab/personal-services/
```

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Recreate

```bash
docker compose down
docker compose up -d --force-recreate
```

### Logs

```bash
docker compose logs -f
```

---

## Floci Stack

Location:

```text
~/homelab/docker-compose/floci/
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

### Logs

```bash
docker compose logs -f floci
```

---

# Monitoring Procedures

## Check Prometheus Targets

Open:

```text
http://10.10.10.10:9090/targets
```

Verify:

* node-exporter
* proxmox-exporter
* prometheus

Status:

```text
UP
```

---

## Check Grafana

Open:

```text
http://10.10.10.10:3001
```

Verify:

* Dashboards load
* Prometheus datasource healthy
* Loki datasource healthy

---

## Check Logs in Grafana

Grafana Explore → Loki

Query:

```text
{container="vaultwarden"}
```

Expected:

Continuous log output.

---

## Verify Loki Status

```bash
docker logs loki
```

Expected components:

* Distributor ACTIVE
* Ingester ACTIVE
* Scheduler ACTIVE
* Compactor ACTIVE

---

# Dashboard Operations

## Verify API Endpoints

Prices:

```bash
curl -s http://10.10.10.10:8000/prices | jq .
```

Weather:

```bash
curl -s http://10.10.10.10:8000/weather | jq .
```

Pokémon:

```bash
curl -s http://10.10.10.10:8000/pokemon | jq .
```

Expected:

Valid JSON responses.

---

## Manual Synchronization

If widgets stop updating:

```bash
scp root@10.10.10.2:/root/homelab/personal-services/homepage-config/data/*.json \
~/homelab/docker-compose/dashboard-api/data/
```

---

## Verify Synchronization Jobs

```bash
crontab -l
```

Expected:

Scheduled feed collection jobs present.

---

# Infrastructure as Code Operations

Location:

```text
~/homelab/terraform/floci/
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
terraform apply -auto-approve
```

---

## Destroy

```bash
terraform destroy -auto-approve
```

---

## Verify Resources

List S3 Buckets:

```bash
aws --endpoint-url=http://10.10.10.10:4566 s3 ls
```

List DynamoDB Tables:

```bash
aws --endpoint-url=http://10.10.10.10:4566 dynamodb list-tables
```

Expected:

* tf-homelab-storage-bucket
* tf-homelab-metadata

---

# Backup Validation

## Verify Proxmox Backup Jobs

Navigate to:

```text
Datacenter → Backup
```

Verify:

* Scheduled jobs exist
* Recent jobs completed successfully

---

## Verify Backup Archives

Navigate to:

```text
Storage → Backups
```

Expected:

* .vma.zst files
* .tar.zst files

---

# Proxmox Operations

## VM Status

```bash
qm status 100
```

---

## LXC Status

```bash
pct status 101
```

---

## Start Athena

```bash
qm start 100
```

---

## Start Hestia

```bash
pct start 101
```

---

# Emergency Procedures

## Reboot Apollo

From Artemis:

```bash
ssh root@apollo "reboot"
```

Verify:

* Apollo returns online
* Athena autostarts
* Hestia autostarts
* Services recover successfully

---

## Router Outage Recovery

Expected behavior:

Tailscale automatically re-establishes mesh connectivity once internet access returns.

Manual intervention is typically unnecessary.

---

# Health Verification Checklist

## Infrastructure

* [ ] Apollo reachable
* [ ] Athena reachable
* [ ] Hestia reachable
* [ ] Tailscale operational
* [ ] NAT functioning

---

## Monitoring

* [ ] Grafana operational
* [ ] Prometheus operational
* [ ] Loki operational
* [ ] Alloy operational
* [ ] Metrics available
* [ ] Logs available

---

## Dashboard Services

* [ ] Dashboard API responding
* [ ] Widgets updating
* [ ] Synchronization jobs functioning

---

## Alerting

* [ ] Telegram notifications operational

---

## Development

* [ ] Floci operational
* [ ] Terraform validation successful

---

## Core Services

* [ ] Homepage accessible
* [ ] Vaultwarden accessible

---

# Useful Commands

General Resource Usage:

```bash
uptime
free -h
df -h
htop
```

Tailscale Status:

```bash
tailscale status
```

Docker Status:

```bash
docker ps
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

**Environment State:** Stable Operational Environment

**Operational Readiness:** Validated

**Documentation Status:** Current
