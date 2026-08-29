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
- Grafana Alloy (Athena + Hestia)
- Node Exporter (Athena + Hestia)
- Proxmox Exporter
- cAdvisor
- Glances
- Portainer
- Floci (only if started on-demand for AWS work)
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

Athena hosts a single-node K3s cluster used for experimentation. No Ingress controller (Traefik) is currently deployed — NodePort services are used to expose test workloads.

## Administration

Management is performed from Artemis using `kubectl`.

Use Athena's LAN address (`10.10.10.10:6443`) in the kubeconfig to match the cluster certificate SANs.

> **Local `kubectl` on Athena itself** requires `sudo` — K3s regenerates `/etc/rancher/k3s/k3s.yaml` with restrictive permissions on every service restart, so a one-time `chmod 644` doesn't stick. Remote `kubectl` from Artemis is unaffected.

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

Homepage runs in a **stock-plus-lightweight-theme configuration** on Hestia — native service-discovery widgets, a purely visual `custom.css` (rounded cards, hover animation, header subtitle — no data logic), and an empty `custom.js`. There is no backend API or fetch/cron pipeline to operate day-to-day:

```bash
docker ps | grep homepage
docker logs homepage
```

The previous custom "Olympus" data widget (FastAPI Dashboard API on Athena + widget logic in `custom.js` on Hestia + per-source cron jobs) was decommissioned from active deployment on 2026-07-10. **This was a deliberate decision to keep the source code in the repository** — `docker-compose/dashboard-api/` and `scripts/fetch_*.sh` are intentionally retained as a portfolio artifact, not stray leftovers to clean up. If you ever want to actually remove them from the repo entirely, that's a separate, explicit decision — don't delete them by default just because they're not running. See `postmortems.md` for what was decommissioned and why.

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

Apollo provides routing and NAT for the internal network via a dedicated firewall script (`/usr/local/sbin/apollo-firewall.sh`), managed by `apollo-firewall.service`, run at boot after `network-online.target`. The script retries its route lookup for up to 30 seconds before failing, and `systemd` will additionally retry the whole service every 10 seconds on failure (`Restart=on-failure`, `RestartSec=10s`) — this hardening was added after the service failed on boot twice (2026-07-26/27, 2026-07-31) due to Wi-Fi association completing later than systemd's networking-ready signal.

After every Apollo reboot verify:

- `systemctl status apollo-firewall.service` reports `active (exited)` — if it's still starting/retrying, give it up to ~30 seconds before assuming a problem
- IP forwarding enabled
- NAT rules present, bound to the actual current WAN interface (detected dynamically, not hardcoded)
- Internet connectivity restored
- Port forwarding operational (both external and hairpin/LAN access)

If NAT ever looks wrong, the script is safe to re-run manually — it checks for existing rules before adding them:

```bash
sudo /usr/local/sbin/apollo-firewall.sh
```

Useful commands:

```bash
sysctl net.ipv4.ip_forward
systemctl status apollo-firewall.service
journalctl -u apollo-firewall.service -b   # check retry attempts on the most recent boot
iptables -t nat -L -v -n
ip route   # confirms which interface is the actual WAN uplink
```

> Apollo runs `iptables` (legacy backend) intentionally — a migration to `nftables` was evaluated and declined since Tailscale, Docker, and K3s all manage their own independent `iptables` chains. See `network.md` and `postmortems.md` (2026-07-18, 2026-07-26→31).

> **SSH access note:** Apollo is not a Tailscale subnet router — SSH to Athena over Tailscale must use Athena's own Tailscale IP directly, or ProxyJump through Apollo's Tailscale IP, not Athena's LAN IP.

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
- postmortems.md

---

# Current Status

**Environment:** Stable Operational Environment

The Olympus HomeLab is operating with validated networking, centralized observability, Kubernetes, Infrastructure as Code workflows, and secure remote administration. Routine operations, maintenance procedures, and recovery workflows are documented to support consistent day-to-day management.