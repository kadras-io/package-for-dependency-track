# Security

## Pod Security Standards

The API Server, the Frontend, and PostgreSQL comply with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), enforced on the package namespace. The containers run as non-root users, without privileges or capabilities, with the default seccomp profile. The root filesystem of the API Server is read-only. The one of the Frontend is writable, since it writes its configuration into the web root at startup.

## Service account tokens

Dependency Track doesn't access the Kubernetes API, so its service account doesn't mount any token.

## Secrets

* **Database credentials**. CloudNativePG generates the credentials of the database user in the `postgresql-dependency-track-app` Secret. The API Server reads them from files mounted from it, not from environment variables.
* **Key encryption key**. Dependency Track encrypts the secrets it manages, such as the credentials for the integrations, before storing them in the database. secretgen-controller generates the key encrypting them at installation time, in the `dependency-track-kek` Secret, and it's kept when uninstalling the package (see [upgrade.md](upgrade.md#uninstalling)). See the Dependency Track documentation for [secret management](https://dependencytrack.github.io/docs/next/guides/administration/configuring-secret-management).
* **Image pull credentials**. The `canonical-registry-credentials` Secret is populated by secretgen-controller with the credentials for the registry hosting the package images, when exported to the namespace. It's used by the API Server, the Frontend, and PostgreSQL.

## Default credentials

At the first installation, Dependency Track creates an `admin` user with the `admin` password, which must be changed at the first login. Do it right after installing the package, or configure OpenID Connect (see [application-configuration.md](application-configuration.md#enabling-openid-connect)).

## Network access

The API Server and the Frontend are exposed via an HTTPRoute, over HTTPS terminated on the Gateway. The management port of the API Server, serving the health probes and the metrics, isn't exposed via a Service. PostgreSQL is only reachable from within the cluster.

The package doesn't include network policies. Add them with a ytt overlay (see [configuration.md](configuration.md#ytt-overlays)): the API Server needs to reach PostgreSQL and the external vulnerability data sources and package repositories, while the Frontend and the API Server need to be reachable from the Envoy proxies of the Gateway.
