# Configuring Observability

Monitor and observe the operation of Dependency Track using logs and metrics.

## Logs

The log verbosity for the Dependency Track API Server can be configured.

```yaml
api_server:
  logging:
    level: info
```

Logs are printed to the console in a human-readable format. If you collect logs with a
structured logging pipeline, you can switch the format to JSON.

```yaml
api_server:
  logging:
    format: json
```

## Metrics

The Dependency Track API Server exposes Prometheus metrics by default on its management port (`9000`), which is only reachable from within the Pod. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from Dependency Track.

If you need, you can always disable the generation of Prometheus metrics.

```yaml
api_server:
  metrics:
    enabled: false
```

For more information, check the Dependency Track documentation for [metrics](https://dependencytrack.github.io/docs/next/reference/configuration/properties/).

The PostgreSQL database used by Dependency Track also exposes metrics that can be scraped by Prometheus. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from the PostgreSQL database.

If you need, you can always disable the generation of Prometheus metrics for the PostgreSQL database.

```yaml
postgresql:
  metrics:
    enabled: false
```

You can refer to the [CloudNativePG documentation](https://cloudnative-pg.io/docs/devel/monitoring/) for more information on how to configure and use these metrics.

## Health

The API Server exposes the `/health/started`, `/health/live`, and `/health/ready` endpoints on its management port (`9000`). They are used by the Kubernetes probes and are not exposed via the Ingress.
