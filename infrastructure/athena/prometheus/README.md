# Prometheus configuration

`alert.rules.yml` is a retained InstanceDown rule copied from the old Athena config. It is a reference, not a newly verified export of the running rule.

The current V2 `prometheus.yml` has not been imported. The old three-target configuration is archived at [the original telemetry snapshot](../../../archive/v1/docker-compose/telemetry/prometheus/prometheus.yml). The reported V2 stack has five active targets; see [observability](../../../docs/observability.md).

After importing and reviewing the current files, validate with the deployed Prometheus version before updating the running stack.
