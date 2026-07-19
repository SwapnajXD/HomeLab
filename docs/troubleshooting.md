# Troubleshooting Guide & Incident Log

## Purpose

This document serves as the operational knowledge base for the Olympus HomeLab.

It records significant incidents, root cause analyses (RCA), verified resolutions, and lessons learned to reduce future recovery time and improve infrastructure reliability.

---

# Incident Summary

| Incident | Severity | Status |
|----------|----------|--------|
| VM & LXC Autostart Failure | Medium | Resolved |
| Apollo NAT Gateway Failure | High | Resolved |
| Athena "Offline" Investigation | High | Resolved |
| K3s Pods Stuck in `ContainerCreating` | High | Resolved |
| Remote kubectl TLS Failure | Medium | Resolved |
| Namespace Visibility Confusion | Low | Resolved |
| Dashboard JSON Corruption *(archived — component removed)* | Medium | Resolved |
| Wallpaper 404 Errors *(archived — component removed)* | Low | Resolved |
| Cron Job Overlap *(archived — component removed)* | Low | Resolved |
| Vaultwarden HTTPS Mismatch | Low | Resolved |
| Grafana Alloy Incomplete Docker Log Discovery | Medium | **Resolved** (confirmed 2026-07-18) |
| Apollo Internet Outage (stale NAT interface) | High | **Resolved** (2026-07-18) |
| `nftables` Migration Question | Medium | **Resolved** — declined, stayed on `iptables` (2026-07-18) |
| Orphaned `core-services` Compose Project | Low | **Open** |
| `k3s.yaml` Permissions Reset on Restart | Low | **Open** (known, workaround exists) |
| Docker DNS Resolver Errors (`127.0.0.53`) | Low | **Open** (informational, not investigated) |

---

# Infrastructure Incidents

## VM & LXC Autostart Failure

### Symptoms

After reboot:

- Athena remained offline
- Hestia remained offline
- Core services unavailable

### Root Cause

Proxmox **Start at Boot** was disabled for:

- VM 100 (Athena)
- CT 101 (Hestia)

### Resolution

Enabled automatic startup for both workloads and validated recovery through reboot testing.

### Lessons Learned

Always verify autostart settings after provisioning new virtual workloads.

---

## K3s Pods Stuck in `ContainerCreating`

### Symptoms

Pods never progressed beyond:

```text
ContainerCreating
```

### Root Cause

Ubuntu was using legacy **cgroup v1**, which conflicted with modern K3s/containerd requirements.

### Resolution

Enabled cgroup v2 by updating GRUB:

```text
systemd.unified_cgroup_hierarchy=1
```

Rebooted Athena and verified normal pod scheduling.

### Lessons Learned

Modern Kubernetes distributions expect cgroup v2. Validate kernel configuration before deployment.

---

# Networking Incidents

## Apollo NAT Gateway Failure

**Severity:** High

### Symptoms

- No internet access from Athena or Hestia
- DNS failures
- Tailscale disconnected
- SSH unavailable
- External APIs unreachable

### Investigation

Confirmed:

- Internal networking operational
- `vmbr0` healthy
- Athena reachable from Apollo
- Failure occurred at the gateway

### Root Cause

Apollo relied on a temporary outbound MASQUERADE rule that disappeared after reboot.

### Resolution

Restored persistent NAT rules and documented verification procedures in the network architecture and operations runbook.

### Lessons Learned

Gateway configuration must persist across reboots. Always validate routing after maintenance.

---

## Athena "Offline" Investigation

### Symptoms

Athena appeared offline from Artemis.

- SSH unavailable
- Tailscale disconnected
- Dashboard unreachable

### Investigation

Local console access showed:

- VM healthy
- Internal networking functional
- External HTTPS requests failed

### Root Cause

Temporary upstream ISP outage.

Tailscale loss was a downstream symptom rather than the primary failure.

### Resolution

Created the **Connectivity Ladder** troubleshooting process to distinguish local failures from upstream connectivity issues.

### Lessons Learned

Always isolate local networking before investigating higher-level services.

---

## Vaultwarden HTTPS Mismatch

### Symptoms

Homepage worked correctly, but Vaultwarden returned:

```text
400 Bad Request
```

### Root Cause

HTTP requests were sent to a service configured for HTTPS only.

### Resolution

Access Vaultwarden using HTTPS.

Networking and port forwarding required no changes.

### Lessons Learned

Application-layer protocol mismatches can resemble network failures.

---

# Kubernetes Incidents

## Remote kubectl TLS Failure

### Symptoms

`kubectl` returned certificate validation errors from Artemis.

### Root Cause

The K3s API certificate SANs were issued for Athena's LAN IP rather than its Tailscale address.

