# Configuring High Availability

For the Frontend component of Dependency Track, you can customize the number of replicas
to achieve high availability.

```yaml
frontend:
  replicas: 3
```

Starting from Dependency Track 5, the API Server component is stateless and it's deployed as a
Deployment that can be scaled horizontally. The only shared state left on disk is the file storage
used for BOMs and other uploaded artifacts, which is backed by a PersistentVolume. By default, that
volume is created with the `ReadWriteOnce` access mode, so a single replica is used.

To run more than one API Server replica, the volume must be shared across Pods. Use a storage class
supporting the `ReadWriteMany` access mode (such as EFS, Azure Files, or CephFS).

```yaml
api_server:
  replicas: 3
  storage:
    class_name: efs-sc
    access_modes: ["ReadWriteMany"]
```

When a component runs more than one replica, a `PodDisruptionBudget` is created for it, keeping at least one Pod available during voluntary disruptions such as node drains.

The PostgreSQL database is deployed via the CloudNativePG Operator and supports a highly availability setup
with one read/write instance and multiple read-only replicas.

```yaml
postgresql:
  instances: 3
```
