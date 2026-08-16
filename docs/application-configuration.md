# Configuring the Application

Beyond the settings this package exposes as dedicated values, both Dependency Track components can be configured directly.

## API Server

The API Server reads its configuration from an `application.properties` file that this package renders into a ConfigMap and mounts into the container. Any property from the [configuration reference](https://dependencytrack.github.io/docs/next/reference/configuration/properties) can be added via `api_server.config`, and it takes precedence over the properties managed by this package.

```yaml
api_server:
  config:
    dt.datasource.pool.max-size: 20
    dt.dex-engine.activity-worker.vuln-analysis.max-concurrency: 20
    dt.task.nvd-vuln-data-source-mirror.cron: "0 4 * * *"
```

Changing these values creates a new ConfigMap and rolls out the API Server.

## Frontend

The Frontend is a static single-page application, entirely configured via environment variables that it renders into `/static/config.json` at startup. Provide them via `frontend.config`.

```yaml
frontend:
  config:
    API_BASE_URL: "https://dependency-track.kadras.io"
```

By default `API_BASE_URL` is left unset, because the Ingress serves the Frontend and the API Server from the same host, so the Frontend calls the API via relative URLs. Set it only when the API Server is reachable at a different address. Since the Frontend runs in the user's browser, that address must be reachable from the browser, not just from within the cluster.

## Enabling OpenID Connect

OpenID Connect requires configuring both components with the same issuer and client ID. The API Server validates the tokens, while the Frontend initiates the authentication flow.

```yaml
api_server:
  config:
    dt.oidc.enabled: true
    dt.oidc.issuer: "https://idp.kadras.io/realms/kadras"
    dt.oidc.client-id: "dependency-track"
    dt.oidc.username-claim: "preferred_username"
    dt.oidc.user-provisioning: true
    dt.oidc.team-synchronization: true
    dt.oidc.teams-claim: "groups"
frontend:
  config:
    OIDC_ISSUER: "https://idp.kadras.io/realms/kadras"
    OIDC_CLIENT_ID: "dependency-track"
    OIDC_SCOPE: "openid profile email"
```

If the identity provider uses a certificate signed by an internal CA, the API Server must also trust it. See [Trusting a Custom CA](custom-ca.md).

For more information, check the Dependency Track documentation for [configuring OpenID Connect](https://dependencytrack.github.io/docs/next/guides/administration/configuring-oidc/).

## Overriding the Dependency Track version

Each release of this package bundles a specific version of Dependency Track, with the container images resolved to their digests and included in the package bundle. You can deploy a different version without rebuilding the package.

```yaml
image:
  tag: "5.0.5"
```

The images for the overridden version are not part of the package bundle, so they must be available in a container registry reachable from the cluster. This is not supported in air-gapped environments, where a new package release is needed instead.
