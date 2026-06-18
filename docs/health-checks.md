# Health Checks

## Purpose

This document provides a standardized set of health verification procedures to confirm the operational status of the HomeLab environment.

These checks should be performed after maintenance activities, infrastructure changes, incident recovery, or as part of routine operational validation.

---

# Infrastructure Health

## Verify Tailscale Connectivity

Execute from Artemis:

```bash
tailscale status
```

### Expected

* Apollo reachable
* Athena reachable
* Nodes report active Tailnet connections

---

## Verify Apollo Reachability

```bash
ping -c 4 apollo
```

### Expected

```text
0% packet loss
```

---

## Verify Guest Compute Status

Execute on Apollo:

```bash
qm status 100
pct status 101
```

### Expected

```text
status: running
```

for both:

* Athena (VM 100)
* Hestia (LXC 101)

---

# Container Runtime Health

## Verify Docker Containers

Execute on Athena and Hestia:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Expected Containers

### Athena

* grafana
* prometheus
* loki
* grafana-alloy
* portainer
* floci_aws
* dashboard-api

### Hestia

* homepage
* vaultwarden

### Expected

All containers report healthy or running status.

---

# Observability Health

## Verify Prometheus

```bash
curl -I http://localhost:9090/-/healthy
```

### Expected

```text
HTTP/1.1 200 OK
```

and:

```text
Prometheus is Healthy
```

---

## Verify Prometheus Targets

```bash
curl -s http://localhost:9090/api/v1/targets \
| jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

### Expected

All targets report:

```text
"health": "up"
```

Including:

* node-exporter
* proxmox-exporter
* prometheus

---

## Verify Grafana

```bash
curl http://localhost:3001/api/health
```

### Expected

```json
{
  "database":"ok"
}
```

---

## Verify Loki

```bash
curl -I http://localhost:3100/ready
```

### Expected

```text
HTTP/1.1 200 OK
```

or

```text
ready
```

---

## Verify Grafana Alloy

```bash
docker logs --tail 50 grafana-alloy
```

### Expected

* Docker discovery active
* No persistent errors
* Successful log forwarding to Loki

---

# Logging Pipeline Health

## Verify Loki Labels

```bash
curl -s http://localhost:3100/loki/api/v1/labels
```

### Expected

Valid JSON response containing labels.

---

## Verify Log Visibility

Open Grafana Explore and query:

```text
{container="vaultwarden"}
```

### Expected

Container logs appear continuously.

---

# Dashboard & Application Health

## Verify Homepage

```bash
curl -I http://100.81.86.51:3000
```

### Expected

```text
HTTP/1.1 200 OK
```

Homepage loads and widgets render correctly.

---

## Verify Vaultwarden

```bash
curl -I http://100.81.86.51:8080
```

### Expected

```text
HTTP/1.1 200 OK
```

or

```text
HTTP/1.1 302 Found
```

Vaultwarden login page is reachable.

---

# Dashboard API & Synchronization Health

## Verify Dashboard API

```bash
curl -s http://localhost:8000/prices | jq .
```

### Expected

Valid JSON response containing synchronized dashboard data.

---

## Verify Inter-Node SSH Synchronization

Execute from Athena:

```bash
ssh -o BatchMode=yes root@10.10.10.2 "echo 'SSH OK'"
```

### Expected

```text
SSH OK
```

Passwordless authentication succeeds.

---

# Local Cloud & IaC Health

## Verify Floci

```bash
curl -I http://localhost:4566
```

### Expected

```text
HTTP/1.1 200 OK
```

Floci responds successfully.

---

## Verify Terraform

Execute from:

```text
~/homelab/terraform/localstack/
```

```bash
terraform plan
```

### Expected

```text
No changes.
Infrastructure matches the configuration.
```

---

# Health Verification Checklist

## Infrastructure

* [ ] Tailscale operational
* [ ] Apollo reachable
* [ ] Athena running
* [ ] Hestia running

## Containers

* [ ] Athena containers healthy
* [ ] Hestia containers healthy

## Observability

* [ ] Prometheus healthy
* [ ] Prometheus targets UP
* [ ] Grafana healthy
* [ ] Loki healthy
* [ ] Grafana Alloy operational
* [ ] Logs visible in Grafana

## Applications

* [ ] Homepage accessible
* [ ] Vaultwarden accessible
* [ ] Dashboard API responding
* [ ] Inter-node synchronization functional

## Development

* [ ] Floci operational
* [ ] Terraform plan clean

---

## Current Health Status

When all checks pass:

```text
ENVIRONMENT STATUS: HEALTHY
```
