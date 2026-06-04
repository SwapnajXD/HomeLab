# Troubleshooting Guide

## Purpose

This document records significant issues encountered during the design, deployment, operation, and maintenance of the homelab environment.

Each incident includes:

- Overview
- Symptoms
- Investigation
- Root Cause
- Resolution
- Verification
- Impact
- Lessons Learned

The goal is to preserve operational knowledge, reduce recovery time, and document engineering decisions for future maintenance and portfolio review.

---

# Permission Denied During Infrastructure Refactoring

## Overview

During the consolidation of multiple Docker Compose projects into a unified infrastructure layout, several directories could not be created or modified within the homelab workspace.

This prevented the migration of monitoring services into their new location and temporarily blocked repository restructuring efforts.

## Symptoms

Attempts to create new directories inside the homelab repository failed immediately.

```bash
mkdir -p ~/homelab/docker-compose/telemetry
```

Result:

```text
mkdir: cannot create directory ... Permission denied
```

Additional operations such as moving files and editing existing directories also failed.

## Investigation

Filesystem ownership was inspected:

```bash
ls -la ~/homelab
```

Several directories were owned by:

```text
root:root
```

instead of the intended user account.

## Root Cause

Previous Docker operations executed with elevated privileges created directories owned by root.

The repository became a mixture of user-owned and root-owned files.

## Resolution

```bash
sudo chown -R $USER:$USER ~/homelab
```

## Verification

Directory creation, file movement, and Git operations completed successfully after ownership was restored.

## Impact

- Repository restructuring delayed
- No service outage
- No data loss

## Lessons Learned

Avoid unnecessary use of sudo during Docker operations and periodically verify repository ownership.

---

# Docker Container Name Conflicts During Stack Consolidation

## Overview

While consolidating monitoring services into a single telemetry stack, Docker failed to create containers due to naming conflicts.

## Symptoms

```text
Conflict. The container name "/proxmox-exporter" is already in use.
```

Similar conflicts occurred for:

- grafana
- prometheus
- promtail
- node-exporter

## Investigation

Existing containers from previous deployments remained registered within Docker.

## Root Cause

Legacy containers were not removed before deploying the new unified compose stack.

## Resolution

```bash
docker rm -f \
proxmox-exporter \
prometheus \
node-exporter \
grafana \
promtail \
loki
```

Then:

```bash
docker compose up -d
```

## Verification

All telemetry containers started successfully within the new compose project.

## Impact

- Telemetry deployment blocked
- No data loss

## Lessons Learned

Always decommission legacy stacks before migration.

---

# VM and LXC Autostart Failure

## Overview

A planned reboot revealed that critical workloads did not automatically start after the hypervisor came back online.

## Symptoms

After rebooting Apollo:

- Athena remained offline
- Hestia remained offline
- Services unavailable

## Investigation

Proxmox startup settings were reviewed.

## Root Cause

The "Start at Boot" option was disabled for both Athena and Hestia.

## Resolution

Enabled:

```text
VM/LXC
→ Options
→ Start at Boot
→ Yes
```

## Verification

Subsequent reboots automatically restored:

- Athena
- Hestia
- Docker services

## Impact

Temporary service outage after reboot.

## Lessons Learned

All production workloads should have autostart enabled and validated during testing.

---

# Apollo Network Outage and Recovery

## Overview

Apollo experienced a network outage that prevented communication between infrastructure components.

## Symptoms

- VMs lost connectivity
- Containers unreachable
- Remote administration unavailable
- Tailscale access unavailable

## Investigation

Bridge interfaces, firewall settings, routing rules, and network configuration files were reviewed.

Commands used:

```bash
ip addr
ip route
bridge link
brctl show
iptables -L -n -v
```

## Root Cause

Network configuration drift combined with bridge and firewall interactions created inconsistent routing behavior.

Additional testing revealed that previous network experiments left behind stale networking artifacts that complicated troubleshooting.

## Resolution

- Validated active bridge assignments
- Corrected routing configuration
- Verified firewall settings
- Restarted affected network services
- Removed obsolete networking components

## Verification

Connectivity restored between:

- Apollo
- Hestia
- Athena
- Artemis

Verified using:

```bash
ping
ssh
tailscale status
```

## Impact

Temporary loss of infrastructure management capability.

## Lessons Learned

Network changes should be documented immediately and tested incrementally.

---

# Stale vmbr1 Bridge Configuration

## Overview

During network troubleshooting, an unused Proxmox bridge interface was discovered.

## Symptoms

Inspection showed:

```bash
brctl show vmbr1
```

Output:

```text
bridge name bridge id STP enabled interfaces
vmbr1 8000.xxxxxxxxxxxx no
```

The bridge existed but had no attached interfaces.

Further validation:

```bash
bridge link | grep vmbr1
```

Returned no results.

## Investigation

Network configuration files and Proxmox bridge assignments were reviewed.

