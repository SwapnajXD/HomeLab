# V2 networking

Current addresses follow the [post-migration report](history/athena-migration-report.md), incorporated 2026-10-09. Firewall/interface implementation details below were last recorded in the September rebuild and were not re-exported.

```mermaid
flowchart TB
    Internet["Internet"] --- Router["Router / gateway<br/>192.168.1.1"]
    Router --- WAN["Apollo Wi-Fi — wlx002e2df0393b<br/>192.168.1.20/24"]
    WAN --- NAT["Apollo IPv4 forwarding / MASQUERADE<br/>Default-route WAN detection at script execution"]
    NAT --- Bridge["vmbr0 — 10.10.10.1/24<br/>bridge-ports none"]
    Bridge --- Athena["Athena VM 102<br/>10.10.10.10"]
    Bridge --- Hermes["Hermes VM 101 — enp6s18<br/>10.10.10.11/24 / gateway 10.10.10.1"]
    Artemis["Artemis — 100.100.252.87"] --> Tailnet["Tailscale management"]
    Tailnet -->|100.81.86.51| NAT
    Tailnet -->|100.93.224.83| Athena
    Tailnet -->|100.91.200.31:6443 — matching TLS SAN| Hermes
```

Ethernet `nic0` is unused. IPv4 forwarding and outbound NAT serve `10.10.10.0/24`. `apollo-firewall.service` runs `/usr/local/sbin/apollo-firewall.sh`, discovers the default-route WAN with up to 15 attempts at two-second intervals, removes duplicate MASQUERADE rules and installs the subnet rule. The reported checks confirmed forwarding and connectivity. WAN discovery happens at script execution.

The post-migration report confirms Athena VM 102 at `10.10.10.10` and Tailscale `100.93.224.83`, replacing VM 100's `100.117.35.70`. Hestia's old `10.10.10.2` is retired. Old Hestia DNAT examples are historical; this report does not establish the final full DNAT ruleset.

## Private management

| Node | Tailscale IP |
|---|---|
| Apollo | `100.81.86.51` |
| Athena | `100.93.224.83` |
| Hermes | `100.91.200.31` |
| Artemis | `100.100.252.87` |

Artemis reaches the K3s API directly at `https://100.91.200.31:6443`. Hermes's `/etc/rancher/k3s/config.yaml` includes that IP in `tls-san`; K3s was restarted and remote `kubectl get nodes` succeeded. This resolves the earlier documented uncertainty over the management API path.

Floci, running on Hermes via Docker Compose (on-demand), is also reported reachable from Artemis over the same Tailscale path at `http://100.91.200.31:4566` — confirmed alongside local testing directly on Hermes.

Hermes interface `enp6s18` uses `/etc/netplan/01-hermes.yaml`: static `10.10.10.11/24`, default gateway `10.10.10.1`, DNS `1.1.1.1` and `8.8.8.8`. Full YAML and the wait-online failed-state investigation are in rebuild sections 12–13.

Athena's unauthenticated Docker TCP 2375 listener was removed; the daemon uses its local socket. Glances port 61208 was confirmed intentional. No public Kubernetes API exposure is reported.

Hermes Alloy forwards Docker logs to `http://100.93.224.83:3100/loki/api/v1/push`; its HTTP interface is `100.91.200.31:12345`. Fresh logs were queried after migration. Infrastructure access remains private through LAN/Tailscale; the proposed Olympus dashboard will access infrastructure APIs server-side.
