# Configuration

The package values cover the decisions most installations need to make: the namespace and domain, the Ingress, the size of each component, the database, trust, observability, and the corporate proxy. Everything else can still be customized in two ways.

## Application properties

The API Server and the Frontend accept any setting supported by Dependency Track via `api_server.config` and `frontend.config`. See [application-configuration.md](application-configuration.md).

## ytt overlays

Any Kubernetes resource of the package can be customized with a [ytt overlay](https://carvel.dev/ytt/docs/latest/ytt-overlays/). Store it in a Secret and reference it from the PackageInstall via the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.0` annotation.

```shell
kubectl create secret generic dependency-track-overlays -n kadras-system --from-file=overlays.yml
kubectl annotate packageinstall dependency-track -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=dependency-track-overlays
```

The API Server runs in the `dependency-track-api-server` Deployment, in a container with the same name, and the Frontend in the `dependency-track-frontend` one. The database is the `postgresql-dependency-track` CloudNativePG Cluster.

### Node placement

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment"}), expects=2
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      nodeSelector:
        kubernetes.io/os: linux
        node.kadras.io/pool: tools
```

The PostgreSQL instances are placed via the `affinity` field of the Cluster. See the [CloudNativePG documentation](https://cloudnative-pg.io/docs/devel/scheduling/).

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Cluster", "metadata": {"name": "postgresql-dependency-track"}})
---
spec:
  #@overlay/match missing_ok=True
  affinity:
    nodeSelector:
      node.kadras.io/pool: databases
```

### Probes

The API Server can take a long time to start after an upgrade, while it migrates the database. Its startup probe allows 30 minutes. Extend it for large databases.

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "dependency-track-api-server"}})
---
spec:
  template:
    spec:
      containers:
        #@overlay/match by="name"
        - name: dependency-track-api-server
          startupProbe:
            failureThreshold: 120
```

### Database backups

CloudNativePG backs up the database to an object store via a plugin, configured on the Cluster. See the [CloudNativePG documentation](https://cloudnative-pg.io/docs/devel/backup/).

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Cluster", "metadata": {"name": "postgresql-dependency-track"}})
---
spec:
  #@overlay/match missing_ok=True
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true
      parameters:
        barmanObjectName: dependency-track-backups
```
