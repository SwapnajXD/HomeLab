# V2 Kubernetes

**Implemented:** single-node K3s on Hermes VM 101, replacing Athena's old installation. The [September 12 rebuild record](history/rebuild-history.md) reports Ubuntu 24.04.5, 4 vCPU, 32 GiB disk; RAM was increased from 4 GiB to **6 GiB** on 2026-09-14 as Kubernetes workloads are expected to grow (Athena was correspondingly reduced to 2 vCPU/2 GiB — see [infrastructure](infrastructure.md)).

| Item | Recorded state |
|---|---|
| Node | `hermes`, Ready, control-plane |
| K3s | `v1.36.4+k3s1` |
| Runtime | `containerd://2.3.4-k3s1.36` |
| Internal IP | `10.10.10.11` |
| Management API | `https://100.91.200.31:6443` |
| System components | CoreDNS, Traefik, Local Path Provisioner, Metrics Server, ServiceLB |

System pods were Running and installation jobs completed. **Traefik is the default Ingress controller and is being kept permanently as part of the platform** (this K3s install used the default installer, unlike the previous, now-retired K3s installation on Athena, which never had Traefik). Default `local-path` StorageClass confirmed; no application PVs/PVCs deployed yet. Single-node operation is intentional for learning and does not provide node redundancy.

## Cluster validation exercise (temporary, cleaned up)

A throwaway Nginx exercise in a `lab` namespace validated the cluster before any real workload: Deployment → ReplicaSet → Pod, manual Pod deletion and automatic recreation (reconciliation loop), a ClusterIP Service with EndpointSlice inspection, scaling 1→3 replicas, and a Traefik Ingress (`nginx.local`) confirming Client → Traefik → Ingress → Service → Pod end-to-end. Everything, including the `lab` namespace itself, was deleted afterward — **no application workloads currently run in K3s on Hermes.** Full detail: [rebuild history §62](history/rebuild-history.md#62-kubernetes-fundamentals-exercise-temporary-cleaned-up).

## Artemis access

`~/.kube/hermes.yaml` uses the Tailscale API endpoint. Adding `100.91.200.31` to `tls-san` in Hermes's `/etc/rancher/k3s/config.yaml`, followed by a K3s restart, resolved the certificate mismatch. Remote node listing succeeded.

Old EKS and local-lab contexts were removed. The Hermes file was copied to `~/.kube/config` with mode `600`; the resulting context is reported as `hermes`. Removing an EKS context does not delete the AWS cluster. See rebuild sections 18–20 for history.

Athena's K3s configuration was backed up before uninstalling.

## Floci (Docker Compose, not K3s)

Floci is now reported deployed on **Hermes** — deliberately via Docker Compose, not as a K3s workload, since it's an on-demand AWS emulator rather than a permanent service. Compose file at `/home/ops/apps/floci/compose.yml`, listens on `4566`, verified reachable locally and from Artemis over Tailscale (`http://100.91.200.31:4566`). See [rebuild history §64](history/rebuild-history.md#64-floci-deployed-on-hermes-on-demand-docker-compose--not-k3s).

## Observability integration — complete

Hermes host metrics (Node Exporter), container metrics (a dedicated cAdvisor `0.60.5` — separate from Athena's own `v0.49.1` instance, upgraded specifically to fix a Floci/overlayfs metrics bug), and Docker logs (Grafana Alloy) are all confirmed flowing into Athena's Prometheus and Loki over Tailscale. See [observability](observability.md) and [rebuild history §63](history/rebuild-history.md#63-hermes--athena-observability-integration-complete).

## Pending baseline and workloads

- Detailed K3s audit; namespaces, RBAC, secrets and resource policy/limits beyond what the validation exercise covered.
- Application ingress and persistent storage validation with a real PVC (the exercise above used no persistent storage).
- Application deployment, including D2Bus; rollout and rollback testing.
- Kubernetes metrics, K3s/containerd workload logs and host journal collection.
- CI/CD and repeatable deployment configuration.

A Raspberry Pi may later support ARM/edge/IoT experiments. Multi-node Kubernetes remains outside the current core design.
