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

## Backup

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: manual-backup
  namespace: cloudnative-pg
spec:
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
  cluster:
    name: cloudnative-pg-cluster
```

```bash
kubectl cnpg backup cloudnative-pg-cluster -n cloudnative-pg -m plugin --plugin-name barman-cloud.cloudnative-pg.io

# Get size of bucket on minio
mc du mc_distributed/cnpg-backup/
```