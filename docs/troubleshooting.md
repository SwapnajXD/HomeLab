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
| Grafana Alloy Incomplete Docker Log Discovery | Medium | **Open** |

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

> The Homepage/Dashboard API integration described in this section was **fully decommissioned** (see `architecture.md`, `postmortems.md`). These entries are kept for historical/portfolio value — the fixes below no longer apply to anything currently running, since the components themselves are gone.

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

# Current Open Incidents

## Grafana Alloy — Incomplete Docker Log Discovery

**Status:** Open (since 2026-07-05)

### Symptoms

Only the `grafana` and `loki` containers appear in Loki (`/label/container/values`). `prometheus`, `cadvisor`, `node-exporter`, `proxmox-exporter`, `portainer`, and `floci_aws` logs are never ingested, despite all of them running on the same Docker host.

### Investigation So Far

- Confirmed the Docker socket (`/var/run/docker.sock`) is mounted into the Alloy container with correct permissions (`srw-rw----`).
- `ss -lx | grep docker` inside the Alloy container returned nothing, suggesting Alloy isn't actually talking to the Docker daemon despite the mount.
- Attempts to inspect Alloy's live `discovery.docker` / `loki.source.docker` configuration were inconclusive — output was too large to work through in one session.

### Suspected Root Cause (unconfirmed)

Either the `discovery.docker` component isn't finding all containers, `loki.source.docker` is only subscribed to two of them, or Alloy cannot fully reach the Docker daemon.

### Next Steps

1. Dump and review Alloy's live `discovery.docker` and `loki.source.docker` component config.
2. Test Docker API connectivity from inside the Alloy container directly (`curl --unix-socket /var/run/docker.sock http://localhost/containers/json`).
3. Review Alloy's own logs for Docker-related discovery errors.

Full write-up: `postmortems.md` (2026-07-05).

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
| Incident Knowledge Base | Current |
| Recovery Procedures | Verified |
| Operational Documentation | Current |
| Infrastructure Stability | Stable |
| Open Incidents | 1 (Grafana Alloy Docker log discovery) |

**Environment State:** Stable Operational Environment