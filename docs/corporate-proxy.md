# Using a Corporate Proxy

When running Dependency Track behind a corporate proxy, you can configure the API Server to proxy communications with external services.

```yaml
proxy:
  http_proxy: "proxy.kadras.io"
  https_proxy: "proxy.kadras.io"
  no_proxy: ".cluster.local., .cluster.local, .svc"
```

For more information, check the Dependency Track documentation for configuring a [proxy](https://docs.dependencytrack.org/getting-started/configuration/).
