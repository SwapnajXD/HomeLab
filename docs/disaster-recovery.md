# Disaster Recovery Runbook

## Purpose

This document defines recovery procedures for the Olympus HomeLab environment.

Its objective is to restore critical services as quickly as possible following hardware failures, software failures, networking issues, configuration drift, or complete infrastructure outages.

The runbook prioritizes restoring foundational infrastructure before dependent services.

---

# Environment Overview

## Apollo

**Role:** Proxmox Hypervisor

Responsibilities:

* Virtual Machine Hosting
* LXC Hosting
* Virtual Networking
* Storage Management
* NAT Gateway Functions

---

## Athena (VM 100)

**Role:** Operations Platform

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

## Hestia (CT 101)

**Role:** Application Platform

Hosted Services:

* Homepage
* Vaultwarden
* Personal Feed Collection Scripts
* SSH Synchronization Endpoint

---

# Recovery Priorities

| Priority   | Components                                 | RTO         |
| ---------- | ------------------------------------------ | ----------- |
| Priority 1 | Apollo, vmbr0, NAT Gateway, Tailscale      | < 5 Minutes |
| Priority 2 | Hestia, Homepage, Vaultwarden              | < 2 Minutes |
| Priority 3 | Grafana, Prometheus, Loki, Alloy, Telegram | < 2 Minutes |
| Priority 4 | Floci, Terraform                           | < 1 Minute  |

---

# Failure Scenarios & Recovery Procedures

## Scenario 1: Apollo Unreachable

### Symptoms

* SSH unavailable
* Proxmox UI unavailable
* Tailscale unreachable
* Internal services inaccessible

### Verification

From Artemis:

```bash
tailscale ping apollo
```

### Recovery

1. Verify Airtel Fiber router is online.
2. Verify Apollo is powered on.
3. Verify network interfaces are active.
4. Verify Tailscale status.
5. If internal workloads cannot reach external networks, verify NAT rules.

Restore outbound NAT if required:

```bash
iptables -t nat -A POSTROUTING \
-s 10.10.10.0/24 \
-o wlx002e2df0393b \
-j MASQUERADE
```

> Physical intervention is required if Apollo cannot be reached remotely.

---

## Scenario 2: Apollo Rebooted Unexpectedly

### Verification

Check Proxmox status.

Expected:

* Athena running
* Hestia running

### Recovery

If guests failed to autostart:

```bash
qm start 100
pct start 101
```

Verify:

```bash
qm status 100
pct status 101
```

---

## Scenario 3: Athena Offline

### Verification

```bash
qm status 100
```

### Recovery

Start Athena:

```bash
qm start 100
```

Verify access:

```bash
ssh ubuntu@athena
tailscale ping athena
```

---

## Scenario 4: Hestia Offline

### Verification

```bash
pct status 101
```

### Recovery

```bash
pct start 101
```

Verify:

```bash
ping 10.10.10.2
```

---

## Scenario 5: Docker Services Not Running

### Verification

SSH into Athena or Hestia:

```bash
docker ps
```

### Recovery

Restart affected stacks.

Telemetry Stack:

```bash
cd ~/homelab/docker-compose/telemetry
docker compose down
docker compose up -d
```

Core Services:

```bash
cd ~/homelab/docker-compose/core-services
docker compose down
docker compose up -d
```

Floci:

```bash
cd ~/homelab/docker-compose/floci
docker compose down
docker compose up -d
```

---

## Scenario 6: Grafana Unavailable

### Verification

Open:

```text
http://<athena-ip>:3001
```

### Recovery

1. Restart telemetry stack.
2. Verify Prometheus datasource.
3. Verify Loki datasource.

---

## Scenario 7: Prometheus Targets Down

### Verification

```text
http://<athena-ip>:9090/targets
```

### Recovery

Review configuration:

```bash
docker logs prometheus
```

Validate:

```bash
cat prometheus.yml
```

Restart:

```bash
docker restart prometheus
```

---

## Scenario 8: Loki Unavailable

### Verification

```bash
curl -I http://localhost:3100/ready
```

Expected:

```text
HTTP/1.1 200 OK
```

Inspect logs:

```bash
docker logs loki
```

### Recovery

Restart Loki:

```bash
docker restart loki
```

If readiness failures persist, verify standalone configuration:

```yaml
replication_factor: 1

kvstore:
  store: inmemory
```

---

## Scenario 9: Logs Missing in Grafana

### Verification