## Root Cause

The bridge remained from earlier networking experiments and was no longer connected to any active workload.

## Resolution

Removed unused bridge configuration and standardized networking around the active infrastructure bridge.

## Verification

Network inventory matched actual infrastructure design.

Only actively used bridges remained.

## Impact

No service outage.

However, it introduced confusion during troubleshooting and network audits.

## Lessons Learned

Unused networking components should be removed after migrations or testing activities.

---

# Loki Centralized Logging Integration

## Overview

Container logs were initially fragmented across multiple hosts and difficult to search.

## Symptoms

No centralized method existed for viewing historical container logs.

Troubleshooting required manually accessing individual hosts and containers.

## Investigation

Docker logging configuration was reviewed across deployed services.

## Root Cause

Containers were writing logs locally without centralized aggregation.

## Resolution

Deployed:

- Loki
- Promtail
- Grafana integration

Configured Docker logging pipelines to forward logs centrally.

## Verification

Logs became visible through Grafana Explore.

Example query:

```logql
{job=~".+"}
```

Vaultwarden and other service logs became searchable from a single interface.

## Impact

Improved troubleshooting efficiency and observability.

## Lessons Learned

Centralized logging should be deployed early in infrastructure projects.

---

# Homepage Dashboard Configuration Recovery

## Overview

The Homepage dashboard configuration was lost during restructuring and migration activities.

## Symptoms

Dashboard sections disappeared or rendered incorrectly.

Widgets failed to display expected service information.

## Investigation

Homepage configuration files were reviewed:

```text
services.yaml
widgets.yaml
settings.yaml
```

## Root Cause

Configuration changes and file restructuring introduced inconsistencies between the deployed container and repository state.

## Resolution

Configuration files were rebuilt and reorganized.

Service definitions were re-added and validated.

## Verification

Homepage successfully displayed:

- Proxmox
- Grafana
- Portainer
- Vaultwarden
- Prometheus

Widgets loaded successfully.

## Impact

Dashboard visibility temporarily reduced.

No underlying services were affected.

## Lessons Learned

Configuration should always be tracked in Git and backed up before major restructuring.

---

# LocalStack and Terraform Infrastructure Validation

## Overview

Infrastructure as Code workflows were validated using LocalStack.

## Symptoms

Required confirmation that Terraform could provision infrastructure successfully through a local AWS-compatible endpoint.

## Investigation

Terraform configuration and LocalStack endpoint configuration were reviewed.

Provider configuration was validated.

## Resolution

Successfully provisioned:

### S3 Bucket

```text
tf-homelab-storage-bucket
```

### DynamoDB Table

```text
tf-homelab-metadata
```

## Verification

Terraform deployment:

```bash
terraform apply
```

Result:

```text
Apply complete! Resources: 2 added.
```

Endpoint validation:

```text
HTTP/1.1 200 OK
```

Resource validation:

```bash
aws s3 ls
aws dynamodb list-tables
```

## Impact

Established a repeatable Infrastructure as Code workflow.

## Lessons Learned

Declarative infrastructure significantly improves recovery, consistency, and scalability.

---

# Headless Operations Validation

## Overview

The infrastructure was tested without requiring a monitor, keyboard, or mouse.

## Objective

Verify that the environment could be fully managed remotely after leaving for college.

## Procedure

Disconnected:

- Monitor
- Keyboard
- Mouse

Left connected:

- Power
- Network

## Verification

Successfully managed infrastructure using:

- Tailscale
- SSH
- Grafana
- Portainer
- Homepage

All services remained accessible.

## Impact

Confirmed remote-only operation capability.

## Lessons Learned

Physical access should never be required for routine administration.

---

# Chaos Reboot Recovery Testing

## Overview

A full recovery test was executed to verify automatic service restoration after a simulated outage.

## Test Procedure

Rebooted Apollo.

Observed:

1. Hypervisor startup
2. VM startup
3. Container startup
4. Network recovery
5. Service recovery

## Verification

Recovered automatically:

- Hestia
- Athena
- Homepage
- Vaultwarden
- Grafana
- Prometheus
- Loki
- Portainer
- LocalStack

Verified through:

```bash
docker ps
tailscale status
```

and web interface accessibility.

## Result

PASS

## Impact

Validated disaster recovery readiness.

## Lessons Learned

Recovery testing is as important as deployment testing.

---

# Key Takeaways

1. Infrastructure should be reproducible through code.
2. Monitoring must exist before major workloads are deployed.
3. Centralized logging dramatically reduces troubleshooting time.
4. Recovery procedures should be tested regularly.
5. Documentation is part of the infrastructure.
6. Network changes should be tracked carefully.
7. Remote administration should be possible without physical access.
8. Every major configuration should be version controlled.
9. Disaster recovery should be validated, not assumed.
10. Operational documentation reduces future troubleshooting effort.