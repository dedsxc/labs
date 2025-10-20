{{/*
This template serves as a blueprint for PodDisruptionBudget objects that are created
using the common library.
*/}}
{{- define "common.class.podDisruptionBudget" -}}
  {{- $rootContext := .rootContext -}}
  {{- $podDisruptionBudgetObject := .object -}}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ printf "%s-%s" $podDisruptionBudgetObject.name $podDisruptionBudgetObject.identifier }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- else if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "umbrella.lib.chart.names.fullname" . }}
{{- end -}}
