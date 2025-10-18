{{/*
This template serves as a blueprint for PodDisruptionBudget objects that are created
using the common library.
*/}}
{{- define "umbrella.class.podDisruptionBudget" -}}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "umbrella.lib.chart.names.fullname" . }}
  {{- with include "umbrella.lib.metadata.allLabels" $ | fromYaml }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.podDisruptionBudget.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
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
