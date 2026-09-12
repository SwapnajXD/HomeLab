# V2 Kubernetes

**Implemented:** single-node K3s on Hermes VM 101, replacing Athena's old installation. The [September 12 rebuild record](rebuild-history.md) reports Ubuntu 24.04.5, 4 vCPU, 4 GiB RAM and a 32 GiB disk.

| Item | Recorded state |
|---|---|
| Node | `hermes`, Ready, control-plane |
| K3s | `v1.36.4+k3s1` |
| Runtime | `containerd://2.3.4-k3s1.36` |
| Internal IP | `10.10.10.11` |
| Management API | `https://100.91.200.31:6443` |
| System components | CoreDNS, Traefik, Local Path Provisioner, Metrics Server, ServiceLB |

System pods were Running and installation jobs completed. Traefik is installed; application ingress setup is still pending. Single-node operation is intentional for learning and does not provide node redundancy.

## Artemis access

`~/.kube/hermes.yaml` uses the Tailscale API endpoint. Adding `100.91.200.31` to `tls-san` in Hermes's `/etc/rancher/k3s/config.yaml`, followed by a K3s restart, resolved the certificate mismatch. Remote node listing succeeded.

Old EKS and local-lab contexts were removed. The Hermes file was copied to `~/.kube/config` with mode `600`; the resulting context is reported as `hermes`. Removing an EKS context does not delete the AWS cluster. See rebuild sections 18–20 for history.

Athena's K3s configuration was backed up before uninstalling. Floci was removed from Athena; a Hermes Floci deployment is not reported.

## Pending baseline and workloads

- Detailed K3s audit; namespaces, RBAC, secrets and resource policy/limits.
- Application ingress and persistent storage validation.
- Application deployment, including D2Bus; rollout and rollback testing.
- Hermes host/Kubernetes metrics and logs integrated with Athena.
- CI/CD and repeatable deployment configuration.

A Raspberry Pi may later support ARM/edge/IoT experiments. Multi-node Kubernetes remains outside the current core design.
