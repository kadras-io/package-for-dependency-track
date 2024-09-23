# Configuring Observability

Monitor and observe the operation of Dependency Track using logs and metrics.

## Logs

The log verbosity for the Dependency Track API Server can be configured.

```yaml
api_server:
  logging:
    level: info
```

For more information, check the Dependency Track documentation for [logs](https://docs.dependencytrack.org/getting-started/monitoring/#logging).

## Metrics

The Dependency Track API Server exposes Prometheus metrics by default. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from Dependency Track.

If you need, you can always disable the generation of Prometheus metrics.

```yaml
api_server:
  metrics:
    enabled: false
```

For more information, check the Dependency Track documentation for [metrics](https://docs.dependencytrack.org/getting-started/monitoring/#metrics).

## Dashboards

If you use the Grafana observability stack, you can refer to this [dashboard](https://docs.dependencytrack.org/getting-started/monitoring/#metrics) as a foundation to build your own.
