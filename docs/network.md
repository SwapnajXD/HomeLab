# Network Architecture

## Overview

The Olympus HomeLab network follows a **private-by-default** architecture designed to provide secure remote administration, reliable internal communication, and minimal external exposure.

All infrastructure services operate within the internal network and are accessed remotely through Tailscale. No intentional public-facing services are exposed directly to the Internet.

### Design Goals

* Security
* Simplicity
* Reliability
* Remote Accessibility
* Operational Independence
* Segmentation of Sensitive Services

---

## Network Topology

### Physical Topology

```text
Internet
    │
    ▼
Airtel Fiber Router
    │
    ▼
Apollo (Proxmox VE)
    │
    ├── VM 100: Athena
    │
    └── CT 101: Hestia
```

---

### Logical Topology

```text
Artemis (Admin Workstation)
        │
        ▼
Tailscale Network
        │
        ▼
Apollo (100.81.86.51)
        │
        ├── Athena (100.117.35.70)
        │
        └── Hestia (Internal Only)
```

---

### Complete Infrastructure Flow

```text
Artemis (Management Workstation)
Tailscale: 100.100.252.87
        │
        │ Encrypted WireGuard Tunnel
        ▼
Apollo (Proxmox Hypervisor)
LAN:       10.10.10.1
Tailscale: 100.81.86.51
        │
        ├──────────── vmbr0 ────────────┐
        │                               │
        ▼                               ▼
Athena (VM 100)                  Hestia (CT 101)
LAN: 10.10.10.10                 LAN: 10.10.10.2
TS:  100.117.35.70               Tailscale: None

Services:                         Services:
• Grafana                         • Homepage
• Prometheus                      • Vaultwarden
• Loki
• Grafana Alloy
• Portainer
• Olympus API
• Floci
```

---

## Network Inventory

| Node    | Type               | LAN Address   | Tailscale Address | Role                   |
| ------- | ------------------ | ------------- | ----------------- | ---------------------- |
| Artemis | Arch Linux Laptop  | Dynamic       | `100.100.252.87`  | Administration         |
| Apollo  | Proxmox Hypervisor | `10.10.10.1`  | `100.81.86.51`    | Compute and Routing    |
| Athena  | Ubuntu VM          | `10.10.10.10` | `100.117.35.70`   | Observability Platform |
| Hestia  | Alpine LXC         | `10.10.10.2`  | None              | Application Services   |

---

## Virtual Networking

Proxmox virtual networking is built on Linux bridges.

### Primary Bridge

```text
vmbr0
```

### Responsibilities

* VM Connectivity
* LXC Connectivity
* Internal Service Communication
* External Network Access

### Connected Systems

* Apollo
* Athena
* Hestia

---

## Remote Access Design

Remote administration is implemented using Tailscale.

### Connected Nodes

* Artemis
* Apollo
* Athena

### Benefits

* End-to-End Encryption
* Device Authentication
* WireGuard Transport
* No Public SSH Exposure
* Simplified Administration
* Reduced Attack Surface

---

## Security Model

### Default Posture

Private by Default.

### Characteristics

* No intentional Internet-facing services
* Internal service communication
* Tailscale-based administration
* Segmented application workloads
* Controlled access paths

---

### Hestia Isolation Strategy

Hestia intentionally does not participate in the Tailscale mesh.

This design protects sensitive services such as Vaultwarden by restricting access to trusted internal routes managed through Apollo.

Benefits include:

* Reduced exposure
* Limited attack surface
* Separation of administrative and user workloads

---

## NAT and Traffic Routing

Apollo serves as the network gateway between Tailscale and isolated internal workloads.

### Inbound Service Forwarding

Apollo forwards approved Tailscale traffic to Hestia.

#### Homepage

```bash
iptables -t nat -A PREROUTING \
    -d 100.81.86.51 \
    -p tcp --dport 3000 \
    -j DNAT --to-destination 10.10.10.2:3000

iptables -t nat -A POSTROUTING \
    -d 10.10.10.2 \
    -p tcp --dport 3000 \
    -j MASQUERADE
```

---