### Resolution

Updated kubeconfig to connect using:

```text
10.10.10.10:6443
```

### Lessons Learned

Certificate SANs must match the endpoint used for cluster administration.

---

## Namespace Visibility Confusion

### Symptoms

Resources appeared missing when queried remotely.

### Root Cause

Workloads were deployed into `artemis-lab` while commands were executed in the default namespace.

### Resolution

Standardized all learning workloads inside:

```text
artemis-lab
```

Updated the default kubectl context.

### Lessons Learned

Use dedicated namespaces consistently during development.

---

# Dashboard Incidents (Archived — Component Removed)

> The Homepage/Dashboard API integration described in this section was **decommissioned from active deployment** (see `architecture.md`, `postmortems.md`) — the service isn't running, though its code is intentionally retained in the repository as a portfolio reference. These entries are kept for historical value — the fixes below no longer apply to anything currently deployed.

## JSON Corruption

### Symptoms

Homepage widgets displayed:

- Invalid JSON
- Missing media information

### Root Cause

Manual JSON generation failed when external data contained quotation marks.

### Resolution

Replaced manual string construction with `jq` for all JSON generation.

### Lessons Learned

Always use structured tools for serialization.

---

## Wallpaper 404 Errors

### Symptoms

Homepage hero images failed to load.

### Root Cause

Wallpaper URLs referenced the wrong GitHub branch.

### Resolution

Updated the image generation logic to reference the correct repository branch.

### Lessons Learned

Validate external asset paths after repository changes.

---

## Cron Job Overlap

### Symptoms

- Duplicate executions
- Log spam
- Race conditions
- Stale widget data

### Root Cause

Cron jobs could start before previous executions completed.

### Resolution

Added `flock` to all scheduled jobs to prevent concurrent execution.

### Lessons Learned

High-frequency automation should always include concurrency control.

---

# Resolved: Grafana Alloy — Incomplete Docker Log Discovery

**Status:** Resolved (opened 2026-07-05, confirmed resolved 2026-07-18)

### Original Symptoms

Only the `grafana` and `loki` containers appeared in Loki (`/label/container/values`). `prometheus`, `cadvisor`, `node-exporter`, `proxmox-exporter`, `portainer`, and `floci_aws` logs were never ingested, despite all of them running on the same Docker host.

### Investigation

- Confirmed the Docker socket (`/var/run/docker.sock`) was mounted into the Alloy container with correct permissions (`srw-rw----`).
- `ss -lx | grep docker` inside the Alloy container initially returned nothing, suggesting Alloy wasn't talking to the Docker daemon despite the mount.
- A later live check (`curl -s http://10.10.10.10:3100/loki/api/v1/label/container/values`) confirmed all 12 running containers across **both** Athena and Hestia are now being ingested: `alloy, cadvisor, glances, grafana, homepage, loki, node-exporter, portainer, portainer_agent, prometheus, proxmox-exporter, vaultwarden`.

### Resolution

The exact fix (config change vs. a subsequent Alloy container restart resolving discovery on its own) wasn't captured at the time it happened — the issue was simply found to be resolved during a routine live-infrastructure audit on 2026-07-18. If it recurs, the original investigation notes above are still the right starting point: check `discovery.docker`/`loki.source.docker` config and Docker socket connectivity from inside the Alloy container first.

Full write-up: `postmortems.md` (2026-07-05, resolution noted 2026-07-18).

---

# Resolved: Apollo Internet Outage — Stale NAT Interface Rule

**Status:** Resolved (2026-07-18)

### Symptoms

Athena could reach Apollo and the rest of the LAN (`ping 10.10.10.1` succeeded) but could not reach the internet (`ping 8.8.8.8` failed). DNS was not the issue; the default route was correctly configured.

### Root Cause

Apollo's outbound MASQUERADE rule was bound to `enx4a7f6c52f9f5` (a USB Ethernet adapter used during an earlier tethering session). After switching back to Wi-Fi (`wlx002e2df0393b`), the rule was never updated — so outbound packets were never actually NAT'd.

### Also Observed: SSH Access Broke

While testing NAT changes, SSH to Athena also stopped working. This was **not** a separate SSH issue — it was a side effect of NAT being in a broken state during active troubleshooting. It resolved on its own once NAT was fixed, with zero SSH-side changes.

### Fix

Re-added the MASQUERADE rule against the correct interface, then replaced the entire hardcoded-interface approach with a dynamic one — see "Resolved: nftables Migration Question" below.

### Lesson

A correct default route does not guarantee internet access — NAT must be bound to the interface that's actually carrying traffic, and that binding needs to survive uplink changes (Wi-Fi ↔ Ethernet ↔ USB tethering).

