# Configuring Observability

Monitor and observe the operation of Dependency Track using logs and metrics.

## Logs

The log verbosity for the Dependency Track API Server can be configured.

```yaml
observability:
  logging:
    level: info
```

Logs are printed in a human-readable text format by default. If you collect logs with a
structured logging pipeline, you can switch the format to JSON.

```yaml
observability:
  logging:
    format: json
```

## Metrics

The Dependency Track API Server exposes Prometheus metrics by default on its management port (`9000`), which is only reachable from within the Pod. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from Dependency Track.


For more information, check the Dependency Track documentation for [metrics](https://dependencytrack.github.io/docs/next/reference/configuration/properties/).

The PostgreSQL database used by Dependency Track also exposes metrics that can be scraped by Prometheus. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from the PostgreSQL database.

The PostgreSQL Pods are annotated via the `inheritedMetadata` field of the CloudNativePG Cluster, which applies the annotations to all the objects the operator creates.

If you need, you can disable the Prometheus metrics of the API Server and the scraping annotations of both.

```yaml
observability:
  metrics:
    enabled: false
```

You can refer to the [CloudNativePG documentation](https://cloudnative-pg.io/docs/devel/monitoring/) for more information on how to configure and use these metrics.

## Health

The API Server exposes the `/health/started`, `/health/live`, and `/health/ready` endpoints on its management port (`9000`). They are used by the Kubernetes probes and are not exposed via the Ingress.
