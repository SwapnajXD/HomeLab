# Troubleshooting Guide

## Purpose

This document records significant incidents encountered during the design, deployment, operation, and evolution of the Olympus HomeLab environment.

Each incident includes an overview, symptoms, investigation, root cause analysis, resolution, verification, impact, and lessons learned. The objective is to preserve operational knowledge, reduce future recovery time, document engineering decisions, and maintain a historical record of infrastructure changes.

---

## Incident Summary

| Incident                                                   | Severity | Status    |
| ---------------------------------------------------------- | -------- | --------- |
| Permission Denied During Infrastructure Refactoring        | Low      | Resolved  |
| Docker Container Name Conflicts During Stack Consolidation | Low      | Resolved  |
| VM and LXC Autostart Failure                               | Medium   | Resolved  |
| Apollo Network Outage and NAT Recovery                     | High     | Resolved  |
| Stale `vmbr1` Bridge Configuration                         | Low      | Resolved  |
| Loki Centralized Logging Integration                       | Low      | Completed |
| Loki Readiness Endpoint Investigation                      | Medium   | Resolved  |
| Homepage Weather Widget Failure                            | Low      | Resolved  |
| Cross-Node Synchronization Failure                         | Medium   | Resolved  |
| AWS Emulation and Terraform Validation                     | Low      | Completed |
| Telegram Alerting Validation                               | Low      | Completed |
| Headless Operations Validation                             | Low      | Completed |
| Chaos Reboot Recovery Testing                              | Medium   | Completed |

---

# 1. Permission Denied During Infrastructure Refactoring

## Overview

During consolidation of multiple Docker Compose projects into a unified infrastructure layout, several directories could not be modified within the homelab workspace.

## Symptoms

* `Permission denied` errors
* Failed directory creation
* Failed file moves
* Repository restructuring blocked

## Investigation

```bash
ls -la
```

Several directories were owned by `root` instead of the intended user account.

## Root Cause

Previous Docker operations executed using `sudo` created root-owned directories.

## Resolution

```bash
sudo chown -R ubuntu:ubuntu ~/homelab
```

## Verification

* Directory creation successful
* Git operations successful
* File modifications successful

## Impact

* Temporary repository restructuring delay
* No service outage
* No data loss

## Lessons Learned

Avoid unnecessary use of `sudo` during routine Docker operations.

---

# 2. Docker Container Name Conflicts During Stack Consolidation

## Overview

While consolidating monitoring services into a unified telemetry stack, Docker failed to create containers due to naming conflicts.

## Symptoms

Conflicts occurred for:

* grafana
* prometheus
* loki
* promtail
* node-exporter

## Investigation

```bash
docker ps -a
```

Legacy containers remained registered.

## Root Cause

Existing containers were not removed before deploying the new stack.

## Resolution

```bash
docker rm -f grafana prometheus promtail node-exporter loki
docker compose up -d
```

## Verification

All telemetry containers started successfully.

## Impact

* Deployment temporarily blocked
* No data loss

## Lessons Learned

Always decommission legacy stacks before migrations.

---

# 3. VM and LXC Autostart Failure

## Overview

A planned reboot revealed critical workloads were not configured to start automatically.

## Symptoms

After reboot:

* Athena offline
* Hestia offline
* Services unavailable

## Investigation

Reviewed Proxmox startup settings.

## Root Cause

**Start at Boot** was disabled for:

* VM 100 (Athena)
* CT 101 (Hestia)

## Resolution

Enabled autostart for both workloads.

## Verification

Subsequent reboots restored services automatically.

## Impact

Temporary service outage after host reboot.

## Lessons Learned

Validate autostart configuration during infrastructure testing.

---

# 4. Apollo Network Outage and NAT Recovery

## Severity

**High**

## Overview

Following a scheduled reboot of Apollo, all virtual workloads lost Internet access and remote administration capabilities.

This became the most significant networking incident experienced within the homelab environment.

