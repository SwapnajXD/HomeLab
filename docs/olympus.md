# Olympus infrastructure dashboard — planned

The [post-migration report](history/athena-migration-report.md) proposes Olympus as a lightweight infrastructure overview and a candidate for the first real application on Hermes K3s. Deployment is not confirmed.

Grafana remains the detailed metrics, logs and observability interface. Olympus should summarize infrastructure state using server-side access to Proxmox, Prometheus, Loki and Kubernetes APIs. Sensitive infrastructure APIs and credentials should not be exposed directly to browser clients or public Docker ports.

The intended host application directory is `~/apps/dashboard/`; Kubernetes configuration lives under `~/k8s/apps/`, `~/k8s/infrastructure/` and `~/k8s/namespaces/`. These are reported host paths, not checked-in application code or manifests. Repository manifest locations remain under [kubernetes/](../kubernetes/README.md).

Next work is to build/deploy a real workload, validate ingress, configuration/secrets, resource policy, persistence where needed, telemetry, rollout/rollback and recovery. D2Bus remains a later application candidate. The retired V1 FastAPI Dashboard API and Homepage widgets in the archive are historical projects, not evidence that this proposed dashboard is running.
