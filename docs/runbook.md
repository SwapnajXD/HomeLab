# Operations Runbook

## Purpose

This document contains standard operational procedures for managing, validating, maintaining, and troubleshooting the HomeLab environment.

The goal is to provide a single reference for routine administration and service management.

---

## Infrastructure Overview

| Host | Purpose |
|--------|---------|
| Apollo | Proxmox VE Hypervisor |
| Hestia | Core Services LXC |
| Athena | Monitoring & Automation VM |
| Artemis | Management Workstation |

---

## Service Inventory

### Hestia

**Services:**

- Homepage
- Vaultwarden

### Athena

**Services:**

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter
- Portainer
- LocalStack

---

## Daily Health Checks

### Verify Tailscale Connectivity

From Artemis:

```bash
tailscale ping apollo
tailscale ping athena
```

**Expected:** `pong` response from both nodes.

### Verify Apollo Reachability

```bash
ping -c 4 apollo
```

**Expected:** `0%` packet loss.

### Verify Athena Reachability

```bash
ssh ubuntu@athena
```

**Expected:** Successful SSH login over Tailscale.

### Verify Docker Services

SSH into Athena and Hestia, then check containers:

```bash
docker ps
```

**Expected containers:**

- Grafana
- Prometheus
- Loki
- Alloy
- Node Exporter
- Proxmox Exporter
- Portainer
- LocalStack
- Homepage
- Vaultwarden

---

## Weekly Health Checks

### Verify Prometheus Readiness

```bash
curl -I http://localhost:9090/-/ready
```

**Expected:**

```text
HTTP/1.1 200 OK
```

### Verify Loki Readiness

```bash
curl -I http://localhost:3100/ready
```

**Expected:**

```text
HTTP/1.1 200 OK
```

### Verify Loki Labels

```bash
curl -s http://localhost:3100/loki/api/v1/labels
```

**Expected:** Returned JSON array of labels.

### Verify Node Exporter & Proxmox Exporter

```bash
curl -s http://localhost:9100/metrics | head -n 5
curl -s http://localhost:9221/metrics | head -n 5
```

**Expected:** Raw Prometheus metrics returned.

### Verify Telegram Alerting

Open:

**Grafana UI → Alerting → Contact Points**

Send a test notification to the Telegram Contact Point.

**Expected:** Telegram message received instantly on your device.

---

## Docker Stack Management

### Telemetry Stack

**Location:**

```text
~/homelab/docker-compose/telemetry/
```

#### Start

```bash
docker compose up -d
```

#### Stop

```bash
docker compose down
```

#### Restart

```bash
./scripts/restart-telemetry.sh
```

#### View Logs

```bash
docker compose logs -f
```

### Core Services Stack

**Location:**

```text
~/homelab/docker-compose/core-services/
```

Use the same Start / Stop / Restart / Logs commands as above.

### LocalStack Stack

**Location:**

```text
~/homelab/docker-compose/localstack/
```

Use the same Start / Stop / Restart / Logs commands as above.

---

## Monitoring Procedures

### Check Prometheus Targets

Open:

```text
http://<athena-ip>:9090/targets
```

Verify **UP** state for:

- node-exporter
- proxmox-exporter
- prometheus (self-scrape)

### Check Grafana

Open:

```text
http://<athena-ip>:3001
```

Verify:

- Dashboards load correctly.
- Prometheus datasource is healthy.
- Loki datasource is healthy.

### Check Logs in Grafana

Open:

**Grafana Explore (Loki Datasource)**

Query:

```text
{container="vaultwarden"}
```

**Expected:** Container logs returned continuously.

### Verify Loki Internal Services

```bash
docker logs loki
```

**Expected output shows:**

- Distributor ACTIVE
- Ingester ACTIVE
- Scheduler ACTIVE
- Compactor ACTIVE

---

## Terraform Operations

**Location:**

```text
~/homelab/terraform/localstack/
```

### Validate

```bash
terraform validate
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply -auto-approve
```

### Destroy

```bash
terraform destroy -auto-approve
```

### Verify Resources

#### List S3 Buckets

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

#### List DynamoDB Tables

```bash
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

**Expected resources:**

- `tf-homelab-storage-bucket`
- `tf-homelab-metadata`

---

## Backup Validation

### Verify Proxmox Backup Jobs

Open:

**Proxmox UI → Datacenter → Backup**

Verify:

- Scheduled jobs are present.
- Status of recent jobs shows **OK**.

### Verify Backup Storage

Open:

**Proxmox UI → Storage (local-btrfs/directory) → Backups**

Confirm backup archives exist:

- `.vma.zst`
- `.tar.zst`

---

## Service Recovery

### Restart Individual Container

```bash
docker restart <container_name>
```

### Recreate Telemetry Stack

```bash
cd ~/homelab/docker-compose/telemetry
docker compose down
docker compose up -d --force-recreate
```

### Recreate Core Services

```bash
cd ~/homelab/docker-compose/core-services
docker compose down
docker compose up -d --force-recreate
```

---

## Proxmox Operations

### Verify VM Status

```bash
qm status 100
```

### Verify LXC Status

```bash
pct status 101
```

### Start Athena (VM)

```bash
qm start 100
```

### Start Hestia (LXC)

```bash
pct start 101
```

---

## Emergency Procedures

### Reboot Apollo

Execute from Artemis (if Apollo SSH is available):

```bash
ssh root@apollo "reboot"
```

#### Verify

- Apollo comes online.
- Athena and Hestia autostart.
- Services report healthy via Tailscale.

### Router Outage Recovery

**Expected sequence:**

Tailscale nodes automatically re-establish mesh tunnels once internet access is restored.

No manual action is normally required.

---

## Health Verification Checklist

### Infrastructure

- [ ] Apollo reachable
- [ ] Athena reachable
- [ ] Hestia reachable
- [ ] Tailscale operational

### Monitoring

- [ ] Grafana operational
- [ ] Prometheus operational
- [ ] Loki operational
- [ ] Alloy operational
- [ ] Metrics available
- [ ] Logs available

### Alerting

- [ ] Telegram notifications operational

### Development

- [ ] LocalStack operational
- [ ] Terraform validation successful

### Core Services

- [ ] Homepage accessible
- [ ] Vaultwarden accessible

---

## Useful Commands

### Execute General Health Check Script

```bash
./scripts/healthcheck.sh
```

### System Resource Usage

```bash
uptime        # Load average
free -h       # Memory usage
df -h         # Disk usage
htop          # Interactive process viewer
```

### Tailscale Status

```bash
tailscale status
```

---

## Related Documentation

- Architecture
- Inventory
- Network
- Troubleshooting
- Disaster Recovery
- Validation Report

---

## Current Operational Status

**Environment State:** Stable Operational Environment

**Operational Readiness:** Validated

**Documentation Status:** Current