## Symptoms

* Athena reported disconnected Tailscale status
* `ping 8.8.8.8` failed
* DNS resolution failures
* SSH sessions hung indefinitely
* Remote administration unavailable
* Internal workloads could not reach external networks

## Investigation Timeline

### Application Validation

Verified application health locally:

```bash
curl http://localhost:8000
```

Result:

* Olympus API functioning correctly
* Applications healthy

---

### Virtual Network Validation

Examined:

```bash
brctl show
bridge link
```

Verified:

* `vmbr0` operational
* Apollo: `10.10.10.1`
* Athena: `10.10.10.10`
* Hestia: `10.10.10.2`

---

### Failure Isolation

Determined that:

* Athena could communicate with Apollo
* Internal networking remained functional
* External traffic failed at Apollo

## Root Cause Analysis

Apollo relied on a dynamically added outbound NAT rule that was not persisted across reboots.

After restart, the MASQUERADE rule disappeared from the kernel packet processing tables.

As a result, traffic originating from the internal subnet (`10.10.10.0/24`) could not be translated through the physical network interface.

## Resolution

Restored outbound NAT:

```bash
iptables -t nat -A POSTROUTING \
    -s 10.10.10.0/24 \
    -o wlx002e2df0393b \
    -j MASQUERADE
```

## Verification

Confirmed recovery of:

* Tailscale synchronization
* DNS resolution
* Internet connectivity
* SSH access
* API reachability

## Impact

* Complete loss of remote administration
* External service disruption
* Temporary observability degradation

## Lessons Learned

* Critical networking rules must persist across reboots.
* Gateway systems represent high-value failure domains.
* Validate outbound routing after maintenance activities.

---

# 5. Stale vmbr1 Bridge Configuration

## Overview

An unused bridge interface was discovered during network auditing.

## Symptoms

`vmbr1` existed without attached workloads.

## Investigation

Reviewed Proxmox network configuration.

## Root Cause

Legacy bridge from earlier experimentation.

## Resolution

Removed `vmbr1` and standardized networking on `vmbr0`.

## Verification

Infrastructure inventory matched deployed architecture.

## Impact

No service outage.

## Lessons Learned

Remove obsolete infrastructure components after testing.

---

# 6. Loki Centralized Logging Integration

## Overview

Container logs were initially distributed across multiple hosts without aggregation.

## Architecture

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

## Symptoms

* No centralized log access
* Difficult troubleshooting
* Limited historical visibility

## Root Cause

Containers only stored local logs.

## Resolution

Implemented:

* Loki
* Grafana Alloy
* Centralized forwarding

## Verification

Grafana Explore query:

```text
{container="vaultwarden"}
```

returned expected logs.

## Impact

Significantly improved troubleshooting capability.

## Lessons Learned

Centralized logging should be implemented early.

---

# 7. Loki Readiness Endpoint Investigation

## Overview

Loki appeared unhealthy despite functioning correctly.

## Symptoms

* Health checks failed
* Readiness probes unstable

## Investigation

```bash
curl -I http://localhost:3100/ready
docker logs loki
```

Observed:

* Distributor ACTIVE
* Ingester ACTIVE
* Scheduler ACTIVE
* Compactor ACTIVE

## Root Cause

Default clustering assumptions conflicted with single-node deployment.

## Resolution

Configured Loki for standalone operation:

```yaml
replication_factor: 1
kvstore:
  store: inmemory
```

## Verification

```bash
curl -I http://localhost:3100/ready
```

Returned:

```text
HTTP/1.1 200 OK
```

## Impact

False-positive health failures.

## Lessons Learned

Validate health checks against deployment architecture.

---

# 8. Homepage Weather Widget Failure

## Overview

Homepage weather widgets began failing intermittently.

## Symptoms

* Widget failures
* `ECONNRESET`
* Unexpected EOF errors
* Missing weather information

## Investigation

