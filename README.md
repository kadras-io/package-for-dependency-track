# Dependency Track

![Test Workflow](https://github.com/kadras-io/package-for-dependency-track/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-dependency-track/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [Dependency Track](https://dependency-track.io), a continuous SBOM Analysis Platform for managing software supply chain security risks.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.30+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Dependencies

Dependency Track requires the following packages included in the Kadras Engineering Platform and available to install from the [Kadras package repository](https://github.com/kadras-io/kadras-packages):

* [cert-manager](https://github.com/kadras-io/package-for-cert-manager)
* [Contour](https://github.com/kadras-io/package-for-contour)
* [secretgen-controller](https://github.com/kadras-io/package-for-secretgen-controller)
* [PostgreSQL Operator](https://github.com/kadras-io/package-for-postgresql-operator). 

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

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to Dependency Track, check out [dependencytrack.org](https://docs.dependencytrack.org/).

## 🎯&nbsp; Configuration

The Dependency Track package can be customized via a `values.yml` file.

```yaml
domain_name: "dependency-track.kadras.io"
ingress_issuer: "kadras-ca-issuer"
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

### Values

The Dependency Track package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|-------|-------------------|-------------|
| `system_requirement_check` | `true` | Whether Dependency Track will check for memory and CPU requirements at startup time. |
| `domain_name` | `""` | Domain name for Dependency Track. It must be a valid DNS name. |
| `ingress_issuer` | `""` | A reference to the ClusterIssuer to use for enabling TLS in Dependency Track. |


Settings for the API Server component.

| Config | Default | Description |
|-------|-------------------|-------------|
| `api_server.logging.level` | `info` | Log verbosity level. Options: `trace`, `debug`, `info`, `warn`, `error`. |
| `api_server.logging.format` | `console` | Log encoding format. Options: `console`, `json`. |
| `api_server.metrics.enabled` | `true` | Whether to enable the generation of Prometheus metrics. |
| `api_server.resources.cpu` | `0.5` | CPU requests configuration for the API Server component. |
| `api_server.resources.memory` | `5Gi` | Memory requests configuration for the API Server component. |
| `api_server.limits.cpu` | `4` | CPU limits configuration for the API Server component. |
| `api_server.limits.memory` | `5Gi` | Memory limits configuration for the API Server component. |
| `api_server.storage.class_name` | `""` | Class name for the PersistenceVolume to create. |
| `api_server.storage.size` | `500Mi` | Size of the PersistenceVolume to create. |

Settings for the Frontend component.

| Config | Default | Description |
|-------|-------------------|-------------|
| `frontend.replicas` | `1` | The number of Frontend replicas. In order to enable high availability, it should be greater than 1. |
| `frontend.resources.cpu` | `0.5` | CPU requests configuration for the Frontend component. |
| `frontend.resources.memory` | `5Gi` | Memory requests configuration for the Frontend component. |
| `frontend.limits.cpu` | `4` | CPU limits configuration for the Frontend component. |
| `frontend.limits.memory` | `5Gi` | Memory limits configuration for the Frontend component. |

Settings for the corporate proxy.

| Config | Default | Description |
|-------|-------------------|-------------|
| `proxy.https_proxy` | `""` | The HTTPS proxy to use for network traffic. |
| `proxy.http_proxy` | `""` | The HTTP proxy to use for network traffic. |
| `proxy.no_proxy` | `""` | A comma-separated list of hostnames, IP addresses, or IP ranges in CIDR format that should not use the proxy. |

Settings for the PostgreSQL database.

| Config | Default | Description |
|-------|-------------------|-------------|
| `postgresql.instances` | `1` | Number of instances for the PostgreSQL database cluster. Define at least 3 for production scenarios. |
| `postgresql.storage.size` | `500Mi` | Size of the PersistenceVolume to create for each PostgreSQL instance. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
