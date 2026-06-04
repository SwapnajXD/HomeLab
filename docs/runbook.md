# Operations Runbook

## Purpose

This document contains common operational procedures for managing, troubleshooting, and recovering the homelab infrastructure.

---

# Infrastructure Overview

| Host | Purpose |
|--------|--------|
| Apollo | Proxmox Hypervisor |
| Hestia | Core Services LXC |
| Athena | Monitoring & Automation VM |
| Artemis | Management Workstation |

---

# Health Checks

## Check Tailscale Connectivity

On Artemis:

```bash
tailscale status
```

Expected:

```text
Apollo    online
Athena    online
```

---

## Verify Athena Reachability

```bash
ping 100.117.35.70
```

Expected:

```text
64 bytes from 100.x.x.x
```

---

## Verify Docker Services

SSH into Athena:

```bash
ssh ubuntu@100.117.35.70
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
promtail
node-exporter
proxmox-exporter
portainer
localstack
```

---

# Service Management

## Telemetry Stack

Location:

```bash
~/homelab/infrastructure/athena/telemetry
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

## LocalStack

Location:

```bash
~/homelab/infrastructure/athena/localstack
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

# Monitoring Procedures

## Check Prometheus Targets

Open:

```text
http://ATHENA_IP:9090/targets
```

Expected Status:

```text
UP
```

for:

- node-exporter
- proxmox-exporter

---

## Check Grafana

Open:

```text
http://ATHENA_IP:3001
```

Verify:

- Dashboards load
- Prometheus datasource healthy
- Loki datasource healthy

---

## Check Loki Logs

Open Grafana:

```text
Explore → Loki
```

Query:

```logql
{job=~".+"}
```

Expected:

Container logs returned.

---

# Terraform Operations

Location:

```bash
~/homelab/terraform/localstack
```

---

## Validate Configuration

```bash
terraform validate
```

---

## View Plan

```bash
terraform plan
```

---

## Deploy Infrastructure

```bash
terraform apply
```

---

## Destroy Infrastructure

```bash
terraform destroy
```

---

## Verify Resources

List buckets:

```bash
aws --endpoint-url=http://100.117.35.70:4566 s3 ls
```

List tables:

```bash
aws --endpoint-url=http://100.117.35.70:4566 dynamodb list-tables
```

---

# Backup Procedures

## Proxmox Backup Verification

Open:

```text
Datacenter
→ Backup
```

Verify:

- Scheduled jobs exist
- Recent backups succeeded

---

## Verify Backup Files

Open:

```text
Datacenter
→ Storage
→ Backups
```

Confirm backup archives are present.

---

# Recovery Procedures

## Recover Failed Container

Check status:

```bash
docker ps -a
```

Inspect logs:

```bash
docker logs CONTAINER_NAME
```

Restart:

```bash
docker restart CONTAINER_NAME
```

---

## Recover Entire Stack

Navigate to stack directory:

```bash
cd ~/homelab/infrastructure/athena/telemetry
```

Recreate:

```bash
docker compose down
docker compose up -d
```

---

## Recover Terraform Resources

Destroy existing state:

```bash
terraform destroy
```

Recreate:

```bash
terraform apply
```

---

# Emergency Procedures

## Apollo Reboot

SSH:

```bash
ssh root@APOLLO_IP
```

Execute:

```bash
reboot
```

Verify:

- Apollo online
- Hestia online
- Athena online
- Docker services healthy

---

## Router Outage Recovery

Expected sequence:

```text
Router boots
    ↓
Apollo reconnects
    ↓
Tailscale reconnects
    ↓
Athena reconnects
    ↓
Services become available
```

No manual action should be required.

---

# Validation Checklist

After any maintenance:

- [ ] Apollo reachable
- [ ] Athena reachable
- [ ] Hestia reachable
- [ ] Tailscale operational
- [ ] Grafana accessible
- [ ] Prometheus targets UP
- [ ] Loki receiving logs
- [ ] LocalStack reachable
- [ ] Terraform deploy succeeds
- [ ] Backups present

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

# Related Documentation

- architecture.md
- network.md
- troubleshooting.md
- disaster-recovery.md
- validation-report.md