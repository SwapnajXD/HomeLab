# Network Architecture

## Overview

The HomeLab network is designed around a private-by-default model.

All infrastructure services operate within the local network and are accessed remotely through Tailscale.

No intentional public-facing services are exposed to the Internet.

Primary goals:

* Security
* Simplicity
* Reliability
* Remote Accessibility
* Operational Independence

---

# Physical Network Topology

```text
Internet
    │
    ▼
Airtel Fiber Router
    │
    ▼
Apollo (Proxmox VE)
    │
    ├── Athena VM
    │
    └── Hestia LXC
```

---

# Logical Network Topology

```text
Artemis
    │
    ▼
Tailscale Network
    │
    ▼
Apollo
    │
    ├── Athena
    │
    └── Hestia
```

---

# Infrastructure Components

## Apollo

Role:

Proxmox Hypervisor

Responsibilities:

* Virtual Networking
* VM Hosting
* LXC Hosting
* Storage Management

Network Functions:

* Network Bridge Management
* Internal Routing
* VM Connectivity
* Container Connectivity

---

## Athena

Role:

Operations Platform

Network Services:

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Portainer
* LocalStack

Communication:

* Internal Service Access
* Metrics Collection
* Log Aggregation
* Alert Generation

---

## Hestia

Role:

Application Services

Hosted Services:

* Homepage
* Vaultwarden

Communication:

* Internal Service Access
* Tailscale Administration Access

---

# Remote Access Design

Remote access is implemented using Tailscale.

Benefits:

* Encrypted Communication
* Device Authentication
* No Port Forwarding
* Reduced Attack Surface
* Simplified Administration

Current Nodes:

* Artemis
* Apollo
* Athena

---

# Virtual Networking

Proxmox virtual networking is based on Linux bridges.

Primary Bridge:

```text
vmbr0
```

Responsibilities:

* VM Connectivity
* LXC Connectivity
* External Network Access
* Internal Service Communication

---

# Metrics Traffic Flow

```text
Node Exporter
        │
        ▼
Prometheus
        │
        ▼
Grafana

Proxmox Exporter
        │
        ▼
Prometheus
```

Purpose:

* Host Monitoring
* Capacity Analysis
* Performance Visibility

---

# Logging Traffic Flow

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
Grafana
```

Purpose:

* Centralized Logging
* Log Search
* Troubleshooting
* Historical Analysis

---

# Alerting Traffic Flow

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

Purpose:

* Service Monitoring
* Incident Notification
* Infrastructure Awareness

---

# Security Model

## Default Posture

Private by Default

Characteristics:

* No Public Services
* Internal Service Communication
* Tailscale-Based Administration
* Controlled Access Paths

---

## Remote Access Security

Authentication provided by:

* Tailscale Identity
* Device Authorization
* Encrypted Transport

Benefits:

* No Exposed Management Ports
* No Public SSH Access
* Simplified Access Control

---

# Network Validation

The following checks are performed during infrastructure validation.

## Connectivity Validation

Verify:

```bash
ping <target>
```

Expected:

```text
Successful response
```

---

## Tailscale Validation

Verify:

```bash
tailscale status
```

Expected:

```text
All nodes connected
```

---

## Bridge Validation

Verify:

```bash
brctl show
```

or

```bash
bridge link
```

Expected:

```text
vmbr0 present and operational
```

---

## Service Reachability

Verify:

* Grafana Accessible
* Prometheus Accessible
* Loki Accessible
* Homepage Accessible
* Vaultwarden Accessible

Expected:

```text
PASS
```

---

# Major Network Incident

## Proxmox Network Isolation Incident

### Symptoms

Observed:

* VM connectivity failures
* Internal communication failures
* Missing bridge connectivity

---

### Investigation

Examined:

```bash
brctl show
```

```bash
bridge link
```

```bash
cat /etc/network/interfaces
```

---

### Root Cause

Incomplete bridge configuration prevented proper attachment of virtual interfaces.

---

### Resolution

Rebuilt and validated:

* vmbr0
* VM connectivity
* LXC connectivity

---

### Verification

Confirmed:

* Host Communication
* VM Communication
* Container Communication
* Internet Connectivity

Infrastructure networking restored successfully.

---

# Future Improvements

## Hardware

Planned:

5-meter CAT6 Ethernet cable

Benefits:

* Reduced Latency
* Improved Stability
* Consistent Throughput
* Reduced Wi-Fi Dependency

---

## Security

Planned:

* Tailscale ACLs
* Device Tagging
* Access Segmentation

---

## Monitoring

Planned:

* Network Latency Tracking
* Uptime Monitoring
* Service-Level Monitoring

---

# Status

| Component             | Status      |
| --------------------- | ----------- |
| vmbr0                 | Operational |
| Internal Networking   | Operational |
| VM Connectivity       | Operational |
| LXC Connectivity      | Operational |
| Tailscale             | Operational |
| Remote Administration | Operational |
| Metrics Traffic       | Operational |
| Logging Traffic       | Operational |
| Alerting Traffic      | Operational |

---

# Conclusion

The network architecture provides secure, reliable, and remotely manageable connectivity for all infrastructure services while maintaining a minimal external attack surface through Tailscale-based administration and private-by-default design principles.
