{{/*
This template serves as a blueprint for Deployment objects that are created
using the common library.
*/}}
{{- define "common.class.deployment" -}}
  {{- $rootContext := . -}}
  {{- $deploymentObject := .Values.controller -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.lib.chart.names.fullname" . }}
  {{- with include "common.lib.controller.metadata.labels" . }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "common.lib.controller.metadata.annotations" . }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ $deploymentObject.revisionHistoryLimit }}
  replicas: {{ $deploymentObject.replicas }}
  strategy:
    type: {{ $deploymentObject.strategy }}
    {{- with $deploymentObject.rollingUpdate }}
      {{- if and (eq $deploymentObject.strategy "RollingUpdate") (or .surge .unavailable) }}
    rollingUpdate:
        {{- with .unavailable }}
      maxUnavailable: {{ . }}
        {{- end }}
        {{- with .surge }}
      maxSurge: {{ . }}
        {{- end }}
      {{- end }}
    {{- end }}
  selector:
    matchLabels:
      {{- include "common.lib.metadata.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with (include "common.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $deploymentObject.annotations)) }}
      annotations: {{ . | nindent 8 }}
      {{- end -}}
      {{- with (include "common.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $deploymentObject.labels)) }}
      labels: {{ . | nindent 8 }}
      {{- end }}
    spec: {{ include "common.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $deploymentObject) | nindent 6 }}
{{- end -}}
