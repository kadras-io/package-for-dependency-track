# Using a Corporate Proxy

When running Dependency Track behind a corporate proxy, you can configure the API Server to proxy communications with external services (vulnerability data sources, package repositories, OIDC discovery, and webhooks).

```yaml
proxy:
  https_proxy: "http://proxy.kadras.io:3128"
  http_proxy: "http://proxy.kadras.io:3128"
  no_proxy: "postgresql-dependency-track-rw,localhost"
```

The Frontend component is a static single-page application, so the requests it appears to make actually originate from the user's browser and are not affected by this configuration.

A few constraints are worth knowing:

* Only plain HTTP proxies are supported, optionally with Basic authentication (`http://user:password@host:port`). HTTPS-fronted proxies and SOCKS proxies don't work.
* The `no_proxy` list accepts hostnames or IP addresses, optionally with a port. An entry matches the host exactly or any of its subdomains. CIDR ranges and leading-dot notation are not supported.

If the proxy terminates and re-issues TLS connections, the API Server must also trust the proxy's certificate authority. See [Trusting a Custom CA](custom-ca.md).

For more information, check the Dependency Track documentation for configuring an [HTTP proxy](https://dependencytrack.github.io/docs/next/guides/administration/configuring-http-proxy/).
