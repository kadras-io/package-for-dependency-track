# Dependency Track

![Test Workflow](https://github.com/kadras-io/package-for-dependency-track/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-dependency-track/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [Dependency Track](https://dependencytrack.org), a continuous SBOM Analysis Platform for managing software supply chain security risks.

## ✨&nbsp; What's Included

* **Dependency Track**. The API Server and the Frontend, served from the same domain via an Ingress with a TLS certificate issued by cert-manager.
* **Database**. A PostgreSQL cluster managed by CloudNativePG, tuned as recommended by Dependency Track. The database, the file storage, and the encryption key for the secrets are kept when uninstalling the package.
* **Observability**. Structured logs, and metrics annotated for Prometheus scraping.
* **Security**. The workloads comply with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), enforced on their namespace, and don't mount service account tokens. The key encrypting the secrets managed by Dependency Track is generated at installation time.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Dependencies

Dependency Track requires [secretgen-controller](https://github.com/kadras-io/package-for-secretgen-controller) to generate its encryption key, and the [PostgreSQL Operator](https://github.com/kadras-io/package-for-postgresql-operator) to run its database. By default, it's exposed via an Ingress for [Contour](https://github.com/kadras-io/package-for-contour), with a TLS certificate issued by [cert-manager](https://github.com/kadras-io/package-for-cert-manager) when `ingress.issuer` is set. All of them are available to install from the [Kadras package repository](https://github.com/kadras-io/kadras-packages).

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

  ```shell
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages \
    -n kadras-system --create-namespace
  ```

<details><summary>Installation without package repository</summary>
The recommended way of installing the Dependency Track package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

  ```shell
  kubectl create namespace kadras-system
  kapp deploy -a dependency-track-package -n kadras-system -y \
    -f https://github.com/kadras-io/package-for-dependency-track/releases/latest/download/metadata.yml \
    -f https://github.com/kadras-io/package-for-dependency-track/releases/latest/download/package.yml
  ```
</details>

Install the Dependency Track package:

  ```shell
  kctrl package install -i dependency-track \
    -p dependency-track.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system
  ```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
>   ```shell
>   kctrl package available list -p dependency-track.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

### Try It Out

Check that Dependency Track is running:

```shell
kubectl get deployment -n dependency-track
kubectl get cluster.postgresql.cnpg.io -n dependency-track
```

Open the domain configured in `domain_name` in your browser, and log in with the default `admin` user and `admin` password. You'll be asked to change the password at the first login.

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to Dependency Track, check out [dependencytrack.org](https://dependencytrack.github.io/docs/).

Features:

* [Application configuration](docs/application-configuration.md)
* [Database](docs/database.md)
* [High availability](docs/high-availability.md)
* [Observability](docs/observability.md)
* [Security](docs/security.md)

Operations:

* [Configuration and ytt overlays](docs/configuration.md)
* [Custom certificate authorities](docs/custom-ca.md)
* [Corporate proxy](docs/corporate-proxy.md)
* [Upgrading and uninstalling](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The Dependency Track package can be customized via a `values.yml` file.

```yaml
domain_name: dependency-track.kadras.io
ingress:
  issuer: kadras-ca-issuer
postgresql:
  instances: 3
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i dependency-track \
  -p dependency-track.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Any resource can be customized beyond the values via ytt overlays. See [configuration.md](docs/configuration.md).

### Values

The Dependency Track package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `"dependency-track"` | The namespace where to install Dependency Track. |
| `domain_name` | `""` | The domain name where Dependency Track is served. Both the Frontend and the API Server (under `/api`) are served from it. |
| `ingress.enabled` | `true` | Whether to expose Dependency Track via an Ingress. When disabled, expose the `dependency-track-frontend` and `dependency-track-api-server` Services yourself. |
| `ingress.class_name` | `"contour"` | The IngressClass to use for the Ingress. |
| `ingress.issuer` | `""` | The cert-manager ClusterIssuer that issues the TLS certificate for the Ingress. When empty, the Secret named `ingress.tls_secret_name` must be provided. |
| `ingress.tls_secret_name` | `"dependency-track-tls-secret"` | The name of the Secret holding the TLS certificate for the Ingress. |
| `image.tag` | `""` | The tag to use for the API Server and Frontend container images, overriding the Dependency Track version bundled with this package. The images must be available in a container registry reachable from the cluster, since they are not part of the package bundle. |
| `api_server.replicas` | `1` | The number of API Server replicas. Values greater than 1 require the `ReadWriteMany` access mode for the storage. |
| `api_server.resources.requests.cpu` | `"0.5"` | The CPU requested by the API Server. |
| `api_server.resources.requests.memory` | `"5Gi"` | The memory requested by the API Server. |
| `api_server.resources.limits.cpu` | `"4"` | The CPU limit for the API Server. |
| `api_server.resources.limits.memory` | `"5Gi"` | The memory limit for the API Server. |
| `api_server.storage.class_name` | `""` | The StorageClass for the PersistentVolume. When empty, the default StorageClass is used. |
| `api_server.storage.size` | `"1Gi"` | The size of the PersistentVolume. |
| `api_server.storage.access_modes` | `["ReadWriteOnce"]` | The access modes for the PersistentVolume. `ReadWriteMany` is required when running more than one API Server replica. |
| `api_server.config` | `{}` | Additional configuration properties for the API Server, appended to the `application.properties` file and taking precedence over the ones managed by this package. See https://dependencytrack.github.io/docs/next/reference/configuration/properties for the full list. |
| `frontend.replicas` | `1` | The number of Frontend replicas. Set it greater than 1 for high availability. |
| `frontend.resources.requests.cpu` | `"150m"` | The CPU requested by the Frontend. |
| `frontend.resources.requests.memory` | `"64Mi"` | The memory requested by the Frontend. |
| `frontend.resources.limits.cpu` | `"500m"` | The CPU limit for the Frontend. |
| `frontend.resources.limits.memory` | `"128Mi"` | The memory limit for the Frontend. |
| `frontend.config` | `{}` | Configuration for the Frontend, provided as environment variables. Use it to enable OpenID Connect, or to point the Frontend at an API Server served from a different host via `API_BASE_URL`. See https://dependencytrack.github.io/docs/next/guides/administration/configuring-oidc for the OpenID Connect settings. |
| `postgresql.instances` | `1` | The number of PostgreSQL instances: one primary and its replicas. Use at least 3 in production. |
| `postgresql.resources.requests.cpu` | `""` | The CPU requested by each PostgreSQL instance. |
| `postgresql.resources.requests.memory` | `""` | The memory requested by each PostgreSQL instance. |
| `postgresql.resources.limits.cpu` | `""` | The CPU limit for each PostgreSQL instance. |
| `postgresql.resources.limits.memory` | `""` | The memory limit for each PostgreSQL instance. |
| `postgresql.storage.class_name` | `""` | The StorageClass for the PersistentVolumes. When empty, the default StorageClass is used. |
| `postgresql.storage.size` | `"1Gi"` | The size of the PersistentVolume of each PostgreSQL instance. |
| `postgresql.parameters` | `{}` | Configuration parameters for the PostgreSQL server, merged on top of the ones recommended by Dependency Track (`jit=off` and `wal_compression=zstd`). Remember that `max_connections` must cover the sum of the connection pools of all the API Server replicas, plus headroom for migrations, backups, and administrator sessions. |
| `ca_cert_data` | `""` | PEM-encoded certificates of the CAs to trust in TLS connections, in addition to the public ones. They're imported into the Java truststore used by the API Server. |
| `observability.logging.level` | `"info"` | The log verbosity level: `trace`, `debug`, `info`, `warn`, or `error`. |
| `observability.logging.format` | `"text"` | The log format: `text`, or `json` for structured logs. |
| `observability.metrics.enabled` | `true` | Whether the API Server and PostgreSQL expose Prometheus metrics, and their Pods are annotated for scraping. |
| `proxy.http_proxy` | `""` | The proxy for the network traffic, in the form `http://[user[:password]@]host[:port]`. Used only when `https_proxy` is not set. |
| `proxy.https_proxy` | `""` | The proxy for the network traffic, in the form `http://[user[:password]@]host[:port]`. |
| `proxy.no_proxy` | `""` | A comma-separated list of hostnames or IP addresses, optionally with a port, that should not use the proxy. An entry matches the host exactly or any of its subdomains. CIDR ranges and leading-dot notation are not supported. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
