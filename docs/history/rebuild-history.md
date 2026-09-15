# Olympus HomeLab V2

## Infrastructure rebuild, challenges, solutions and current state

**Recorded baseline: 2026-09-12.** This implementation/history document records the operator-supplied rebuild report for future maintenance and troubleshooting. Versions, health results and capacity figures below are reported observations from that rebuild, not a live audit performed by this documentation update. Commands describe completed work; destructive commands are historical records, not a procedure to replay.

## 1. Overview

V2 focuses on Cloud/DevOps learning, infrastructure management, Kubernetes, observability, networking, virtualization, backup/recovery, security and reproducibility. Responsibilities are separated between infrastructure, observability and applications.

```text
                       APOLLO — Proxmox VE
                                 |
                    +------------+------------+
                    |                         |
              ATHENA — VM 100           HERMES — VM 101
              Observability             Single-node K3s
                    |
          Prometheus / Grafana / Loki
                    |
              Alloy / Exporters

ARTEMIS — management workstation — Tailscale / SSH / kubectl / Git
```

Artemis management access is already in use. A Raspberry Pi is an optional future ARM/edge/IoT experiment, outside the current core architecture.

## 2. Apollo responsibility boundary

Apollo owns Proxmox VE, VMs, virtual networking, storage, routing/NAT, firewalling, VM backups and infrastructure management. Application workloads belong on guests unless there is a specific infrastructure reason.

## 3. Apollo baseline

| Item | Recorded value |
|---|---|
| Platform | Proxmox VE 9.2.2; Debian GNU/Linux 13 (trixie) |
| Kernel | `7.0.2-6-pve` |
| CPU | AMD Ryzen 7 3700X, 8 cores / 16 threads |
| Memory | 16 GiB |
| NVMe | Approximately 238.5 GB; EFI, root, swap, `local-lvm` thin pool |
| SATA | Approximately 232.9 GB, mounted at `/mnt/pve/Storage`; persistent backup storage |
| Proxmox storage | `local`, `local-lvm`, `Storage` |

## 4. Apollo networking

| Interface / node | Address / purpose |
|---|---|
| Wi-Fi `wlx002e2df0393b` | `192.168.1.20/24`, gateway `192.168.1.1` |
| Ethernet `nic0` | Currently unused |
| Bridge `vmbr0` | `10.10.10.1/24`, `bridge-ports none` |
| VM network | `10.10.10.0/24` |
| Athena | `10.10.10.x` in the supplied report; exact LAN address unconfirmed |
| Hermes | `10.10.10.11` |

Apollo routes traffic for the private VM bridge. Earlier documents list Athena as `10.10.10.10`; the rebuild report does not reconfirm that address.

## 5. Apollo routing and NAT

IPv4 forwarding is enabled. `/usr/local/sbin/apollo-firewall.sh`, run by `apollo-firewall.service`, provides outbound MASQUERADE for `10.10.10.0/24` through the detected default-route interface. The recorded WAN is Wi-Fi.

```text
10.10.10.0/24 → MASQUERADE → wlx002e2df0393b → 192.168.1.1 → Internet
```

## 6. Firewall startup challenge

The WAN/default route may not exist when systemd starts the service. The script discovers it using:

```bash
ip route | awk '/^default/ {print $5; exit}'
```

It retries up to 15 attempts with two seconds between attempts, removes existing duplicate MASQUERADE rules and creates:

```text
-A POSTROUTING -s 10.10.10.0/24 -o <detected WAN interface> -j MASQUERADE
```

Reported checks confirmed Apollo Internet access, VM-network access, forwarding and the expected NAT rule. Detection occurs when the script runs; this record does not establish continuous route-change monitoring.

## 7. Hestia V1 retirement

Hestia was CT 101: Alpine personal services, hostname `hestia`, 512 MB RAM, 1 CPU, 8 GB disk, `10.10.10.2`, gateway `10.10.10.1`. Its September backup was retained and tested before destruction:

```bash
zstd -t /mnt/pve/Storage/dump/vzdump-lxc-101-2026_09_01-00_01_38.tar.zst
```

The archive passed. The recorded retirement commands were `pct shutdown 101` and `pct destroy 101`. A stale temporary configuration was removed. `/etc/pve/lxc/` was empty afterward; no containers remained on Apollo. ID 101 was subsequently reused for the Hermes VM. Do not reuse the old CT commands against the current inventory.

