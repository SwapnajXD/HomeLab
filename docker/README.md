# Docker deployments

[telemetry/](telemetry/) is the intended location for Athena's V2 Compose stack. Its current host configuration still needs to be imported and reviewed.

The repository's previous Compose file uses Promtail and omits parts of the reported eight-container V2 stack. It is preserved in [archive/v1/docker-compose/telemetry](../archive/v1/docker-compose/telemetry/) along with the other [retired deployments](../archive/v1/docker-compose/). It has not been relabeled as a deployable V2 stack.

See [observability](../docs/observability.md) for the reported live baseline.
