# Docker Compose Stacks

> **V2 context:** Retained examples, diagrams or screenshots may describe the earlier deployment. See the [September 12 rebuild record](../../../docs/history/rebuild-history.md) for the current reported state: Hestia retired, K3s on Hermes, Athena observability-only, and Floci/Portainer removed from Athena. These assets have not been synchronized with the rebuilt hosts.

## Purpose

This directory contains Docker Compose stacks used throughout the HomeLab environment.

Services are organized into logical stacks to simplify deployment, maintenance, upgrades, and troubleshooting.

---

## Contents

### `core-services/`

User-facing applications hosted on Hestia.

Services include:

* Homepage
* Vaultwarden

### `telemetry/`

Observability and monitoring platform hosted on Athena.

Services include:

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter

### `localstack/`

Development and Infrastructure as Code testing environment.

Services include:

* LocalStack

---

## Usage

Navigate to the desired stack directory and deploy services:

```bash
docker compose up -d
```

Stop services:

```bash
docker compose down
```

View logs:

```bash
docker compose logs -f
```

---

## Dependencies

* Docker Engine
* Docker Compose Plugin
* Linux host with container support

---

## Maintenance

* Keep compose files version-controlled.
* Remove obsolete containers before major refactors.
* Review image versions regularly for updates and security patches.
* Update documentation whenever services are added or removed.

---

## Status

**Deployment Model:** Active

**Stack Organization:** Standardized

**Documentation Status:** Current
