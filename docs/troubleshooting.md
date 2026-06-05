# Troubleshooting Guide

## Purpose

This document records significant issues encountered during the design, deployment, operation, maintenance, and evolution of the HomeLab environment.

Each incident includes an overview, symptoms, investigation, root cause, resolution, verification, impact, and lessons learned. The objective is to preserve operational knowledge, reduce future recovery time, document engineering decisions, and maintain a historical record of infrastructure changes.

---

## Incident Summary

| Incident                                                   | Severity | Status    |
| ---------------------------------------------------------- | -------- | --------- |
| Permission Denied During Infrastructure Refactoring        | Low      | Resolved  |
| Docker Container Name Conflicts During Stack Consolidation | Low      | Resolved  |
| VM and LXC Autostart Failure                               | Medium   | Resolved  |
| Apollo Network Outage and Recovery                         | High     | Resolved  |
| Stale vmbr1 Bridge Configuration                           | Low      | Resolved  |
| Loki Centralized Logging Integration                       | Low      | Completed |
| Loki Readiness Endpoint Investigation                      | Medium   | Resolved  |
| Homepage Dashboard Configuration Recovery                  | Low      | Resolved  |
| LocalStack and Terraform Validation                        | Low      | Completed |
| Telegram Alerting Validation                               | Low      | Completed |
| Headless Operations Validation                             | Low      | Completed |
| Chaos Reboot Recovery Testing                              | Medium   | Completed |

---

## 1. Permission Denied During Infrastructure Refactoring

### Overview

During consolidation of multiple Docker Compose projects into a unified infrastructure layout, several directories could not be created or modified within the homelab workspace.

### Symptoms

* `Permission denied` errors during directory creation
* Failed file moves
* Failed repository restructuring operations

### Investigation

```bash
ls -la
```

Several directories were owned by `root` rather than the intended user account.

### Root Cause

Previous Docker operations executed with elevated privileges (`sudo`) created root-owned directories.

### Resolution

```bash
sudo chown -R ubuntu:ubuntu ~/homelab
```

### Verification

* Directory creation successful
* Git operations successful
* File modifications successful

### Impact

* Temporary repository restructuring delay
* No service outage
* No data loss

### Lessons Learned

Avoid unnecessary use of `sudo` during routine Docker operations.

---

## 2. Docker Container Name Conflicts During Stack Consolidation

### Overview

While consolidating monitoring services into a unified telemetry stack, Docker failed to create containers due to naming conflicts.

### Symptoms

Conflicts occurred for:

* grafana
* prometheus
* loki
* promtail
* node-exporter

### Investigation

```bash
docker ps -a
```

Legacy containers remained registered from previous deployments.

### Root Cause

Existing containers were not removed before deploying the new stack.

### Resolution

```bash
docker rm -f grafana prometheus promtail node-exporter loki
docker compose up -d
```

### Verification

All telemetry containers started successfully.

### Impact

* Deployment blocked temporarily
* No data loss

### Lessons Learned

Always decommission legacy stacks before migrations.

---

## 3. VM and LXC Autostart Failure

### Overview

A planned reboot revealed critical workloads were not configured to start automatically.

### Symptoms

After reboot:

* Athena offline
* Hestia offline
* Services unavailable

### Investigation

Reviewed Proxmox startup settings.

### Root Cause

**Start at Boot** was disabled for:

* VM 100 (Athena)
* LXC 101 (Hestia)

### Resolution

Enabled Proxmox autostart for both workloads.

### Verification

Subsequent reboots automatically restored services.

### Impact

Temporary service outage after host reboot.

### Lessons Learned

Validate autostart configuration during infrastructure testing.

---

## 4. Apollo Network Outage and Recovery

### Overview

Apollo experienced a network outage that interrupted connectivity between infrastructure components.

### Symptoms

* VMs unreachable
* Containers unreachable
* SSH unavailable
* Tailscale inaccessible

### Investigation

Reviewed:

* Proxmox bridge configuration
* Routing
* Firewall rules
* Interface assignments

### Root Cause

Network configuration drift combined with stale bridge configurations and firewall interactions.

### Resolution

* Validated active bridge assignments (`vmbr0`)
* Corrected routing configuration
* Verified firewall settings
* Restarted networking services
* Removed obsolete networking components

### Verification

```bash
ping
tailscale ping
```

Connectivity restored between:

* Apollo
* Athena
* Hestia
* Artemis

### Impact

Temporary infrastructure management outage.

### Lessons Learned

Network changes should be documented immediately and validated incrementally.

---

## 5. Stale vmbr1 Bridge Configuration

### Overview

An unused bridge interface was discovered during network auditing.

### Symptoms

`vmbr1` existed but had no active workloads attached.

### Investigation

Reviewed Proxmox network configuration.

### Root Cause

Legacy bridge from earlier networking experiments.

### Resolution

Removed unused bridge and standardized networking on `vmbr0`.

### Verification

Network inventory matched actual infrastructure design.

### Impact