## 8. V1 backup preservation

Apollo's retained configuration material is under `/root/olympus-v1-backup/`, with compressed archive `/root/olympus-v1-backup.tar.gz`. The report lists:

```text
apollo-firewall.service       apollo-firewall.service.d/
apollo-firewall.sh            fstab
hosts                        interfaces
iptables-save.txt            nft-ruleset.txt
pct-101.conf                 qm-100.conf
storage.cfg                  k3s/
docker/                      portainer-volume.tar.gz
vault.crt                    vault.key
```

Athena-local K3s, Docker and Portainer backups are also recorded under Athena's `/root/olympus-v1-backup/` in sections 24, 41 and 47. The same absolute path on different hosts is not the same directory; consolidation of all guest archives into Apollo's compressed archive is not established. Preserve the Vaultwarden certificate and private key without committing their contents to Git.

## 9. Hermes creation

Hermes is VM 101 with 4 GiB RAM, 4 vCPU, 32 GiB disk, Q35, VirtIO networking, VirtIO SCSI and QEMU Guest Agent enabled.

```bash
qm create 101 \
  --name hermes \
  --memory 4096 \
  --cores 4 \
  --sockets 1 \
  --cpu x86-64-v2-AES \
  --machine q35 \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --net0 virtio,bridge=vmbr0 \
  --agent enabled=1 \
  --onboot 1 \
  --startup up=60
```

Disk: `local-lvm:vm-101-disk-0`.

## 10. VM creation option challenge

The initial invocation returned `Unknown option: iothread` and `Unknown option: discard`. Those options were removed from that invocation; the disk was successfully created with:

```bash
qm set 101 --scsi0 local-lvm:32
```

This records an invocation error, rather than establishing that those disk properties are unsupported in every Proxmox configuration context.

## 11. Installation ISO boot issue

The attached `ubuntu-24.04.5-live-server-amd64.iso` remained preferred after installation, returning Hermes to the installer. On Apollo:

```bash
qm set 101 --boot order=scsi0
qm set 101 --delete ide2
```

Hermes then booted from its installed disk.

## 12. Hermes operating system and static network

Recorded OS: Ubuntu Server 24.04.5 LTS. `/etc/netplan/01-hermes.yaml` has restricted permissions and contains:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp6s18:
      dhcp4: false
      addresses:
        - 10.10.10.11/24
      routes:
        - to: default
          via: 10.10.10.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

## 13. Network service failed-state issue

`systemd-networkd-wait-online.service` showed failed even though the static IP, gateway, Internet access and DNS worked. After confirming connectivity:

```bash
sudo systemctl reset-failed systemd-networkd-wait-online.service
systemctl --failed
```

Result: `0 loaded units listed.` Resetting the recorded state did not establish a fix for any possible future boot-time wait failure.

## 14. Hermes disk expansion

Ubuntu's logical volume initially used about half of the 32 GB virtual disk, leaving approximately 15 GB free in its volume group.

```bash
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

Root grew to approximately 30 GB, with approximately 23 GB available. This expanded the guest LV/filesystem within the existing virtual disk.

## 15. K3s installation

Recorded installation command on Hermes:

```bash
curl -sfL https://get.k3s.io | sh -s - server
```

Recorded version: `v1.36.4+k3s1`; runtime: `containerd://2.3.4-k3s1.36`. The unpinned installer command is historical and does not guarantee those versions on a future run.

```text
NAME     STATUS   ROLES           VERSION        INTERNAL-IP
hermes   Ready    control-plane   v1.36.4+k3s1   10.10.10.11
```

## 16. Single-node architecture decision

Use single-node K3s for learning deployment, networking, storage, observability, CI/CD and experiments. Multiple nodes add complexity beyond the current learning needs. A Raspberry Pi may later support ARM, edge, IoT or Kubernetes experiments; it is not currently a cluster member.

## 17. K3s system components

CoreDNS, Traefik, Local Path Provisioner, Metrics Server and ServiceLB were deployed by K3s. `coredns`, `local-path-provisioner`, `metrics-server`, `traefik` and `svclb-traefik` pods were reported Running; installation jobs completed. Application ingress configuration remains pending despite Traefik being installed.

## 18. API access from Artemis

Hermes's kubeconfig was copied to Artemis at `~/.kube/hermes.yaml`. Its local-only endpoint `https://127.0.0.1:6443` was changed to `https://100.91.200.31:6443`, Hermes's Tailscale address.

