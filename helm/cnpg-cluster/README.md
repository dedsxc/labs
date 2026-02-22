# CloudNativePG Cluster Helm Chart

## Overview

**cnpg-cluster** is a production-ready Helm chart for deploying and managing PostgreSQL clusters using [CloudNativePG](https://cloudnative-pg.io/) operator on Kubernetes. This chart provides a declarative way to create highly available PostgreSQL databases with automatic failover, point-in-time recovery, and comprehensive backup strategies.

**Version:** 4.2.0  
**Type:** Application  
**Operator Required:** CloudNativePG >= 1.28.0

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration Guide](#configuration-guide)
  - [Cluster Configuration](#cluster-configuration)
  - [Database Management](#database-management)
  - [Backup Strategies](#backup-strategies)
  - [High Availability](#high-availability)
  - [Monitoring](#monitoring)
  - [Security](#security)
- [Advanced Features](#advanced-features)
- [Examples](#examples)
- [Backup & Recovery](#backup--recovery)
- [Troubleshooting](#troubleshooting)
- [Migration Guide](#migration-guide)
- [Best Practices](#best-practices)

---

## Features

### Core Capabilities

✅ **High Availability**
- Multi-instance PostgreSQL clusters (3+ replicas recommended)
- Automatic failover and self-healing
- Read-write and read-only service endpoints
- Pod Disruption Budgets for cluster stability

✅ **Comprehensive Backup**
- Scheduled backups using Barman Cloud (S3/MinIO/GCS/Azure)
- VolumeSnapshot-based backups for fast recovery
- Point-in-Time Recovery (PITR)
- WAL archiving for continuous backup

✅ **Database Management**
- Declarative database and user provisioning
- Auto-generated credentials with External Secrets integration
- Schema and extension management
- Logical replication support for upgrades

✅ **Enterprise Features**
- PostgreSQL 11-18 support
- Custom storage classes for data and WAL
- Resource management and QoS
- Image catalog support for version management
- Superuser access control

✅ **Observability**
- Prometheus metrics via PodMonitor
- Query performance monitoring
- Connection pooling metrics
- WAL and replication lag tracking

---

## Prerequisites

### Required Components

1. **Kubernetes Cluster:** >= 1.28.0
2. **CloudNativePG Operator:** >= 1.28.0
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.0.yaml
   ```

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


