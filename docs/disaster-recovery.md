# Disaster Recovery Runbook

## Purpose

This document defines the recovery procedures for the homelab environment.

The objective is to restore services as quickly as possible after hardware, software, network, or configuration failures.

---

# Environment Overview

## Infrastructure

```text
Artemis (Management Laptop)
        │
   Tailscale
        │
      Apollo
        │
 ┌─────────────┐
 │  Proxmox VE │
 └─────────────┘
      │
 ┌────┴────┐
 │         │
Hestia   Athena
```

## Hestia

Services:

- Homepage
- Vaultwarden

## Athena

Services:

- Grafana
- Prometheus
- Loki
- Promtail
- Portainer
- LocalStack

---

# Recovery Priority Levels

## Priority 1

Critical Infrastructure

- Apollo
- Proxmox Networking
- Tailscale Connectivity

## Priority 2

Core Services

- Homepage
- Vaultwarden

## Priority 3

Monitoring Services

- Grafana
- Prometheus
- Loki
- Promtail

## Priority 4

Development Services

- LocalStack
- Terraform

---

# Scenario 1: Cannot Reach Apollo

## Symptoms

- SSH unavailable
- Proxmox UI unavailable
- Tailscale unreachable

## Checks

From Artemis:

```bash
tailscale status
```

```bash
ping <apollo-ip>
```

```bash
ping <apollo-tailscale-ip>
```

## Recovery

Verify:

1. Power connected
2. Router online
3. Ethernet connected
4. Apollo powered on

If remote recovery fails:

Physical intervention required.

---

# Scenario 2: Apollo Rebooted Unexpectedly

## Symptoms

Services unavailable.

## Verification

Wait:

```text
2–5 minutes
```

Check:

```bash
tailscale status
```

SSH:

```bash
ssh root@apollo
```

Verify:

```bash
qm list
pct list
```

Expected:

- Athena running
- Hestia running

## Recovery

Start manually if required:

### VM

```bash
qm start <vmid>
```

### LXC

```bash
pct start <ctid>
```

---

# Scenario 3: Hestia Offline

## Symptoms

Homepage unavailable.

Vaultwarden unavailable.

## Verification

On Apollo:

```bash
pct list
```

Check status:

```bash
pct status <ctid>
```

## Recovery

Start container:

```bash
pct start <ctid>
```

Verify:

```bash
pct exec <ctid> ip a
```

---

# Scenario 4: Athena Offline

## Symptoms

Monitoring unavailable.

Grafana unavailable.

Prometheus unavailable.

## Verification

On Apollo:

```bash
qm list
```

Check status:

```bash
qm status <vmid>
```

## Recovery

Start VM:

```bash
qm start <vmid>
```

Access:

```bash
ssh ubuntu@athena
```

---

# Scenario 5: Docker Services Not Running

## Symptoms

Containerized services unavailable.

## Verification

```bash
docker ps -a
```

Check logs:

```bash
docker logs <container>
```

## Recovery

Navigate:

```bash
cd ~/homelab/docker-compose
```

Restart stack:

```bash
docker compose up -d
```

Verify:

```bash
docker ps
```

---

# Scenario 6: Grafana Unavailable

## Verification

```bash
docker ps
```

```bash
docker logs grafana
```

## Recovery

Restart:

```bash
docker restart grafana
```

If necessary:

```bash
docker compose up -d
```

---

# Scenario 7: Prometheus Targets Down

## Verification

Open:

```text
http://athena:9090/targets
```

Check:

```text
UP
```

status.

## Recovery

Validate:

```bash
docker logs prometheus
```

Check:

```bash
cat prometheus/prometheus.yml
```

Restart:

```bash
docker restart prometheus
```

---

# Scenario 8: Loki Not Receiving Logs

## Verification

Check:

```bash
docker logs loki
```

```bash
docker logs promtail
```

In Grafana Explore:

```logql
{job=~".+"}
```

## Recovery

Restart:

```bash
docker restart loki
docker restart promtail
```

---

# Scenario 9: Homepage Not Loading

## Verification

Check:

```bash
docker ps
```

Inspect:

```bash
docker logs homepage
```

Review configuration:

```text
services.yaml
widgets.yaml
settings.yaml
```

## Recovery

Restart:

```bash
docker restart homepage
```

---

# Scenario 10: Vaultwarden Unavailable

## Verification

```bash
docker logs vaultwarden
```

Verify:

```bash
docker ps
```

## Recovery

Restart:

```bash
docker restart vaultwarden
```

Verify access.

---

# Scenario 11: LocalStack Unavailable

## Verification

```bash
docker ps
```

```bash
docker logs localstack
```

Test endpoint:

```bash
curl http://localhost:4566
```

Expected:

```text
HTTP/1.1 200 OK
```

## Recovery

Restart:

```bash
docker restart localstack
```

---

# Scenario 12: Terraform Deployment Failure

## Verification

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

## Recovery

Refresh state:

```bash
terraform refresh
```

Reapply:

```bash
terraform apply
```

---

# Scenario 13: Tailscale Connectivity Failure

## Verification

Check:

```bash
tailscale status
```

Restart:

```bash
sudo systemctl restart tailscaled
```

Reconnect:

```bash
sudo tailscale up
```

## Validation

Verify peer visibility.

---

# Scenario 14: Storage Running Out

## Verification

```bash
df -h
```

Check Docker usage:

```bash
docker system df
```

## Recovery

Prune unused resources:

```bash
docker system prune -a
```

Review logs and backups.

---

# Scenario 15: Complete Service Recovery

## Recovery Sequence

### Step 1

Verify Apollo online.

### Step 2

Verify networking.

### Step 3

Verify Hestia running.

### Step 4

Verify Athena running.

### Step 5

Verify Docker services.

### Step 6

Verify Tailscale.

### Step 7

Verify Homepage.

### Step 8

Verify Grafana.

### Step 9

Verify Vaultwarden.

### Step 10

Verify LocalStack.

---

# Health Verification Checklist

```bash
tailscale status
```

```bash
docker ps
```

```bash
df -h
```

```bash
free -h
```

```bash
uptime
```

## Service Verification

- Homepage accessible
- Vaultwarden accessible
- Grafana accessible
- Prometheus accessible
- Loki receiving logs
- LocalStack responding
- Terraform operational

---

# Recovery Objectives

| Objective | Target |
|------------|----------|
| Apollo Recovery | < 5 minutes |
| Athena Recovery | < 2 minutes |
| Hestia Recovery | < 2 minutes |
| Docker Service Recovery | < 1 minute |
| Monitoring Recovery | < 2 minutes |
| Full Environment Recovery | < 10 minutes |

---

# Conclusion

The homelab environment is designed to recover from common failures through:

- Proxmox autostart
- Docker restart policies
- Tailscale remote access
- Infrastructure as Code
- Version-controlled configuration

The goal is to maintain a fully recoverable environment that can be operated remotely without requiring physical access.