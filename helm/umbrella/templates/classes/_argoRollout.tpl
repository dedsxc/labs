{{/*
This template serves as a blueprint for ArgoRollout objects that are created
using the common library.
*/}}
{{- define "umbrella.class.argorollout" -}}
  {{- $strategy := default "canary" .Values.controller.rollout.strategy -}}
  {{- if and (ne $strategy "canary") (ne $strategy "bluegreen") -}}
    {{- fail (printf "Not a valid strategy type for Rollout (%s)" $strategy) -}}
  {{- end -}}
  {{- if empty .Values.controller.rollout.config }}
    {{- fail (printf "No configuration for strategy (%s) is defined" $strategy) }}
  {{- end }}
---
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: {{ include "umbrella.lib.chart.names.fullname" . }}
  {{- with include "umbrella.lib.controller.metadata.labels" . }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "umbrella.lib.controller.metadata.annotations" . }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ .Values.controller.replicas }}
  {{- with .Values.controller.rollout.analysis }}
  {{- if . }}
  analysis:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "umbrella.lib.metadata.selectorLabels" . | nindent 6 }}
  {{- with .Values.controller.rollout.workloadRef }}
  {{- if . }}
  workloadRef: 
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
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
  revisionHistoryLimit: 0
  paused: {{ .Values.controller.rollout.paused }}
  progressDeadlineSeconds: {{ .Values.controller.rollout.progressDeadlineSeconds }}
  progressDeadlineAbort: {{ .Values.controller.rollout.progressDeadlineAbort }}
  strategy:
    {{- include "umbrella.lib.controller.rolloutStrategy" . | nindent 4 }}
{{- end -}}