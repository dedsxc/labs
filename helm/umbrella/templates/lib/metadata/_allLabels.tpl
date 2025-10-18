{{/* Common labels shared across objects */}}
{{- define "umbrella.lib.metadata.allLabels" -}}
helm.sh/chart: {{ include "umbrella.lib.chart.names.chart" . }}
{{ include "umbrella.lib.metadata.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "umbrella.lib.metadata.globalLabels" . }}
{{- end -}}
