# app-template

A thin Helm chart wrapper built on top of the `common` library chart.

It provides a quick and standardized way to deploy any application on Kubernetes
(Deployment, StatefulSet, DaemonSet, Job, CronJob) with built-in support for
Services, Ingress/Routes, volumes, probes, securityContext, resources, and more.

## Table of Contents

- [app-template](#app-template)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [How it works](#how-it-works)
  - [Quick start](#quick-start)
    - [1. Fetch dependencies](#1-fetch-dependencies)
    - [2. Create a values file](#2-create-a-values-file)
    - [3. Render the templates](#3-render-the-templates)
    - [4. Install](#4-install)
  - [Minimal values.yaml](#minimal-valuesyaml)
  - [Examples](#examples)
    - [Example 1: StatefulSet + Service + ephemeral volumes](#example-1-statefulset--service--ephemeral-volumes)
    - [Example 2: Traefik IngressRoute (CRD) via `rawResources`](#example-2-traefik-ingressroute-crd-via-rawresources)
    - [Example 3: External secret (Infisical) via `rawResources`](#example-3-external-secret-infisical-via-rawresources)
  - [Useful commands](#useful-commands)
    - [Lint](#lint)
    - [Render with debug](#render-with-debug)
    - [Diff upgrade (requires helm-diff plugin)](#diff-upgrade-requires-helm-diff-plugin)
    - [Upgrade](#upgrade)
    - [Rollback](#rollback)
    - [Uninstall](#uninstall)
  - [Important conventions](#important-conventions)
  - [Troubleshooting](#troubleshooting)
  - [Values reference](#values-reference)

## Prerequisites

- Kubernetes `>= 1.28`
- Helm `>= 3.12`
- Access to the `common` dependency chart (local or OCI)

The chart declares:

```yaml
apiVersion: v2
name: app-template
version: 2.0.0
dependencies:
  - name: common
    repository: oci://ghcr.io/dedsxc
    version: 2.0.0
```

## How it works

The main template `templates/common.yaml`:

1. Initializes the `common` library loader
2. Forces `global.nameOverride` to the release name if not explicitly set
3. Delegates all resource rendering to `common`

Everything is configured through `values.yaml` following the `common` schema.

## Quick start

### 1. Fetch dependencies

From `labs/helm/fork/app-template`:

```bash
helm dependency update
```

### 2. Create a values file

Minimal example (`myapp-values.yaml`):

```yaml
controller:
  enabled: true
  type: deployment
  replicas: 1

  containers:
    main:
      image:
        repository: nginx
        tag: "1.27"
        pullPolicy: IfNotPresent

      ports:
        - name: http
          containerPort: 80
          protocol: TCP

service:
  main:
    enabled: true
    type: ClusterIP
    ports:
      http:
        enabled: true
        port: 80
        targetPort: 80
        protocol: HTTP
```

### 3. Render the templates

```bash
helm template myapp . -f myapp-values.yaml --namespace apps
```

### 4. Install

```bash
helm upgrade --install myapp . \
  -f myapp-values.yaml \
  --namespace apps \
  --create-namespace
```

## Minimal values.yaml

Recommended baseline for a web application:

```yaml
controller:
  enabled: true
  type: deployment
  replicas: 1
  containers:
    main:
      image:
        repository: ghcr.io/org/app
        tag: "1.0.0"
      env:
        TZ: Europe/Paris
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 500m
          memory: 512Mi
      probes:
        liveness:
          enabled: true
          type: HTTP
          spec:
            httpGet:
              path: /healthz
              port: 8080
        readiness:
          enabled: true
          type: HTTP
          spec:
            httpGet:
              path: /readyz
              port: 8080
      ports:
        - name: http
          containerPort: 8080

service:
  main:
    enabled: true
    type: ClusterIP
    ports:
      http:
        enabled: true
        port: 8080
        targetPort: 8080
        protocol: HTTP
```

## Examples

### Example 1: StatefulSet + Service + ephemeral volumes

```yaml
controller:
  enabled: true
  type: statefulset
  replicas: 3

  containers:
    main:
      image:
        repository: vaultwarden/server
        tag: 1.35.3-alpine
      env:
        WEBSOCKET_ENABLED: "true"
      ports:
        - name: http
          containerPort: 80

service:
  main:
    enabled: true
    type: ClusterIP
    ports:
      http:
        enabled: true
        port: 80
        targetPort: 80

persistence:
  tmp:
    enabled: true
    type: emptyDir
    globalMounts:
      - path: /tmp
  data:
    enabled: true
    type: emptyDir
    globalMounts:
      - path: /data
```

### Example 2: Traefik IngressRoute (CRD) via `rawResources`

```yaml
rawResources:
  ingress-route:
    enabled: true
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    spec:
      entryPoints:
        - websecure
      routes:
        - match: Host(`app.example.com`) && PathPrefix(`/`)
          kind: Rule
          services:
            - name: "{{ .Release.Name }}"
              port: 80
```

### Example 3: External secret (Infisical) via `rawResources`

```yaml
serviceAccount:
  default:
    enabled: true

rawResources:
  infisical-secret:
    enabled: true
    apiVersion: secrets.infisical.com/v1alpha1
    kind: InfisicalSecret
    spec:
      hostAPI: http://infisical.apps.svc.cluster.local:8080
      authentication:
        kubernetesAuth:
          identityId: <identity-id>
          autoCreateServiceAccountToken: true
          serviceAccountRef:
            name: "{{ .Release.Name }}"
            namespace: "{{ .Release.Namespace }}"
          secretsScope:
            projectSlug: kubernetes
            envSlug: prod
            secretsPath: "/{{ .Release.Name }}"
            recursive: true
      managedSecretReference:
        secretName: "{{ .Release.Name }}-secret"
        secretNamespace: "{{ .Release.Namespace }}"
```

## Useful commands

### Lint

```bash
helm lint . -f myapp-values.yaml
```

### Render with debug

```bash
helm template myapp . -f myapp-values.yaml --debug
```

### Diff upgrade (requires helm-diff plugin)

```bash
helm diff upgrade myapp . -f myapp-values.yaml -n apps
```

### Upgrade

```bash
helm upgrade myapp . -f myapp-values.yaml -n apps
```

### Rollback

```bash
helm rollback myapp 1 -n apps
```

### Uninstall

```bash
helm uninstall myapp -n apps
```

## Important conventions

- **Single controller per release (v2):** `app-template` v2.0.0 supports only one controller. Use separate Helm releases for multiple controllers.
- **Automatic name override:** If `global.nameOverride` is not set, it is automatically set to `{{ .Release.Name }}`.
- **Values inherited from `common`:** All top-level keys (`controller`, `service`, `ingress`, `persistence`, `serviceAccount`, `rbac`, `networkPolicy`, `metrics`, `rawResources`, etc.) come from the `common` library.
- **Helm templating in values:** Expressions like `"{{ .Release.Name }}"` are supported in most string fields.

## Troubleshooting

- **`common` dependency not found:** Run `helm dependency update` from `labs/helm/fork/app-template`.
- **No resources rendered:** Make sure `controller.enabled: true` and at least one container is defined under `controller.containers.main`.
- **Pod crashing:** Check `image`, `env`, `envFrom`, probes, and volume mounts.
- **Service has no endpoints:** Verify that labels/selectors match the controller and that the pod is `Ready`.

## Values reference

`app-template` is a thin wrapper. The full key reference is the `common` library chart:

- See `labs/helm/fork/common/README.md`
- Real-world examples:
  - `gitops-charts/kubernetes/apps/public/bitwarden/values.yaml`
  - `gitops-charts/kubernetes/apps/internal/db-backup/values.yaml`

These cover concrete cases: StatefulSet, HTTP probes, securityContext, persistence, Services, and CRDs via `rawResources`.
