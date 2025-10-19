{{/*
This template serves as the blueprint for the StatefulSet objects that are created
within the common library.
*/}}
{{- define "common.class.statefulset" -}}
  {{- $rootContext := . -}}
  {{- $statefulsetObject := .Values.controller -}}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "common.lib.chart.names.fullname" . }}
  {{- with include "common.lib.controller.metadata.labels" . }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "common.lib.controller.metadata.annotations" . }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
spec:
  revisionHistoryLimit: {{ include "common.lib.defaultKeepNonNullValue" (dict "value" $statefulsetObject.revisionHistoryLimit "default" 3) }}
  replicas: {{ $statefulsetObject.replicas }}
  podManagementPolicy: {{ dig "statefulset" "podManagementPolicy" "OrderedReady" $statefulsetObject }}
  updateStrategy:
    type: {{ $statefulsetObject.strategy }}
    {{- if and (eq $statefulsetObject.strategy "RollingUpdate") (dig "rollingUpdate" "partition" nil $statefulsetObject) }}
    rollingUpdate:
      partition: {{ $statefulsetObject.rollingUpdate.partition }}
    {{- end }}
  {{- if and (ge ($rootContext.Capabilities.KubeVersion.Minor | int) 31) }}
    {{- with (dig "statefulset" "startOrdinal" nil $statefulsetObject) }}
  ordinals:
    start: {{ . }}
    {{- end }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.lib.metadata.selectorLabels" . | nindent 6 }}
  serviceName: {{ include "common.lib.chart.names.fullname" . }}
  {{- with (dig "statefulset" "persistentVolumeClaimRetentionPolicy" nil $statefulsetObject) }}
  persistentVolumeClaimRetentionPolicy:  {{ . | toYaml | nindent 4 }}
  {{- end }}
  template:
    metadata:
      {{- with (include "common.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject)) }}
      annotations: {{ . | nindent 8 }}
      {{- end -}}
      {{- with (include "common.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject)) }}
      labels: {{ . | nindent 8 }}
      {{- end }}
    spec: {{ include "common.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject) | nindent 6 }}
  {{- with (include "common.lib.statefulset.volumeclaimtemplates" (dict "rootContext" $rootContext "statefulsetObject" $statefulsetObject)) }}
  volumeClaimTemplates: {{ . | nindent 4 }}
  {{- end }}
{{- end }}