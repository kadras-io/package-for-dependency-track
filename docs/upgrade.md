# Upgrading

Upgrade the package to a new version via `kctrl`.

```shell
kctrl package installed update -i dependency-track -v ${VERSION} -n kadras-system
```

Read the [Dependency Track release notes](https://github.com/DependencyTrack/hyades/releases) of each version first. The first time the new API Server starts, it migrates the database, which can take a while for large databases. Its startup probe allows up to 30 minutes (see [configuration.md](configuration.md#probes) to extend it). Back up the database before upgrading (see [configuration.md](configuration.md#database-backups)).

## Values renamed in the new package foundation

The values were reorganized to align with the other Kadras packages. Update your `values.yml` before upgrading. The package rejects the old values.

| Old value | New value |
|-----------|-----------|
| `ingress_issuer` | Removed: TLS is terminated on the Gateway (see below) |
| `api_server.logging.level` | `observability.logging.level` |
| `api_server.logging.format` (`console` or `json`) | `observability.logging.format` (`text` or `json`) |
| `api_server.metrics.enabled` | `observability.metrics.enabled` |
| `postgresql.metrics.enabled` | `observability.metrics.enabled` |

Installations created before this version must untrack the Secret holding the material of the encryption key from the package, so that uninstalling the package keeps it instead of failing:

```shell
kubectl label secret dependency-track-kek-material -n dependency-track kapp.k14s.io/app="" --overwrite
```

Dependency Track is now exposed via a Gateway API HTTPRoute instead of an Ingress, on the external Gateway of the [Envoy Gateway package](https://github.com/kadras-io/package-for-envoy-gateway) by default (`ingress.gateway`). The Gateway terminates TLS and redirects HTTP to HTTPS: configure it with a `domain` (and a cert-manager issuer) whose `*.<domain>` wildcard covers `domain_name`. Upgrading replaces the Ingress with the HTTPRoute, so update the DNS record of `domain_name` to point at the Envoy Service of the Gateway (`envoy-external` in `envoy-gateway-system`).

The new values `namespace`, `ingress.enabled`, `postgresql.resources`, and `postgresql.storage.class_name` default to the previous behavior.

## Uninstalling

The data of Dependency Track lives in the PostgreSQL database and in the file storage of the API Server, and the secrets stored in the database are encrypted with a key generated at installation time. Uninstalling the package doesn't delete them: it deletes the API Server, the Frontend, and the HTTPRoute, and keeps the namespace with the PostgreSQL Cluster, the PersistentVolumeClaim of the file storage, and the encryption key. PostgreSQL keeps running.

Installing the package again in the same namespace adopts them, and Dependency Track starts with the existing data.

To delete the data too, delete the namespace after uninstalling the package.

```shell
kctrl package installed delete -i dependency-track -n kadras-system
kubectl delete namespace dependency-track
```

> **Warning**
> Without the encryption key, the secrets stored in the database (such as the credentials for the integrations) can't be decrypted anymore. Back it up together with the database: it's stored in the `dependency-track-kek` Secret.
