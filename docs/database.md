# Configuring the Database

Dependency Track stores everything it persists in PostgreSQL, deployed via the [CloudNativePG Operator](https://github.com/kadras-io/package-for-postgresql-operator). PostgreSQL usually becomes the bottleneck before the API Server does, so it's worth tuning for anything beyond an evaluation deployment.

## Sizing

The Dependency Track documentation recommends starting from 8 GB of memory and 4 CPU cores for the database, and not going below 4 GB and 2 cores even for evaluation workloads.

For production, run at least three instances so that a failure of the read/write one doesn't take Dependency Track down.

```yaml
postgresql:
  instances: 3
  storage:
    size: 50Gi
```

## Configuration parameters

The default PostgreSQL configuration is deliberately conservative, so that it runs on minimal hardware. This package applies two settings recommended by Dependency Track for the workload it generates:

* `jit=off`, because Dependency Track's workload is dominated by short, latency-sensitive queries, where just-in-time compilation costs more than it saves. PostgreSQL 19 changes the default to `off` for the same reason.
* `wal_compression=zstd`, because importing BOMs fills the write-ahead log quickly, making the database I/O bound. Compressing the WAL trades a little CPU for significantly less I/O.

Both can be overridden, and any other parameter can be added, via `postgresql.parameters`.

```yaml
postgresql:
  parameters:
    max_connections: 200
    shared_buffers: "2GB"
    effective_cache_size: "6GB"
```

[PGTune](https://pgtune.leopard.in.ua) gives a sensible baseline for the memory settings, given the resources available to the database. Select `Online transaction processing system` as the DB type.

## Connections

Each API Server replica maintains its own connection pool, sized by `dt.datasource.pool.max-size` (30 by default). The database must be able to accept all of them at once, plus headroom for migrations, backups, and administrator sessions:

```text
max_connections >= api_server.replicas × dt.datasource.pool.max-size + headroom
```

With the PostgreSQL default of 100 connections, three API Server replicas already consume 90. Either raise `max_connections` or lower the pool size.

```yaml
api_server:
  replicas: 3
  config:
    dt.datasource.pool.max-size: 20
postgresql:
  parameters:
    max_connections: 200
```

Above roughly five replicas, a centralised connection pooler such as PgBouncer becomes the better option. That's not supported by this package.

## Autovacuum

The `COMPONENT` table sees frequent inserts, updates, and deletes, which produces a lot of dead tuples. The default autovacuum threshold kicks in too late on such a table, and because autovacuum also runs `ANALYZE`, slow vacuuming leads the query planner to choose inefficient execution plans.

This is a table-level setting, so it can't be applied via `postgresql.parameters`. Run it once against the database:

```sql
ALTER TABLE "COMPONENT" SET (AUTOVACUUM_VACUUM_SCALE_FACTOR = 0.02);
```

Alternatively, since the database is dedicated to Dependency Track, you can lower the threshold for every table.

```yaml
postgresql:
  parameters:
    autovacuum_vacuum_scale_factor: "0.02"
```

For more information, check the Dependency Track documentation for [configuring the database](https://dependencytrack.github.io/docs/next/guides/administration/configuring-database/).