#### Vaultwarden

```bash
iptables -t nat -A PREROUTING \
    -d 100.81.86.51 \
    -p tcp --dport 8080 \
    -j DNAT --to-destination 10.10.10.2:8080

iptables -t nat -A POSTROUTING \
    -d 10.10.10.2 \
    -p tcp --dport 8080 \
    -j MASQUERADE
```

---

### Outbound NAT

Apollo provides Internet access for isolated internal workloads.

```bash
iptables -t nat -A POSTROUTING \
    -s 10.10.10.0/24 \
    -o wlx002e2df0393b \
    -j MASQUERADE
```

Purpose:

* API Access
* Package Downloads
* External Service Integration

---

## Metrics Traffic Flow

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

### Purpose

* Host Monitoring
* Capacity Planning
* Performance Visibility

---

## Logging Traffic Flow

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

### Purpose

* Centralized Logging
* Troubleshooting
* Historical Analysis
* Log Search

---

## Alerting Traffic Flow

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

### Purpose

* Incident Notification
* Infrastructure Awareness
* Service Monitoring

---

## Automation Traffic Flow

Homepage data is generated on Hestia and synchronized to Athena.

```text
Hestia Cron Jobs
        │
        ▼
Generate JSON Assets
        │
        ▼
Secure SCP Transfer
        │
        ▼
Athena Data Directory
        │
        ▼
Olympus Dashboard API
        │
        ▼
Homepage Widgets
```

### Characteristics

* SSH Transport
* Ed25519 Authentication
* Five-Minute Synchronization Interval

---

## Network Validation

The following checks are performed during routine validation.

### Connectivity Validation

```bash
ping <target>
```

Expected:

```text
Successful response
```

---

### Tailscale Validation

```bash
tailscale status
```

Expected:

```text
All nodes connected
```

---

### Bridge Validation

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

### NAT Validation

```bash
iptables -t nat -L -n -v
```

Expected:

```text
Required forwarding rules present
```

---

### Service Reachability

Verify access to:

* Grafana
* Prometheus
* Loki
* Homepage
* Vaultwarden

Expected:

```text
PASS
```

---

## Major Network Incident

### Proxmox Network Isolation Incident

#### Symptoms

* VM connectivity failures
* Internal communication failures
* Missing bridge connectivity

---

#### Investigation

Commands used:

```bash
brctl show
bridge link
cat /etc/network/interfaces
```

---

#### Root Cause

Incomplete bridge configuration prevented virtual interfaces from attaching correctly to `vmbr0`.

---

#### Resolution

Validated and rebuilt:

* vmbr0
* VM networking
* LXC networking

---

#### Verification

Confirmed:

* Host Communication
* VM Communication
* Container Communication
* Internet Connectivity

Infrastructure networking was successfully restored.

---

## Future Improvements

### Security

Planned improvements:

* Tailscale ACLs
* Device Tagging
* Access Segmentation

---

### Monitoring

Planned improvements:

* Network Latency Tracking
* Uptime Monitoring
* Service-Level Monitoring

---

### Hardware

Planned improvements:

* 5-meter CAT6 Ethernet Cable

Expected benefits:

* Lower Latency
* Improved Stability
* Consistent Throughput
* Reduced Wi-Fi Dependency

---

## Operational Status

| Component                  | Status      |
| -------------------------- | ----------- |
| vmbr0                      | Operational |
| Internal Networking        | Operational |
| VM Connectivity            | Operational |
| LXC Connectivity           | Operational |
| Tailscale                  | Operational |
| Remote Administration      | Operational |
| NAT Rules                  | Operational |
| Metrics Traffic            | Operational |
| Logging Traffic            | Operational |
| Alerting Traffic           | Operational |
| Automation Synchronization | Operational |

---

## Conclusion

The Olympus HomeLab network architecture provides secure, remotely accessible, and resilient connectivity through a private-by-default design. Tailscale enables encrypted administration without exposing management interfaces to the Internet, while Apollo enforces segmentation and controlled routing between workloads. This approach balances operational simplicity with strong security practices and supports future growth of the homelab environment.
