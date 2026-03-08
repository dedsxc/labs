# cnpg-cluster

> **RAG-optimized reference document.** This file is the authoritative source of truth for any
> AI agent generating or reviewing `cnpg-cluster` configurations. Every schema key, type,
> default value, constraint, behavioral rule, and generated resource is documented here.
>
> **Authoritative version**: always check `Chart.yaml` — `grep '^version:' Chart.yaml`
>
> ⚠️ **Schema validity**: when the chart version changes, verify breaking changes in `CHANGELOG.md` before generating new configurations.

A production-ready Helm chart for deploying PostgreSQL clusters using the
[CloudNativePG](https://cloudnative-pg.io/) operator on Kubernetes.

**Type:** Application | **Operator required:** CloudNativePG >= 1.28.0

## Table of Contents

- [cnpg-cluster](#cnpg-cluster)
  - [Table of Contents](#table-of-contents)
  - [Architecture](#architecture)
  - [Prerequisites and cluster operators](#prerequisites-and-cluster-operators)
  - [What this chart generates](#what-this-chart-generates)
  - [Quick start](#quick-start)
  - [Schema reference](#schema-reference)
    - [cluster](#cluster)
      - [cluster.image vs cluster.imageCatalogRef](#clusterimage-vs-clusterimagecatalogref)
      - [cluster.storage and cluster.walStorage](#clusterstorage-and-clusterwalstroage)
      - [cluster.postgresql](#clusterpostgresql)
      - [cluster.roles](#clusterroles)
      - [cluster.bootstrap](#clusterbootstrap)
      - [cluster.externalClusters](#clusterexternalclusters)
      - [cluster.plugins](#clusterplugins)
      - [cluster.backup](#clusterbackup)
      - [cluster.monitoring and cluster.podMonitor](#clustermonitoring-and-clusterpodmonitor)
      - [cluster.externalService](#clusterexternalservice)
    - [database](#database)
      - [database.list entry](#databaselist-entry)
      - [database.list[].extensions](#databaselistextensions)
      - [database.list[].schemas](#databaselistschemas)
      - [database.list[].logicalReplication](#databaselistlogicalreplication)
      - [database.list[].recovery](#databaselistrecovery)
    - [scheduledBackup](#scheduledbackup)
      - [scheduledBackup.plugin](#scheduledbackupplugin)
      - [scheduledBackup.volumeSnapshot](#scheduledbackupvolumesnapshot)
    - [objectStore](#objectstore)
  - [Generated resources reference](#generated-resources-reference)
  - [Service endpoints](#service-endpoints)
  - [Secret format (auto-generated per database)](#secret-format-auto-generated-per-database)
  - [Production-ready examples](#production-ready-examples)
    - [Minimal single-instance cluster](#minimal-single-instance-cluster)
    - [HA cluster with multiple databases, monitoring, and S3 backup](#ha-cluster-with-multiple-databases-monitoring-and-s3-backup)
    - [Bootstrap from S3 backup (disaster recovery)](#bootstrap-from-s3-backup-disaster-recovery)
    - [Database with extensions, schemas, and logical replication](#database-with-extensions-schemas-and-logical-replication)
    - [Database migration with pgcopydb](#database-migration-with-pgcopydb)
    - [VolumeSnapshot scheduled backup](#volumesnapshot-scheduled-backup)
  - [Useful commands](#useful-commands)
  - [Critical conventions and known gotchas](#critical-conventions-and-known-gotchas)
  - [Troubleshooting](#troubleshooting)
  - [Values reference index](#values-reference-index)

---

## Architecture

```
cnpg-cluster chart
├── templates/cluster.yaml         → postgresql.cnpg.io/v1 Cluster CRD
├── templates/database.yaml        → postgresql.cnpg.io/v1 Database CRD (1 per database.list entry)
│                                    + external-secrets.io/v1 ExternalSecret (if autoGeneratePassword)
│                                    + postgresql.cnpg.io/v1 Publication (if logicalReplication.publication)
│                                    + postgresql.cnpg.io/v1 Subscription (if logicalReplication.subscription)
│                                    + batch/v1 Job (if recovery.enabled)
├── templates/superUserPassword.yaml → external-secrets.io/v1 ExternalSecret (superuser password)
├── templates/backup.yaml          → postgresql.cnpg.io/v1 ScheduledBackup (plugin and/or volumeSnapshot)
│                                    + v1 ServiceAccount / Role / RoleBinding / CronJob (retention cleaner)
├── templates/objectStore.yaml     → barmancloud.cnpg.io/v1 ObjectStore
├── templates/podMonitor.yaml      → monitoring.coreos.com/v1 PodMonitor
└── templates/svc.yaml             → v1 Service (LoadBalancer, only when externalService.enabled)
```

**Cluster naming rule:** `cluster.clusterName` defaults to `{{ .Release.Name }}-cluster`.
All internal Kubernetes Service names follow the CNPG convention:
- `<clusterName>-rw` — read/write (primary)
- `<clusterName>-r` — read-only (any replica)
- `<clusterName>-ro` — read-only (replicas only, never primary)

---

## Prerequisites and cluster operators

| Component | Version | Purpose |
|---|---|---|
| Kubernetes | >= 1.28 | Required by CNPG operator |
| Helm | >= 3.12 | Chart deployment |
| CloudNativePG operator | >= 1.28.0 | Manages Cluster/Database CRDs |
| External Secrets Operator | >= 0.10 | Auto-generates DB passwords via `ClusterGenerator` named `password-cluster-generator` |
| Barman Cloud plugin | >= 0.5 (optional) | S3/MinIO/GCS/Azure WAL archiving and backup |
| Prometheus Operator | any (optional) | PodMonitor scraping |
| VolumeSnapshot CRDs | any (optional) | VolumeSnapshot-based backups |

> **Hard dependency:** `autoGeneratePassword: true` (the default) requires the External Secrets
> Operator and a `ClusterGenerator` named **`password-cluster-generator`** to exist in the
> same namespace. Without it, the chart renders but ExternalSecret objects will fail to reconcile.

---

## What this chart generates

| Condition | Generated resource(s) |
|---|---|
| Always | `Cluster` (CNPG) |
| Always | `ExternalSecret` for superuser password |
| Per `database.list` entry | `Database` (CNPG) |
| Per `database.list` entry where `autoGeneratePassword: true` | `ExternalSecret` (password + connection URI) |
| Per `database.list` entry where `logicalReplication.publication.enabled: true` | `Publication` (CNPG) |
| Per `database.list` entry where `logicalReplication.subscription.enabled: true` | `Subscription` (CNPG) |
| Per `database.list` entry where `recovery.enabled: true` | `Job` (pgcopydb migration, PostSync ArgoCD hook) |
| `scheduledBackup.plugin.enabled: true` | `ScheduledBackup` (barman-cloud method) |
| `scheduledBackup.volumeSnapshot.enabled: true` | `ScheduledBackup` (volumeSnapshot method) + `ServiceAccount` + `Role` + `RoleBinding` + `CronJob` (retention cleaner) |
| `objectStore.enabled: true` | `ObjectStore` (barmancloud.cnpg.io) |
| `cluster.podMonitor.enabled: true` | `PodMonitor` |
| `cluster.externalService.enabled: true` | `Service` (LoadBalancer) |

---

## Quick start

```bash
# Minimal install — single instance, no backup, no external service
helm upgrade --install my-postgres . \
  --set cluster.instances=1 \
  --set cluster.storage.storageClass=standard \
  --set cluster.walStorage.storageClass=standard \
  --namespace postgresql --create-namespace

# With a values file (recommended)
helm upgrade --install my-postgres . -f values-prod.yaml -n postgresql --create-namespace

# Dry-run to inspect all generated manifests
helm template my-postgres . -f values-prod.yaml -n postgresql
```

---

## Schema reference

### cluster

```yaml
cluster:
  clusterName: ""              # string — default: "{{ .Release.Name }}-cluster"
  instances: 2                 # int — number of PostgreSQL instances (1=single, 2+=HA)
  annotations: {}              # map[string]string — on the Cluster resource
  affinity: {}                 # map — Kubernetes affinity for cluster pods
  imagePullSecrets: []         # list[{name: string}] — registry pull secrets
                               #   e.g. [{name: private-registries}]

  # Image — choose ONE of imageCatalogRef OR image.name (see below)
  imageCatalogRef: {}          # map — reference to a ClusterImageCatalog CRD
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:...
                               # string — full image reference (repository:tag@digest)
    pullPolicy: IfNotPresent   # Always | IfNotPresent | Never

  storage:
    storageClass: openebs-hostpath   # string — storage class for data PVC
    size: 8Gi                         # string — data PVC size
  walStorage:
    storageClass: openebs-hostpath   # string — storage class for WAL PVC
    size: 1Gi                         # string — WAL PVC size (recommended: 3–5× max_wal_size)

  resources: {}                # map — standard Kubernetes resources (requests/limits)

  superuserSecret: superuser-secret   # string — name of the ExternalSecret/Secret for postgres superuser
  enableSuperuserAccess: true         # bool — grants superuser access to the postgres user
  refreshPasswordInterval: 0s         # string — ESO refresh interval for superuser secret ("0s" = refresh once)

  roles: []                    # list — managed roles (see cluster.roles below)
  bootstrap: {}                # map — bootstrap method (initdb or recovery)
  externalClusters: []         # list — external clusters for recovery or replication
  plugins: []                  # list — CNPG plugins (e.g. barman-cloud)
  backup: {}                   # map — backup configuration (barmanObjectStore, volumeSnapshot, etc.)
  monitoring: {}               # map — CNPG monitoring configuration
  podMonitor:
    enabled: false             # bool — creates a PodMonitor for Prometheus Operator

  externalService:
    enabled: false             # bool — creates a LoadBalancer Service
    targetInstanceRole: primary  # primary | replica
```

#### cluster.image vs cluster.imageCatalogRef

Use **`imageCatalogRef`** to reference a cluster-level `ClusterImageCatalog` CRD (recommended for
managing upgrades centrally). Use **`image.name`** for a direct image pin.

```yaml
# Option A — ImageCatalog (recommended for version management)
cluster:
  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ClusterImageCatalog
    name: postgresql-standard-trixie
    major: 18

# Option B — Direct image pin
cluster:
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
```

> **Rule:** If `imageCatalogRef.name` is set and non-empty, `imageCatalogRef` takes precedence
> and `image.name` is ignored.

#### cluster.storage and cluster.walStorage

```yaml
cluster:
  storage:
    storageClass: openebs-lvmpv   # Use a RWO storage class
    size: 32Gi
  walStorage:
    storageClass: openebs-lvmpv
    size: 27Gi                    # Recommended: 3–5× max_wal_size (default max_wal_size=1GB → 3–5Gi)
```

> **Rule:** WAL and data storage use separate PVCs. They can use different storage classes.
> Both PVCs are created and managed by the CNPG operator; they are NOT deleted on `helm uninstall`.

#### cluster.postgresql

Full pass-through to the CNPG `Cluster.spec.postgresql` field.

```yaml
cluster:
  postgresql:
    parameters:
      max_connections: "300"
      min_wal_size: "2GB"
      max_wal_size: "8GB"
      # pg_stat_monitor tuning
      pg_stat_monitor.pgsm_query_max_len: "4096"
      pg_stat_monitor.pgsm_normalized_query: "0"
      pg_stat_monitor.pgsm_enable_query_plan: "on"
      # pg_stat_statements tuning
      pg_stat_statements.max: "10000"
      pg_stat_statements.track: "all"
      pg_stat_statements.track_utility: "off"
    shared_preload_libraries:
      - pg_stat_statements
      - pg_stat_monitor
```

> **Rule:** All values under `parameters` must be **strings** (even numeric values like `"300"`).

#### cluster.roles

Managed roles are created and kept in sync by the CNPG operator.

```yaml
cluster:
  roles:
    - name: myapp
      ensure: present          # present | absent
      superuser: false
      login: true
      createdb: true
      inherit: true
      replication: false
      connectionLimit: -1      # int (-1 = unlimited)
      inRoles:                 # list[string] — PostgreSQL roles to inherit from
        - pg_read_all_data
      passwordSecret:
        name: myapp-cnpg       # name of the Kubernetes Secret containing the password
```

#### cluster.bootstrap

**Fresh cluster (initdb):**

```yaml
cluster:
  bootstrap:
    initdb:
      database: app
      owner: app
      dataChecksums: true
      encoding: UTF8
      postInitSQL:
        - CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

**Restore from S3 backup (recovery):**

```yaml
cluster:
  bootstrap:
    recovery:
      source: postgresql-cluster   # must match a name in cluster.externalClusters

  externalClusters:
    - name: postgresql-cluster
      plugin:
        name: barman-cloud.cloudnative-pg.io
        enabled: true
        isWALArchiver: false
        parameters:
          barmanObjectName: minio-store   # name of the ObjectStore resource
          serverName: postgresql-cluster  # name of the source cluster in the backup
```

#### cluster.externalClusters

Used for recovery and logical replication sources.

```yaml
cluster:
  externalClusters:
    - name: origin-cluster
      plugin:
        name: barman-cloud.cloudnative-pg.io
        enabled: true
        isWALArchiver: false
        parameters:
          barmanObjectName: s3-storage
          serverName: origin-cluster
```

#### cluster.plugins

```yaml
cluster:
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true          # enables continuous WAL archiving
      parameters:
        barmanObjectName: s3-storage   # name of the ObjectStore resource
```

#### cluster.backup

Full pass-through to `Cluster.spec.backup`. Used with barman-cloud plugin for PITR.

```yaml
cluster:
  backup:
    retentionPolicy: "30d"
    barmanObjectStore:
      endpointURL: http://s3.minio.svc.cluster.local:9000
      destinationPath: s3://backups/postgresql
      s3Credentials:
        accessKeyId:
          name: minio-secret
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: minio-secret
          key: ACCESS_SECRET_KEY
      wal:
        compression: gzip
```

#### cluster.monitoring and cluster.podMonitor

```yaml
cluster:
  monitoring: {}          # map — passed directly to Cluster.spec.monitoring

  podMonitor:
    enabled: false        # bool — creates a monitoring.coreos.com/v1 PodMonitor
                          # The PodMonitor targets pods with label cnpg.io/cluster=<clusterName>
                          # and scrapes the `metrics` port.
```

#### cluster.externalService

Creates a `LoadBalancer` Service pointing to the primary (or replica) instance.

```yaml
cluster:
  externalService:
    enabled: true
    targetInstanceRole: primary   # primary | replica
# Generated: Service/<release-name>-lb (type: LoadBalancer, port: 5432)
# Selector: cnpg.io/cluster=<clusterName>, cnpg.io/instanceRole=primary
```

---

### database

```yaml
database:
  autoGeneratePassword: true        # bool — generates an ExternalSecret per DB using the
                                    # ClusterGenerator named "password-cluster-generator"
  refreshPasswordInterval: 0s       # string — ESO refresh interval ("0s" = once, "1h" = hourly)
  databaseReclaimPolicy: retain     # retain | delete — what happens to the DB when the
                                    # Database CRD is deleted
  list: []                          # list — database entries (see below)
```

#### database.list entry

```yaml
database:
  list:
    - name: myapp                   # string — REQUIRED — PostgreSQL database name
      owner: myapp_user             # string — REQUIRED — database owner role
      secretName: myapp-cnpg        # string — defaults to name; name of the generated Secret
      autoGeneratePassword:         # bool — per-database override of database.autoGeneratePassword
      databaseReclaimPolicy:        # retain | delete — per-database override
      extensions: []                # list — see below
      schemas: []                   # list — see below
      logicalReplication: {}        # map — see below
      recovery: {}                  # map — see below
```

#### database.list[].extensions

```yaml
      extensions:
        - name: pg_stat_monitor     # string — extension name
          ensure: present           # present | absent
        - name: postgis
          ensure: present
        - name: vector
          ensure: present
```

#### database.list[].schemas

```yaml
      schemas:
        - name: analytics           # string — schema name
          owner: myapp_user         # string — schema owner
          ensure: present           # present | absent
```

#### database.list[].logicalReplication

Used for zero-downtime major version upgrades (publish on old cluster, subscribe on new).
**Mutually exclusive:** enable either `publication` or `subscription`, not both for the same database.

```yaml
      logicalReplication:
        publication:
          enabled: false
          target:
            # allTables: true
            objects:
              - tablesInSchema: public
        subscription:
          enabled: false
          externalClusterName: origin-cluster   # must match a cluster.externalClusters[].name
                                                # REQUIRED when subscription.enabled=true
```

> **Rule:** When `subscription.enabled: true`, `externalClusterName` is **required** — the chart
> will `fail` at render time if it is missing.

#### database.list[].recovery

Triggers a one-shot `pgcopydb clone` Job (ArgoCD PostSync hook) to migrate data from a source
PostgreSQL instance. Requires `pgcopydb` in the container image.

```yaml
      recovery:
        enabled: false
        imageName: ghcr.io/cloudnative-pg/postgresql:16.2-16   # image with pgcopydb installed
        dbSourceHost: old-postgres.example.com                  # string — REQUIRED
        dbSourcePort: "5432"                                     # string — default "5432"
        dbSourceSecretName: old-db-secret                        # string — REQUIRED
                                                                 # Secret must contain DB_USERNAME, DB_PASSWORD, DB_DATABASE
        tableJobs: "48"                                          # string — pgcopydb --table-jobs
        indexJobs: "16"                                          # string — pgcopydb --index-jobs
```

> **Result:** Creates a `batch/v1 Job` with `restartPolicy: Never` and `backoffLimit: 1`.
> The job clones the source DB into the target without roles, owners, ACLs, comments, or extensions
> (`--no-role-passwords --no-owner --no-acl --no-comments --skip-extensions --drop-if-exists`).
> The ArgoCD annotation `argocd.argoproj.io/hook: PostSync` ensures it runs after all resources sync.

---

### scheduledBackup

#### scheduledBackup.plugin

Requires the barman-cloud CNPG plugin installed in the cluster.

```yaml
scheduledBackup:
  plugin:
    enabled: false
    scheduledBackup: "0 0 0 * * *"           # string — cron expression (6 fields: sec min hour dom mon dow)
    name: barman-cloud.cloudnative-pg.io      # string — plugin name
# Generated: ScheduledBackup/<release-name>-cluster-plugin-backup
# spec.method: plugin | spec.pluginConfiguration.name: barman-cloud.cloudnative-pg.io
```

#### scheduledBackup.volumeSnapshot

Requires VolumeSnapshot CRDs and a CSI driver that supports snapshots.

```yaml
scheduledBackup:
  volumeSnapshot:
    enabled: false
    scheduledBackup: "0 0 0 * * *"           # string — cron expression (6 fields)
    retentionDays: 7                          # int — snapshots older than N days are deleted
    retentionImage: "debian:trixie-slim"      # string — image used by the retention cleaner CronJob
                                              # MUST contain curl and jq
# Generated:
#   ScheduledBackup/<release-name>-cluster-volumesnapshot-backup (method: volumeSnapshot)
#   ServiceAccount/volume-snapshot-deleter-sa
#   Role/volume-snapshot-deleter (verbs: get/list/watch/delete on volumesnapshots)
#   RoleBinding/volume-snapshots-deleter-binding
#   CronJob/volume-snapshot-retention-cleaner (runs daily at midnight)
```

---

### objectStore

Creates a `barmancloud.cnpg.io/v1 ObjectStore` resource. Required when using the barman-cloud
plugin for WAL archiving or backup.

```yaml
objectStore:
  enabled: false
  name: s3-storage                  # string — name of the ObjectStore resource
  spec:
    configuration:
      destinationPath: s3://backup  # string — S3 path
      endpointURL: http://s3.minio.svc.cluster.local:9000   # string — S3-compatible endpoint
      s3Credentials:
        accessKeyId:
          name: s3-minio-secret     # Secret name containing the key
          key: MINIO_ROOT_USER      # Key name in the Secret (must be ACCESS_KEY_ID or MINIO_ROOT_USER)
        secretAccessKey:
          name: s3-minio-secret
          key: MINIO_ROOT_PASSWORD  # Key name (must be ACCESS_SECRET_KEY or MINIO_ROOT_PASSWORD)
      wal:
        compression: gzip           # none | gzip | bzip2 | snappy
    retentionPolicy: 30d            # string — backup retention duration
```

---

## Generated resources reference

### Service endpoints

The CNPG operator automatically creates the following Services (not managed by this chart):

| Service name | Type | Target | Use |
|---|---|---|---|
| `<clusterName>-rw` | ClusterIP | Primary instance | Read-write connections |
| `<clusterName>-r` | ClusterIP | Any instance | Read-only load-balanced |
| `<clusterName>-ro` | ClusterIP | Replica instances only | Read-only, never primary |
| `<release-name>-lb` | LoadBalancer | Configurable | External access (optional) |

### Secret format (auto-generated per database)

When `database.autoGeneratePassword: true`, an `ExternalSecret` is created per database entry.
The resulting Kubernetes `Secret` contains:

| Key | Value |
|---|---|
| `username` | value of `database.list[].owner` |
| `password` | auto-generated password from `ClusterGenerator` |
| `DB_HOST` | `<clusterName>-rw` |
| `DB_HOST_RO` | `<clusterName>-r` |
| `DB_DATABASE` | value of `database.list[].name` |
| `DB_CONNECTION_URI` | `postgres://<owner>:<password>@<clusterName>-rw:5432/<name>` |
| `DB_CONNECTION_URI_RO` | `postgres://<owner>:<password>@<clusterName>-r:5432/<name>` |

The generated Secret also carries label `cnpg.io/reload: "true"` so the CNPG operator
hot-reloads credentials without a pod restart.

---

## Production-ready examples

### Minimal single-instance cluster

```yaml
cluster:
  instances: 1
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
  storage:
    storageClass: standard
    size: 10Gi
  walStorage:
    storageClass: standard
    size: 3Gi
  superuserSecret: superuser-secret
  enableSuperuserAccess: true
  postgresql:
    parameters:
      max_connections: "100"

database:
  autoGeneratePassword: true
  list:
    - name: myapp
      owner: myapp
      secretName: myapp-cnpg
```

---

### HA cluster with multiple databases, monitoring, and S3 backup

```yaml
cluster:
  instances: 3

  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ClusterImageCatalog
    name: postgresql-standard-trixie
    major: 18

  imagePullSecrets:
    - name: private-registries

  storage:
    storageClass: openebs-lvmpv
    size: 32Gi
  walStorage:
    storageClass: openebs-lvmpv
    size: 27Gi

  resources:
    requests:
      cpu: "1"
      memory: 2Gi
    limits:
      memory: 4Gi

  superuserSecret: superuser-postgres
  enableSuperuserAccess: true
  refreshPasswordInterval: 0s

  postgresql:
    parameters:
      max_connections: "300"
      min_wal_size: "2GB"
      max_wal_size: "8GB"
      pg_stat_statements.max: "10000"
      pg_stat_statements.track: "all"
      pg_stat_statements.track_utility: "off"
    shared_preload_libraries:
      - pg_stat_statements
      - pg_stat_monitor

  roles:
    - name: prometheus
      ensure: present
      superuser: true
      login: true
      createdb: false
      inRoles:
        - pg_monitor
      passwordSecret:
        name: prometheus-cnpg
    - name: manager
      ensure: present
      inherit: true
      superuser: false
      login: true
      createdb: false
      connectionLimit: -1
      inRoles:
        - pg_read_all_data
      passwordSecret:
        name: manager-secret

  podMonitor:
    enabled: true

  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true
      parameters:
        barmanObjectName: minio-store

  externalService:
    enabled: true
    targetInstanceRole: primary

database:
  autoGeneratePassword: true
  databaseReclaimPolicy: retain
  list:
    - name: authentik
      owner: authentik
      secretName: authentik-cnpg
      extensions:
        - name: pg_stat_monitor
          ensure: present
    - name: bitwarden
      owner: bitwarden_user
      secretName: bitwarden-cnpg
      extensions:
        - name: pg_stat_monitor
          ensure: present
    - name: umami
      owner: umami
      secretName: umami-cnpg

scheduledBackup:
  plugin:
    enabled: true
    scheduledBackup: "0 0 0 * * *"
    name: barman-cloud.cloudnative-pg.io

objectStore:
  enabled: true
  name: minio-store
  spec:
    configuration:
      destinationPath: s3://postgresql-backup
      endpointURL: http://minio.minio-distributed.svc.cluster.local:9000
      s3Credentials:
        accessKeyId:
          name: minio-distributed
          key: MINIO_ROOT_USER
        secretAccessKey:
          name: minio-distributed
          key: MINIO_ROOT_PASSWORD
      wal:
        compression: gzip
    retentionPolicy: 30d
```

---

### Bootstrap from S3 backup (disaster recovery)

```yaml
cluster:
  instances: 1

  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ClusterImageCatalog
    name: postgresql-standard-trixie
    major: 18

  storage:
    storageClass: openebs-lvmpv
    size: 32Gi
  walStorage:
    storageClass: openebs-lvmpv
    size: 27Gi

  superuserSecret: superuser-postgres

  bootstrap:
    recovery:
      source: postgresql-cluster    # must match externalClusters[].name

  externalClusters:
    - name: postgresql-cluster
      plugin:
        name: barman-cloud.cloudnative-pg.io
        enabled: true
        isWALArchiver: false
        parameters:
          barmanObjectName: minio-store      # must match objectStore.name
          serverName: postgresql-cluster     # name of the originating cluster in the backup

objectStore:
  enabled: true
  name: minio-store
  spec:
    configuration:
      destinationPath: s3://postgresql-backup
      endpointURL: http://minio.minio-distributed.svc.cluster.local:9000
      s3Credentials:
        accessKeyId:
          name: minio-distributed
          key: MINIO_ROOT_USER
        secretAccessKey:
          name: minio-distributed
          key: MINIO_ROOT_PASSWORD

database:
  autoGeneratePassword: true
  list:
    - name: myapp
      owner: myapp
      secretName: myapp-cnpg
```

---

### Database with extensions, schemas, and logical replication

```yaml
database:
  autoGeneratePassword: true
  list:
    - name: analytics
      owner: analytics_user
      secretName: analytics-cnpg
      extensions:
        - name: pg_stat_monitor
          ensure: present
        - name: postgis
          ensure: present
        - name: timescaledb
          ensure: present
      schemas:
        - name: raw
          owner: analytics_user
          ensure: present
        - name: reporting
          owner: analytics_user
          ensure: present
      logicalReplication:
        publication:
          enabled: true
          target:
            objects:
              - tablesInSchema: public
```

---

### Database migration with pgcopydb

```yaml
database:
  autoGeneratePassword: true
  list:
    - name: legacy_app
      owner: legacy_app
      secretName: legacy-app-cnpg
      recovery:
        enabled: true
        imageName: ghcr.io/cloudnative-pg/postgresql:16.2-16  # must have pgcopydb
        dbSourceHost: old-rds.us-east-1.rds.amazonaws.com
        dbSourcePort: "5432"
        dbSourceSecretName: old-rds-secret   # must contain DB_USERNAME, DB_PASSWORD, DB_DATABASE
        tableJobs: "48"
        indexJobs: "16"
```

---

### VolumeSnapshot scheduled backup

```yaml
scheduledBackup:
  volumeSnapshot:
    enabled: true
    scheduledBackup: "0 0 1 * * *"    # daily at 1 AM
    retentionDays: 7
    retentionImage: "debian:trixie-slim"   # must contain curl and jq
```

---

## Useful commands

```bash
# Install / upgrade
helm upgrade --install my-postgres . -f values.yaml -n postgresql --create-namespace

# Dry-run render (inspect all manifests before applying)
helm template my-postgres . -f values.yaml -n postgresql

# Diff current vs new (requires helm-diff plugin)
helm diff upgrade my-postgres . -f values.yaml -n postgresql

# Check cluster status
kubectl get cluster -n postgresql
kubectl describe cluster my-postgres-cluster -n postgresql

# Check all databases
kubectl get database -n postgresql

# Check generated secrets
kubectl get secret -n postgresql -l cnpg.io/reload=true

# Force a manual backup (plugin method)
kubectl cnpg backup my-postgres-cluster -n postgresql

# Check backup status
kubectl get scheduledbackup -n postgresql
kubectl get backup -n postgresql

# Trigger failover (promote a replica)
kubectl cnpg promote my-postgres-cluster/<pod-name> -n postgresql

# Check replication lag
kubectl cnpg status my-postgres-cluster -n postgresql
```

---

## Critical conventions and known gotchas

| # | Rule | Impact if ignored |
|---|---|---|
| 1 | **Cluster name = `{{ .Release.Name }}-cluster` by default.** All service names (`-rw`, `-r`, `-ro`) are derived from this value. | Applications referencing the wrong hostname will fail to connect. |
| 2 | **`autoGeneratePassword: true` requires a `ClusterGenerator` named `password-cluster-generator`** in the same namespace. | ExternalSecret objects will remain `NotReady`; databases will have no credentials. |
| 3 | **All postgresql `parameters` values must be strings.** Even integers: `max_connections: "300"`. | Helm will silently pass an int, causing the CNPG operator to reject the config. |
| 4 | **WAL PVC size should be 3–5× `max_wal_size`** (default `max_wal_size=1GB` → `3–5Gi`). | WAL partition fills up, causing the cluster to stop and go into `Failover`. |
| 5 | **PVCs are NOT deleted on `helm uninstall`.** Data and WAL PVCs persist. | Manual cleanup required after decommissioning. Use `kubectl delete pvc` explicitly. |
| 6 | **`scheduledBackup` cron uses 6 fields** (`sec min hour dom mon dow`), not standard 5-field cron. | Wrong schedule silently accepted; backups never run. |
| 7 | **`logicalReplication.subscription.externalClusterName` is REQUIRED** when `subscription.enabled: true`. | Chart render fails with a Helm `fail` error. |
| 8 | **`recovery.enabled: true` generates a Job with ArgoCD `PostSync` hook.** Outside ArgoCD the Job runs immediately on install. | In ArgoCD, ensure the cluster is fully up before the Job executes (PostSync order). |
| 9 | **`enableSuperuserAccess: false` is the CNPG default;** this chart sets it to `true`. | Superuser access allows unrestricted access — disable in hardened environments. |
| 10 | **`objectStore` and `scheduledBackup.plugin` are independent.** The ObjectStore defines WHERE to store, the plugin backup defines WHEN to trigger. Both are needed for full barman-cloud backup. | Missing ObjectStore means plugin backups will fail at runtime even if the ScheduledBackup is created. |
| 11 | **The generated Secret uses `cnpg.io/reload: "true"` label.** The CNPG operator watches for this label to hot-reload credentials. | Removing this label causes the cluster to not pick up password rotations without a restart. |
| 12 | **`database.databaseReclaimPolicy: retain` (default).** Database CRDs deleted via Helm do NOT drop the PostgreSQL database. | Use `delete` only if you explicitly want the CNPG operator to DROP the database on CRD deletion. |

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Cluster` stuck in `Setting up primary` | Storage class not found, PVC not bound | Check `kubectl get pvc -n <ns>`, verify `storageClass` exists |
| `ExternalSecret` stuck `SecretSyncedError` | `ClusterGenerator` `password-cluster-generator` missing | Install the ESO ClusterGenerator in the namespace |
| Pod `ImagePullBackOff` | `imagePullSecrets` not set or secret missing | Add `cluster.imagePullSecrets: [{name: your-secret}]` |
| Pod `OOMKilled` | Memory limit too low for the workload | Increase `cluster.resources.limits.memory`; check `max_connections` (each connection uses ~5MB) |
| `Cluster` in `Failed` state, WAL errors | WAL PVC full | Increase `walStorage.size`; check `max_wal_size` parameter |
| Application can't connect: `could not connect to server` | Wrong service name or port | Use `<clusterName>-rw:5432` for writes; check `DB_HOST` in the generated Secret |
| `Database` CRD stuck `ReconciliationError` | Role `owner` does not exist in the cluster | Add the role to `cluster.roles` before creating the database |
| `ExternalSecret` not refreshing password | `refreshPasswordInterval: 0s` | Change to `"1h"` or trigger manual sync with `kubectl annotate externalsecret ...` |
| `ScheduledBackup` never triggers | Wrong cron format (5 fields instead of 6) | Use 6-field cron: `"0 0 0 * * *"` (sec min hour dom mon dow) |
| `pgcopydb` Job fails | Missing `DB_USERNAME`/`DB_PASSWORD`/`DB_DATABASE` keys in source secret | Ensure `dbSourceSecretName` Secret has exactly these three keys |
| VolumeSnapshot retention cleaner errors | `curl` or `jq` not in `retentionImage` | Use an image with both: `debian:trixie-slim` or `alpine` with curl+jq installed |

---

## Values reference index

| Top-level key | Controls |
|---|---|
| `cluster` | CNPG `Cluster` CRD: instances, image, storage, WAL, PostgreSQL config, roles, bootstrap, recovery, plugins, backup, monitoring, external service |
| `database.list` | CNPG `Database` CRD per entry + ESO `ExternalSecret` + optional `Publication`/`Subscription`/`Job` |
| `database.autoGeneratePassword` | Whether to create an `ExternalSecret` per database (requires `ClusterGenerator`) |
| `database.databaseReclaimPolicy` | Whether CNPG drops the database when the `Database` CRD is deleted |
| `scheduledBackup.plugin` | CNPG `ScheduledBackup` using barman-cloud plugin |
| `scheduledBackup.volumeSnapshot` | CNPG `ScheduledBackup` using VolumeSnapshot + retention `CronJob` |
| `objectStore` | barmancloud `ObjectStore` CRD (S3/MinIO backend definition) |

3. **Storage:**
   - StorageClass with dynamic provisioning
   - Recommended: Separate storage classes for data and WAL

### Optional Components

- **External Secrets Operator:** For automatic credential management
- **Prometheus Operator:** For metrics collection
- **VolumeSnapshot CRDs:** For snapshot-based backups
- **Object Storage:** S3-compatible storage for Barman backups

---

## Installation

### Add Helm Repository (if published)

```bash
helm repo add myrepo https://charts.example.com
helm repo update
```

### Install from Local Chart

```bash
# Clone the repository
git clone https://github.com/yourusername/labs.git
cd labs/helm/cnpg-cluster

# Install the chart
helm install my-postgres . -n database --create-namespace
```

### Install with Custom Values

```bash
helm install my-postgres . \
  -n database \
  --create-namespace \
  -f values.yaml \
  -f production-overrides.yaml
```

### Verify Installation

```bash
# Check cluster status
kubectl get cluster -n database

# Check pods
kubectl get pods -n database

# Check services
kubectl get svc -n database

# View cluster details
kubectl describe cluster my-postgres-cluster -n database
```

---

## Quick Start

### Minimal Configuration

Create a basic 3-instance PostgreSQL 18 cluster:

```yaml
# values.yaml
cluster:
  instances: 3
  
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
  
  storage:
    storageClass: fast-ssd
    size: 20Gi
  
  walStorage:
    storageClass: fast-ssd
    size: 5Gi
  
  postgresql:
    parameters:
      max_connections: "500"

database:
  autoGeneratePassword: true
  list:
    - name: myapp
      owner: myapp_user
```

Install:
```bash
helm install my-postgres . -n database --create-namespace
```

Connect to the database:
```bash
# Get the generated password
kubectl get secret myapp-secret -n database -o jsonpath='{.data.password}' | base64 -d

# Connect to primary (read-write)
kubectl port-forward svc/my-postgres-cluster-rw 5432:5432 -n database
psql postgresql://myapp_user:<password>@localhost:5432/myapp

# Connect to replicas (read-only)
kubectl port-forward svc/my-postgres-cluster-r 5432:5432 -n database
```

---

## Configuration Guide

### Cluster Configuration

#### Basic Cluster Settings

```yaml
cluster:
  # Cluster name (default: <release-name>-cluster)
  clusterName: "production-db"
  
  # Number of instances (min 1, recommended 3+ for HA)
  instances: 3
  
  # Annotations for the cluster resource
  annotations:
    description: "Production PostgreSQL cluster"
  
  # Affinity rules for pod scheduling
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values: [postgres]
            topologyKey: kubernetes.io/hostname
```

#### Image Configuration

**Using Image Catalog (Recommended):**
```yaml
cluster:
  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ClusterImageCatalog
    name: postgresql-standard-trixie
    major: 18
```

**Direct Image Specification:**
```yaml
cluster:
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
    pullPolicy: IfNotPresent
  
  imagePullSecrets:
    - name: private-registry
```

#### Storage Configuration

```yaml
cluster:
  # Primary data storage
  storage:
    storageClass: fast-ssd
    size: 100Gi
  
  # WAL storage (write-ahead logs)
  walStorage:
    storageClass: fast-ssd
    size: 20Gi
```

**Storage Best Practices:**
- Use separate storage classes for data and WAL
- Data: High capacity, good IOPS
- WAL: Lower capacity, very high IOPS and throughput
- Consider local SSDs for maximum performance

#### Resource Management

```yaml
cluster:
  resources:
    limits:
      cpu: "4"
      memory: 8Gi
    requests:
      cpu: "2"
      memory: 4Gi
```

**Resource Sizing Guidelines:**
- **Small workload:** 1-2 CPU, 2-4Gi memory
- **Medium workload:** 2-4 CPU, 4-8Gi memory
- **Large workload:** 4-8 CPU, 8-16Gi memory
- **Memory:** Should be 2x-4x the size of your dataset for caching

#### PostgreSQL Configuration

```yaml
cluster:
  postgresql:
    parameters:
      # Connection limits
      max_connections: "500"
      
      # Memory settings
      shared_buffers: "2GB"
      effective_cache_size: "6GB"
      work_mem: "64MB"
      maintenance_work_mem: "512MB"
      
      # Write performance
      wal_buffers: "16MB"
      checkpoint_completion_target: "0.9"
      max_wal_size: "4GB"
      
      # Query optimization
      random_page_cost: "1.1"
      effective_io_concurrency: "200"
      
      # Logging
      log_statement: "all"
      log_duration: "on"
      log_min_duration_statement: "1000"
    
    # Enable extensions
    shared_preload_libraries:
      - pg_stat_statements
      - auto_explain
      - pgaudit
```

#### Superuser Management

```yaml
cluster:
  # Enable superuser access (disable in production)
  enableSuperuserAccess: false
  
  # Secret containing superuser credentials
  superuserSecret: postgres-superuser-secret
  
  # Refresh password interval (0s = never)
  refreshPasswordInterval: 0s
```

#### Managed Roles

```yaml
cluster:
  roles:
    - name: readonly_user
      ensure: present
      superuser: false
      login: true
      createdb: false
      passwordSecret:
        name: readonly-user-secret
    
    - name: app_admin
      ensure: present
      superuser: false
      login: true
      createdb: true
      passwordSecret:
        name: app-admin-secret
```

---

### Database Management

#### Database Provisioning

```yaml
database:
  # Auto-generate passwords for all databases
  autoGeneratePassword: true
  
  # Password refresh interval
  refreshPasswordInterval: 0s
  
  # Reclaim policy: retain | delete
  databaseReclaimPolicy: retain
  
  list:
    - name: app_production
      owner: app_user
      secretName: app-db-secret
      
      # Per-database password generation override
      autoGeneratePassword: true
      
      # Per-database reclaim policy override
      databaseReclaimPolicy: retain
      
      # Enable extensions
      extensions:
        - name: pg_stat_statements
          ensure: present
        - name: pgcrypto
          ensure: present
        - name: uuid-ossp
          ensure: present
      
      # Create schemas
      schemas:
        - name: audit
          owner: app_user
          ensure: present
        - name: analytics
          owner: readonly_user
          ensure: present
```

#### Database Recovery

Restore a database from another PostgreSQL instance using pgcopydb:

```yaml
database:
  list:
    - name: restored_db
      owner: db_user
      secretName: restored-db-secret
      
      recovery:
        enabled: true
        # Image must contain pgcopydb
        imageName: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie
        dbSourceHost: old-postgres.example.com
        dbSourceSecretName: source-db-credentials
```

The recovery job will:
1. Create the target database
2. Use pgcopydb to copy schema and data
3. Clean up after completion

#### Logical Replication

**Publication (Source Database):**
```yaml
database:
  list:
    - name: myapp
      owner: myapp_user
      
      logicalReplication:
        publication:
          enabled: true
          target:
            allTables: true
```

**Subscription (Target Database):**
```yaml
cluster:
  externalClusters:
    - name: source-cluster
      connectionParameters:
        host: source-postgres-cluster-rw
        user: myapp_user
        dbname: myapp
      password:
        name: source-db-secret
        key: password

database:
  list:
    - name: myapp
      owner: myapp_user
      
      logicalReplication:
        subscription:
          enabled: true
          externalClusterName: source-cluster
```

**Use Case:** Zero-downtime PostgreSQL major version upgrades

---

### Backup Strategies

#### Plugin-Based Backup (Barman Cloud)

**Prerequisites:**
- S3-compatible object storage (AWS S3, MinIO, GCS, Azure Blob)
- Object store configuration

```yaml
# Configure object storage
objectStore:
  enabled: true
  name: s3-backup-storage
  spec:
    configuration:
      destinationPath: s3://my-backups/postgres
      endpointURL: https://s3.us-east-1.amazonaws.com
      
      s3Credentials:
        accessKeyId:
          name: s3-credentials
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: s3-credentials
          key: AWS_SECRET_ACCESS_KEY
      
      wal:
        compression: gzip
        encryption: AES256
    
    retentionPolicy: "30d"

# Enable backup plugin
cluster:
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true
      parameters:
        barmanObjectName: s3-backup-storage
  
  backup:
    barmanObjectStore:
      destinationPath: s3://my-backups/postgres
      s3Credentials:
        accessKeyId:
          name: s3-credentials
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: s3-credentials
          key: AWS_SECRET_ACCESS_KEY
      
      wal:
        compression: gzip
    
    retentionPolicy: "30d"

# Schedule backups
scheduledBackup:
  plugin:
    enabled: true
    scheduledBackup: "0 2 * * *"  # Daily at 2 AM
    name: barman-cloud.cloudnative-pg.io
```

#### VolumeSnapshot-Based Backup

**Prerequisites:**
- VolumeSnapshot CRDs installed
- StorageClass with snapshot support

```yaml
scheduledBackup:
  volumeSnapshot:
    enabled: true
    scheduledBackup: "0 3 * * *"  # Daily at 3 AM
    retentionDays: 7
    retentionImage: "debian:trixie-slim"  # Must contain curl and jq
```

**VolumeSnapshot Benefits:**
- Very fast backup and restore (minutes vs hours)
- Lower network bandwidth usage
- Instant cloning for dev/test environments
- Consistent snapshots across data and WAL volumes

**Automatic Cleanup:**
The chart deploys a CronJob to automatically clean up old snapshots based on `retentionDays`.

---

### High Availability

#### Multi-Instance Configuration

```yaml
cluster:
  # Minimum 3 instances for HA
  instances: 3
  
  # Pod anti-affinity to spread across nodes
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              cnpg.io/cluster: my-postgres-cluster
          topologyKey: kubernetes.io/hostname
```

#### Service Endpoints

The chart automatically creates:

1. **Read-Write Service:** `<release-name>-cluster-rw`
   - Routes to the current primary instance
   - Automatically updates on failover

2. **Read-Only Service:** `<release-name>-cluster-r`
   - Load-balances across all replicas
   - Ideal for read-heavy workloads

3. **External Service (Optional):**
```yaml
cluster:
  externalService:
    enabled: true
    targetInstanceRole: primary  # or 'any'
```

#### Automatic Failover

CloudNativePG handles failover automatically:
- Detects primary failure within seconds
- Promotes healthiest replica
- Updates service endpoints
- No data loss with synchronous replication

#### Pod Disruption Budget

Automatically enabled to prevent simultaneous pod evictions:
```yaml
# Built-in PDB configuration
cluster:
  enablePDB: true  # Always enabled
```

---

### Monitoring

#### Prometheus Integration

```yaml
cluster:
  monitoring:
    enablePodMonitor: true
    
    customQueries:
      - name: database_size
        query: SELECT pg_database_size(current_database())
      
      - name: slow_queries
        query: |
          SELECT count(*) 
          FROM pg_stat_activity 
          WHERE state = 'active' 
          AND now() - query_start > interval '5 seconds'

  podMonitor:
    enabled: true
```

**Available Metrics:**
- Connection pool statistics
- Query performance (via pg_stat_statements)
- Replication lag
- WAL generation rate
- Database size and growth
- Lock contention
- Cache hit ratios

#### Grafana Dashboards

Import CloudNativePG dashboards:
- https://grafana.com/grafana/dashboards/20417 (Cluster Overview)
- https://grafana.com/grafana/dashboards/20418 (Query Performance)

---

### Security

#### Network Policies

```yaml
# Example NetworkPolicy (add to your chart)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: postgres-network-policy
spec:
  podSelector:
    matchLabels:
      cnpg.io/cluster: my-postgres-cluster
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Allow from application pods
    - from:
        - podSelector:
            matchLabels:
              app: myapp
      ports:
        - protocol: TCP
          port: 5432
    
    # Allow from monitoring
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring
      ports:
        - protocol: TCP
          port: 9187  # Metrics port
  
  egress:
    # DNS
    - to:
        - namespaceSelector:
            matchLabels:
              name: kube-system
        - podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
    
    # S3 backup (if using)
    - to:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 443
```

#### Encryption

**At Rest:**
- Transparent data encryption via storage layer
- Encrypted backups (AES256 for S3)

**In Transit:**
- TLS for client connections
- TLS for replication

```yaml
cluster:
  postgresql:
    parameters:
      ssl: "on"
      ssl_cert_file: "/etc/ssl/certs/server.crt"
      ssl_key_file: "/etc/ssl/certs/server.key"
```

#### Pod Security

CloudNativePG runs as non-root by default:
- User: postgres (UID 26)
- Read-only root filesystem
- No privilege escalation

---

## Advanced Features

### Bootstrap from Existing Cluster

#### Full Recovery from Backup

```yaml
cluster:
  bootstrap:
    recovery:
      source: production-backup
  
  externalClusters:
    - name: production-backup
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: s3-backup-storage
          serverName: production-cluster
```

#### Point-in-Time Recovery (PITR)

```yaml
cluster:
  bootstrap:
    recovery:
      source: production-backup
      recoveryTarget:
        targetTime: "2026-02-22 14:30:00+00"
```

### Init Database

```yaml
cluster:
  bootstrap:
    initdb:
      database: myapp
      owner: myapp_user
      dataChecksums: true
      encoding: 'UTF8'
      localeCollate: 'en_US.UTF-8'
      localeCType: 'en_US.UTF-8'
      
      postInitSQL:
        - CREATE EXTENSION IF NOT EXISTS pg_stat_statements
        - CREATE EXTENSION IF NOT EXISTS pgcrypto
        - CREATE SCHEMA IF NOT EXISTS audit
```

### Connection Pooling

Use PgBouncer for connection pooling:

```yaml
# Separate deployment (not included in this chart)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgbouncer
spec:
  template:
    spec:
      containers:
        - name: pgbouncer
          image: edoburu/pgbouncer:1.21.0
          env:
            - name: DATABASE_URL
              value: "postgres://app_user:password@my-postgres-cluster-rw:5432/myapp"
            - name: POOL_MODE
              value: "transaction"
            - name: MAX_CLIENT_CONN
              value: "1000"
            - name: DEFAULT_POOL_SIZE
              value: "25"
```

---

## Examples

### Example 1: Development Cluster

Single instance, no backups, minimal resources:

```yaml
cluster:
  instances: 1
  
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
  
  storage:
    storageClass: standard
    size: 10Gi
  
  walStorage:
    storageClass: standard
    size: 1Gi
  
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
  
  enableSuperuserAccess: true

database:
  autoGeneratePassword: true
  list:
    - name: dev_db
      owner: dev_user
```

### Example 2: Production Cluster with S3 Backup

```yaml
cluster:
  instances: 3
  
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
  
  storage:
    storageClass: fast-ssd
    size: 100Gi
  
  walStorage:
    storageClass: fast-ssd
    size: 20Gi
  
  resources:
    requests:
      cpu: 4000m
      memory: 8Gi
    limits:
      cpu: 8000m
      memory: 16Gi
  
  postgresql:
    parameters:
      max_connections: "500"
      shared_buffers: "4GB"
      effective_cache_size: "12GB"
    
    shared_preload_libraries:
      - pg_stat_statements
      - auto_explain
  
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true
      parameters:
        barmanObjectName: s3-backup-storage
  
  backup:
    barmanObjectStore:
      destinationPath: s3://prod-backups/postgres
      s3Credentials:
        accessKeyId:
          name: s3-creds
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: s3-creds
          key: AWS_SECRET_ACCESS_KEY
      wal:
        compression: gzip
    retentionPolicy: "30d"
  
  monitoring:
    enablePodMonitor: true
  
  podMonitor:
    enabled: true
  
  enableSuperuserAccess: false

database:
  autoGeneratePassword: true
  databaseReclaimPolicy: retain
  
  list:
    - name: app_production
      owner: app_user
      
      extensions:
        - name: pg_stat_statements
          ensure: present
        - name: pgcrypto
          ensure: present

scheduledBackup:
  plugin:
    enabled: true
    scheduledBackup: "0 2 * * *"
    name: barman-cloud.cloudnative-pg.io
  
  volumeSnapshot:
    enabled: true
    scheduledBackup: "0 3 * * *"
    retentionDays: 7

objectStore:
  enabled: true
  name: s3-backup-storage
  spec:
    configuration:
      destinationPath: s3://prod-backups/postgres
      endpointURL: https://s3.amazonaws.com
      s3Credentials:
        accessKeyId:
          name: s3-creds
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: s3-creds
          key: AWS_SECRET_ACCESS_KEY
      wal:
        compression: gzip
    retentionPolicy: "30d"
```

### Example 3: Multi-Database Cluster

```yaml
cluster:
  instances: 3
  
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:d393376fb67a2df53bb09acae89b39b2742b77519b4bc59f337ca9dfb7455cb1
  
  storage:
    size: 50Gi
  
  walStorage:
    size: 10Gi

database:
  autoGeneratePassword: true
  
  list:
    # Application database
    - name: app_production
      owner: app_user
      extensions:
        - name: pg_stat_statements
          ensure: present
    
    # Analytics database
    - name: analytics
      owner: analytics_user
      extensions:
        - name: pg_stat_statements
          ensure: present
        - name: timescaledb
          ensure: present
    
    # Audit database
    - name: audit_logs
      owner: audit_user
      databaseReclaimPolicy: retain
      extensions:
        - name: pgaudit
          ensure: present
```

---

## Backup & Recovery

### Backup Verification

```bash
# List backups (Barman)
kubectl exec -it my-postgres-cluster-1 -n database -- \
  barman-cloud-backup-list \
  --endpoint-url https://s3.amazonaws.com \
  s3://prod-backups/postgres \
  my-postgres-cluster

# List volume snapshots
kubectl get volumesnapshots -n database
```

### Restore from Backup

#### Full Cluster Restore

```yaml
# Create new cluster from backup
cluster:
  clusterName: restored-cluster
  
  bootstrap:
    recovery:
      source: original-cluster
  
  externalClusters:
    - name: original-cluster
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: s3-backup-storage
          serverName: my-postgres-cluster
```

#### Point-in-Time Recovery

```yaml
cluster:
  bootstrap:
    recovery:
      source: original-cluster
      recoveryTarget:
        targetTime: "2026-02-22 10:00:00+00"
```

#### Clone from VolumeSnapshot

```yaml
cluster:
  storage:
    size: 100Gi
    dataSource:
      apiGroup: snapshot.storage.k8s.io
      kind: VolumeSnapshot
      name: my-postgres-cluster-snapshot-20260222
  
  walStorage:
    size: 20Gi
    dataSource:
      apiGroup: snapshot.storage.k8s.io
      kind: VolumeSnapshot
      name: my-postgres-cluster-wal-snapshot-20260222
```

---

## Troubleshooting

### Common Issues

#### Pod Not Starting

**Symptoms:** Pods stuck in Pending or CrashLoopBackOff

**Checks:**
```bash
# Check pod status
kubectl describe pod my-postgres-cluster-1 -n database

# Check events
kubectl get events -n database --sort-by='.lastTimestamp'

# Check logs
kubectl logs my-postgres-cluster-1 -n database
```

**Common Causes:**
- Insufficient storage quota
- StorageClass not available
- Resource limits too low
- PVC already bound to another pod

#### Connection Failures

**Symptoms:** Cannot connect to database

**Checks:**
```bash
# Verify services
kubectl get svc -n database

# Check cluster status
kubectl get cluster -n database

# Test connection from within cluster
kubectl run -it --rm debug --image=postgres:18 --restart=Never -- \
  psql postgresql://myapp_user:password@my-postgres-cluster-rw:5432/myapp
```

#### Replication Lag

**Symptoms:** Read replicas are behind

**Diagnosis:**
```sql
-- Check replication status
SELECT * FROM pg_stat_replication;

-- Check replication lag
SELECT 
  application_name,
  client_addr,
  state,
  sync_state,
  pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

**Solutions:**
- Increase WAL storage size
- Adjust `wal_keep_size` parameter
- Check network latency
- Verify resource limits

#### Backup Failures

**Symptoms:** ScheduledBackup shows failed status

**Checks:**
```bash
# Check backup status
kubectl get scheduledbackup -n database

# Check backup pods
kubectl get pods -l cnpg.io/cluster=my-postgres-cluster -n database

# Check logs
kubectl logs <backup-pod> -n database
```

**Common Causes:**
- S3 credentials incorrect
- Network connectivity issues
- Insufficient disk space for WAL archiving

### Debug Commands

```bash
# Get cluster status
kubectl get cluster -n database -o yaml

# Check cluster conditions
kubectl get cluster -n database -o jsonpath='{.status.conditions}'

# View operator logs
kubectl logs -n cnpg-system deployment/cnpg-controller-manager

# Exec into pod
kubectl exec -it my-postgres-cluster-1 -n database -- bash

# Run psql as postgres user
kubectl exec -it my-postgres-cluster-1 -n database -- psql -U postgres

# Check PostgreSQL logs
kubectl logs my-postgres-cluster-1 -n database -c postgres
```

---

## Migration Guide

### Migrating from Version 3.x to 4.0

**Breaking Changes:**

1. **Backup Configuration Renamed:**
   - `objectStore.*` moved to `scheduledBackup.*`
   - New `backup` block in cluster configuration

**Migration Steps:**

**Before (3.x):**
```yaml
objectStore:
  enabled: true
  backup:
    scheduledBackup: "0 2 * * *"
```

**After (4.0):**
```yaml
scheduledBackup:
  plugin:
    enabled: true
    scheduledBackup: "0 2 * * *"
    name: barman-cloud.cloudnative-pg.io

cluster:
  backup:
    barmanObjectStore:
      destinationPath: s3://backups
      # ...
```

2. **Database Reclaim Policy:**
   - New `databaseReclaimPolicy` field
   - Default: `retain` (databases persist after helm uninstall)

```yaml
database:
  databaseReclaimPolicy: retain  # or 'delete'
```

### Upgrading PostgreSQL Version

#### In-Place Upgrade (Same Major Version)

```yaml
cluster:
  image:
    name: ghcr.io/cloudnative-pg/postgresql:18.2-standard-trixie
```

Apply changes:
```bash
helm upgrade my-postgres . -n database
```

CloudNativePG will perform a rolling update.

#### Major Version Upgrade (e.g., 17 → 18)

Use logical replication for zero-downtime upgrade:

1. **Create new cluster with PostgreSQL 18**
2. **Set up logical replication from old cluster**
3. **Cutover when synchronized**

See [Logical Replication](#logical-replication) section.

---

## Best Practices

### Production Deployment

✅ **DO:**

1. **Use 3+ instances for high availability**
   ```yaml
   cluster:
     instances: 3
   ```

2. **Enable both backup strategies**
   ```yaml
   scheduledBackup:
     plugin:
       enabled: true
     volumeSnapshot:
       enabled: true
   ```

3. **Set resource limits**
   ```yaml
   cluster:
     resources:
       limits:
         cpu: "8"
         memory: 16Gi
       requests:
         cpu: "4"
         memory: 8Gi
   ```

4. **Disable superuser access**
   ```yaml
   cluster:
     enableSuperuserAccess: false
   ```

5. **Use separate storage for WAL**
   ```yaml
   cluster:
     walStorage:
       storageClass: high-iops-ssd
   ```

6. **Enable monitoring**
   ```yaml
   cluster:
     podMonitor:
       enabled: true
   ```

7. **Retain databases on uninstall**
   ```yaml
   database:
     databaseReclaimPolicy: retain
   ```

❌ **DON'T:**

1. **Run single instance in production**
2. **Skip backups**
3. **Hardcode passwords in values**
4. **Use default PostgreSQL parameters**
5. **Ignore monitoring**
6. **Run without PodDisruptionBudget**

### Security Hardening

```yaml
cluster:
  # Disable superuser
  enableSuperuserAccess: false
  
  postgresql:
    parameters:
      # Enforce SSL
      ssl: "on"
      ssl_min_protocol_version: "TLSv1.2"
      
      # Logging
      log_connections: "on"
      log_disconnections: "on"
      log_statement: "ddl"
      log_line_prefix: "%t [%p]: user=%u,db=%d,app=%a,client=%h"
      
      # Restrict functions
      shared_preload_libraries:
        - pgaudit
  
  # Network isolation
  # (Add NetworkPolicy separately)

database:
  # Auto-generate passwords
  autoGeneratePassword: true
  
  # Never rotate in production
  refreshPasswordInterval: 0s
```

### Performance Tuning

```yaml
cluster:
  postgresql:
    parameters:
      # Memory
      shared_buffers: "25% of RAM"
      effective_cache_size: "75% of RAM"
      work_mem: "RAM / max_connections / 4"
      maintenance_work_mem: "RAM / 16"
      
      # Checkpoints
      checkpoint_completion_target: "0.9"
      max_wal_size: "4GB"
      min_wal_size: "1GB"
      
      # Query planner
      random_page_cost: "1.1"  # For SSD
      effective_io_concurrency: "200"
      
      # Connections
      max_connections: "500"
      
      # WAL
      wal_level: "replica"
      wal_compression: "on"
      
      # Autovacuum
      autovacuum_max_workers: "4"
      autovacuum_naptime: "30s"
```

---

## Support & Resources

- **CloudNativePG Docs:** https://cloudnative-pg.io/docs/
- **Operator GitHub:** https://github.com/cloudnative-pg/cloudnative-pg
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Slack Community:** Join #cloudnativepg on Kubernetes Slack

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and migration notes.


