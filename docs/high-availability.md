# Configuring High Availability

For the Frontend component of Dependency Track, you can customize the number of replicas
to achieve high availability.

```yaml
frontend:
  replicas: 3
```

The API Server component doesn't support horizontal scaling by design and it's therefore deployed
as a StatefulSet with a single instance.

The PostgreSQL database is deployed via the CloudNativePG Operator and supports a highly availability setup
with one read/write instance and multiple read-only replicas.

```yaml
postgresql:
  instances: 3
```
