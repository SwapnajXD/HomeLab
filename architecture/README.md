# Olympus V2 diagrams

Current Mermaid sources live at the repository root alongside the current documentation. They reflect the operator-reported September 12, 2026 baseline; no new live audit or restore drill was performed.

| Diagram | Scope |
|---|---|
| [Architecture](../architecture-diagram.mmd) | Apollo, Athena telemetry, Hermes K3s and Artemis management |
| [Networking](../networking-diagram.mmd) | Wi-Fi WAN, private bridge, NAT and Tailscale API access |
| [Metrics](../metrics-flow.mmd) | Five active scrape targets and pending Hermes integration |
| [Logging](../logging-flow.mmd) | Athena Alloy/Loki pipeline and retention |
| [Alerting](../alerting-flow.mmd) | Validated Prometheus rule and notification tests still pending |
| [Recovery](../recovery-flow.mmd) | Planned recovery sequence and archive verification limits |

Diagrams are also embedded in the root [architecture](../architecture.md), [networking](../networking.md), [observability](../observability.md) and [recovery](../disaster-recovery.md) pages for Mermaid-capable Markdown viewers. Raw `.mmd` files contain Mermaid syntax without Markdown fences.

Old standalone diagrams are preserved in [the historical diagram archive](../docs/historical/diagrams/). Embedded diagrams in historical documents retain their original state. Dashed links and pending labels identify work not established by the V2 report. Data-flow arrows in metrics/logging diagrams show data movement, not necessarily connection initiation.