Full write-up: `postmortems.md` (2026-07-18).

---

# Resolved: `nftables` Migration Question

**Status:** Resolved — decision made, not migrating (2026-07-18)

### The Question

Since Proxmox 9 ships with `nftables`, should Apollo's firewall be migrated off `iptables`?

### Investigation

A test migration was attempted (`/etc/nftables.conf` written, loaded, tested against the working `iptables` setup). This surfaced that Apollo's `iptables` binary reports `iptables v1.8.11 (legacy)` — the **legacy** backend, which maintains a completely independent rule set from `nftables`. The whole time `nftables` rules were being tested, the actually-working NAT was still coming from `iptables`.

### Decision

**Stay on `iptables`.** Migrating would mean either running two disconnected firewalls simultaneously, or also migrating Tailscale's, Docker's, and K3s's self-managed `iptables` chains — well outside the scope of the actual bug (one stale interface name).

### What Shipped Instead

- `/usr/local/sbin/apollo-firewall.sh` — idempotent script handling outbound NAT (dynamic WAN detection), port forwarding, and hairpin NAT.
- `apollo-firewall.service` — `systemd` unit, runs once at boot after networking.
- `/etc/network/interfaces` cleaned up to only configure networking, no embedded firewall logic.
- Explicitly leaves Tailscale, Docker, and K3s/Flannel's own `iptables` rules untouched.

Full write-up: `postmortems.md` (2026-07-18).

---

# Current Open Incidents

## Orphaned `core-services` Compose Project

**Status:** Open (found 2026-07-18)

### Symptoms

The central Portainer container on Athena reports Compose project label `core-services`, but `docker compose -p core-services config` returns `no configuration file provided: not found` — no matching `docker-compose.yml` exists anywhere on Athena's filesystem.

### Impact

Low — Portainer itself is running fine. The risk is only realized if the container ever needs to be recreated: there's currently nothing on disk to recreate it from.

### Next Steps

Write a proper `docker-compose.yml` for Portainer (matching its current image/ports/volumes) and place it under `~/homelab/docker-compose/` so the project is reproducible again.

---

## `k3s.yaml` Permissions Reset on Restart

**Status:** Open (known, workaround exists)

### Symptoms

`kubectl` on Athena itself fails with a permission error against `/etc/rancher/k3s/k3s.yaml` unless `sudo` is used, even though this was previously worked around with `chmod 644`.

### Root Cause

K3s regenerates `k3s.yaml` with restrictive permissions on every service restart, silently undoing the earlier `chmod`.

### Workaround

Use `sudo kubectl` on Athena, or reapply `chmod 644 /etc/rancher/k3s/k3s.yaml` after any `k3s` restart. (Remote `kubectl` from Artemis is unaffected — it uses its own kubeconfig copy.)

### Next Steps

Automate the permission fix via a systemd drop-in or a small post-start script, rather than reapplying manually.

---

---

## Docker DNS Resolver Errors on Athena

**Status:** Open (informational, not investigated)

### Symptoms

Athena's `dockerd` journal shows recurring `[resolver] failed to query external DNS server` errors against `127.0.0.53` (the local `systemd-resolved` stub).

### Impact

Unknown — not currently linked to any observed service failure. Noted here so it's tracked rather than lost in journal noise.

### Next Steps

Investigate `dockerd`'s embedded DNS resolver configuration and `systemd-resolved` interaction if it starts correlating with real issues (e.g., container name resolution failures).

---

# Operational Lessons

## Persistence Matters

Critical infrastructure settings—including NAT rules, VM autostart, and forwarding—must survive reboots.

---

## Validate External Data

Always use structured tools such as `jq` when processing API responses to prevent malformed data.

---

## Isolate Before Escalating

Follow the Connectivity Ladder:

1. Gateway
2. Internet
3. DNS / HTTPS
4. Tailscale
5. Internal communication

This prevents unnecessary investigation of unrelated systems.

---

## Separate Infrastructure Layers

Many failures initially appeared to be networking problems but originated at different layers:

- ISP connectivity
- TLS certificates
- HTTP vs HTTPS
- Kubernetes namespaces

Identifying the affected layer dramatically reduces troubleshooting time.

---

## Test Recovery Regularly

Recovery procedures should be validated through controlled reboot and failover testing rather than assumed to work.

---

# Current Status

| Item | Status |
|------|--------|
| Incident Knowledge Base | Current — last verified against live systems 2026-07-18 |
| Recovery Procedures | Verified |
| Operational Documentation | Current |
| Infrastructure Stability | Stable |
| Open Incidents | 3 (all low severity — see "Current Open Incidents" above) |

**Environment State:** Stable Operational Environment