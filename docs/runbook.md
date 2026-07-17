# Operations Runbook

## Purpose

This runbook defines the standard operating procedures (SOPs) for managing, maintaining, validating, and recovering the Olympus HomeLab environment.

It serves as the operational reference for routine administration, preventative maintenance, infrastructure changes, and incident response.

---

# Infrastructure Overview

| Host | Purpose |
|------|---------|
| Apollo | Proxmox VE Hypervisor & Network Gateway |
| Athena | Operations, Observability & Kubernetes |
| Hestia | Frontend Application Services |
| Artemis | Management Workstation |

---

# Daily Health Checks

Perform these checks daily or after significant infrastructure changes.

| Check | Command / Method | Expected Result |
|--------|------------------|-----------------|
| Tailscale | `tailscale status` | Apollo and Athena connected |
| Compute | `qm list` / `pct list` | Athena and Hestia running |
| Internet Access | `curl -I https://google.com` (Athena) | HTTP 200/301 |
| Homepage | Open Homepage | Loads and service links resolve |
| Kubernetes | `kubectl get nodes` | Athena reports **Ready** |

---

# Service Verification

## Athena

Verify critical services are running:

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter
- Portainer
- Floci
- K3s

Check:

```bash
docker ps
```

---

## Hestia

Verify:

- Homepage
- Vaultwarden

Check:

```bash
docker ps
```

---

# Kubernetes Operations

Athena hosts a single-node K3s cluster used for experimentation.

## Administration

Management is performed from Artemis using `kubectl`.

Use Athena's LAN address (`10.10.10.10:6443`) in the kubeconfig to match the cluster certificate SANs.

## Namespace Policy

Deploy learning workloads inside:

```text
artemis-lab
```

Avoid deploying workloads into:

- default
- kube-system

---

## Common Commands

View cluster status:

```bash
kubectl get nodes
kubectl get pods -A
```

Scale a deployment:

```bash
kubectl scale deployment <deployment> \
-n artemis-lab \
--replicas=3
```

View services:

```bash
kubectl get svc -n artemis-lab
```

---

# Homepage Operations

Homepage runs in its **stock configuration** on Hestia — a static service-link dashboard with no custom widget, no backend API, and no fetch/cron pipeline to operate. There is nothing to refresh or troubleshoot beyond the container itself:

```bash
docker ps | grep homepage
docker logs homepage
```

The previous custom "Olympus" dashboard (FastAPI Dashboard API on Athena + `custom.js`/`custom.css` on Hestia + per-source cron jobs) was fully decommissioned. If any of `dashboard-api`, `olympus_update.sh`, or `/var/log/olympus_fetch.log` show up on a host, they're leftovers from before the removal and can be cleaned up — see `postmortems.md` for what was removed and why.

---

# Monitoring Operations

## Verify Prometheus

```bash
curl http://10.10.10.10:9090/-/ready
```

Expected:

```text
HTTP 200
```

---

## Verify Loki

```bash
curl http://10.10.10.10:3100/ready
```

Expected:

```text
HTTP 200
```

---

## Verify Grafana

Confirm:

- Dashboards load
- Prometheus datasource healthy
- Loki datasource healthy
- Alerts configured

---

## Verify Alerting

Send a test notification through Grafana Alerting.

Expected:

Telegram notification received.

---

# Infrastructure as Code

Terraform is the authoritative method for managing AWS-emulated infrastructure.

Working directory:

```text
~/homelab/infrastructure/terraform/
```

Recommended workflow:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Verify Floci resources before modifying state.

---

# Networking Operations

Apollo provides routing and NAT for the internal network.

After every Apollo reboot verify:

- IP forwarding enabled
- NAT rules present
- Internet connectivity restored
- Port forwarding operational

Useful commands:

```bash
sysctl net.ipv4.ip_forward
iptables -t nat -L -v -n
```

---

# Emergency Procedures

## Connectivity Ladder

Always troubleshoot in this order:

1. Ping Apollo (`10.10.10.1`)
2. Ping `8.8.8.8`
3. `curl -I https://google.com`
4. `tailscale status`
5. Verify LAN communication between nodes

Following this sequence isolates bridge, routing, DNS, internet, firewall, and Tailscale issues efficiently.

---

## Cold Start Procedure

If the entire lab is powered down:

1. Boot Apollo.
2. Verify `vmbr0`.
3. Verify NAT and forwarding.
4. Start Athena.
5. Start Hestia.
6. Verify Homepage.
7. Verify Vaultwarden.
8. Verify Kubernetes.
9. Verify monitoring stack.

---

# Health Checklist

## Infrastructure

- [ ] Apollo operational
- [ ] Athena operational
- [ ] Hestia operational
- [ ] Tailscale connected
- [ ] NAT functioning

## Observability

- [ ] Grafana
- [ ] Prometheus
- [ ] Loki
- [ ] Grafana Alloy
- [ ] Metrics collecting
- [ ] Logs collecting
- [ ] Alerting operational

## Applications

- [ ] Homepage available
- [ ] Vaultwarden available
- [ ] Homepage loads and service links resolve

## Kubernetes

- [ ] Cluster Ready
- [ ] Pods healthy
- [ ] Services reachable

## Infrastructure as Code

- [ ] Terraform validation successful
- [ ] Floci operational

---

# Useful Commands

System:

```bash
uptime
free -h
df -h
htop
```

Docker:

```bash
docker ps
docker logs <container>
docker compose ps
```

Kubernetes:

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
```

Networking:

```bash
tailscale status
ping
ip addr
iptables -t nat -L -v
```

---

# Related Documentation

- architecture.md
- network.md
- inventory.md
- troubleshooting.md
- disaster-recovery.md

---

# Current Status

**Environment:** Stable Operational Environment

The Olympus HomeLab is operating with validated networking, centralized observability, Kubernetes, Infrastructure as Code workflows, and secure remote administration. Routine operations, maintenance procedures, and recovery workflows are documented to support consistent day-to-day management.