# Disaster Recovery Runbook

## Purpose

This document defines recovery procedures for the HomeLab environment.

The objective is to restore services as quickly as possible following hardware failures, software failures, networking issues, configuration drift, or infrastructure outages.

---

## Environment Overview

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
- Portainer
- LocalStack

---

## Recovery Priority Levels

### Priority 1: Critical Infrastructure

- Apollo (Proxmox Host)
- Proxmox Virtual Networking
- Tailscale Connectivity

### Priority 2: Core Services

- Homepage
- Vaultwarden

### Priority 3: Observability Platform

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Telegram Alerting

### Priority 4: Development Services

- LocalStack
- Terraform

---

## Failure Scenarios & Recovery Steps

### Scenario 1: Cannot Reach Apollo

**Symptoms:** SSH unavailable, Proxmox UI unavailable, Tailscale unreachable.

**Verification:** From Artemis, verify using:

```bash
tailscale ping apollo
```

**Recovery:**

1. Verify router is online.
2. Verify Apollo is powered on.
3. Verify network connectivity is available.
4. Verify Tailscale is operational.

> **Note:** If remote recovery fails, physical intervention is required.

---

### Scenario 2: Apollo Rebooted Unexpectedly

**Verification:** Check the Proxmox summary dashboard.

**Expected:**

- Athena running
- Hestia running

**Recovery:**

If workloads did not autostart, run the following from Apollo:

```bash
qm start 100
pct start 101
```

---

### Scenario 3: Athena Offline

**Verification:**

```bash
qm status 100
```

**Recovery:**

Start the VM:

```bash
qm start 100
```

Verify SSH access via Tailscale:

```bash
ssh ubuntu@athena
```

---

### Scenario 4: Hestia Offline

**Verification:**

```bash
pct status 101
```

**Recovery:**

Verify internal networking and start the container:

```bash
pct start 101
```

---

### Scenario 5: Docker Services Not Running

**Verification:**

SSH into Athena/Hestia and inspect running containers:

```bash
docker ps
```

**Recovery:**

Navigate to the affected stack and recreate it:

```bash
cd ~/homelab/docker-compose/telemetry
docker compose down && docker compose up -d
```

Repeat for:

- `~/homelab/docker-compose/core-services`
- `~/homelab/docker-compose/localstack`

---

### Scenario 6: Grafana Unavailable

**Verification:**

Access:

```text
http://<athena-ip>:3001
```

**Recovery:**

1. Restart the telemetry stack.
2. Verify Prometheus datasource connectivity.
3. Verify Loki datasource connectivity.

---

### Scenario 7: Prometheus Targets Down

**Verification:**

Open:

```text
http://<athena-ip>:9090/targets
```

Check target status.

**Recovery:**

1. Review container logs.
2. Validate `prometheus.yml`.
3. Restart Prometheus:

```bash
docker restart prometheus
```

---

### Scenario 8: Loki Unavailable

**Verification:**

Check readiness endpoint:

```bash
curl -I http://localhost:3100/ready
```

**Expected:** HTTP 200

Check Loki logs:

```bash
docker logs loki
```

Expected components:

- Distributor
- Ingester
- Scheduler
- Compactor

All should be ACTIVE.

**Recovery:**

Restart the Loki container.

---

### Scenario 9: Logs Not Appearing in Grafana

**Verification:**

Verify labels API:

```bash
curl -s http://localhost:3100/loki/api/v1/labels
```

Check Grafana Explore.

**Recovery:**

1. Restart Grafana Alloy.
2. Verify Docker container discovery.
3. Verify Loki ingestion pipeline is active.

---

### Scenario 10: Homepage Unavailable

**Verification:**

Review configuration files:

- `services.yaml`
- `widgets.yaml`
- `settings.yaml`

**Recovery:**

1. Restore configuration from Git backup.
2. Restart the `core-services` stack.

---

### Scenario 11: Vaultwarden Unavailable

**Verification:**

Check whether the Vaultwarden login page loads.

**Recovery:**

Restart the Vaultwarden container.

---

### Scenario 12: LocalStack Failure

**Verification:**

```bash
curl http://localhost:4566
```

**Recovery:**

1. Verify container status.
2. Recreate the LocalStack deployment.

---

### Scenario 13: Terraform Deployment Failure

**Verification:**

Review output from:

```bash
terraform plan
```

or

```bash
terraform apply
```

**Recovery:**

1. Verify S3 bucket exists.
2. Verify DynamoDB table exists.
3. Validate resources using AWS CLI against LocalStack.
4. Destroy and re-apply if state corruption is detected.

---

### Scenario 14: Tailscale Failure

**Verification:**

```bash
tailscale status
```

**Recovery:**

```bash
tailscale up
```

**Validation:**

Verify all nodes are connected:

- Artemis
- Apollo
- Athena

---

### Scenario 15: Telegram Alerting Failure

**Verification:**

Review Grafana Alerting configuration:

- Telegram Bot Token
- Chat ID
- Notification Policies

**Recovery:**

1. Reconfigure Telegram contact point.
2. Trigger test notification.

**Validation:**

Confirm Telegram message is received.

---

### Scenario 16: Storage Running Out

**Verification:**

```bash
df -h
```

**Recovery:**

1. Remove unused resources.
2. Review stale logs.
3. Delete obsolete Proxmox backups.
4. Remove unused Docker resources:

```bash
docker system prune
```

---

### Scenario 17: Complete Environment Recovery (Service Restoration Order)

#### Recovery Sequence

1. Verify Apollo is operational.
2. Verify networking (bridges active).
3. Verify Tailscale mesh connectivity.
4. Verify Athena is running.
5. Verify Hestia is running.
6. Verify all Docker services started successfully.
7. Verify Grafana accessibility.
8. Verify Prometheus metric collection.
9. Verify Loki readiness.
10. Verify Grafana Alloy log forwarding.
11. Verify Homepage widget rendering.
12. Verify Vaultwarden accessibility.
13. Verify LocalStack responsiveness.
14. Verify Telegram alert delivery.

---

## Recovery Objectives

| Objective | Target |
|------------|---------|
| Apollo Recovery | < 5 Minutes |
| Athena Recovery | < 2 Minutes |
| Hestia Recovery | < 2 Minutes |
| Docker Recovery | < 1 Minute |
| Observability Recovery | < 2 Minutes |
| Full Environment Recovery | < 10 Minutes |

---

## Recovery Design Principles

- Proxmox Autostart enabled for critical VMs/LXCs
- Docker restart policies (`unless-stopped`) configured
- Tailscale remote administration
- Version-controlled configuration via Git
- Infrastructure as Code (LocalStack/Terraform)
- Heavily documented recovery procedures

---

## Health Verification Checklist

### Service Verification

- [ ] Homepage accessible
- [ ] Vaultwarden accessible
- [ ] Grafana accessible
- [ ] Prometheus accessible
- [ ] Loki healthy (`/ready` endpoint returns 200 OK)
- [ ] Logs visible in Grafana Explore
- [ ] Telegram alerts operational
- [ ] LocalStack responding
- [ ] Terraform operational

---

## Conclusion

The HomeLab environment is designed to recover from common infrastructure failures through virtualization, containerization, observability, remote administration, and documented operational procedures.

**Current Recovery Status:** Operational

**Recovery Procedures:** Documented and Tested

**Overall Environment State:** Stable Operational Environment