No service outage.

### Lessons Learned

Remove obsolete infrastructure components after testing.

---

## 6. Loki Centralized Logging Integration

### Overview

Container logs were initially distributed across multiple hosts without centralized aggregation.

### Architecture

```text
Docker Containers
        │
        ▼
Grafana Alloy
        │
        ▼
Loki
        │
        ▼
Grafana Explore
```

### Symptoms

* No centralized log access
* Difficult troubleshooting
* Limited historical log visibility

### Root Cause

Containers only stored local logs.

### Resolution

Implemented:

* Loki
* Grafana Alloy
* Centralized log forwarding

### Verification

Grafana Explore query:

```text
{container="vaultwarden"}
```

returned expected logs.

### Impact

Significantly improved troubleshooting capability.

### Lessons Learned

Centralized logging should be deployed early.

---

## 7. Loki Readiness Endpoint Investigation

### Overview

Loki appeared unhealthy despite functioning correctly.

### Symptoms

Health checks reported Loki unavailable.

### Investigation

```bash
curl -I http://localhost:3100/ready
docker logs loki
```

Internal services reported:

* Distributor ACTIVE
* Ingester ACTIVE
* Scheduler ACTIVE
* Compactor ACTIVE

### Root Cause

Incorrect readiness configuration for single-node deployment.

### Resolution

Configured Loki for standalone operation:

```yaml
replication_factor: 1
kvstore:
  store: inmemory
```

Validated correct readiness endpoint:

```bash
curl -I http://localhost:3100/ready
```

### Verification

Returned:

```text
HTTP/1.1 200 OK
```

### Impact

False-positive health failures.

### Lessons Learned

Validate health endpoints against deployment architecture.

---

## 8. Homepage Dashboard Configuration Recovery

### Overview

Homepage configuration became inconsistent during infrastructure restructuring.

### Symptoms

* Missing dashboard sections
* Missing widgets
* Incorrect service rendering

### Investigation

Reviewed:

* services.yaml
* widgets.yaml
* settings.yaml

### Root Cause

Configuration drift during repository reorganization.

### Resolution

Rebuilt Homepage configuration from Git-backed configuration files.

### Verification

Successfully rendered:

* Proxmox
* Grafana
* Portainer
* Vaultwarden
* Prometheus

### Impact

Reduced dashboard visibility.

### Lessons Learned

Store all application configuration in version control.

---

## 9. LocalStack and Terraform Infrastructure Validation

### Overview

Validated Infrastructure as Code workflows using LocalStack.

### Objective

Verify Terraform provisioning against a local AWS-compatible environment.

### Resolution

Successfully provisioned:

* `tf-homelab-storage-bucket`
* `tf-homelab-metadata`

using:

```bash
terraform apply
```

### Verification

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

Resources successfully created.

### Impact

Established repeatable Infrastructure as Code workflows.

### Lessons Learned

Infrastructure should be reproducible through code.

---

## 10. Telegram Alerting Validation

### Overview

Validated Grafana alert delivery through Telegram.

### Alert Flow

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

### Verification

Triggered test alert through Grafana Contact Points.

Telegram notification received successfully.

### Result

**PASS**

### Lessons Learned

Alerting systems must be validated regularly.

---

## 11. Headless Operations Validation

### Overview

Verified complete infrastructure management without monitor, keyboard, or mouse.

### Procedure

Disconnected:

* Monitor
* Keyboard
* Mouse

### Verification

Successfully managed infrastructure using:

* Tailscale
* SSH
* Grafana
* Portainer
* Homepage

### Result

**PASS**

### Impact

Confirmed remote-only administration capability.

### Lessons Learned

Routine administration should never require physical access.

---

## 12. Chaos Reboot Recovery Testing

### Overview

Executed full recovery testing to validate automatic service restoration.

### Procedure

Rebooted Apollo and monitored:

* Hypervisor startup
* VM startup
* Container startup
* Network recovery
* Service recovery

### Verification

Recovered automatically:

* Athena
* Hestia
* Grafana
* Prometheus
* Loki
* Homepage
* Vaultwarden
* Portainer
* LocalStack

Verified via:

```bash
tailscale ping
```

and service accessibility checks.

### Result

**PASS**

### Impact

Validated disaster recovery readiness.

### Lessons Learned

Recovery testing is as important as deployment testing.

---

## Key Takeaways

1. Infrastructure should be reproducible through code.
2. Monitoring should exist before major workloads are deployed.
3. Centralized logging dramatically reduces troubleshooting time.
4. Recovery procedures must be tested regularly.
5. Documentation is part of the infrastructure.
6. Network changes should be tracked carefully.
7. Remote administration should not require physical access.
8. Configuration should be version controlled.
9. Alerting systems should be tested regularly.
10. Operational knowledge should be preserved through documentation.

---

## Status

**Incident Log Status:** Current

**Historical Records:** Preserved

**Operational Knowledge Base:** Active

**Overall Environment State:** Stable Operational Environment