## 19. TLS SAN challenge

The API certificate included addresses such as `10.10.10.11`, `10.43.0.1`, `127.0.0.1` and `::1`, but initially excluded the Tailscale address. On Hermes, `/etc/rancher/k3s/config.yaml` was updated with:

```yaml
tls-san:
  - 100.91.200.31
```

After `sudo systemctl restart k3s`, the cluster remained healthy and this succeeded from Artemis:

```bash
kubectl --kubeconfig ~/.kube/hermes.yaml get nodes
```

## 20. Kubeconfig cleanup

Old EKS and local-lab contexts were removed. The recorded EKS context was `arn:aws:eks:ap-south-1:427827266164:cluster/probes-cluster`; the old local context was `default`. Hermes became the primary configuration:

```bash
cp ~/.kube/hermes.yaml ~/.kube/config
chmod 600 ~/.kube/config
```

The resulting context was reported as `hermes`. Deleting an EKS kubeconfig context only removes local access configuration; it does not delete the EKS cluster. The record does not provide the context-renaming command.

## 21. Tailscale management

| Node | Tailscale address |
|---|---|
| Apollo | `100.81.86.51` |
| Hermes | `100.91.200.31` |
| Athena | `100.117.35.70` |
| Artemis | `100.100.252.87` |

Artemis uses private management connectivity without directly exposing management services to the public Internet.

## 22. Athena role and baseline

Athena is observability VM 100: 4 GiB RAM, 4 vCPU, 32 GB disk, Ubuntu 20.04.6 LTS, kernel `5.4.0-216-generic`. Its telemetry stack runs through Docker Compose.

## 23. Athena V1 cleanup

Removed Portainer, Floci UI/API and EC2 components, old Floci components, networks, images, K3s, obsolete Promtail configuration, LocalStack-related infrastructure and old scripts. Athena is now observability-only. No Floci deployment on Hermes is established by this report.

## 24. Athena K3s removal

Athena's `/etc/rancher/k3s` and `/etc/systemd/system/k3s.service` were backed up under `/root/olympus-v1-backup/k3s/` before:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```

The service became inactive; the binary, processes and listening ports were gone. `/etc/rancher/node/password` was intentionally retained.

## 25. Athena Docker stack

All eight containers were running: `prometheus`, `grafana`, `loki`, `alloy`, `node-exporter`, `cadvisor`, `proxmox-exporter`, `glances`.

## 26. Prometheus

Configuration: `~/homelab/docker-compose/telemetry/prometheus/prometheus.yml` on Athena.

| Job | Reported target / instance | Status |
|---|---|---|
| cadvisor | `cadvisor:8080` | up |
| node | `node-exporter:9100` | up |
| probes | `probes-794f.onrender.com` | up |
| prometheus | `localhost:9090` | up |
| proxmox | `100.81.86.51` | up |

Coverage includes Prometheus itself, Athena host/container metrics, Apollo/Proxmox and external probes. Hermes integration is pending.

## 27. Historical Hestia target challenge

The old series `node 10.10.10.2:9100 0` appeared after Hestia retirement. The stale configuration entry was removed from `prometheus.yml`, Prometheus was recreated and `/api/v1/targets` confirmed no active Hestia target. Historical time series can outlive target removal; no manual data deletion was needed.

## 28. Prometheus alert-rules mount challenge

Validation failed because `/etc/prometheus/alert.rules.yml` was referenced but not mounted. The Compose mount was added:

```yaml
- ./prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml:ro
```

After recreation, validation reported one rule file, a valid `prometheus.yml` and one rule. Readiness returned `Prometheus Server is Ready.`

## 29. Loki

Loki `3.0.0` uses persistent volume `telemetry_loki_data`. Configuration: `~/homelab/docker-compose/telemetry/loki/loki-config.yaml` on Athena.

## 30. Loki retention configuration

Seven-day retention was configured:

```yaml
limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  retention_period: 168h
  creation_grace_period: 10m

compactor:
  working_directory: /loki/compactor
  compaction_interval: 10m
  retention_enabled: true
  delete_request_store: filesystem
  retention_delete_delay: 2h
```

## 31. Retention validation

To control disk growth, the old configuration was saved as `loki-config.yaml.before-retention`. Before recreating Loki:

