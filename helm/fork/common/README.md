# Common Helm Library Chart

## Overview

**Common** is a Helm library chart that provides reusable templates and functions for creating Kubernetes resources. This chart follows the library pattern and is designed to be used as a dependency in other Helm charts, significantly reducing boilerplate code and standardizing resource definitions across your applications.

**Type:** Library | **Minimum Kubernetes Version:** 1.28.0

> **Authoritative version**: always check `Chart.yaml` — `grep '^version:' Chart.yaml`
>
> ⚠️ **Schema validity**: when the chart version changes, verify breaking changes in `CHANGELOG.md`. The "Single Controller" architecture (no `controllers:` wrapper) is a permanent breaking change from v1.x — this constraint applies to all versions >= 2.0.0.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Configuration Guide](#configuration-guide)
  - [Global Settings](#global-settings)
  - [Controllers](#controllers)
  - [Containers](#containers)
  - [Services](#services)
  - [Ingress](#ingress)
  - [Persistence](#persistence)
  - [ConfigMaps & Secrets](#configmaps--secrets)
  - [Service Accounts](#service-accounts)
  - [Network Policies](#network-policies)
  - [RBAC](#rbac)
  - [Monitoring](#monitoring)
- [Advanced Features](#advanced-features)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Migration Guide](#migration-guide)

---

## Installation

### Adding as a Dependency

To use this library chart, add it as a dependency in your `Chart.yaml`:

```yaml
apiVersion: v2
name: my-application
description: My awesome application
type: application
version: 1.0.0
dependencies:
  - name: common
    version: "*"    # Pin to a specific version in production: grep '^version:' ../common/Chart.yaml
    repository: file://../common  # Or use an OCI registry or HTTP URL
```

Then run:

```bash
helm dependency update
```

### Using Templates

In your chart's templates, create a file (e.g., `templates/common.yaml`) to include the library:

```yaml
{{- include "common.loader.all" . }}
```

This single line will render all configured resources based on your `values.yaml`.

---

## Quick Start

### Minimal Example

Create a simple deployment with a service:

```yaml
# values.yaml
controller:
  enabled: true
  type: deployment
  replicas: 3
  containers:
    main:
      image:
        repository: nginx
        tag: "1.25"
        pullPolicy: IfNotPresent
      env:
        APP_ENV: production
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

service:
  main:
    enabled: true
    type: ClusterIP
    ports:
      http:
        enabled: true
        port: 80
        protocol: HTTP
```

This configuration will create:
- A Deployment with 3 replicas
- A ClusterIP Service exposing port 80
- Automatic probes (liveness, readiness, startup)
- Resource limits and requests

---

## Core Concepts

### 1. Library Pattern

This chart doesn't deploy resources directly. Instead, it provides templates that your parent chart includes and renders.

### 2. Single Controller Approach

**Version 2.0.0 Breaking Change:** This chart now supports only **one controller per chart**. If you need multiple controllers, use multiple Helm releases.

### 3. Identifier-Based Resources

Resources can reference each other using identifiers rather than hardcoded names, making configurations more maintainable.

### 4. Template-Enabled Values

Most string values support Helm templating with the `{{ }}` syntax, allowing dynamic configurations.

### 5. Merge Strategies

The chart supports different merge strategies for default options:
- `overwrite` (default): Child settings replace parent settings
- `merge`: Child settings are merged with parent settings

---

## Configuration Guide

### Global Settings

```yaml
global:
  # Override the resource name prefix
  nameOverride: "custom-name"
  
  # Override the full resource name
  fullnameOverride: "my-app"
  
  # Propagate global labels to all Pods
  propagateGlobalMetadataToPods: true
  
  # Global labels applied to all resources
  labels:
    environment: production
    team: platform
  
  # Global annotations applied to all resources
  annotations:
    owner: "platform-team@example.com"
```

**Use Cases:**
- Standardize naming across multiple charts
- Apply organization-wide labels (cost center, department)
- Add compliance annotations

---

### Controllers

#### Supported Controller Types

1. **Deployment** (default)
2. **StatefulSet**
3. **DaemonSet**
4. **CronJob**
5. **Job**

#### Basic Controller Configuration

```yaml
controller:
  enabled: true
  type: deployment  # deployment | statefulset | daemonset | cronjob | job
  
  annotations:
    description: "Main application controller"
  
  labels:
    app-tier: backend
  
  replicas: 3
  
  strategy: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
  
  revisionHistoryLimit: 5
```

#### Deployment Example

```yaml
controller:
  enabled: true
  type: deployment
  replicas: 3
  strategy: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 2
  
  containers:
    main:
      image:
        repository: myapp/backend
        tag: "v1.2.3"
        pullPolicy: IfNotPresent
```

#### StatefulSet Example

```yaml
controller:
  enabled: true
  type: statefulset
  replicas: 3
  
  statefulset:
    podManagementPolicy: Parallel
    volumeClaimTemplates:
      - name: data
        accessMode: ReadWriteOnce
        size: 10Gi
        storageClass: fast-ssd
        globalMounts:
          - path: /var/lib/data
```

#### CronJob Example

```yaml
controller:
  enabled: true
  type: cronjob
  
  cronjob:
    schedule: "0 2 * * *"  # Every day at 2 AM
    concurrencyPolicy: Forbid
    successfulJobsHistory: 3
    failedJobsHistory: 5
    startingDeadlineSeconds: 300
    backoffLimit: 3
  
  containers:
    main:
      image:
        repository: myapp/backup-job
        tag: "latest"
      command:
        - /bin/sh
        - -c
        - |
          echo "Running backup..."
          /app/backup.sh
```

#### DaemonSet Example

```yaml
controller:
  enabled: true
  type: daemonset
  
  containers:
    main:
      image:
        repository: myapp/node-exporter
        tag: "v1.0.0"
      
      securityContext:
        privileged: true
  
  pod:
    hostNetwork: true
    hostPID: true
```

---

### Containers

#### Main Container Configuration

```yaml
controller:
  containers:
    main:
      # Container name override
      nameOverride: "api-server"
      
      # Image configuration
      image:
        repository: docker.io/myorg/myapp
        tag: "1.0.0"
        digest: ""  # Optional SHA256 digest
        pullPolicy: IfNotPresent
      
      # Command and arguments
      command:
        - /app/entrypoint.sh
      
      args:
        - --config=/etc/app/config.yaml
        - --verbose
      
      # Working directory
      workingDir: /app
      
      # Environment variables
      env:
        # Simple key-value
        APP_ENV: production
        PORT: "8080"
        
        # Templated value
        POD_NAME: "{{ .Release.Name }}-pod"
        
        # From ConfigMap
        DATABASE_URL:
          configMapKeyRef:
            name: app-config
            key: db-url
        
        # From Secret
        DATABASE_PASSWORD:
          secretKeyRef:
            name: app-secret
            key: db-password
        
        # Field reference
        NODE_NAME:
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
      
      # Load environment from ConfigMaps/Secrets
      envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secret
      
      # Resource limits
      resources:
        limits:
          cpu: 1000m
          memory: 1Gi
        requests:
          cpu: 500m
          memory: 512Mi
      
      # Security context
      securityContext:
        runAsUser: 1000
        runAsGroup: 3000
        runAsNonRoot: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
      
      # Lifecycle hooks
      lifecycle:
        postStart:
          exec:
            command:
              - /bin/sh
              - -c
              - echo "Container started"
        preStop:
          exec:
            command:
              - /bin/sh
              - -c
              - sleep 15
```

#### Multiple Containers (Sidecars)

```yaml
controller:
  containers:
    main:
      image:
        repository: nginx
        tag: "1.25"
    
    # Sidecar container
    log-collector:
      image:
        repository: fluent/fluent-bit
        tag: "2.0"
      
      env:
        OUTPUT_HOST: logging.example.com
      
      resources:
        limits:
          cpu: 100m
          memory: 128Mi
```

#### Init Containers

```yaml
controller:
  initContainers:
    db-migration:
      image:
        repository: myapp/migrations
        tag: "v1.0.0"
      
      command:
        - /app/migrate
      
      env:
        DATABASE_URL:
          secretKeyRef:
            name: db-credentials
            key: url
    
    wait-for-db:
      image:
        repository: busybox
        tag: "1.36"
      
      command:
        - sh
        - -c
        - |
          until nc -z postgres-service 5432; do
            echo "Waiting for database..."
            sleep 2
          done
```

---

### Probes (Health Checks)

```yaml
controller:
  containers:
    main:
      probes:
        # Liveness probe
        liveness:
          enabled: true
          type: HTTP  # HTTP | TCP | EXEC
          spec:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
        
        # Readiness probe
        readiness:
          enabled: true
          type: HTTP
          spec:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
        
        # Startup probe
        startup:
          enabled: true
          type: TCP
          spec:
            tcpSocket:
              port: http
            initialDelaySeconds: 0
            periodSeconds: 5
            failureThreshold: 30  # 30 * 5s = 150s max startup time
```

#### Custom Probe Example

```yaml
controller:
  containers:
    main:
      probes:
        liveness:
          enabled: true
          custom: true
          spec:
            exec:
              command:
                - /bin/sh
                - -c
                - pgrep -f myapp || exit 1
            initialDelaySeconds: 30
            periodSeconds: 10
```

---

### Services

#### Basic Service Configuration

```yaml
service:
  main:
    enabled: true
    primary: true  # Used in probes and notes
    
    type: ClusterIP  # ClusterIP | NodePort | LoadBalancer | ExternalName
    
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    
    labels:
      monitoring: "true"
    
    ports:
      http:
        enabled: true
        primary: true
        port: 80
        targetPort: 8080
        protocol: HTTP
      
      metrics:
        enabled: true
        port: 9090
        protocol: HTTP
```

#### LoadBalancer Service

```yaml
service:
  main:
    enabled: true
    type: LoadBalancer
    
    externalTrafficPolicy: Local
    
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    
    ports:
      http:
        enabled: true
        port: 80
        targetPort: 8080
        nodePort: 30080  # Optional fixed NodePort
```

#### Multi-Port Service

```yaml
service:
  main:
    enabled: true
    type: ClusterIP
    
    ports:
      http:
        enabled: true
        port: 80
        protocol: HTTP
      
      https:
        enabled: true
        port: 443
        protocol: HTTPS
      
      grpc:
        enabled: true
        port: 50051
        protocol: TCP
        appProtocol: grpc
```

---

### Ingress

#### Basic Ingress Configuration

```yaml
ingress:
  main:
    enabled: true
    
    className: nginx
    
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/rewrite-target: /
    
    hosts:
      - host: app.example.com
        paths:
          - path: /
            pathType: Prefix
            service:
              name: main
              port: http
    
    tls:
      - secretName: app-tls
        hosts:
          - app.example.com
```

#### Multiple Hosts

```yaml
ingress:
  main:
    enabled: true
    className: nginx
    
    hosts:
      - host: app.example.com
        paths:
          - path: /
            pathType: Prefix
            service:
              name: main
              port: http
      
      - host: api.example.com
        paths:
          - path: /v1
            pathType: Prefix
            service:
              name: main
              port: http
          - path: /v2
            pathType: Prefix
            service:
              name: main
              port: http
    
    tls:
      - secretName: app-tls
        hosts:
          - app.example.com
          - api.example.com
```

#### Advanced Ingress with Annotations

```yaml
ingress:
  main:
    enabled: true
    className: nginx
    
    annotations:
      # SSL/TLS
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      
      # Rate limiting
      nginx.ingress.kubernetes.io/limit-rps: "100"
      
      # CORS
      nginx.ingress.kubernetes.io/enable-cors: "true"
      nginx.ingress.kubernetes.io/cors-allow-origin: "https://example.com"
      
      # Timeouts
      nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
      
      # Body size
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
```

---

### Persistence

#### PersistentVolumeClaim

```yaml
persistence:
  data:
    enabled: true
    type: persistentVolumeClaim
    
    storageClass: fast-ssd
    accessMode: ReadWriteOnce
    size: 10Gi
    
    retain: true  # Keep PVC on helm uninstall
    
    globalMounts:
      - path: /data
        readOnly: false
```

#### EmptyDir Volume

```yaml
persistence:
  temp:
    enabled: true
    type: emptyDir
    
    globalMounts:
      - path: /tmp
```

#### ConfigMap Volume

```yaml
persistence:
  config:
    enabled: true
    type: configMap
    name: app-config  # Existing ConfigMap name
    
    globalMounts:
      - path: /etc/app
        readOnly: true
```

#### Secret Volume

```yaml
persistence:
  secrets:
    enabled: true
    type: secret
    name: app-credentials
    
    globalMounts:
      - path: /etc/secrets
        readOnly: true
```

#### HostPath Volume

```yaml
persistence:
  logs:
    enabled: true
    type: hostPath
    hostPath: /var/log/myapp
    hostPathType: DirectoryOrCreate
    
    globalMounts:
      - path: /logs
```

#### NFS Volume

```yaml
persistence:
  shared:
    enabled: true
    type: nfs
    server: nfs.example.com
    path: /exports/shared
    
    globalMounts:
      - path: /shared
        readOnly: false
```

#### Volume Mounts per Container

```yaml
persistence:
  data:
    enabled: true
    type: persistentVolumeClaim
    size: 5Gi
    
    # Don't mount globally
    globalMounts: []
    
    # Mount to specific containers
    advancedMounts:
      main:  # Controller name
        main:  # Container name
          - path: /data
            readOnly: false
        backup:  # Another container
          - path: /backup-source
            readOnly: true
```

---

### ConfigMaps & Secrets

#### ConfigMaps

```yaml
configMaps:
  app-config:
    enabled: true
    
    labels:
      app: myapp
    
    annotations:
      description: "Application configuration"
    
    data:
      app.conf: |
        server {
          listen 8080;
          location / {
            proxy_pass http://backend;
          }
        }
      
      settings.json: |
        {
          "debug": false,
          "maxConnections": 100
        }
```

#### ConfigMaps from Folder

```yaml
configMapsFromFolder:
  enabled: true
  basePath: "files/configMaps"
  
  configMapsOverrides:
    nginx-conf:
      annotations:
        description: "Nginx configuration files"
      
      fileAttributeOverrides:
        nginx.conf.tpl:
          # Don't template this file
          escaped: true
        
        logo.png:
          # Binary file
          binary: true
```

**Directory structure:**
```
files/
└── configMaps/
    └── nginx-conf/
        ├── nginx.conf.tpl
        ├── mime.types
        └── logo.png
```

#### Secrets

```yaml
secrets:
  db-credentials:
    enabled: true
    
    annotations:
      description: "Database credentials"
    
    stringData:
      username: admin
      password: "{{ .Values.database.password }}"
      connection-string: "postgresql://{{ .Values.database.host }}:5432/mydb"
```

⚠️ **Warning:** Never commit sensitive data to Git. Use external secret management.

#### External Secrets (ESO)

```yaml
externalSecret:
  db-creds:
    enabled: true
    
    refreshInterval: "1h"
    
    secretStoreRef:
      name: vault-backend
      kind: SecretStore
    
    data:
      - secretKey: username
        remoteRef:
          key: database/credentials
          property: username
      
      - secretKey: password
        remoteRef:
          key: database/credentials
          property: password
```

#### Infisical Secrets

```yaml
infisicalSecret:
  app-secrets:
    enabled: true
    
    hostAPI: "http://infisical.default.svc.cluster.local:8080"
    resyncInterval: 60
    
    authentication:
      serviceToken:
        secretsScope:
          envSlug: production
          secretsPath: /app
        serviceToken:
          secretKeyRef:
            name: infisical-token
            key: token
```

---

### Service Accounts

```yaml
serviceAccount:
  default:
    enabled: true
    
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/my-app-role"
    
    labels:
      app: myapp
```

#### Custom Service Account

```yaml
serviceAccount:
  custom-sa:
    enabled: true
    
    annotations:
      description: "Service account for batch jobs"

controller:
  serviceAccount:
    name: custom-sa
```

---

### Network Policies

```yaml
networkpolicies:
  main:
    enabled: true
    controller: main
    
    policyTypes:
      - Ingress
      - Egress
    
    rules:
      ingress:
        # Allow from specific namespace
        - from:
            - namespaceSelector:
                matchLabels:
                  name: frontend
          ports:
            - protocol: TCP
              port: http
        
        # Allow from specific pods
        - from:
            - podSelector:
                matchLabels:
                  app: monitoring
          ports:
            - protocol: TCP
              port: metrics
      
      egress:
        # Allow DNS
        - to:
            - namespaceSelector:
                matchLabels:
                  name: kube-system
          ports:
            - protocol: UDP
              port: 53
        
        # Allow to database
        - to:
            - podSelector:
                matchLabels:
                  app: postgres
          ports:
            - protocol: TCP
              port: 5432
        
        # Allow HTTPS to external
        - to:
            - podSelector: {}
          ports:
            - protocol: TCP
              port: 443
```

---

### RBAC

```yaml
rbac:
  roles:
    app-role:
      enabled: true
      type: Role  # Role or ClusterRole
      
      rules:
        - apiGroups: [""]
          resources: ["configmaps", "secrets"]
          verbs: ["get", "list", "watch"]
        
        - apiGroups: ["apps"]
          resources: ["deployments"]
          verbs: ["get", "list"]
  
  bindings:
    app-binding:
      enabled: true
      type: RoleBinding  # RoleBinding or ClusterRoleBinding
      
      roleRef:
        name: app-role
        kind: Role
      
      subjects:
        - kind: ServiceAccount
          name: default
          namespace: "{{ .Release.Namespace }}"
```

---

### Monitoring

#### ServiceMonitor (Prometheus Operator)

```yaml
serviceMonitor:
  main:
    enabled: true
    
    labels:
      prometheus: kube-prometheus
    
    serviceName: '{{ include "common.lib.chart.names.fullname" $ }}'
    
    endpoints:
      - port: metrics
        path: /metrics
        interval: 30s
        scrapeTimeout: 10s
        
        # Metric relabeling
        metricRelabelings:
          - sourceLabels: [__name__]
            regex: 'go_.*'
            action: drop
    
    targetLabels:
      - app
      - environment
```

#### PodDisruptionBudget

```yaml
podDisruptionBudget:
  enabled: true
  controller: main
  
  # Ensure at least 1 pod is always available
  minAvailable: 1
  
  # Or use maxUnavailable
  # maxUnavailable: 1
```

---

## Advanced Features

### Default Pod Options

Apply settings to all pods:

```yaml
defaultPodOptions:
  # Security
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  
  # Scheduling
  nodeSelector:
    disktype: ssd
  
  tolerations:
    - key: "app"
      operator: "Equal"
      value: "myapp"
      effect: "NoSchedule"
  
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                    - myapp
            topologyKey: kubernetes.io/hostname
  
  # Topology spread
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app: myapp
  
  # DNS
  dnsPolicy: ClusterFirst
  dnsConfig:
    options:
      - name: ndots
        value: "2"
  
  # Service links
  enableServiceLinks: false
  
  # Image pull secrets
  imagePullSecrets:
    - name: private-registry
  
  # Termination
  terminationGracePeriodSeconds: 30
```

### Gateway API Routes

```yaml
route:
  main:
    enabled: true
    kind: HTTPRoute
    
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: my-gateway
        namespace: gateway-system
    
    hostnames:
      - app.example.com
    
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /api
        
        backendRefs:
          - name: main
            port: http
        
        filters:
          - type: RequestHeaderModifier
            requestHeaderModifier:
              add:
                - name: X-Custom-Header
                  value: "my-value"
```

### Raw Resources

For resources not supported by the library:

```yaml
rawResources:
  custom-resource:
    enabled: true
    apiVersion: custom.io/v1
    kind: CustomResource
    
    annotations:
      description: "Custom resource definition"
    
    spec:
      foo: bar
      replicas: 3
```

---

## Examples

### Example 1: Simple Web Application

```yaml
controller:
  enabled: true
  type: deployment
  replicas: 3
  
  containers:
    main:
      image:
        repository: nginx
        tag: "1.25-alpine"
      
      resources:
        limits:
          cpu: 200m
          memory: 128Mi
        requests:
          cpu: 100m
          memory: 64Mi

service:
  main:
    enabled: true
    type: ClusterIP
    ports:
      http:
        enabled: true
        port: 80

ingress:
  main:
    enabled: true
    className: nginx
    hosts:
      - host: myapp.example.com
        paths:
          - path: /
            pathType: Prefix
            service:
              name: main
              port: http
```

### Example 2: Stateful Application with Persistence

```yaml
controller:
  enabled: true
  type: statefulset
  replicas: 3
  
  containers:
    main:
      image:
        repository: postgres
        tag: "15-alpine"
      
      env:
        POSTGRES_DB: mydb
        POSTGRES_USER:
          secretKeyRef:
            name: postgres-secret
            key: username
        POSTGRES_PASSWORD:
          secretKeyRef:
            name: postgres-secret
            key: password

persistence:
  data:
    enabled: true
    type: persistentVolumeClaim
    storageClass: fast-ssd
    size: 20Gi
    accessMode: ReadWriteOnce
    globalMounts:
      - path: /var/lib/postgresql/data

secrets:
  postgres-secret:
    enabled: true
    stringData:
      username: postgres
      password: "changeme"
```

### Example 3: Background Job (CronJob)

```yaml
controller:
  enabled: true
  type: cronjob
  
  cronjob:
    schedule: "0 2 * * *"
    concurrencyPolicy: Forbid
    successfulJobsHistory: 3
    failedJobsHistory: 5
  
  containers:
    main:
      image:
        repository: myapp/backup
        tag: "latest"
      
      env:
        BACKUP_TARGET: s3://mybucket/backups
      
      envFrom:
        - secretRef:
            name: s3-credentials

secrets:
  s3-credentials:
    enabled: true
    stringData:
      AWS_ACCESS_KEY_ID: "AKIAIOSFODNN7EXAMPLE"
      AWS_SECRET_ACCESS_KEY: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

### Example 4: Multi-Container Pod with Sidecar

```yaml
controller:
  enabled: true
  type: deployment
  
  containers:
    main:
      image:
        repository: myapp/api
        tag: "v1.0.0"
      
      ports:
        - name: http
          containerPort: 8080
    
    log-shipper:
      image:
        repository: fluent/fluent-bit
        tag: "2.0"
      
      env:
        OUTPUT_HOST: logs.example.com
        OUTPUT_PORT: "24224"
      
      resources:
        limits:
          cpu: 100m
          memory: 128Mi

persistence:
  logs:
    enabled: true
    type: emptyDir
    advancedMounts:
      main:
        main:
          - path: /var/log/app
        log-shipper:
          - path: /fluent-bit/log
```

---

## Best Practices

### 1. Security

```yaml
defaultPodOptions:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault

controller:
  containers:
    main:
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
```

### 2. Resource Management

Always set resource requests and limits:

```yaml
controller:
  containers:
    main:
      resources:
        limits:
          cpu: 1000m
          memory: 1Gi
        requests:
          cpu: 500m
          memory: 512Mi
```

### 3. High Availability

```yaml
controller:
  replicas: 3

defaultPodOptions:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: DoNotSchedule

podDisruptionBudget:
  enabled: true
  minAvailable: 2
```

### 4. Observability

```yaml
controller:
  containers:
    main:
      probes:
        liveness:
          enabled: true
        readiness:
          enabled: true
        startup:
          enabled: true

serviceMonitor:
  main:
    enabled: true
```

### 5. Secret Management

Use External Secrets Operator instead of plain secrets:

```yaml
externalSecret:
  db-creds:
    enabled: true
    secretStoreRef:
      name: vault-backend
    data:
      - secretKey: password
        remoteRef:
          key: /database/prod/password
```

---

## Troubleshooting

### Issue: Pods Not Starting

**Symptoms:** Pods in `Pending` or `CrashLoopBackOff` state

**Checks:**
1. Verify image name and tag are correct
2. Check image pull secrets
3. Verify resource requests don't exceed node capacity
4. Check node selectors and affinity rules

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name> -c <container-name>
```

### Issue: Service Not Accessible

**Symptoms:** Cannot reach service endpoint

**Checks:**
1. Verify service selector matches pod labels
2. Check service port and targetPort configuration
3. Verify network policies allow traffic

```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
```

### Issue: Probe Failures

**Symptoms:** Pods restarting frequently

**Solution:** Adjust probe timing:

```yaml
controller:
  containers:
    main:
      probes:
        liveness:
          spec:
            initialDelaySeconds: 30  # Increase if app takes time to start
            periodSeconds: 30        # Check less frequently
            failureThreshold: 5      # Allow more failures before restart
```

### Issue: ConfigMap/Secret Not Mounted

**Checks:**
1. Verify the ConfigMap/Secret exists
2. Check mount paths don't conflict
3. Verify persistence configuration

```bash
kubectl get configmap
kubectl describe pod <pod-name>
```

---

## Migration Guide

### Migrating from Version 1.x to 2.0

**Breaking Changes:**

1. **Single Controller Only**
   - **Before (v1.x):**
     ```yaml
     controllers:
       main:
         type: deployment
       worker:
         type: deployment
     ```
   
   - **After (v2.0):**
     ```yaml
     controller:
       type: deployment
     ```
   
   Split multiple controllers into separate Helm releases.

2. **Simplified Structure**
   - Remove `controllers:` wrapper
   - Use `controller:` (singular) at root level

3. **Updated Probe Syntax**
   - Probe configuration moved under `containers.<name>.probes`

### Migration Steps

1. **Backup existing values:**
   ```bash
   helm get values my-release > values-backup.yaml
   ```

2. **Update Chart dependency:**
   ```yaml
   dependencies:
     - name: common
       version: 2.0.0  # Update version
   ```

3. **Refactor values.yaml:**
   - Change `controllers.main` to `controller`
   - Remove additional controller definitions

4. **Test in non-production:**
   ```bash
   helm upgrade --install my-release ./my-chart \
     --dry-run --debug
   ```

5. **Deploy:**
   ```bash
   helm upgrade --install my-release ./my-chart
   ```

---

## Architecture

### Template Structure

```
templates/
├── classes/          # Resource class definitions
│   ├── _deployment.tpl
│   ├── _statefulset.tpl
│   ├── _service.tpl
│   └── ...
├── lib/             # Helper functions
│   ├── chart/
│   ├── container/
│   ├── metadata/
│   └── ...
├── loader/          # Resource loaders
├── render/          # Rendering logic
└── values/          # Value processing
```

### Rendering Flow

1. **Load values** → `values.yaml`
2. **Process templates** → `common.loader.all`
3. **Generate resources** → Individual resource classes
4. **Apply metadata** → Labels, annotations, names
5. **Render output** → Final Kubernetes manifests

---

## Contributing

When extending this library chart:

1. **Follow naming conventions:** Use `common.lib.<category>.<function>`
2. **Document all parameters:** Use Helm doc comments
3. **Maintain backward compatibility:** Deprecate before removing
4. **Add examples:** Provide clear usage examples
5. **Test thoroughly:** Cover edge cases

---

## Support & Resources

- **Repository:** [github.com/dedsxc/labs](https://github.com/dedsxc/labs)
- **Issues:** Report bugs and feature requests on GitHub
- **Documentation:** See inline comments in templates
- **Examples:** Check `examples/` directory in repository

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and migration notes.

---

## License

This chart is provided as-is. Check repository for license details.

---

## Appendix: Complete Values Reference

For a complete, commented reference of all available values, see the [values.yaml](values.yaml) file.

### Quick Value Index

| Category | Key | Description |
|----------|-----|-------------|
| Global | `global.nameOverride` | Override name prefix |
| Global | `global.labels` | Global labels |
| Controller | `controller.type` | Controller type (deployment/statefulset/etc) |
| Controller | `controller.replicas` | Number of replicas |
| Container | `controller.containers.main.image` | Container image |
| Container | `controller.containers.main.env` | Environment variables |
| Container | `controller.containers.main.resources` | Resource limits/requests |
| Service | `service.main.type` | Service type |
| Service | `service.main.ports` | Service ports |
| Ingress | `ingress.main.enabled` | Enable ingress |
| Ingress | `ingress.main.hosts` | Ingress hosts |
| Persistence | `persistence.<name>.type` | Volume type |
| Persistence | `persistence.<name>.size` | Volume size |
| ConfigMap | `configMaps.<name>.data` | ConfigMap data |
| Secret | `secrets.<name>.stringData` | Secret data |
| ServiceAccount | `serviceAccount.default.enabled` | Enable service account |
| RBAC | `rbac.roles` | RBAC roles |
| Network | `networkpolicies.main.enabled` | Enable network policy |
| Monitoring | `serviceMonitor.main.enabled` | Enable Prometheus scraping |

---

**Last Updated:** 2026-02-22  
**Chart Version:** 2.0.0  
**Maintained by:** Platform Engineering Team