Network tracing identified intermittent TLS failures with Open-Meteo.

Stable connectivity existed to other external services.

## Root Cause

Unreliable upstream TLS handshakes with the weather provider.

## Resolution

Replaced the native Homepage widget with a custom solution:

* Queried `wttr.in`
* Processed responses locally
* Generated structured JSON assets
* Served data through the existing dashboard pipeline

## Verification

Weather widgets rendered consistently.

## Impact

Temporary dashboard degradation.

## Lessons Learned

Critical dashboards should tolerate external API instability.

---

# 9. Cross-Node Synchronization Failure

## Overview

Automation pipelines initially failed to synchronize data between Hestia and Athena.

## Symptoms

* Connection refused errors
* Failed SCP transfers
* Missing Homepage data updates

## Investigation

Verified network connectivity and authentication paths.

## Root Cause

Alpine Linux containers do not enable SSH services by default.

Hestia lacked an operational SSH daemon.

## Resolution

Enabled SSH services:

```bash
apk add openssh
ssh-keygen -A
rc-service sshd start
```

Configured passwordless Ed25519 authentication.

## Verification

* SCP successful
* Automated synchronization operational
* Dashboard data updated correctly

## Impact

Automation pipeline interruption.

## Lessons Learned

Minimal operating systems require explicit enablement of supporting services.

---

# 10. AWS Emulation and Terraform Validation

## Overview

Validated Infrastructure as Code workflows using AWS emulation.

## Objective

Verify Terraform provisioning workflows.

## Resolution

Successfully provisioned:

* `tf-homelab-storage-bucket`
* `tf-homelab-metadata`

using:

```bash
terraform apply
```

## Verification

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

Resources created successfully.

## Impact

Established reproducible IaC workflows.

## Lessons Learned

Infrastructure should be reproducible through code.

---

# 11. Telegram Alerting Validation

## Overview

Validated Grafana alert delivery.

## Alert Flow

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

## Verification

Triggered test alerts through Grafana Contact Points.

Telegram notifications received successfully.

## Result

**PASS**

## Lessons Learned

Alerting systems require routine validation.

---

# 12. Headless Operations Validation

## Overview

Validated complete remote administration capability.

## Procedure

Disconnected:

* Monitor
* Keyboard
* Mouse

## Verification

Successfully administered infrastructure using:

* Tailscale
* SSH
* Grafana
* Portainer
* Homepage

## Result

**PASS**

## Impact

Confirmed remote-only operational capability.

## Lessons Learned

Routine administration should not require physical access.

---

# 13. Chaos Reboot Recovery Testing

## Overview

Validated automatic recovery after complete infrastructure reboot.

## Procedure

Rebooted Apollo and monitored:

* Hypervisor startup
* VM startup
* Container startup
* Network restoration
* Service recovery

## Verification

Automatically recovered:

* Athena
* Hestia
* Grafana
* Prometheus
* Loki
* Homepage
* Vaultwarden
* Portainer
* Floci

Verified using:

```bash
tailscale ping
```

and service accessibility checks.

## Result

**PASS**

## Impact

Validated disaster recovery readiness.

## Lessons Learned

Recovery testing is as important as deployment testing.

---

## Key Takeaways

1. Infrastructure should be reproducible through code.
2. Monitoring should exist before major workloads are deployed.
3. Centralized logging dramatically reduces troubleshooting time.
4. Recovery procedures must be tested regularly.
5. Documentation is part of the infrastructure.
6. Critical network rules must persist across reboots.
7. Remote administration should not require physical access.
8. Configuration should be version controlled.
9. Alerting systems should be tested regularly.
10. Operational knowledge should be preserved through documentation.

---

## Status

| Item                       | Status    |
| -------------------------- | --------- |
| Incident Log               | Current   |
| Historical Records         | Preserved |
| Operational Knowledge Base | Active    |
| Environment Stability      | Stable    |

**Overall Environment State: Stable Operational Environment**
