# Disaster Recovery Runbook

## Purpose

This document defines recovery procedures for the HomeLab environment.

The objective is to restore services as quickly as possible following hardware failures, software failures, networking issues, configuration drift, or infrastructure outages.

---

# Environment Overview

## Infrastructure

```text
Artemis (Management Workstation)
        │
    Tailscale
        │
        ▼
Apollo (Proxmox VE)
        │
 ┌──────┴──────┐
 │             │
 ▼             ▼
Hestia       Athena
(LXC)         (VM)
```

---

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
* Portainer
* LocalStack

---

# Recovery Priority Levels

## Priority 1

Critical Infrastructure

* Apollo
* Proxmox Networking
* Tailscale Connectivity

---

## Priority 2

Core Services

* Homepage
* Vaultwarden

---

## Priority 3

Observability Platform

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Telegram Alerting

---

## Priority 4

Development Services

* LocalStack
* Terraform

---

# Scenario 1: Cannot Reach Apollo

## Symptoms

* SSH unavailable
* Proxmox UI unavailable
* Tailscale unreachable

## Verification

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

1. Router online
2. Apollo powered on
3. Network connectivity available
4. Tailscale operational

If remote recovery fails:

Physical intervention required.

---

# Scenario 2: Apollo Rebooted Unexpectedly

## Verification

```bash
tailscale status
```

```bash
ssh root@apollo
```

Check:

```bash
qm list
pct list
```

Expected:

* Athena running
* Hestia running

## Recovery

Start VM:

```bash
qm start 101
```

Start container:

```bash
pct start <ctid>
```

---

# Scenario 3: Athena Offline

## Verification

On Apollo:

```bash
qm list
```

```bash
qm status 101
```

## Recovery

```bash
qm start 101
```

Access:

```bash
ssh ubuntu@athena
```

---

# Scenario 4: Hestia Offline

## Verification

```bash
pct list
```

```bash
pct status <ctid>
```

## Recovery

```bash
pct start <ctid>
```

Verify networking:

```bash
pct exec <ctid> ip a
```

---

# Scenario 5: Docker Services Not Running

## Verification

```bash
docker ps -a
```

Inspect logs:

```bash
docker logs <container>
```

## Recovery

Telemetry Stack:

```bash
cd ~/homelab/docker-compose/telemetry
docker compose up -d
```

Core Services:

```bash
cd ~/homelab/docker-compose/core-services
docker compose up -d
```

LocalStack:

```bash
cd ~/homelab/docker-compose/localstack
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
docker logs grafana
```

## Recovery

```bash
docker restart grafana
```

Verify access through browser.

---

# Scenario 7: Prometheus Targets Down

## Verification

Open:

```text
http://athena:9090/targets
```

Check target status.

## Recovery

Review:

```bash
docker logs prometheus
```

Validate configuration:

```bash
cat prometheus/prometheus.yml
```

Restart:

```bash
docker restart prometheus
```

---

# Scenario 8: Loki Unavailable

## Verification

```bash
docker logs loki
```

Check readiness:

```bash
curl http://localhost:3100/ready
```

Expected:

```text
ready
```

Check services:

```bash
curl http://localhost:3100/services
```

## Recovery

```bash
docker restart loki
```

---

# Scenario 9: Logs Not Appearing in Grafana

## Verification

```bash
docker logs alloy
```

Verify labels:

```bash
curl http://localhost:3100/loki/api/v1/labels
```

Check Grafana Explore.

## Recovery

Restart Alloy:

```bash
docker restart alloy
```

Verify Loki ingestion.

---

# Scenario 10: Homepage Unavailable

## Verification

```bash
docker logs homepage
```

Review configuration:

* services.yaml
* widgets.yaml
* settings.yaml

## Recovery

```bash
docker restart homepage
```

---

# Scenario 11: Vaultwarden Unavailable

## Verification

```bash
docker logs vaultwarden
```

## Recovery

```bash
docker restart vaultwarden
```

Verify login page loads successfully.

---

# Scenario 12: LocalStack Failure

## Verification

```bash
docker logs localstack
```

Test endpoint:

```bash
curl http://localhost:4566
```

## Recovery

```bash
docker restart localstack
```

Verify:

```bash
awslocal s3 ls
```

---

# Scenario 13: Terraform Deployment Failure

## Verification

```bash
terraform validate
```

```bash
terraform plan
```

## Recovery

```bash
terraform refresh
```

```bash
terraform apply
```

Verify resources exist within LocalStack.

---

# Scenario 14: Tailscale Failure

## Verification

```bash
tailscale status
```

## Recovery

```bash
sudo systemctl restart tailscaled
```

Reconnect:

```bash
sudo tailscale up
```

## Validation

Verify nodes:

* Artemis
* Apollo
* Athena

---

# Scenario 15: Telegram Alerting Failure

## Verification

Open Grafana:

```text
Alerting → Contact Points
```

Review:

* Telegram Bot Token
* Chat ID
* Notification Policies

## Recovery

Reconfigure Telegram contact point if necessary.

Send test notification.

## Validation

Telegram message received successfully.

---

# Scenario 16: Storage Running Out

## Verification

```bash
df -h
```

```bash
docker system df
```

## Recovery

Remove unused resources:

```bash
docker system prune -a
```

Review:

* Logs
* Backups
* Docker volumes

---

# Scenario 17: Complete Environment Recovery

## Recovery Sequence

### Step 1

Verify Apollo operational.

### Step 2

Verify networking.

### Step 3

Verify Tailscale.

### Step 4

Verify Athena running.

### Step 5

Verify Hestia running.

### Step 6

Verify Docker services.

### Step 7

Verify Grafana.

### Step 8

Verify Prometheus.

### Step 9

Verify Loki.

### Step 10

Verify Grafana Alloy.

### Step 11

Verify Homepage.

### Step 12

Verify Vaultwarden.

### Step 13

Verify LocalStack.

### Step 14

Verify Telegram alerting.

---

# Health Verification Checklist

Infrastructure:

```bash
tailscale status
docker ps
df -h
free -h
uptime
```

---

## Service Verification

* Homepage accessible
* Vaultwarden accessible
* Grafana accessible
* Prometheus accessible
* Loki healthy
* Logs visible in Grafana
* Telegram alerts operational
* LocalStack responding
* Terraform operational

---

# Recovery Objectives

| Objective                 | Target       |
| ------------------------- | ------------ |
| Apollo Recovery           | < 5 Minutes  |
| Athena Recovery           | < 2 Minutes  |
| Hestia Recovery           | < 2 Minutes  |
| Docker Recovery           | < 1 Minute   |
| Observability Recovery    | < 2 Minutes  |
| Full Environment Recovery | < 10 Minutes |

---

# Recovery Design Principles

* Proxmox Autostart Enabled
* Docker Restart Policies Enabled
* Tailscale Remote Administration
* Version-Controlled Configuration
* Infrastructure as Code
* Documented Recovery Procedures

---

# Conclusion

The HomeLab environment is designed to recover from common infrastructure failures through virtualization, containerization, observability, remote administration, and documented operational procedures.

Current Recovery Status:

Operational

Recovery Procedures:

Documented and Tested

Overall Environment State:

Stable Operational Environment