```bash
docker run --rm \
  -v /home/ubuntu/homelab/docker-compose/telemetry/loki/loki-config.yaml:/etc/loki/config.yaml:ro \
  grafana/loki:3.0.0 \
  -config.file=/etc/loki/config.yaml \
  -verify-config=true
```

Result: `config is valid`.

## 32. Loki startup delay

Loki initially returned `Ingester not ready: waiting for 15s after being ready`, then `ready`. The compactor joined and became active; logs included `waiting 10m0s for ring to stay stable`. These were reported startup stabilization messages, not a configuration failure.

## 33. Loki ingestion verification

```bash
curl -sG 'http://localhost:3100/loki/api/v1/query' \
  --data-urlencode 'query={host="athena"}' \
  --data-urlencode 'limit=5'
```

Fresh Grafana logs were returned, confirming Docker → Alloy → Loki → query API for that sample. This check does not establish complete log coverage for every container.

## 34. Grafana

Internal exposure: Athena port `3001` maps to container port `3000`. `curl -s http://localhost:3001/api/health` returned:

```json
{
  "database": "ok",
  "version": "13.0.1+security-01",
  "commit": "9bbe672d"
}
```

## 35. Alloy

Alloy discovers Docker containers through the read-only mount of `/var/run/docker.sock`, adds `container`, `image` and `host` labels, and forwards logs to Loki for Grafana queries.

## 36. cAdvisor

Version `v0.49.1`; container reported healthy; Prometheus target `cadvisor:8080` was up.

## 37. Node Exporter

Target `node-exporter:9100` was up, providing Athena CPU, memory, filesystem, network and other Linux host metrics.

## 38. Proxmox Exporter

Image: `prompve/prometheus-pve-exporter`; exporter port `9221`. Apollo's Tailscale address `100.81.86.51` is the monitored Proxmox target/instance. The exporter queries Apollo and exposes metrics to Prometheus; the target label alone is not the exporter's scrape URL. The reported Proxmox target was up.

## 39. Glances

Glances uses `pid: host` and `network_mode: host`. Port `61208/tcp` was investigated and confirmed to belong to the intended Glances process, so it was retained.

## 40. Docker log growth

An old Loki container JSON log had grown to approximately 1.2 GB. Athena's `/etc/docker/daemon.json` was configured with:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Validation:

```bash
sudo dockerd --validate --config-file=/etc/docker/daemon.json
```

Result: `configuration OK`. Telemetry containers were recreated and verified to use `json-file`, `max-size=10m`, `max-file=3`.

## 41. Docker TCP 2375 closure

Athena previously exposed the unauthenticated Docker API at `tcp://0.0.0.0:2375`. The old systemd override was saved at `/root/olympus-v1-backup/docker/override.conf` on Athena. Its replacement was:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd \
  -H fd:// \
  --containerd=/run/containerd/containerd.sock
```

After systemd reload and Docker restart, listening-port inspection confirmed `2375 not listening`.

## 42. Athena disk use before cleanup

Root was approximately 30 GB total, 18 GB used, 64% used. Large consumers included Docker (approximately 12 GB), journal data (approximately 2.2 GB) and the old Loki Docker log (approximately 1.2 GB). These categories overlap; the Loki log is part of Docker usage.

## 43. Historical journal cleanup

The operator authorized deleting old journal data during the rebuild. Journals were rotated and vacuumed using `sudo journalctl --rotate` and `sudo journalctl --vacuum-time=1s`. Remaining files under `/var/log/journal/` were cleared while `systemd-journald` was stopped, then the service was restarted. Final usage was 8.0 MB. This deletion is recorded as history, not a recurring maintenance instruction.

## 44. Persistent journald limits

Athena's `/etc/systemd/journald.conf.d/99-olympus.conf`:

```ini
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=50M
MaxRetentionSec=7day
```

Journald was restarted and reported active.

## 45. Docker resources after cleanup

Eight containers, eight images and three active volumes remained.

```text
nicolargo/glances:latest-full
grafana/alloy:latest
prom/prometheus:latest
prompve/prometheus-pve-exporter:latest
grafana/grafana-oss:latest
prom/node-exporter:latest
grafana/loki:3.0.0
gcr.io/cadvisor/cadvisor:v0.49.1
```

Volumes: `telemetry_grafana_data`, `telemetry_loki_data`, `telemetry_prometheus_data`.

Networks: `bridge`, `host`, `none`, `telemetry_telemetry-net`. Old V1 networks were removed. Mutable image tags record the configuration at the time, not reproducible version pins.

## 46. Build cache retained

Approximately 558.5 MB of reclaimable Docker build cache was intentionally retained because its removal provided little benefit during continuing development. Cleanup remains optional if disk pressure returns.

## 47. Portainer data preservation

On Athena, before removal:

```bash
sudo tar -C /var/lib/docker/volumes \
  -czf /root/olympus-v1-backup/portainer-volume.tar.gz \
  core-services_portainer_data
