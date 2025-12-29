# cloudnative-pg

CloudNativePG is an open source operator designed to manage PostgreSQL workloads on any supported Kubernetes cluster running in private, public, hybrid, or multi-cloud environments.

More info [github](https://github.com/cloudnative-pg/charts)

```bash
# Check status
kubectl cnpg status cloudnative-pg-cluster -n cloudnative-pg

# Promote instance to be primary
kubectl cnpg promote cloudnative-pg-cluster cloudnative-pg-cluster-<id> -n cloudnative-pg
```

# Barman cloud plugin

## Installation

```bash
kubectl create ns cnpg-system
kubectl apply -f https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.6.0/manifest.yaml

# Install on specific namespace
curl -L -o manifest.yaml https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.6.0/manifest.yaml
sed -i 's/namespace: cnpg-system/namespace: myNamespace/g' manifest.yaml
# For MacOS
# sed -ie 's/namespace: cnpg-system/namespace: myNamespace/g' manifest.yaml
kubectl apply -f manifest.yaml
```

After configuring barman cloud, the cluster of cnpg pod should be restarted to run barman cloud as sidecar container


## Postgresql image version

Postgresql version image are available in the following link: https://github.com/cloudnative-pg/postgres-containers/blob/main/README.md
Each image is identified by its digest and a main tag of the form:

```
MM.mm-TS-TYPE-OS
```

where:

- `MM` is the PostgreSQL major version (e.g. `16`)
- `mm` is the PostgreSQL minor version (e.g. `10`)
- `TS` is the build timestamp with minute precision (e.g. `202509090953`)
- `TYPE` is image type (e.g. `standard` or `minimal`)
- `OS` is the underlying distribution (e.g. `trixie`)

For example: `16.10-202509090953-minimal-trixie` or `16.10-standard-trixie` or `16-standard-trixie`

> [!WARNING]
> Following this [tweet](https://x.com/gwenshap/status/1990942970682749183), always add the debian image in the version
> to avoid breaking change issue during a MINOR update version using docker

## Bootstrap

https://cloudnative-pg.io/docs/1.28/bootstrap

Bootstrap section allows multiple types of bootstrap:

From scratch
```yaml
bootstrap:
  initdb:
    database: bitwarden
    owner: bitwarden
    secret:
      # Containing "password" and "username" key
      name: bitwarden-secret
    # You can execute queries after initdb: https://cloudnative-pg.io/docs/1.28/bootstrap#executing-queries-after-initialization
    postInitSQL:
      - CREATE DATABASE angus
```

From initdb to [import](https://cloudnative-pg.io/docs/1.28/database_import/) database from external db (can be running on different version)
```yaml
bootstrap:
  initdb:
    import:
      type: monolith # or micro-service, to backup only on db on the source db
      databases:
        - bitwarden
        - authentik
        - outline
        - wiki
      roles:
        - bitwarden_user
        - authentik
        - outline
        - wiki_user
      source:
        externalCluster: primary
      #postImportApplicationSQL:
      #- |
      #  INSERT YOUR SQL QUERIES HERE

  externalClusters:
    - name: primary
      connectionParameters:
        host: postgresql-cluster-rw
        user: postgres
      password:
        name: superuser-postgres
        key: password
```

From pg_basebackup. Clone existing db with the same major version
```yaml
bootstrap:
  pg_basebackup:
    source: source-db

externalClusters:
  - name: source-db
    connectionParameters:
      host: source-db.foo.com # db host to replicate
      user: streaming_replica
      # with tls
      sslmode: verify-full
    password:
      name: source-db-replica-user
      key: password
    sslKey:
      name: cluster-example-replication
      key: tls.key
    sslCert:
      name: cluster-example-replication
      key: tls.crt
    sslRootCert:
      name: cluster-example-ca
      key: ca.crt
```

## Barman cloud plugin

### Installation

```bash
kubectl create ns cnpg-system
kubectl apply -f https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.6.0/manifest.yaml

# Install on specific namespace
curl -L -o manifest.yaml https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.6.0/manifest.yaml
sed -i 's/namespace: cnpg-system/namespace: myNamespace/g' manifest.yaml
# For MacOS
# sed -ie 's/namespace: cnpg-system/namespace: myNamespace/g' manifest.yaml
kubectl apply -f manifest.yaml
```

After configuring barman cloud, the cluster of cnpg pod should be restarted to run barman cloud as sidecar container

## Scheduled Backup

```yaml
objectStore:
  enabled: true
  name: s3-storage
  spec:
    configuration:
      destinationPath: s3://backup
      endpointURL: http://s3.minio.svc.cluster.local:9000
      s3Credentials:
      # Key should be named as ACCESS_KEY_ID and ACCESS_SECRET_KEY
        accessKeyId:
          name: s3-minio-secret
          key: MINIO_ROOT_USER
        secretAccessKey:
          name: s3-minio-secret
          key: MINIO_ROOT_PASSWORD
      wal:
        compression: gzip
    retentionPolicy: 30d
```

Manual backup
```bash
kubectl cnpg backup cloudnative-pg-cluster -n cloudnative-pg -m plugin --plugin-name barman-cloud.cloudnative-pg.io

# Get size of bucket on minio
mc du mc_distributed/cnpg-backup/
```

## Restore

Add this following section on the current deployment
```yaml
cluster:
  bootstrap:
    recovery:
      source: origin # Reference the external cluster defined below
      # recoveryTarget: 
        # Specified specific time to recover
        # targetTime: "2023-08-11 11:14:21.00000+02"
        # Or specify backupID
        # backupID: "20251228T000001"

  externalClusters:
    - name: origin
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: cluster-example-backup
          serverName: cluster-example
```


## Logical Replication

### Create publication on primary

```yaml
database:
  autoGeneratePassword: true
  list:
    - name: authentik
      owner: authentik
      secretName: authentik-cnpg
      logicalReplication:
        publication:
          enabled: true
          target:
            objects:
            - tablesInSchema: public
```

### Create subscription on replica

```yaml
# Create database with subscription enabled
database:
  autoGeneratePassword: true
  list:
    - name: authentik
      owner: authentik
      secretName: authentik-cnpg
      logicalReplication:
        subscription:
          enabled: true
          externalClusterName: "authentik-primary"

cluster:
  ...

  # Init cluster from primary. It will copy database from primary to replica
  bootstrap:
    initdb:
      import:
        type: monolith
        databases:
          - bitwarden
          - authentik
        # Must import role from primary to replicas
        roles:
          - authentik
          - bitwarden
        source:
          externalCluster: primary
  
  externalClusters:
    # Define primary cluster to connect
    - name: primary
      connectionParameters:
        host: postgresql-cluster-rw
        user: postgres
      password:
        name: superuser-postgres
        key: password
    # Define primary cluster to connect in the database to subscribe
    - name: authentik-primary
      connectionParameters:
        host: postgresql-cluster-rw
        user: postgres
        dbname: authentik
      password:
        name: authentik_cnpg
        key: password
```

### Troubleshoot

Verify logical replication on publication
```sql
SELECT slot_name, plugin, slot_type, active, restart_lsn
FROM pg_replication_slots;
```

List replicate tables on subscription (r=ready, d=data copy)
```sql
SELECT c.relname, r.srsubstate 
FROM pg_subscription_rel r
JOIN pg_class c ON r.srrelid = c.oid;

-- Filter on ready table only
SELECT c.relname, r.srsubstate 
FROM pg_subscription_rel r
JOIN pg_class c ON r.srrelid = c.oid
WHERE r.srsubstate = 'r';

-- If the table is in d state on table X, truncate table (empty table)
TRUNCATE TABLE table_name CASCADE;
```

Delete subscription
```sql
-- list subscription
SELECT * FROM pg_replication_slots ;
SELECT pg_drop_replication_slot('slot_name');
```

Check subscription connection info
```sql
SELECT subconninfo FROM pg_subscription;
```

## Wal storage

| Concept              | Explanation                                                                                                                                                                   |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **WAL purpose**      | WAL stores all changes to the database before they are written to the main data files. It ensures **crash recovery**, **replication**, and **point-in-time recovery (PITR)**. |
| **Storage size**     | The `walStorage` PVC specifies the **maximum space allocated** for WAL segments. This is **not cumulative WAL**, but the actual space available on disk.                      |
| **HostPath vs LVM**  | HostPath does **not enforce the size**, so WAL can grow beyond the requested PVC. LVM LocalPV enforces the size, ensuring disk limits are respected.                          |
| **Sizing guideline** | For a cluster with ~8 GiB of data, **4–8 GiB for WAL** is typically enough. Adjust according to workload, replication, and PITR requirements.                                 |

### Debugging WAL Usage

To check WAL usage and track cumulative bytes written:
```sql
-- Shows the current WAL LSN and the total WAL bytes written since cluster creation
SELECT pg_current_wal_lsn(), pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0') AS wal_bytes;
````

__Interpretation__

pg_current_wal_lsn() → current WAL log sequence number

pg_wal_lsn_diff(..., '0/0') → total WAL bytes written since cluster creation (cumulative)

__Notes__

This cumulative value is not the size on disk; actual disk usage depends on WAL recycling, max_wal_size, and backup retention.

For debug purposes, you can monitor this value over time to estimate WAL growth and plan walStorage sizing.