```bash
curl -s http://localhost:3100/loki/api/v1/labels
```

Check Grafana Explore.

### Recovery

1. Restart Alloy.

```bash
docker restart alloy
```

2. Verify Docker discovery.
3. Confirm Loki ingestion.

---

## Scenario 10: Homepage Unavailable

### Verification

Inspect:

* services.yaml
* widgets.yaml
* settings.yaml

### Recovery

1. Restore configuration from Git.
2. Restart core services.

```bash
docker compose restart
```

---

## Scenario 11: Vaultwarden Unavailable

### Verification

Confirm login page accessibility.

### Recovery

```bash
docker restart vaultwarden
```

---

## Scenario 12: Floci Failure

### Verification

```bash
curl http://localhost:4566
```

### Recovery

```bash
cd ~/homelab/docker-compose/floci
docker compose down
docker compose up -d
```

Validate Terraform workflows afterward.

---

## Scenario 13: Terraform Failure

### Verification

```bash
terraform plan
```

or

```bash
terraform apply
```

### Recovery

Verify resources:

* tf-homelab-storage-bucket
* tf-homelab-metadata

If state corruption exists:

```bash
terraform destroy
terraform apply
```

---

## Scenario 14: Dashboard Synchronization Failure

### Symptoms

Homepage widgets show stale or missing data.

Examples:

* Weather
* Prices
* Pokémon
* Last.fm

### Verification

Check API responses:

```bash
curl http://10.10.10.10:8000/prices
```

Verify Hestia SSH:

```bash
rc-service sshd status
```

Test synchronization:

```bash
scp root@10.10.10.2:/root/homelab/personal-services/homepage-config/data/*.json \
~/homelab/docker-compose/dashboard-api/data/
```

### Recovery

1. Restart sshd if necessary.
2. Verify Ed25519 keys.
3. Review cron jobs.

```bash
crontab -l
```

---

## Scenario 15: Tailscale Failure

### Verification

```bash
tailscale status
```

### Recovery

```bash
tailscale up
```

### Validation

Verify connectivity:

* Artemis
* Apollo
* Athena

---

## Scenario 16: Telegram Alert Failure

### Verification

Review Grafana contact points:

* Bot Token
* Chat ID
* Notification Policies

### Recovery

1. Reconfigure Telegram integration.
2. Send a test notification.

### Validation

Confirm message delivery.

---

## Scenario 17: Storage Exhaustion

### Verification

```bash
df -h
```

### Recovery

1. Remove obsolete backups.
2. Remove stale logs.
3. Prune unused Docker resources.

```bash
docker system prune
```

---

# Complete Environment Recovery

## Cold-Start Restoration Sequence

Execute recovery in this order:

1. Verify Apollo is operational.
2. Verify vmbr0 bridge status.
3. Restore outbound NAT if required.
4. Verify Tailscale connectivity.
5. Start Athena.
6. Start Hestia.
7. Verify Homepage and Vaultwarden.
8. Start telemetry services.
9. Verify Prometheus targets.
10. Verify Loki readiness.
11. Verify Alloy forwarding.
12. Verify Dashboard API operation.
13. Verify dashboard synchronization.
14. Verify Floci.
15. Validate Terraform.
16. Send Telegram test notification.

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

* Proxmox guest autostart enabled
* Docker restart policies configured
* Tailscale remote administration
* Git-backed configuration management
* Terraform-managed infrastructure
* Documented and tested recovery procedures
* Restore dependencies before applications

---

# Health Verification Checklist

## Infrastructure

* [ ] Apollo reachable
* [ ] vmbr0 operational
* [ ] NAT functioning
* [ ] Tailscale healthy

## Applications

* [ ] Homepage accessible
* [ ] Vaultwarden accessible

## Observability

* [ ] Grafana accessible
* [ ] Prometheus healthy
* [ ] Loki `/ready` returns 200 OK
* [ ] Logs visible in Grafana Explore
* [ ] Telegram alerts operational

## Development Services

* [ ] Floci responding
* [ ] Terraform operational

## Dashboard Services

* [ ] Olympus Dashboard API responding
* [ ] Personal widgets updating
* [ ] Synchronization jobs functioning

---

# Conclusion

The Olympus HomeLab is designed to recover from common infrastructure failures through virtualization, containerization, observability, secure remote administration, and well-defined operational procedures.

**Current Recovery Status:** Operational

**Recovery Procedures:** Documented and Tested

**Overall Environment State:** Stable Operational Environment