```

The archive was inspected and verified before `docker volume rm core-services_portainer_data`. Principle: back up first, verify second, delete last.

## 48. Athena final disk state

Approximately 30 GB total, 12 GB used, 17 GB available, 40% used, compared with approximately 64% before cleanup.

## 49. Athena final memory state

Approximately 3.8 GiB total, 1 GiB used, 2.6 GiB available. Swap: 2 GiB total, approximately 10 MiB used. The recorded workload had memory headroom.

## 50. Athena health checks

All eight containers were running. Systemd reported zero failed units. Prometheus was ready; Grafana database health was `ok`; Loki was `ready`; all five listed Prometheus targets were up. Docker TCP 2375 was not listening. Loki retention was `168h`. These are the reported rebuild checks.

## 51. Athena package update

`sudo apt update` offered three normal upgrades: `python3-update-manager`, `update-manager-core` and `tailscale`. All were upgraded successfully; Tailscale changed from `1.102.2` to `1.102.4`. Ubuntu remained 20.04.6 LTS and kernel `5.4.0-216-generic`. No reboot was required. Systemd again reported zero failed units and all eight Docker containers remained running.

## 52. Ubuntu support consideration

APT reported additional security updates requiring Ubuntu Pro / ESM. The operator deferred Athena's Ubuntu 20.04 → 24.04 migration so it could be planned and tested separately from the infrastructure rebuild. The supplied account reports both a post-backup package update and a final baseline backup; exact ordering of the package update relative to the named archive is not independently established here.

## 53. Athena V2 backup

An initial `vzdump 100` attempt inside Athena returned `Command 'vzdump' not found`. `vzdump` belongs on Apollo, where the successful command was:

```bash
vzdump 100 \
  --storage Storage \
  --mode snapshot \
  --compress zstd \
  --notes-template "Olympus HomeLab V2 - Athena observability baseline"
