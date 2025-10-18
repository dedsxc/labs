{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "umbrella.class.daemonset" -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "umbrella.lib.chart.names.fullname" . }}
  {{- with include "umbrella.lib.controller.metadata.labels" . }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "umbrella.lib.controller.metadata.annotations" . }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ .Values.controller.revisionHistoryLimit }}
  selector:
    matchLabels:
      {{- include "umbrella.lib.metadata.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with include ("umbrella.lib.metadata.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "umbrella.lib.metadata.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "umbrella.lib.controller.pod" . | nindent 6 }}
{{- end }}
