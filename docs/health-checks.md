# Health Checks

## Verify Tailscale Connectivity

```bash
tailscale status
```

Expected:

* Apollo reachable
* Athena reachable

---

## Verify Docker Containers

```bash
docker ps
```

Expected:

* Grafana
* Prometheus
* Loki
* Promtail
* LocalStack
* Portainer

All running.

---

## Verify Prometheus

```bash
curl http://localhost:9090/-/healthy
```

Expected:

```text
Prometheus is Healthy
```

---

## Verify Grafana

```bash
curl http://localhost:3000/api/health
```

Expected:

```json
{
  "database":"ok"
}
```

---

## Verify Loki

```bash
curl http://localhost:3100/ready
```

Expected:

```text
ready
```

---

## Verify LocalStack

```bash
curl http://localhost:4566
```

Expected:

```text
HTTP/1.1 200 OK
```

---

## Verify Terraform

```bash
terraform plan
```

Expected:

```text
No changes.
Infrastructure matches configuration.
```

---

## Verify Prometheus Targets

Navigate to:

```text
http://ATHENA-IP:9090/targets
```

Expected:

All configured targets report:

```text
UP
```

---

## Verify Grafana Dashboards

Navigate to:

```text
http://ATHENA-IP:3001
```

Expected:

* Dashboards load successfully
* Metrics are updating
* Loki queries return logs

---

## Verify Homepage

Navigate to:

```text
http://HESTIA-IP
```

Expected:

* Homepage loads
* Service links are accessible
* Monitoring widgets update correctly