```

Completed archive: `/mnt/pve/Storage/dump/vzdump-qemu-100-2026_09_12-18_35_13.vma.zst`, approximately 7.8 GB.

## 54. Backup integrity verification

On Apollo:

```bash
zstd -t /mnt/pve/Storage/dump/vzdump-qemu-100-2026_09_12-18_35_13.vma.zst
```

Reported output: `28462859776 bytes`, with no error. The compressed stream passed Zstandard integrity testing. Retain this as the Athena V2 baseline recovery archive. A full VM restore/boot/application recovery test is still pending; compressed-stream integrity alone does not prove recoverability.

## 55. Lessons learned

- Run `vzdump`, `qm` and `pct` on Apollo; run guest Linux/Docker commands on the relevant VM.
- Check Prometheus `activeTargets` before treating historical series as configured targets.
- Keep the Docker remote API protected; Athena now uses its local socket.
- Create backups, verify them and preserve recovery material before deletion/change.
- Design Docker, journald and Loki retention to control disk consumption.
- Validate configuration before restarting: `promtool check config`, Loki `-verify-config=true`, Docker `dockerd --validate`.
- Investigate actual functionality before interpreting or resetting a failed systemd state.

## 56. Current known-good state

| Node | Recorded baseline |
|---|---|
| Apollo | Proxmox 9.2.2; `10.10.10.1`; Tailscale `100.81.86.51`; NAT, firewall service and storage working |
| Athena | VM 100; Ubuntu 20.04.6; 4 vCPU / 4 GiB / 32 GiB; eight telemetry containers running and reported health checks passing |
| Hermes | VM 101; Ubuntu 24.04.5; 4 vCPU / 4 GiB / 32 GiB; `10.10.10.11`; Tailscale `100.91.200.31`; single-node K3s `v1.36.4+k3s1`, Ready |
| Artemis | Management workstation with Tailscale, SSH, kubectl and Git |
| Hestia | Retired; backup retained; no LXC containers remain |

## 57. Backup state

Apollo backup storage: `/mnt/pve/Storage/dump/`. V1 material: `/root/olympus-v1-backup/` and `/root/olympus-v1-backup.tar.gz`, with host-local guest archives noted above. Retain the September Hestia backup and named Athena V2 archive. Backup automation, rotation, off-box copies and restore testing are not established by these archive checks.

## 58. Pending work

**Hermes:** detailed K3s baseline audit, resource policy, namespace strategy, RBAC, secrets, application ingress, persistent storage tests, resource limits, applications, rollout/rollback tests and observability integration.

**Athena:** Ubuntu migration planning, exporter/dashboard improvements, alerting improvements and optional build-cache cleanup.

**Olympus:** automated backups, rotation, restore tests, infrastructure-as-code, Terraform, Ansible, CI/CD, Kubernetes applications, Hermes-to-Athena metrics/logs and D2Bus deployment. Retained Terraform/Floci examples do not establish a current emulator deployment.

## 59. V2 philosophy

Keep infrastructure simple, separate responsibilities, back up before destructive operations, validate major changes, prefer reproducible configuration, secure management access and add complexity when it provides learning value. Apollo owns infrastructure; Athena owns observability; Hermes owns Kubernetes/applications; Artemis owns management.

---

**Recorded continuation baseline: 2026-09-14.** The sections below record a further operator-supplied update following section 59. As above, these are reported observations, not a live audit performed by this documentation update.

## 60. Resource reallocation

Following stability confirmation, resource allocation was reviewed against actual workload demand rather than initial defaults.

| VM | Before | After |
|---|---|---|
| Athena | 4 vCPU / 4 GiB RAM | 2 vCPU / 2 GiB RAM |
| Hermes | 4 vCPU / 4 GiB RAM | 4 vCPU / 6 GiB RAM |

Rationale: Athena's observability stack (Prometheus, Grafana, Loki, Alloy, exporters) runs comfortably within 2 GiB given a 7-day Loki retention window and a small number of monitored targets; Hermes was given the freed RAM headroom since Kubernetes workloads are expected to grow. Post-resize verification: Athena reported ~1.9 GiB usable / ~1.0 GiB available memory with all observability containers still running; Hermes reported ~5.8 GiB usable / ~4.8 GiB available with the K3s node still `Ready` and all system pods running. Apollo's own allocation (16 GiB RAM, 16 threads) was unchanged.

## 61. K3s baseline confirmed

Current K3s workloads on Hermes: `coredns`, `local-path-provisioner`, `metrics-server`, `traefik`, `svclb-traefik`. Traefik is the default K3s-installed Ingress controller and is being kept permanently as part of the platform (this K3s installation used the default installer without `--disable traefik`, unlike the retired Athena K3s installation, which never had Traefik running). Default `local-path` StorageClass confirmed (provisioner `rancher.io/local-path`, reclaim policy `Delete`, binding mode `WaitForFirstConsumer`); no application PVs/PVCs deployed yet.

## 62. Kubernetes fundamentals exercise (temporary, cleaned up)

A throwaway exercise was run in a `lab` namespace to confirm the cluster behaves correctly before real workloads are deployed to it — not a permanent addition:

- Nginx Deployment created; a Pod was manually deleted and Kubernetes recreated it automatically (reconciliation loop confirmed).
- ClusterIP Service created; internal connectivity verified with a temporary curl Pod; EndpointSlice inspected to confirm correct Pod targeting.
- Deployment scaled from 1 → 3 replicas.
- A Traefik Ingress (`nginx-ingress`, host `nginx.local`) was created and tested with `curl -H "Host: nginx.local" http://10.10.10.11`, confirming the path Client → Traefik → Ingress → Service → Pod.
- Everything (Deployment, Service, Ingress, and the `lab` namespace itself) was deleted afterward. Final namespace list: `default`, `kube-node-lease`, `kube-public`, `kube-system` — no application workloads currently run in K3s on Hermes.

## 63. Hermes → Athena observability integration (complete)

This completes the host/Docker metrics and Docker log paths within the "Hermes-to-Athena metrics/logs" item listed as pending in section 58. Kubernetes metrics, K3s/containerd workload logs and host journal collection remain unverified.

**Host metrics:** Node Exporter installed directly on Hermes as a systemd service (`node_exporter 1.10.2`, endpoint `100.91.200.31:9100`). Athena's Prometheus scrapes it under job `hermes`; target confirmed `UP`.

**Container metrics:** cAdvisor deployed as a Docker container on Hermes — a separate instance from Athena's own cAdvisor (still `v0.49.1`, monitoring Athena's own containers). Hermes's cAdvisor initially shipped at `v0.49.1` but failed to expose Floci's container metrics (`failed to identify the read-write layer ID`, related to Docker's `overlayfs` storage driver). Upgraded to `ghcr.io/google/cadvisor:0.60.5` with the same host mounts retained (`/`, `/var/run`, `/sys`, `/var/lib/docker`, `/dev/disk`); after the upgrade, `floci-floci-1` container metrics (e.g. `container_memory_usage_bytes`) were confirmed exposed and scraped correctly by Athena's Prometheus under job `hermes-cadvisor` (target `100.91.200.31:8080`, confirmed `UP`).

**Logs:** Grafana Alloy installed directly on Hermes as a systemd service, reading `unix:///var/run/docker.sock` and pushing to `http://100.117.35.70:3100/loki/api/v1/push` (Athena's Loki), labeled `host="hermes"`. The Alloy service account (`alloy`) needed to be added to the `docker` group (`usermod -aG docker alloy`) to read the socket — Docker socket permissions were not weakened and the Docker TCP API was not re-enabled to achieve this. Verified via a Loki query for `{host="hermes"}` after restarting Floci to generate fresh events: 50 log entries returned with correct `container`, `host`, and `service_name` labels.

**Full verified pipeline:** `Floci → Docker → cAdvisor 0.60.5 → Tailscale → Athena Prometheus` (metrics) and `Floci → Docker → Grafana Alloy → Tailscale → Athena Loki` (logs). Athena is now the confirmed centralized observability layer for both itself and Hermes.

## 64. Floci deployed on Hermes (on-demand, Docker Compose — not K3s)

Floci is intentionally run via Docker Compose on Hermes rather than as a K3s workload, since it's an on-demand AWS emulator, not a permanent service. Compose file: `/home/ops/apps/floci/compose.yml`; persistent data: `/home/ops/apps/floci/data`; image `floci/floci:latest`; listens on `4566`. Verified locally on Hermes (`HTTP/1.1 200 OK`) and remotely from Artemis over Tailscale (`http://100.91.200.31:4566`). No Floci UI deployed at this stage. This supersedes the "not reported" status in section 22/58 above — Floci is now reported running on Hermes, on-demand, alongside K3s's permanent workloads.

## 65. Updated known-good state (supersedes section 56 for Athena/Hermes specs)

| Node | Recorded baseline |
|---|---|
| Apollo | Unchanged — Proxmox 9.2.2; `10.10.10.1`; Tailscale `100.81.86.51`; NAT, firewall service and storage working |
| Athena | VM 100; Ubuntu 20.04.6; **2 vCPU / 2 GiB RAM** / 32 GiB disk; eight telemetry containers running; now also scraping Hermes host/Docker metrics and receiving Docker logs |
| Hermes | VM 101; Ubuntu 24.04.5; **4 vCPU / 6 GiB RAM** / 32 GiB disk; `10.10.10.11`; Tailscale `100.91.200.31`; single-node K3s `v1.36.4+k3s1` (containerd `2.3.4-k3s1.36`), Ready; Traefik, CoreDNS, metrics-server, local-path-provisioner running; Floci running on-demand via Docker Compose; Node Exporter and Grafana Alloy running as host-level systemd services; cAdvisor `0.60.5` running as a Docker container |
| Artemis | Unchanged |
| Hestia | Unchanged — retired |

## 66. Pending work (supersedes section 58)

**Hermes:** Kubernetes metrics, K3s/containerd workload logs and host journal collection; detailed K3s baseline audit (namespaces, RBAC, secrets, resource limits beyond what's noted above), persistent storage tests with a real PVC, application ingress beyond the cleaned-up exercise, a real application deployment (D2Bus is the stated future candidate), rollout/rollback tests, failure-testing exercises.

**Athena:** Ubuntu 20.04 → 24.04 migration planning (still deliberately deferred), exporter/dashboard improvements, alerting improvements.

**Olympus:** automated backups, rotation, restore tests, infrastructure-as-code, Terraform, Ansible, CI/CD, GitOps, secrets management (SOPS+age), and D2Bus deployment. Hermes-to-Athena metrics/logs integration (previously pending) is now complete as of section 63.
